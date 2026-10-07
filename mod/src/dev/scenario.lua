-- Declarative run setup. A scenario is a Lua table (see mod/dev/scenario.lua for every field).
--
-- mod/dev/scenario.lua            applied to every new run while its `enabled = true`
-- mod/dev/scenarios/<name>.lua    applied on demand: dev.new_run('<name>')
--
-- Files are re-read each time, so edit + start a new run; no game restart needed.

local dev = BPlus.dev

-- name: nil (default file), a scenario name, or a table (returned as-is)
function dev.load_scenario(name)
    if type(name) == 'table' then return name end
    local path = name and ('dev/scenarios/' .. name .. '.lua') or 'dev/scenario.lua'
    local chunk, err = SMODS.load_file(path, BPlus.id)
    if not chunk then error(err, 2) end
    return chunk()
end

-- Resolve every key up front so a typo errors here instead of crashing mid-run-start.
function dev.validate_scenario(s)
    if s.deck then dev.resolve_key(s.deck) end
    for _, field in ipairs({ 'jokers', 'consumables', 'vouchers', 'shop_queue', 'shop_pool' }) do
        for _, spec in ipairs(s[field] or {}) do dev.resolve_key(type(spec) == 'table' and spec.key or spec) end
    end
    return s
end

-- Start a fresh run with a scenario. Works from the main menu or mid-run.
function dev.new_run(name)
    local scenario = dev.validate_scenario(dev.load_scenario(name))
    dev.pending_scenario = scenario
    if scenario.deck then
        G.GAME.viewed_back = Back(G.P_CENTERS[dev.resolve_key(scenario.deck)])
        G.GAME.selected_back = G.GAME.viewed_back
    end
    G:delete_run()
    G:start_run({ stake = scenario.stake, seed = scenario.seed })
    return true
end

local function take_scenario(args)
    if args.savetext then return nil end -- continuing a saved run
    local scenario = dev.pending_scenario
    dev.pending_scenario = nil
    if scenario then return scenario end
    local ok, default = pcall(function() return dev.validate_scenario(dev.load_scenario()) end)
    if not ok then
        dev.log('dev/scenario.lua failed to load: ' .. tostring(default))
        return nil
    end
    return default.enabled and default or nil
end

function dev.apply_scenario(s)
    if s.dollars then G.GAME.dollars = s.dollars end
    if s.infinite_money then dev.set_infinite_money(s.infinite_money) end
    if s.free_rerolls then dev.set_free_rerolls(true) end
    if s.hands then G.GAME.round_resets.hands = s.hands end
    if s.discards then G.GAME.round_resets.discards = s.discards end
    if s.ante then
        G.GAME.round_resets.ante = s.ante
        G.GAME.round_resets.blind_ante = s.ante
    end
    if s.shop_queue then dev.queue_shop(s.shop_queue) end
    if s.shop_pool then dev.set_shop_pool(s.shop_pool) end

    -- Card areas exist once start_run returns; add cards in an event so they animate in with the deal.
    G.E_MANAGER:add_event(Event({
        func = function()
            if s.joker_slots then G.jokers.config.card_limit = s.joker_slots end
            if s.consumable_slots then G.consumeables.config.card_limit = s.consumable_slots end
            if s.hand_size then G.hand:change_size(s.hand_size - G.hand.config.card_limit) end
            for _, key in ipairs(s.vouchers or {}) do dev.redeem_voucher(key) end
            for _, spec in ipairs(s.jokers or {}) do dev.give(spec) end
            for _, spec in ipairs(s.consumables or {}) do dev.give(spec) end
            return true
        end
    }))
    dev.log('Applied scenario' .. (s.name and (' "' .. s.name .. '"') or ''))
end

local start_run_ref = Game.start_run
function Game:start_run(args)
    args = args or {}
    local scenario = take_scenario(args)
    if scenario and scenario.seed and not args.seed then args.seed = scenario.seed end
    start_run_ref(self, args)
    if scenario then dev.apply_scenario(scenario) end
end
