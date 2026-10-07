-- Dev toolkit for testing. Only loaded when config.dev_mode is true.
--
--   actions.lua   BPlus.dev.* helpers: give cards, control the shop, money, win blind, state snapshot
--   scenario.lua  declarative run setup from mod/dev/scenario.lua or mod/dev/scenarios/<name>.lua
--   remote.lua    terminal -> game command channel used by ./dev.sh eval
--   console.lua   DebugPlus console commands + keybinds
--
-- Per-run dev state lives in G.GAME.bplus_dev so it is saved and restored with the run.

BPlus.dev = {}
local dev = BPlus.dev

function dev.log(msg)
    sendInfoMessage(tostring(msg), 'BPlus.dev')
end

function dev.run_state()
    G.GAME.bplus_dev = G.GAME.bplus_dev or { shop_queue = {} }
    return G.GAME.bplus_dev
end

-- Readable dump of any Lua value, for logs and terminal results.
function dev.inspect(value, depth, indent)
    depth, indent = depth or 3, indent or ''
    if type(value) == 'string' then return ('%q'):format(value) end
    if type(value) ~= 'table' then return tostring(value) end
    if depth <= 0 then return '{...}' end
    local keys = {}
    for k in pairs(value) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b)
        if type(a) == type(b) and (type(a) == 'number' or type(a) == 'string') then return a < b end
        return type(a) < type(b)
    end)
    if #keys == 0 then return '{}' end
    local inner, lines = indent .. '  ', {}
    for _, k in ipairs(keys) do
        local label = type(k) == 'number' and '' or (tostring(k) .. ' = ')
        lines[#lines + 1] = inner .. label .. dev.inspect(value[k], depth - 1, inner)
    end
    return '{\n' .. table.concat(lines, ',\n') .. '\n' .. indent .. '}'
end

for _, file in ipairs({ 'actions', 'scenario', 'remote', 'console', 'test/init' }) do
    BPlus.load('src/dev/' .. file .. '.lua')
end

local update_ref = Game.update
function Game:update(dt)
    update_ref(self, dt)
    dev.tick(dt)
    dev.remote_tick(dt)
    BPlus.test.tick()
end

dev.log('Dev toolkit loaded')
