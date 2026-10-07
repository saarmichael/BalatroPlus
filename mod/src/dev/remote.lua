-- Terminal -> game command channel (used by ./dev.sh eval).
--
-- dev.sh writes Lua to <save dir>/bplus_dev/cmd.lua (first line "-- id: <id>"); the game polls for it,
-- runs it, and writes "<id>\n<ok|error>\n<result>" to bplus_dev/out.txt. Code runs with `dev` = BPlus.dev
-- in scope; expressions are returned automatically ("G.GAME.dollars" works like "return G.GAME.dollars").

local dev = BPlus.dev

local DIR = love.filesystem.getSaveDirectory() .. '/bplus_dev'
local CMD, OUT = DIR .. '/cmd.lua', DIR .. '/out.txt'
local POLL_SECONDS = 0.2

love.filesystem.createDirectory('bplus_dev')

local function read_file(path)
    local f = io.open(path, 'r')
    if not f then return nil end
    local content = f:read('*a')
    f:close()
    return content
end

-- Write to a temp file then rename, so dev.sh never reads a half-written result.
local function write_file(path, content)
    local tmp = path .. '.tmp'
    local f = assert(io.open(tmp, 'w'))
    f:write(content)
    f:close()
    os.rename(tmp, path)
end

local function compile(code)
    local chunk = loadstring('return ' .. code, '=remote')
    if not chunk then
        local err
        chunk, err = loadstring(code, '=remote')
        if not chunk then return nil, err end
    end
    return setfenv(chunk, setmetatable({ dev = dev }, { __index = _G }))
end

local function execute(code)
    local chunk, err = compile(code)
    if not chunk then return false, err end
    local results = { pcall(chunk) }
    if not results[1] then return false, tostring(results[2]) end
    local parts = {}
    for i = 2, table.maxn(results) do parts[#parts + 1] = dev.inspect(results[i], 4) end
    return true, table.concat(parts, '\n')
end

local timer = 0
function dev.remote_tick(dt)
    timer = timer + dt
    if timer < POLL_SECONDS then return end
    timer = 0

    local code = read_file(CMD)
    if not code then return end
    os.remove(CMD)

    local id = code:match('^%-%- id: (%S+)') or '?'
    local ok, result = execute(code)
    write_file(OUT, ('%s\n%s\n%s'):format(id, ok and 'ok' or 'error', result))
end
