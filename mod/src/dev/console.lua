-- Interactive entry points: a `bp` command in the DebugPlus console (press / in game) and keybinds.
-- Keybinds use Option (lalt) because DebugPlus owns Ctrl/Cmd + letter.

local dev = BPlus.dev

local function on_off(arg)
    return arg ~= 'off' and arg ~= 'false' and arg ~= '0'
end

local SUBCOMMANDS = {
    give = {
        usage = 'give <key> [edition]   add a card (joker/consumable/voucher) to the run',
        run = function(args)
            dev.give({ key = args[1], edition = args[2] })
            return 'Gave ' .. dev.resolve_key(args[1])
        end,
    },
    shop = {
        usage = 'shop <key> [key...]     force cards into the next shop joker slots',
        run = function(args)
            return 'Shop queue: ' .. table.concat(dev.queue_shop(args), ', ')
        end,
    },
    pool = {
        usage = 'pool <key...> | pool off   restrict every shop joker slot to these cards',
        run = function(args)
            if not args[1] or args[1] == 'off' then
                dev.set_shop_pool(nil)
                return 'Shop pool cleared'
            end
            return 'Shop pool: ' .. table.concat(dev.set_shop_pool(args), ', ')
        end,
    },
    money = {
        usage = 'money <n> | money inf [floor] | money off   add money or toggle infinite money',
        run = function(args)
            if args[1] == 'inf' then return 'Infinite money: $' .. dev.set_infinite_money(tonumber(args[2]) or true) end
            if args[1] == 'off' then dev.set_infinite_money(false); return 'Infinite money off' end
            dev.add_money(tonumber(args[1]) or 100)
            return 'Added money'
        end,
    },
    rerolls = {
        usage = 'rerolls on|off           free shop rerolls',
        run = function(args)
            dev.set_free_rerolls(on_off(args[1]))
            return 'Free rerolls ' .. (on_off(args[1]) and 'on' or 'off')
        end,
    },
    win = {
        usage = 'win                      win the current blind',
        run = function()
            local ok, err = dev.win_blind()
            return ok and 'Blind won' or err, ok and 'INFO' or 'ERROR'
        end,
    },
    run = {
        usage = 'run [scenario]           new run with dev/scenario.lua or dev/scenarios/<name>.lua',
        run = function(args)
            dev.new_run(args[1])
            return 'Started run' .. (args[1] and (' with scenario ' .. args[1]) or '')
        end,
    },
    state = {
        usage = 'state                    print a snapshot of the run',
        run = function() return dev.inspect(dev.state(), 2) end,
    },
}

local function help()
    local lines = { 'Usage: bp <subcommand>' }
    for _, name in ipairs({ 'give', 'shop', 'pool', 'money', 'rerolls', 'win', 'run', 'state' }) do
        lines[#lines + 1] = '  ' .. SUBCOMMANDS[name].usage
    end
    return table.concat(lines, '\n')
end

local has_debugplus, dp_api = pcall(require, 'debugplus-api')
if has_debugplus and dp_api.isVersionCompatible(1) then
    local dp = dp_api.registerID('BalatroPlus')
    dp.addCommand({
        name = 'bp',
        shortDesc = 'Balatro Plus dev tools',
        desc = help(),
        exec = function(args)
            local sub = SUBCOMMANDS[table.remove(args, 1) or '']
            if not sub then return help() end
            local ok, msg, level = pcall(sub.run, args)
            if not ok then return tostring(msg), 'ERROR' end
            return msg, level
        end,
    })
else
    dev.log('DebugPlus not found; `bp` console command unavailable')
end

local function keybind(key, action)
    SMODS.Keybind({
        key = 'dev_' .. key,
        key_pressed = key,
        held_keys = { 'lalt' },
        action = function()
            local ok, err = pcall(action)
            if not ok then dev.log('Keybind error: ' .. tostring(err)) end
        end,
    })
end

keybind('n', function() dev.new_run() end) -- new run with dev/scenario.lua
keybind('w', function() dev.win_blind() end)
keybind('m', function()
    dev.set_infinite_money(not dev.run_state().money_floor)
end)
