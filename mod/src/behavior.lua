-- Temporary behaviour switching: a joker can *behave as* another center without changing card.
-- This is what Carpenter (M1: a vanilla joker behaves as its "+" version) and The Rust (M10: a "+"
-- joker behaves as its vanilla version) are built on.
--
--   BPlus.with_center(card, center, fn)   run fn() while `card` is shaped as `center`
--   BPlus.plus_calculate(card, context)    run the "+" behaviour on any card (vanilla or "+")
--   BPlus.base_calculate(card, context)    run the vanilla behaviour on any card (vanilla or "+")
--   BPlus.add_behavior_provider(priority, fn)
--        fn(card) -> 'plus' | 'base' | nil. The highest-priority provider that answers wins.
--        Carpenter and The Rust each register one. Answers that don't apply (e.g. 'plus' on a joker
--        that is already "+", or on a carpenter_compat = false joker) are ignored.
--   BPlus.behaves_as(card)                 center key the card currently behaves as
--   BPlus.find_behaving(key)               jokers in G.jokers currently behaving as `key`
--
-- How `with_center` works: the card's `ability` and `config.center` are swapped for the duration of
-- the call, so the other center's own code (vanilla's name-based logic or a "+" joker's calculate)
-- runs unchanged on the real card object. The alternate ability table ("view") is built from the
-- other center's config and kept in ability.bplus_alt[center_key] between calls; it falls through
-- to the real ability for anything it doesn't define (stickers, edition values, debuff state...).
-- The paths in the "+" joker's bplus.state_transfer are the fields both shapes share: they are
-- copied into the view before the call and back afterwards, so a growing joker keeps its stored
-- value and only the growth rate changes.
--
-- Hooked card functions (calculate_joker, calculate_dollar_bonus, add_to_deck, remove_from_deck,
-- generate_UIBox_ability_table) follow the card's current behaviour automatically.

BPlus.behavior_providers = {}

function BPlus.add_behavior_provider(priority, fn)
    local list = BPlus.behavior_providers
    list[#list + 1] = { priority = priority, fn = fn }
    table.sort(list, function(a, b) return a.priority > b.priority end)
end

-- The fields set_ability derives from a center, so the view looks like a freshly created card.
local function center_fields(center)
    local c = center.config or {}
    local f = {
        name = center.name, effect = center.effect, set = center.set,
        mult = c.mult or 0, h_mult = c.h_mult or 0, h_x_mult = c.h_x_mult or 0,
        h_dollars = c.h_dollars or 0, p_dollars = c.p_dollars or 0,
        t_mult = c.t_mult or 0, t_chips = c.t_chips or 0,
        x_mult = c.Xmult or c.x_mult or 1, h_chips = c.h_chips or 0,
        x_chips = c.x_chips or 1, h_x_chips = c.h_x_chips or 1,
        repetitions = c.repetitions or 0, h_size = c.h_size or 0, d_size = c.d_size or 0,
        -- false, not nil: a missing `extra` must not fall through to the other shape's extra
        extra = c.extra ~= nil and BPlus.copy(c.extra) or false,
        type = c.type or '', order = center.order,
    }
    for k, v in pairs(c) do
        if k ~= 'bonus' then f[k] = BPlus.copy(v) end
    end
    -- vanilla set_ability's per-joker initialisation
    if f.name == 'Invisible Joker' then f.invis_rounds = 0 end
    if f.name == 'Caino' then f.caino_xmult = 1 end
    if f.name == 'Yorick' then f.yorick_discards = f.extra.discards end
    if f.name == 'Loyalty Card' then
        f.burnt_hand = 0
        f.loyalty_remaining = f.extra.every
    end
    return f
end

-- Pairs of { own_path, view_path } shared between the card's own center and `center`.
local function shared_paths(own_center, center)
    local out = {}
    if BPlus.upgrade_map[own_center.key] == center.key then
        for src, dst in pairs(center.bplus.state_transfer) do out[#out + 1] = { src, dst } end
    elseif BPlus.base_map[own_center.key] == center.key then
        for src, dst in pairs(own_center.bplus.state_transfer) do out[#out + 1] = { dst, src } end
    end
    return out
end

-- Cards currently swapped by with_center, outermost first. Events queued during a swap run their func
-- under the same swaps later: vanilla code often reads `self.ability` inside a deferred event
-- (e.g. Burglar's ease_hands_played(self.ability.extra)), after the swap would otherwise be undone.
local alt_frames = {}

local add_event_ref = EventManager.add_event
function EventManager:add_event(event, queue, front)
    if #alt_frames > 0 and type(event) == 'table' and event.func then
        local frames, func = { unpack(alt_frames) }, event.func
        event.func = function(...)
            local args = { ... }
            local function run(i)
                if i > #frames then return func(unpack(args)) end
                return BPlus.with_center(frames[i].card, frames[i].center, function() return run(i + 1) end)
            end
            return run(1)
        end
    end
    return add_event_ref(self, event, queue, front)
end

function BPlus.with_center(card, center, fn)
    if card.bplus_in_alt then return fn() end
    if type(center) == 'string' then center = G.P_CENTERS[center] end
    local own, own_center = card.ability, card.config.center
    own.bplus_alt = own.bplus_alt or {}
    local view = own.bplus_alt[center.key]
    if not view then
        view = center_fields(center)
        own.bplus_alt[center.key] = view
    end
    local paths = shared_paths(own_center, center)
    for _, p in ipairs(paths) do
        local v = BPlus.get_path(own, p[1])
        if v ~= nil then BPlus.set_path(view, p[2], BPlus.copy(v)) end
    end

    setmetatable(view, { __index = own })
    card.ability, card.config.center, card.bplus_in_alt = view, center, center.key
    alt_frames[#alt_frames + 1] = { card = card, center = center }
    local res = { pcall(fn) }
    alt_frames[#alt_frames] = nil
    card.ability, card.config.center, card.bplus_in_alt = own, own_center, nil
    -- never leave the metatable on: the view lives inside `own`, and copy_table follows metatables
    setmetatable(view, nil)

    for _, p in ipairs(paths) do
        local v = BPlus.get_path(view, p[2])
        if v ~= nil then BPlus.set_path(own, p[1], BPlus.copy(v)) end
    end
    if not res[1] then error(res[2], 0) end
    return unpack(res, 2)
end

local calculate_joker_ref = Card.calculate_joker

-- "+" behaviour on any card: the card itself if it is "+", else the "+" version of its center.
function BPlus.plus_calculate(card, context)
    if BPlus.is_plus(card) then return calculate_joker_ref(card, context) end
    local key = BPlus.upgrade_map[card.config.center.key]
    if not key then return end
    return BPlus.with_center(card, G.P_CENTERS[key], function() return calculate_joker_ref(card, context) end)
end

-- Vanilla behaviour on any card: the card itself if it is vanilla, else its vanilla center.
function BPlus.base_calculate(card, context)
    local key = BPlus.base_map[card.config.center.key]
    if not key then return calculate_joker_ref(card, context) end
    return BPlus.with_center(card, G.P_CENTERS[key], function() return calculate_joker_ref(card, context) end)
end

-- Behaviour tracking ------------------------------------------------------------------

-- The center key `card` should behave as right now, or nil for its own center.
function BPlus.behavior_target(card)
    if not (card.ability and card.ability.set == 'Joker') then return nil end
    local mode
    for _, p in ipairs(BPlus.behavior_providers) do
        mode = p.fn(card)
        if mode then break end
    end
    local own = card.config.center.key
    if mode == 'plus' and BPlus.is_eligible(card) then
        local key = BPlus.upgrade_map[own]
        if G.P_CENTERS[key].bplus.carpenter_compat then return key end
    elseif mode == 'base' and BPlus.is_plus(card) then
        if card.config.center.bplus.carpenter_compat then return BPlus.base_map[own] end
    end
    return nil
end

function BPlus.behaves_as(card)
    return card.bplus_in_alt or (card.ability and card.ability.bplus_behaving) or card.config.center.key
end

function BPlus.find_behaving(key)
    local out = {}
    for _, card in ipairs(G.jokers and G.jokers.cards or {}) do
        if not card.debuff and BPlus.behaves_as(card) == key then out[#out + 1] = card end
    end
    return out
end

-- Re-evaluates the providers and switches the card's behaviour if the answer changed. Deck effects
-- (hand size, discards, Credit Card...) are removed under the old behaviour and re-added under the
-- new one, the same way the game handles a debuff (no "card added" events fire).
function BPlus.sync_behavior(card)
    if card.bplus_in_alt or card.bplus_syncing or not card.ability then return end
    local want = BPlus.behavior_target(card)
    if want == card.ability.bplus_behaving then return end
    card.bplus_syncing = true
    local was_added = card.added_to_deck
    if was_added then card:remove_from_deck(true) end
    card.ability.bplus_behaving = want
    if was_added then card:add_to_deck(true) end
    card.bplus_syncing = nil
    -- the display must be rebuilt from the other behaviour's definition
    if card.joker_display_values and card.update_joker_display then card:update_joker_display(true, true, 'bplus_behavior') end
end

-- Back to the card's own behaviour and shape (used before a permanent upgrade).
function BPlus.reset_behavior(card)
    if card.ability.bplus_behaving then
        local was_added = card.added_to_deck
        if was_added then card:remove_from_deck(true) end
        card.ability.bplus_behaving = nil
        if was_added then card:add_to_deck(true) end
    end
    card.ability.bplus_alt = nil
end

local function alt_center(card)
    if card.bplus_in_alt then return nil end
    local key = card.ability and card.ability.bplus_behaving
    return key and G.P_CENTERS[key] or nil
end

-- Hooks ------------------------------------------------------------------------------------

function Card:calculate_joker(context)
    if self.ability and self.ability.set == 'Joker' then BPlus.sync_behavior(self) end
    local center = alt_center(self)
    if center then
        return BPlus.with_center(self, center, function() return calculate_joker_ref(self, context) end)
    end
    return calculate_joker_ref(self, context)
end

local function wrap(name)
    local ref = Card[name]
    Card[name] = function(self, ...)
        local center = alt_center(self)
        if center then
            local args = { ... }
            return BPlus.with_center(self, center, function() return ref(self, unpack(args)) end)
        end
        return ref(self, ...)
    end
end
for _, name in ipairs({ 'calculate_dollar_bonus', 'add_to_deck', 'remove_from_deck', 'generate_UIBox_ability_table', 'update' }) do
    wrap(name)
end

-- JokerDisplay (optional mod): its definition lookup and refs all go through card.config.center /
-- card.ability, so running its per-card entry points under the swap makes a joker display what it
-- currently behaves as (D20). Installed lazily because JokerDisplay may load after this file.
local jd_installed = false
local function install_jokerdisplay()
    ---@diagnostic disable: undefined-field
    if jd_installed or not (rawget(_G, 'JokerDisplay') and Card.update_joker_display and Card.calculate_joker_display
        and Card.initialize_joker_display) then return end
    jd_installed = true
    wrap('initialize_joker_display')
    wrap('calculate_joker_display')
    wrap('update_joker_display')
end
install_jokerdisplay()

local update_ref = Game.update
function Game:update(dt)
    update_ref(self, dt)
    install_jokerdisplay()
    if G.STAGE == G.STAGES.RUN and G.jokers then
        for _, card in ipairs(G.jokers.cards) do BPlus.sync_behavior(card) end
    end
end
