-- Test runner: discovers mod/dev/tests/**/*.lua, runs each test in its own coroutine (resumed once
-- per frame from Game:update), and streams results to <save dir>/bplus_dev/test_out.txt.
--
-- Started by `./dev.sh test [filter]` (which calls BPlus.test.run). Tests run on a dedicated
-- profile with everything unlocked; the previous profile and game speed are restored afterwards.

local T = BPlus.test

T.config = {
    profile = 3,          -- dedicated test profile (never the player's)
    speed = 16,           -- game speed multiplier during tests (player setting is restored after)
    timeout = 20,         -- seconds T.wait_until / T.wait_idle may wait
    test_timeout = 120,   -- seconds a single test may take
    settle_frames = 3,    -- consecutive idle frames before the game counts as idle
}

local OUT = love.filesystem.getSaveDirectory() .. '/bplus_dev/test_out.txt'
local TEST_DIR = 'dev/tests'

---@type table|nil
local run = nil          -- the active run, if any
---@type table|nil
local registering = nil  -- test list being filled while a test file loads
---@type file*|nil
local out = nil

local function emit(line)
    out:write(line, '\n')
    out:flush()
end

-- Registration -------------------------------------------------------------

-- Called from test files: T.test('Joker adds +4 mult', function() ... end)
function T.test(name, fn)
    if not registering then error('T.test can only be called while a test file is loading', 2) end
    registering[#registering + 1] = { name = name, fn = fn }
end

local function list_test_files(dir, files)
    files = files or {}
    local items = NFS.getDirectoryItems(BPlus.path .. dir)
    table.sort(items)
    for _, item in ipairs(items) do
        local rel = dir .. '/' .. item
        local info = NFS.getInfo(BPlus.path .. rel)
        if info and info.type == 'directory' then
            list_test_files(rel, files)
        elseif item:match('%.lua$') then
            files[#files + 1] = rel
        end
    end
    return files
end

-- Test files are re-read on every run, so editing tests never needs a game restart.
local function discover(filter)
    local tests = {}
    for _, path in ipairs(list_test_files(TEST_DIR)) do
        local file = path:sub(#TEST_DIR + 2)
        registering = {}
        local chunk, err = SMODS.load_file(path, BPlus.id)
        local ok = chunk ~= nil
        if chunk then ok, err = pcall(chunk) end
        if not ok then
            tests[#tests + 1] = { file = file, name = '(load)', load_error = tostring(err) }
        else
            for _, t in ipairs(registering) do
                t.file = file
                local full = file .. ' > ' .. t.name
                if not filter or full:lower():find(filter:lower(), 1, true) then tests[#tests + 1] = t end
            end
        end
        registering = nil
    end
    return tests
end

-- Profile handling --------------------------------------------------------------

-- Same path as picking a profile in the Profile menu; ends on the main menu.
local function switch_profile(profile)
    G.focused_profile = profile
    G.FUNCS.load_profile()
    T.wait_until(function() return G.SETTINGS.profile == profile end, 'profile ' .. profile .. ' to load', 30)
    T.wait_until(function() return G.STAGE == G.STAGES.MAIN_MENU end, 'the main menu', 30)
    T.wait_idle(30)
end

-- Same effect as the Profile menu's "Unlock All" button.
local function unlock_all()
    local profile = G.PROFILES[G.SETTINGS.profile]
    if profile.all_unlocked then return end
    profile.all_unlocked = true
    EMPTY(G.P_LOCKED)
    for _, pool in ipairs({ G.P_CENTERS, G.P_BLINDS, G.P_TAGS }) do
        for _, v in pairs(pool) do
            if not v.demo and not v.wip then
                v.alerted, v.discovered, v.unlocked = true, true, true
            end
        end
    end
    set_profile_progress()
    set_discover_tallies()
    G:save_progress()
end

-- Running ---------------------------------------------------------------------

-- Resume fn as a child coroutine until it finishes, yielding a frame whenever it waits.
local function run_child(fn, time_limit)
    local co = coroutine.create(fn)
    local deadline = love.timer.getTime() + time_limit
    while true do
        local ok, err = coroutine.resume(co)
        if not ok then return false, err, co end
        if coroutine.status(co) == 'dead' then return true end
        if love.timer.getTime() > deadline then
            return false, { message = ('test exceeded %ds'):format(time_limit), where = nil }, co
        end
        coroutine.yield()
    end
end

local function game_summary()
    if G.STAGE ~= G.STAGES.RUN then return 'not in a run' end
    local s = BPlus.dev.state()
    return ('state=%s ante=%s round=%s dollars=%s hands_left=%s jokers=%s'):format(
        s.state, s.ante, s.round, s.dollars, s.hands_left, table.concat(s.jokers, ','))
end

local function indent(text)
    return '      ' .. tostring(text):gsub('\n', '\n      ')
end

local function run_one(t)
    local label = t.file .. ' > ' .. t.name
    if t.load_error then
        run.errors = run.errors + 1
        emit('ERROR ' .. label)
        emit(indent(t.load_error))
        return
    end
    local started = love.timer.getTime()
    local ok, err, co = run_child(t.fn, T.config.test_timeout)
    local took = ('(%.1fs)'):format(love.timer.getTime() - started)
    if ok then
        run.passed = run.passed + 1
        emit(('PASS  %s %s'):format(label, took))
    elseif T.is_failure(err) or (type(err) == 'table' and err.message) then
        run.failed = run.failed + 1
        emit(('FAIL  %s %s'):format(label, took))
        emit(indent(err.message .. (err.where and ('   [' .. err.where .. ']') or '')))
        emit(indent('game: ' .. game_summary()))
    else
        run.errors = run.errors + 1
        emit(('ERROR %s %s'):format(label, took))
        emit(indent(debug.traceback(co, tostring(err))))
        emit(indent('game: ' .. game_summary()))
    end
end

local function main(opts)
    local tests = discover(opts.filter)
    emit(('Running %d test(s)%s on profile %d at speed x%d'):format(
        #tests, opts.filter and (' matching "' .. opts.filter .. '"') or '', T.config.profile, opts.speed or T.config.speed))
    for _, e in ipairs(BPlus.load_errors) do emit('WARN  mod file skipped at load: ' .. e) end

    run.saved = { profile = G.SETTINGS.profile, speed = G.SETTINGS.GAMESPEED }
    if G.SETTINGS.profile ~= T.config.profile then switch_profile(T.config.profile) end
    unlock_all()
    G.SETTINGS.GAMESPEED = opts.speed or T.config.speed

    for _, t in ipairs(tests) do run_one(t) end

    G.SETTINGS.GAMESPEED = run.saved.speed
    if opts.stay then
        emit('Staying on the test profile (stay = true)')
    elseif G.SETTINGS.profile ~= run.saved.profile then
        switch_profile(run.saved.profile)
    end
    G:save_settings()
end

local function finish()
    local total = love.timer.getTime() - run.started
    local ok = run.failed == 0 and run.errors == 0
    emit(('%d passed, %d failed, %d errors (%.1fs)'):format(run.passed, run.failed, run.errors, total))
    emit('== done ' .. run.id .. ' ' .. (ok and 'PASS' or 'FAIL') .. ' ==')
    out:close()
    run, out = nil, nil
end

-- Start a run. opts: { id, filter, speed, stay }. Returns immediately; progress goes to test_out.txt.
function T.run(opts)
    if run then error('a test run is already in progress (' .. run.id .. ')') end
    opts = opts or {}
    run = { id = opts.id or tostring(os.time()), started = love.timer.getTime(), passed = 0, failed = 0, errors = 0 }
    out = assert(io.open(OUT, 'w'))
    emit('id ' .. run.id)
    run.co = coroutine.create(function() main(opts) end)
    return run.id
end

function T.running()
    return run ~= nil
end

function T.tick()
    if not run then return end
    local ok, err = coroutine.resume(run.co)
    if not ok then
        run.errors = run.errors + 1
        emit('RUNNER ERROR')
        emit(indent(T.is_failure(err) and err.message or debug.traceback(run.co, tostring(err))))
        if run.saved then G.SETTINGS.GAMESPEED = run.saved.speed end
        finish()
    elseif coroutine.status(run.co) == 'dead' then
        finish()
    end
end
