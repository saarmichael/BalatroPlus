-- Safe game actions for tests. Each action:
--   1. checks the same preconditions the real button checks (T.fail with a clear message otherwise),
--   2. calls the game's own button callback with button-equivalent arguments,
--   3. waits until the game is idle again (animations done, state settled).
-- All of them must run inside a test (they yield while waiting).

local T = BPlus.test
local dev = BPlus.dev

-- Waiting --------------------------------------------------------------------

local STABLE_STATES = {
    SELECTING_HAND = true, BLIND_SELECT = true, SHOP = true, ROUND_EVAL = true, GAME_OVER = true,
    TAROT_PACK = true, PLANET_PACK = true, SPECTRAL_PACK = true, STANDARD_PACK = true,
    BUFFOON_PACK = true, SMODS_BOOSTER_OPENED = true,
}

function T.state_name()
    for name, value in pairs(G.STATES) do
        if value == G.STATE then return name end
    end
    return tostring(G.STATE)
end

-- Idle = nothing blocking in the event queues, no input locks, and a settled stable state.
function T.is_idle()
    if G.screenwipe or G.CONTROLLER.locked then return false end
    for _, locked in pairs(G.CONTROLLER.locks) do
        if locked then return false end
    end
    for _, queue in pairs(G.E_MANAGER.queues) do
        for _, event in ipairs(queue) do
            if event.blocking then return false end
        end
    end
    if G.STAGE == G.STAGES.MAIN_MENU then return true end
    return G.STAGE == G.STAGES.RUN and G.STATE_COMPLETE and STABLE_STATES[T.state_name()] or false
end

local function describe_game()
    if G.STAGE ~= G.STAGES.RUN then return 'stage=' .. tostring(G.STAGE) end
    return ('state=%s ante=%s dollars=%s'):format(T.state_name(), G.GAME.round_resets.ante, G.GAME.dollars)
end

-- Yield frames until predicate() is true; fails after `timeout` real seconds.
function T.wait_until(predicate, what, timeout)
    local deadline = love.timer.getTime() + (timeout or T.config.timeout)
    while not predicate() do
        if love.timer.getTime() > deadline then
            T.fail(('timed out waiting for %s (%s)'):format(what or 'condition', describe_game()))
        end
        coroutine.yield()
    end
end

-- Wait until the game has been idle for a few consecutive frames (event chains can pause for a frame).
function T.wait_idle(timeout)
    local settled = 0
    T.wait_until(function()
        settled = T.is_idle() and settled + 1 or 0
        return settled >= T.config.settle_frames
    end, 'the game to become idle', timeout)
end

-- Wait a number of game-frames (rarely needed; prefer wait_idle).
function T.wait_frames(n)
    for _ = 1, n do coroutine.yield() end
end

local function expect_state(expected, action)
    local current = T.state_name()
    if G.STAGE ~= G.STAGES.RUN or current ~= expected then
        T.fail(('%s needs state %s, but the game is in %s'):format(action, expected, describe_game()))
    end
end

-- Cards ----------------------------------------------------------------------

local RANKS = {
    A = 'Ace', K = 'King', Q = 'Queen', J = 'Jack', T = '10', ['10'] = '10',
    ['9'] = '9', ['8'] = '8', ['7'] = '7', ['6'] = '6', ['5'] = '5', ['4'] = '4', ['3'] = '3', ['2'] = '2',
}
local SUITS = { S = 'Spades', H = 'Hearts', D = 'Diamonds', C = 'Clubs' }

-- 'AS', '10H', 'TD' or { 'KH', enhancement = 'glass', edition = 'foil', seal = 'Red' }
function T.parse_card(spec)
    local t = type(spec) == 'table' and spec or { spec }
    local rank, suit = tostring(t[1] or ''):upper():match('^(%w-)([SHDC])$')
    if not rank or not RANKS[rank] then
        T.fail(('bad card spec %s (use rank + suit, e.g. "AS", "10H", "TD")'):format(BPlus.dev.inspect(spec)))
    end
    local function center(key, prefix)
        if not key then return nil end
        local full = G.P_CENTERS[key] and key or G.P_CENTERS[prefix .. key] and (prefix .. key)
        if not full then T.fail(('unknown %s: %s'):format(prefix == 'm_' and 'enhancement' or 'edition', key)) end
        return full
    end
    return {
        rank = RANKS[rank], suit = SUITS[suit], label = rank .. suit,
        enhancement = center(t.enhancement, 'm_'), edition = center(t.edition, 'e_'), seal = t.seal,
    }
end

local function card_matches(card, parsed)
    return card.base.value == parsed.rank and card.base.suit == parsed.suit
end

-- Resolve hand cards by index (1 = leftmost) or by spec ('KH'). Each card is used once.
function T.hand_cards(selectors)
    local picked, used = {}, {}
    for _, sel in ipairs(selectors) do
        local card
        if type(sel) == 'number' then
            card = G.hand.cards[sel]
            if not card then T.fail(('no hand card at index %d (hand has %d)'):format(sel, #G.hand.cards)) end
        else
            local parsed = T.parse_card(sel)
            for _, c in ipairs(G.hand.cards) do
                if not used[c] and card_matches(c, parsed) then card = c; break end
            end
            if not card then T.fail(('no %s in hand; hand is %s'):format(parsed.label, BPlus.dev.inspect(dev.state().hand, 1))) end
        end
        if used[card] then T.fail('the same hand card was selected twice') end
        used[card] = true
        picked[#picked + 1] = card
    end
    return picked
end

local function apply_card_spec(card, parsed)
    SMODS.change_base(card, parsed.suit, parsed.rank)
    card:set_ability(G.P_CENTERS[parsed.enhancement or 'c_base'], nil, true)
    card:set_edition(parsed.edition, true, true)
    card:set_seal(parsed.seal, true, true)
end

-- Replace the current hand with exactly these cards (rewrites existing hand cards; extra cards
-- go back to the deck, missing ones are created). Deterministic hands for scoring tests.
function T.set_hand(specs)
    expect_state('SELECTING_HAND', 'set_hand')
    local parsed = {}
    for i, spec in ipairs(specs) do parsed[i] = T.parse_card(spec) end
    local cards = {}
    for i, card in ipairs(G.hand.cards) do cards[i] = card end
    for i = #parsed + 1, #cards do
        draw_card(G.hand, G.deck, 90, 'down', nil, cards[i])
    end
    for i, p in ipairs(parsed) do
        if cards[i] then
            apply_card_spec(cards[i], p)
        else
            local card = SMODS.add_card({ set = 'Base', rank = p.rank, suit = p.suit, area = G.hand, skip_materialize = true })
            apply_card_spec(card, p)
        end
    end
    T.wait_idle()
    G.hand:sort()
    return G.hand.cards
end

-- Find a card by key (or 1-based index) in an area. Returns nil if absent.
function T.find(area, key_or_index)
    if not area then return nil end
    if type(key_or_index) == 'number' then return area.cards[key_or_index] end
    local key = dev.resolve_key(key_or_index)
    for _, card in ipairs(area.cards) do
        if card.config.center.key == key then return card end
    end
end

function T.joker(key_or_index) return T.find(G.jokers, key_or_index) end
function T.consumable(key_or_index) return T.find(G.consumeables, key_or_index) end

local function require_card(area_names, key_or_index, action)
    for _, name in ipairs(area_names) do
        local card = T.find(G[name], key_or_index)
        if card then return card end
    end
    T.fail(('%s: %s not found in %s'):format(action, tostring(key_or_index), table.concat(area_names, '/')))
end

local function fake_button(card)
    return { config = { ref_table = card } }
end

-- Run flow --------------------------------------------------------------------

local TEST_DEFAULTS = { seed = 'BPTEST', deck = 'b_red', stake = 1 }

-- Fresh run from a scenario table (same fields as mod/dev/scenario.lua). Defaults to a seeded
-- Red Deck / White Stake run so results are reproducible. Ends at BLIND_SELECT.
function T.start_run(scenario)
    local s = {}
    for k, v in pairs(TEST_DEFAULTS) do s[k] = v end
    for k, v in pairs(scenario or {}) do s[k] = v end
    local ok, err = pcall(dev.validate_scenario, s)
    if not ok then T.fail('invalid scenario: ' .. tostring(err)) end
    dev.last_hand = nil
    dev.new_run(s)
    T.wait_until(function() return G.STAGE == G.STAGES.RUN end, 'the run to start')
    T.wait_idle()
    return dev.state()
end

local function blind_option()
    local on_deck = G.GAME.blind_on_deck
    local opts = on_deck and G.blind_select_opts and G.blind_select_opts[on_deck:lower()]
    if not opts then T.fail('no blind option on deck (' .. tostring(on_deck) .. ')') end
    return opts, on_deck
end

-- Select the blind currently on deck (Small -> Big -> Boss). Ends at SELECTING_HAND.
function T.select_blind()
    expect_state('BLIND_SELECT', 'select_blind')
    local opts = blind_option()
    G.FUNCS.select_blind(opts:get_UIE_by_ID('select_blind_button'))
    T.wait_idle()
    return G.GAME.blind.name
end

local function find_ui_by_button(node, button)
    if node.config and node.config.button == button then return node end
    for _, child in ipairs(node.children or {}) do
        local found = find_ui_by_button(child, button)
        if found then return found end
    end
end

-- Skip the blind on deck (not allowed for the Boss). Returns the tag gained.
function T.skip_blind()
    expect_state('BLIND_SELECT', 'skip_blind')
    local opts, on_deck = blind_option()
    if on_deck == 'Boss' then T.fail('the Boss blind cannot be skipped') end
    local button = find_ui_by_button(opts.UIRoot, 'skip_blind')
    if not button then T.fail('skip button not found') end
    local tags_before = #G.GAME.tags
    G.FUNCS.skip_blind(button)
    T.wait_idle()
    return G.GAME.tags[tags_before + 1]
end

-- Play hand cards (indices or specs). Returns { hand, chips, mult, score, dollars, state }.
function T.play(selectors)
    expect_state('SELECTING_HAND', 'play')
    local cards = T.hand_cards(selectors)
    if #cards < 1 or #cards > G.hand.config.highlighted_limit then
        T.fail(('play needs 1-%d cards, got %d'):format(G.hand.config.highlighted_limit, #cards))
    end
    if G.GAME.current_round.hands_left <= 0 then T.fail('no hands left') end
    G.hand:unhighlight_all()
    for _, card in ipairs(cards) do G.hand:add_to_highlighted(card, true) end
    local dollars_before = G.GAME.dollars
    dev.last_hand = nil
    G.FUNCS.play_cards_from_highlighted()
    T.wait_idle()
    local hand = dev.last_hand or {}
    return {
        hand = hand.name, chips = hand.chips, mult = hand.mult, score = hand.score,
        dollars = G.GAME.dollars - dollars_before, state = T.state_name(),
    }
end

-- Discard hand cards (indices or specs) using a real discard (counts down, draws back up).
function T.discard(selectors)
    expect_state('SELECTING_HAND', 'discard')
    local cards = T.hand_cards(selectors)
    if #cards < 1 or #cards > G.hand.config.highlighted_limit then
        T.fail(('discard needs 1-%d cards, got %d'):format(G.hand.config.highlighted_limit, #cards))
    end
    if G.GAME.current_round.discards_left <= 0 then T.fail('no discards left') end
    G.hand:unhighlight_all()
    for _, card in ipairs(cards) do G.hand:add_to_highlighted(card, true) end
    G.FUNCS.discard_cards_from_highlighted(nil) -- never pass the second arg: that is The Hook's free discard
    T.wait_idle()
end

-- Shortcut: score the blind's requirement instantly (skips scoring; jokers don't trigger on hands).
function T.win_blind()
    expect_state('SELECTING_HAND', 'win_blind')
    local ok, err = dev.win_blind()
    if not ok then T.fail(err) end
    T.wait_idle()
end

-- ROUND_EVAL -> SHOP. Returns the money gained.
function T.cash_out()
    expect_state('ROUND_EVAL', 'cash_out')
    local before = G.GAME.dollars
    G.FUNCS.cash_out({ config = {} })
    T.wait_idle()
    return G.GAME.dollars - before
end

-- Shop -----------------------------------------------------------------------

-- Buy a shop card by key or index (jokers/consumables via Buy, vouchers via Redeem, boosters via Open).
function T.buy(key_or_index)
    expect_state('SHOP', 'buy')
    local card = require_card({ 'shop_jokers', 'shop_vouchers', 'shop_booster' }, key_or_index, 'buy')
    if card.cost > G.GAME.dollars - G.GAME.bankrupt_at and card.cost > 0 then
        T.fail(('cannot afford %s ($%d, have $%d)'):format(card.config.center.key, card.cost, G.GAME.dollars))
    end
    local set = card.ability.set
    if set == 'Voucher' or set == 'Booster' then
        G.FUNCS.use_card(fake_button(card))
    else
        if not G.FUNCS.check_for_buy_space(card) then T.fail('no room for ' .. card.config.center.key) end
        G.FUNCS.buy_from_shop(fake_button(card))
    end
    T.wait_idle()
    return card
end

function T.reroll()
    expect_state('SHOP', 'reroll')
    local cost = G.GAME.current_round.reroll_cost
    if cost > G.GAME.dollars - G.GAME.bankrupt_at and cost > 0 then
        T.fail(('cannot afford reroll ($%d, have $%d)'):format(cost, G.GAME.dollars))
    end
    G.FUNCS.reroll_shop()
    T.wait_idle()
end

-- SHOP -> BLIND_SELECT
function T.leave_shop()
    expect_state('SHOP', 'leave_shop')
    G.FUNCS.toggle_shop()
    T.wait_idle()
end

-- Sell an owned joker or consumable (key or index; jokers searched first).
function T.sell(key_or_index)
    local card = require_card({ 'jokers', 'consumeables' }, key_or_index, 'sell')
    if not card:can_sell_card() then T.fail('cannot sell ' .. card.config.center.key .. ' right now') end
    local before = G.GAME.dollars
    G.FUNCS.sell_card(fake_button(card))
    T.wait_idle()
    return G.GAME.dollars - before
end

-- Use a consumable (owned or in an open pack). `targets` = hand cards to highlight first.
function T.use(key_or_index, targets)
    local card = require_card({ 'consumeables', 'pack_cards' }, key_or_index, 'use')
    if targets then
        G.hand:unhighlight_all()
        for _, c in ipairs(T.hand_cards(targets)) do G.hand:add_to_highlighted(c, true) end
    end
    if not card:can_use_consumeable() then T.fail('cannot use ' .. card.config.center.key .. ' right now') end
    G.FUNCS.use_card(fake_button(card))
    T.wait_idle()
end

-- Take a joker/playing card from an open pack (same button as "Select").
function T.pick(key_or_index)
    local card = require_card({ 'pack_cards' }, key_or_index, 'pick')
    G.FUNCS.use_card(fake_button(card))
    T.wait_idle()
end

function T.skip_pack()
    if not G.pack_cards then T.fail('no pack is open') end
    G.FUNCS.skip_booster({ config = {} })
    T.wait_idle()
end

-- Convenience ------------------------------------------------------------------

-- From BLIND_SELECT: select blind, win it instantly, cash out. Ends in the SHOP.
function T.to_shop()
    T.select_blind()
    T.win_blind()
    T.cash_out()
end

function T.state() return dev.state() end

-- Upgrades and behaviour -------------------------------------------------------------

-- Permanent upgrade through the real entry point (BPlus.upgrade_card). Returns the card.
function T.upgrade(key_or_index)
    local card = require_card({ 'jokers' }, key_or_index, 'upgrade')
    if not BPlus.upgrade_card(card) then T.fail('upgrade: ' .. card.config.center.key .. ' is not eligible') end
    T.wait_idle()
    return card
end

-- Make an owned joker behave as its "+" version ('plus', what Carpenter does), as its vanilla
-- version ('base', what The Rust does), or normally again (nil). Overrides every mechanic.
-- Use it to test a joker's alternate behaviour without depending on Carpenter / The Rust.
-- T.joker_display(k): what JokerDisplay shows for an owned joker, as strings. Forces a full rebuild of the
-- display, then reads the rendered nodes. Returns { text = '+20', reminder = '(Round)', extra = { '(1 in 4)' },
-- values = card.joker_display_values }. `live = true` skips the forced rebuild and reads what the game's own
-- updates produced (use after T.wait_frames to test automatic refresh). Fails if JokerDisplay isn't installed.
function T.joker_display(key_or_index, live)
    ---@diagnostic disable: undefined-global
    local card = require_card({ 'jokers' }, key_or_index, 'joker_display')
    if not (JokerDisplay and card.update_joker_display) then T.fail('joker_display: JokerDisplay is not installed') end
    if not live then card:update_joker_display(true, true, 'test') end
    local box = card.children.joker_display or card.children.joker_display_small
    if not box then T.fail('joker_display: card has no display box') end
    local function read(node)
        if node.UIT == G.UIT.T then
            if node.config.ref_table and node.config.ref_value then
                return JokerDisplay.text_format(node.config.ref_table[node.config.ref_value], node)
            end
            return tostring(node.config.text or '')
        end
        local out = {}
        for _, child in ipairs(node.children or {}) do out[#out + 1] = read(child) end
        return table.concat(out)
    end
    local extra = {}
    for _, row in ipairs(box.extra and box.extra.children or {}) do extra[#extra + 1] = read(row) end
    return {
        text = box.text and read(box.text) or '',
        reminder = box.reminder_text and read(box.reminder_text) or '',
        extra = extra,
        values = card.joker_display_values,
    }
end

function T.force_behavior(key_or_index, mode)
    local card = require_card({ 'jokers' }, key_or_index, 'force_behavior')
    card.bplus_forced = mode
    BPlus.sync_behavior(card)
    if mode and not card.ability.bplus_behaving then
        T.fail(('force_behavior: %s cannot behave as %s'):format(card.config.center.key, mode))
    end
    T.wait_idle()
    return card
end
