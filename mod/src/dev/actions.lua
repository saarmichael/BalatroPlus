-- BPlus.dev.* helpers. Usable from the DebugPlus console (`eval dev...` / `bp ...`),
-- from the terminal (./dev.sh eval '...'), and by scenarios.

local dev = BPlus.dev

local DEFAULT_MONEY_FLOOR = 1000

-- Keys -----------------------------------------------------------------------

local KEY_PREFIXES = { 'j_', 'j_bplus_', 'c_', 'v_', 'p_', 'b_' }

-- 'blueprint' -> 'j_blueprint'; full keys pass through.
function dev.resolve_key(key)
    if G.P_CENTERS[key] then return key end
    for _, prefix in ipairs(KEY_PREFIXES) do
        if G.P_CENTERS[prefix .. key] then return prefix .. key end
    end
    error(('unknown card key: %s'):format(tostring(key)), 2)
end

local function resolve_keys(list)
    local out = {}
    for i, key in ipairs(list or {}) do out[i] = dev.resolve_key(key) end
    return out
end

-- 'hook' -> 'bl_hook'
function dev.resolve_blind(key)
    if G.P_BLINDS[key] then return key end
    if G.P_BLINDS['bl_' .. key] then return 'bl_' .. key end
    error(('unknown blind: %s'):format(tostring(key)), 2)
end

local function resolve_edition(edition)
    if not edition or G.P_CENTERS[edition] then return edition end
    if G.P_CENTERS['e_' .. edition] then return 'e_' .. edition end
    error(('unknown edition: %s'):format(tostring(edition)), 2)
end

-- Cards ----------------------------------------------------------------------

-- spec: 'blueprint' or { key = 'j_joker', edition = 'foil', stickers = { 'eternal' }, ... }
-- Extra fields are passed to SMODS.add_card. Vouchers are redeemed instead.
function dev.give(spec)
    if type(spec) == 'string' then spec = { key = spec } end
    local t = {}
    for k, v in pairs(spec) do t[k] = v end
    t.key = dev.resolve_key(t.key)
    t.edition = resolve_edition(t.edition)
    if G.P_CENTERS[t.key].set == 'Voucher' then return dev.redeem_voucher(t.key) end
    return SMODS.add_card(t)
end

-- Same path vanilla uses for a challenge's starting vouchers.
function dev.redeem_voucher(key)
    key = dev.resolve_key(key)
    G.GAME.used_vouchers[key] = true
    G.E_MANAGER:add_event(Event({
        func = function()
            Card.apply_to_run(nil, G.P_CENTERS[key])
            return true
        end
    }))
    return key
end

-- Shop -----------------------------------------------------------------------

-- Keys are forced into the next shop joker slots (in order), then normal generation resumes.
function dev.queue_shop(keys)
    local queue = dev.run_state().shop_queue
    for _, key in ipairs(resolve_keys(keys)) do queue[#queue + 1] = key end
    return queue
end

-- While set, every shop joker slot is drawn from this list. nil restores normal generation.
function dev.set_shop_pool(keys)
    dev.run_state().shop_pool = keys and resolve_keys(keys) or nil
    return dev.run_state().shop_pool
end

function dev.next_shop_key()
    local st = G.GAME.bplus_dev
    if not st then return nil end
    if st.shop_queue and st.shop_queue[1] then return table.remove(st.shop_queue, 1) end
    if st.shop_pool and st.shop_pool[1] then
        return pseudorandom_element(st.shop_pool, pseudoseed('bplus_dev_pool'))
    end
end

local create_card_for_shop_ref = create_card_for_shop
function create_card_for_shop(area)
    local key = area == G.shop_jokers and dev.next_shop_key()
    if not key then return create_card_for_shop_ref(area) end
    local card = SMODS.create_card({ key = key, area = area, bypass_discovery_center = true })
    create_shop_card_ui(card, card.ability.set, area)
    return card
end

function dev.set_free_rerolls(on)
    dev.run_state().free_rerolls = on or nil
    if on and G.GAME.current_round then G.GAME.current_round.reroll_cost = 0 end
end

local calculate_reroll_cost_ref = calculate_reroll_cost
function calculate_reroll_cost(skip_increment)
    if G.GAME.bplus_dev and G.GAME.bplus_dev.free_rerolls then
        G.GAME.current_round.reroll_cost = 0
        return
    end
    return calculate_reroll_cost_ref(skip_increment)
end

-- Money ----------------------------------------------------------------------

local function set_dollars_silently(amount)
    G.GAME.dollars = amount
    local ui = G.HUD and G.HUD:get_UIE_by_ID('dollar_text_UI')
    if ui then ui.config.object:update() end
end

-- Goes through ease_dollars, so money-reactive jokers see the change.
function dev.add_money(amount)
    ease_dollars(amount)
end

-- on: true (= $1000 floor), a number (custom floor) or false. Money is topped back up whenever it drops below the floor.
function dev.set_infinite_money(on)
    local floor = on == true and DEFAULT_MONEY_FLOOR or on or nil
    dev.run_state().money_floor = floor
    if floor and G.GAME.dollars < floor then set_dollars_silently(floor) end
    return floor
end

-- Blind ----------------------------------------------------------------------

-- Same approach as DebugPlus's "Win Blind" button.
function dev.win_blind()
    if G.STATE ~= G.STATES.SELECTING_HAND then
        return false, 'not selecting a hand (enter a blind and wait for the deal)'
    end
    G.GAME.chips = G.GAME.blind.chips
    G.STATE = G.STATES.HAND_PLAYED
    G.STATE_COMPLETE = true
    end_round()
    return true
end

-- Scoring ----------------------------------------------------------------------

-- evaluate_play computes the whole score synchronously (events only animate it), so the
-- final chips/mult are readable right after it returns, before SMODS resets them.
local evaluate_play_ref = G.FUNCS.evaluate_play
G.FUNCS.evaluate_play = function(e)
    local ret = evaluate_play_ref(e)
    dev.last_hand = {
        name = SMODS.last_hand and SMODS.last_hand.scoring_name,
        chips = SMODS.get_scoring_parameter('chips'),
        mult = SMODS.get_scoring_parameter('mult'),
        score = SMODS.last_hand_score,
    }
    return ret
end

-- Snapshot -------------------------------------------------------------------

local function describe_cards(area)
    local out = {}
    for i, card in ipairs(area and area.cards or {}) do
        local label = card.playing_card and (card.base.value .. ' of ' .. card.base.suit) or card.config.center.key
        if card.edition and card.edition.type then label = label .. ' [' .. card.edition.type .. ']' end
        out[i] = label
    end
    return out
end

local function state_name()
    for name, value in pairs(G.STATES) do
        if value == G.STATE then return name end
    end
end

-- Compact view of the current run, handy for asserting from the terminal.
function dev.state()
    if G.STAGE ~= G.STAGES.RUN then return { stage = 'menu' } end
    local round = G.GAME.current_round
    return {
        stage = 'run',
        state = state_name(),
        ante = G.GAME.round_resets.ante,
        round = G.GAME.round,
        dollars = G.GAME.dollars,
        hands_left = round.hands_left,
        discards_left = round.discards_left,
        blind = G.GAME.blind and G.GAME.blind.name,
        blind_chips = G.GAME.blind and G.GAME.blind.chips,
        chips = G.GAME.chips,
        seed = G.GAME.pseudorandom.seed,
        jokers = describe_cards(G.jokers),
        consumables = describe_cards(G.consumeables),
        hand = describe_cards(G.hand),
        shop = describe_cards(G.shop_jokers),
        dev = G.GAME.bplus_dev,
    }
end

-- Per-frame upkeep ------------------------------------------------------------

function dev.tick(dt)
    local st = G.STAGE == G.STAGES.RUN and G.GAME.bplus_dev
    if st and st.money_floor and G.GAME.dollars < st.money_floor and G.STATE ~= G.STATES.HAND_PLAYED then
        set_dollars_silently(st.money_floor)
    end
end
