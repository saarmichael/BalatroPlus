-- Table-driven copy checks over EVERY "+" joker (BPlus.upgrade_map), see plannig/specs/jokers/j_blueprint.yaml.
--   A  vanilla Blueprint / Brainstorm: compat state matches the "+" joker's blueprint_compat
--   B  a full round (blind select, discard, play, win, cash out, shop) with the joker copied by
--      vanilla Blueprint and Brainstorm raises no error
--   C  growing / shrinking jokers: one trigger with a copier in the lineup moves the stored value by exactly
--      one step (the `not context.blueprint` guard holds), for Blueprint and Brainstorm
--   E  exact-number checks for ten representative jokers, alone / copied by Blueprint / copied by Brainstorm
local T = BPlus.test

local function short(plus_key) return (plus_key:gsub('^j_bplus_', ''):gsub('_plus$', '')) end

local function plus_keys()
    local out = {}
    for _, plus in pairs(BPlus.upgrade_map) do out[#out + 1] = plus end
    table.sort(out)
    return out
end

local function near(a, e, what) T.near(a, e, 1e-6, what) end

-- One round of generic play: setting_blind, discard, hand, end of round, cash out, shop.
local function full_round()
    T.select_blind()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    if G.GAME.current_round.discards_left > 0 then   -- Cat Burglar removes every discard
        T.discard({ '3D' })
        T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    end
    T.play({ '2S', '2H' })
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end   -- big copied xMult may win it already
    if T.state_name() ~= 'ROUND_EVAL' then return end   -- e.g. Troubadour: one hand only, game over
    T.cash_out()
    T.leave_shop()
end

-- A + B ----------------------------------------------------------------------------------------------------
-- One run per joker, X = the "+" joker: lineup  X, Brainstorm (copies slot 1), Blueprint (copies slot 4), X

for _, plus in ipairs(plus_keys()) do
    local center = G.P_CENTERS[plus]
    local want = center.blueprint_compat and 'compatible' or 'incompatible'
    T.test(('Copy sweep: %s (copyable=%s): Blueprint/Brainstorm state, then both copy a full round'):format(short(plus), tostring(center.blueprint_compat)), function()
        T.start_run({ jokers = { plus, 'brainstorm', 'blueprint', plus }, ante = 8, joker_slots = 8, dollars = 50 })
        T.wait_frames(5)
        T.eq(T.joker(3).ability.blueprint_compat, want, 'vanilla Blueprint state')
        T.eq(T.joker(2).ability.blueprint_compat, want, 'vanilla Brainstorm state')
        full_round()
    end)
end

-- C --------------------------------------------------------------------------------------------------------

local function discards(n)
    while n > 0 do
        local k = math.min(5, n)
        local idx = {}
        for i = 1, k do idx[i] = i end
        T.discard(idx)
        n = n - k
    end
end

local function plain_hand() T.set_hand({ '2S', '3H', '7C', '5D', '9D' }) end
local STRAIGHT = { '5S', '6H', '7C', '8D', '9D' }
local HEARTS = { '2H', '4H', '6H', '8H', 'KH' }

-- name: "+" joker short name; step: expected change of read(card) for ONE trigger; setup/act run after start_run
-- scenario: extra start_run fields; extras: jokers placed behind the "+" joker (spacers / victims)
local GROW = {
    { name = 'caino', step = 1 * 2, scenario = { consumables = { 'hanged_man' }, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ 'KS', 'QH', '7C', '5D', '3D', '2C', '4S', '6H' })
            T.use('hanged_man', { 'KS' })
        end },
    { name = 'campfire', step = 0.4, scenario = { ante = 3, boss = 'club' }, extras = { 'joker', 'joker', 'joker' },
        read = function(c) return c.ability.extra.Xmult end,
        act = function() T.sell('joker') end },
    { name = 'castle', step = 6, scenario = { ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.chips end,
        setup = function()
            T.select_blind()
            G.GAME.current_round.castle_card.suit = 'Hearts'
        end,
        act = function()
            T.set_hand(HEARTS)
            T.discard({ '2H' })
        end },
    { name = 'ceremonial', step = 3 * 3, scenario = { ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.mult end,
        act = function() T.select_blind() end },
    { name = 'constellation', step = 0.2, scenario = { consumables = { 'mercury' }, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function() T.use('mercury') end },
    { name = 'flash', step = 4, scenario = { dollars = 100, free_rerolls = true, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.mult end,
        setup = function() T.to_shop() end,
        act = function() T.reroll() end },
    { name = 'glass', step = 1.5, scenario = { consumables = { 'hanged_man' }, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ { 'KH', enhancement = 'glass' }, 'KS', '2C', '3D', '4D' })
            T.use('hanged_man', { 'KH' })
        end },
    { name = 'green_joker', step = 2, scenario = { hands = 5, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.mult end,
        setup = function() T.select_blind() end,
        act = function() plain_hand(); T.play({ '2S' }) end },
    { name = 'hit_the_road', step = 1, scenario = { ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ 'JS', '2C', '3D', '4D', '6H' })
            T.discard({ 'JS' })
        end },
    { name = 'hologram', step = 2 * 0.35, scenario = { consumables = { 'cryptid' }, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function()
            plain_hand()
            T.use('cryptid', { '2S' })
        end },
    { name = 'lucky_cat', step = 0.4, scenario = { ante = 8, hands = 6 }, extras = { 'oops', 'oops', 'oops' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ { 'KH', enhancement = 'lucky' }, '2S', '3H', '5D', '7C' })
            T.play({ 'KH' })
        end },
    { name = 'madness', step = 0.75, scenario = { ante = 3 }, extras = { 'joker', 'joker', 'joker' },
        read = function(c) return c.ability.extra.Xmult end,
        act = function() T.select_blind() end },
    { name = 'obelisk', step = 0.4, scenario = { ante = 3, hands = 6 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function()
            T.select_blind()
            G.GAME.hands['Pair'].played = 10
        end,
        act = function() T.set_hand(HEARTS); T.play(HEARTS) end },
    { name = 'red_card', step = 5, scenario = { dollars = 100, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.mult end,
        setup = function() T.to_shop() end,
        act = function()
            T.buy(G.shop_booster.cards[1].config.center.key)
            T.skip_pack()
        end },
    { name = 'ride_the_bus', step = 2, scenario = { hands = 5, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.mult end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
            T.play({ '2S', '2H' })
        end },
    { name = 'runner', step = 30, scenario = { hands = 6, ante = 8 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.chips end,
        setup = function() T.select_blind() end,
        act = function() T.set_hand(STRAIGHT); T.play(STRAIGHT) end },
    { name = 'square', step = 16, scenario = { hands = 6, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.chips end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ '2S', '2H', '3C', '3D', '7D' })
            T.play({ '2S', '2H', '3C', '3D' })
        end },
    { name = 'trousers', step = 4, scenario = { hands = 6, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.mult end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ '2S', '2H', '3C', '3D', '7H' })
            T.play({ '2S', '2H', '3C', '3D' })
        end },
    { name = 'vampire', step = 0.2, scenario = { hands = 6, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ { 'KH', enhancement = 'steel' }, '2S', '3H', '5D', '7C' })
            T.play({ 'KH' })
        end },
    { name = 'wee', step = 16, scenario = { hands = 6, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.chips end,
        setup = function() T.select_blind() end,
        act = function()
            T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
            T.play({ '2S' })
        end },
    { name = 'yorick', step = 1, scenario = { discards = 8, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function() discards(14) end },
    -- shrinking jokers (empty state_transfer, but the same guard applies)
    { name = 'ice_cream', step = -5, scenario = { hands = 5, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.chips end,
        setup = function() T.select_blind() end,
        act = function() plain_hand(); T.play({ '2S' }) end },
    { name = 'selzer', step = -1, scenario = { hands = 5, ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.hands_left end,
        setup = function() T.select_blind() end,
        act = function() plain_hand(); T.play({ '2S' }) end },
    { name = 'popcorn', step = -5, scenario = { ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.mult end,
        setup = function() T.select_blind() end,
        act = function() T.win_blind() end },
    { name = 'ramen', step = -0.01, scenario = { ante = 3 }, extras = { 'four_fingers' },
        read = function(c) return c.ability.extra.Xmult end,
        setup = function() T.select_blind() end,
        act = function() plain_hand(); T.discard({ '2S' }) end },
}

-- Jokers with a non-empty state_transfer that this file does not exercise, and why.
local NOT_EXERCISED = {
    loyalty_card = 'stored state is a creation counter (hands_played_at_create), not a value that a trigger grows',
    todo_list = 'stored state is the listed poker hand; it only changes by random re-roll at end of round, no step',
    invisible = 'blueprint_compat = false (cannot be copied)',
    rocket = 'blueprint_compat = false (cannot be copied)',
}

local COPIERS = {
    { name = 'Blueprint', lineup = function(x, extras) return { 'blueprint', x, unpack(extras) } end },
    { name = 'Brainstorm', lineup = function(x, extras)
        local l = { x, unpack(extras) }
        l[#l + 1] = 'brainstorm'
        return l
    end },
}

local covered = {}
for _, entry in ipairs(GROW) do
    local plus = 'bplus_' .. entry.name .. '_plus'
    covered[entry.name] = true
    for _, copier in ipairs(COPIERS) do
        T.test(('Copy sweep growth: %s copied by %s -> stored value moves by exactly one step (%s)'):format(entry.name, copier.name, tostring(entry.step)), function()
            ---@type table<string, any>
            local s = { joker_slots = 8 }
            for k, v in pairs(entry.scenario) do s[k] = v end
            s.jokers = copier.lineup(plus, entry.extras)
            T.start_run(s)
            if entry.setup then entry.setup() end
            local card = T.joker(plus)
            T.truthy(card, 'the "+" joker exists')
            local before = entry.read(card)
            entry.act()
            card = T.joker(plus)
            if not card then
                -- shrinking jokers may be eaten; that never applies to one step from the full value
                T.fail(plus .. ' disappeared')
            end
            near(entry.read(card) - before, entry.step, ('%s: stored value change (%s -> %s)'):format(entry.name, before, entry.read(card)))
        end)
    end
end

T.test('Copy sweep growth: coverage (every "+" joker with state_transfer is either exercised above or listed as not exercised)', function()
    local missing, listed = {}, {}
    for _, plus in ipairs(plus_keys()) do
        local c = G.P_CENTERS[plus]
        local st = c.bplus and c.bplus.state_transfer
        if st and next(st) then
            local n = short(plus)
            if covered[n] then
                listed[#listed + 1] = n .. ': exercised'
            elseif NOT_EXERCISED[n] then
                listed[#listed + 1] = n .. ': NOT EXERCISED, ' .. NOT_EXERCISED[n]
            else
                missing[#missing + 1] = n
            end
        end
    end
    print('[copy sweep growth coverage]\n  ' .. table.concat(listed, '\n  '))
    T.eq(missing, {}, 'jokers with state_transfer that are neither exercised nor excused')
end)


-- E ---------------------------------------------------------------------------------------------------------
local VARIANTS = { 'alone', 'blueprint', 'brainstorm' }

local function lineup(variant, x, y, extra)
    local l
    if variant == 'alone' then l = { x }
    elseif variant == 'blueprint' then l = { 'blueprint', x }
    else l = { x, 'brainstorm' } end
    for _, e in ipairs(extra or {}) do l[#l + 1] = e end
    return l
end

-- spec: name, x, y, extra, scenario, measure() -> table, expect = { variant -> table }
local function representative(spec)
    for _, variant in ipairs(VARIANTS) do
        T.test(('%s: %s'):format(spec.name, spec.title[variant]), function()
            ---@type table<string, any>
            local s = { joker_slots = 8 }
            for k, v in pairs(spec.scenario or {}) do s[k] = v end
            s.jokers = lineup(variant, spec.x, spec.y or 'joker', spec.extra)
            T.start_run(s)
            local got = spec.measure()
            local want = spec.expect[variant]
            for k, v in pairs(want) do
                near(got[k], v, ('%s.%s'):format(variant, k))
            end
        end)
    end
end

local function titles(alone, blueprint, brainstorm)
    return { alone = alone, blueprint = blueprint, brainstorm = brainstorm }
end

local PAIR = { '2S', '2H', '7C', '5D', '3D' }
local function play_pair()
    T.set_hand(PAIR)
    return T.play({ '2S', '2H' })
end

-- B1 Merry Joker: +20 Mult on Pair ------------------------------------------------------------------------
representative({
    name = 'Merry Joker', x = 'bplus_jolly_plus', scenario = { ante = 3 },
    title = titles('alone: +20', 'Blueprint copies it: 2 x +20', 'Brainstorm copies it: 2 x +20'),
    measure = function()
        T.select_blind()
        local r = play_pair()
        return { chips = r.chips, mult = r.mult }
    end,
    expect = {
        alone = { chips = 10 + 2 + 2, mult = 2 + 20 },
        blueprint = { chips = 10 + 2 + 2, mult = 2 + 20 + 20 },
        brainstorm = { chips = 10 + 2 + 2, mult = 2 + 20 + 20 },
    },
})

-- B2 Undercover Joker: $6 for 3 discarded faces. Y = vanilla Faceless Joker ($5) ------------------------------
representative({
    name = 'Undercover Joker', x = 'bplus_faceless_plus', y = 'faceless', scenario = { dollars = 0, ante = 3 },
    title = titles('alone: $6', 'Blueprint copies it: 2 x $6', 'Brainstorm copies it: 2 x $6'),
    measure = function()
        T.select_blind()
        T.set_hand({ 'KS', 'QH', 'JD', '2C', '3C', '4C', '5C', '6C' })
        T.discard({ 'KS', 'QH', 'JD' })
        return { dollars = G.GAME.dollars }
    end,
    expect = {
        alone = { dollars = 6 },
        blueprint = { dollars = 6 + 6 },
        brainstorm = { dollars = 6 + 6 },
    },
})

-- B3 Ur-Joker: X1.5 per scored card of the Ur suit (Spades), applied per scoring card --------------------------
representative({
    name = 'Ur-Joker', x = 'bplus_ancient_plus', scenario = { ante = 3 },
    title = titles('alone: 2S scores X1.5', 'Blueprint copies it: X1.5 twice', 'Brainstorm copies it: X1.5 twice'),
    measure = function()
        T.select_blind()
        G.GAME.current_round.bplus_ur_card.suit = 'Spades'
        local r = play_pair()
        return { mult = r.mult }
    end,
    -- the xMult of the 2 of Spades applies while the card scores (before the jokers' joker_main), then Joker's +4s
    expect = {
        alone = { mult = 2 * 1.5 },
        blueprint = { mult = 2 * 1.5 * 1.5 },
        brainstorm = { mult = 2 * 1.5 * 1.5 },
    },
})

-- B4 Professor: each scored Ace +40 Chips +10 Mult ------------------------------------------------------------
representative({
    name = 'Professor', x = 'bplus_scholar_plus', scenario = { ante = 3 },
    title = titles('alone: pair of Aces', 'Blueprint copies it: doubled', 'Brainstorm copies it: doubled'),
    measure = function()
        T.select_blind()
        T.set_hand({ 'AS', 'AH', '7C', '5D', '3D' })
        local r = T.play({ 'AS', 'AH' })
        return { chips = r.chips, mult = r.mult }
    end,
    expect = {
        alone = { chips = 10 + 11 + 11 + 40 * 2, mult = 2 + 10 * 2 },
        blueprint = { chips = 10 + 11 + 11 + 40 * 2 * 2, mult = 2 + 10 * 2 * 2 },
        brainstorm = { chips = 10 + 11 + 11 + 40 * 2 * 2, mult = 2 + 10 * 2 * 2 },
    },
})

-- B5 Galaxy: +X0.2 per Planet used; the copies do not add a second step ---------------------------------------
-- Planets are used while the copier is already in the lineup; Pluto levels High Card, the played Pair is untouched.
representative({
    name = 'Galaxy', x = 'bplus_constellation_plus', scenario = { consumables = { 'pluto', 'pluto' }, ante = 3 },
    title = titles('alone: 2 Planets -> X1.4', 'Blueprint copies it: X1.4 twice, stored stays X1.4',
        'Brainstorm copies it: X1.4 twice, stored stays X1.4'),
    measure = function()
        T.select_blind()
        T.use('pluto')
        T.use('pluto')
        local stored = T.joker('bplus_constellation_plus').ability.extra.Xmult
        local r = play_pair()
        return { stored = stored, stored_after = T.joker('bplus_constellation_plus').ability.extra.Xmult, mult = r.mult }
    end,
    expect = {
        alone = { stored = 1 + 0.2 * 2, stored_after = 1 + 0.2 * 2, mult = 2 * 1.4 },
        blueprint = { stored = 1 + 0.2 * 2, stored_after = 1 + 0.2 * 2, mult = 2 * 1.4 * 1.4 },
        brainstorm = { stored = 1 + 0.2 * 2, stored_after = 1 + 0.2 * 2, mult = 2 * 1.4 * 1.4 },
    },
})

-- B6 Chocolate Bar: +150 Chips, -5 per hand; a copy must not double the decay -----------------------------------
representative({
    name = 'Chocolate Bar', x = 'bplus_ice_cream_plus', scenario = { ante = 3, hands = 5 },
    title = titles('alone: +150, decays to 145', 'Blueprint copies it: +150 twice, decays only to 145',
        'Brainstorm copies it: +150 twice, decays only to 145'),
    measure = function()
        T.select_blind()
        local r = play_pair()
        return { chips = r.chips, mult = r.mult, stored = T.joker('bplus_ice_cream_plus').ability.extra.chips }
    end,
    expect = {
        alone = { chips = 10 + 2 + 2 + 150, mult = 2, stored = 150 - 5 },
        blueprint = { chips = 10 + 2 + 2 + 150 * 2, mult = 2, stored = 150 - 5 },
        brainstorm = { chips = 10 + 2 + 2 + 150 * 2, mult = 2, stored = 150 - 5 },
    },
})

-- B7 Evergreen Joker: +2 Mult per hand played (grows in `before`, scores in joker_main) ------------------------
representative({
    name = 'Evergreen Joker', x = 'bplus_green_joker_plus', scenario = { ante = 3, hands = 5 },
    title = titles('alone: first hand +2', 'Blueprint copies it: +2 twice, grows by 2 only',
        'Brainstorm copies it: +2 twice, grows by 2 only'),
    measure = function()
        T.select_blind()
        local r = play_pair()
        return { mult = r.mult, stored = T.joker('bplus_green_joker_plus').ability.extra.mult }
    end,
    expect = {
        alone = { mult = 2 + 2, stored = 2 },
        blueprint = { mult = 2 + 2 + 2, stored = 2 },
        brainstorm = { mult = 2 + 2 + 2, stored = 2 },
    },
})

-- B8 Spirit Board: 2 Spectral cards on a Straight Flush; each copy creates its own while slots allow -------------
local function spectral_count()
    local n = 0
    for _, c in ipairs(G.consumeables.cards) do
        if c.ability.set == 'Spectral' then n = n + 1 end
    end
    return n
end
local function straight_flush()
    T.select_blind()
    T.set_hand({ '9S', '8S', '7S', '6S', '5S' })
    local r = T.play({ '9S', '8S', '7S', '6S', '5S' })
    T.eq(r.hand, 'Straight Flush')
    return { spectral = spectral_count() }
end
representative({
    name = 'Spirit Board', x = 'bplus_seance_plus', y = 'seance',
    scenario = { ante = 5, consumable_slots = 8 },
    title = titles('alone: 2 Spectral cards', 'Blueprint copies it: 2 + 2', 'Brainstorm copies it: 2 + 2'),
    measure = straight_flush,
    expect = {
        alone = { spectral = 2 },
        blueprint = { spectral = 2 + 2 },
        brainstorm = { spectral = 2 + 2 },
    },
})

T.test('Spirit Board: Blueprint copy with only 3 consumable slots -> 2 + 1 (the copy stops at the limit)', function()
    T.start_run({ jokers = { 'blueprint', 'bplus_seance_plus' }, ante = 5, consumable_slots = 3 })
    T.eq(straight_flush().spectral, 3)
end)

-- B9 Melpomene and Thalia: retriggers face cards; Oops! All 6s makes its 1 in 2 certain (2 retriggers) -----------
-- Y = vanilla Sock and Buskin (1 retrigger). Trailing Oops! All 6s is not copyable and sits outside the copied slots.
local function king_chips() 
    T.select_blind()
    T.set_hand({ 'KS', '2H', '3C', '5D', '7D' })
    local r = T.play({ 'KS' })
    return { chips = r.chips, mult = r.mult }
end
representative({
    name = 'Melpomene and Thalia', x = 'bplus_sock_and_buskin_plus', y = 'sock_and_buskin', extra = { 'oops' },
    scenario = { ante = 3 },
    title = titles('alone (with Oops): King scores 1 + 2 times', 'Blueprint copies it: 1 + 2 + 2 times',
        'Brainstorm copies it: 1 + 2 + 2 times'),
    measure = king_chips,
    expect = {
        alone = { chips = 5 + 10 * (1 + 2), mult = 1 },
        blueprint = { chips = 5 + 10 * (1 + 2 + 2), mult = 1 },
        brainstorm = { chips = 5 + 10 * (1 + 2 + 2), mult = 1 },
    },
})

-- B10 Canio+: +X2 per destroyed face card; copies neither add nor double the gain ------------------------------
representative({
    name = 'Canio+', x = 'bplus_caino_plus', scenario = { consumables = { 'hanged_man' }, ante = 3 },
    title = titles('alone: 2 faces destroyed -> X5', 'Blueprint copies it: X5 twice, stored stays X5',
        'Brainstorm copies it: X5 twice, stored stays X5'),
    measure = function()
        T.select_blind()
        T.set_hand({ 'KS', 'QH', '7C', '5D', '3D', '2C', '4S', '6H' })
        T.use('hanged_man', { 'KS', 'QH' })
        local stored = T.joker('bplus_caino_plus').ability.extra.Xmult
        local r = play_pair()
        return { stored = stored, mult = r.mult }
    end,
    expect = {
        alone = { stored = 1 + 2 * 2, mult = 2 * 5 },
        blueprint = { stored = 1 + 2 * 2, mult = 2 * 5 * 5 },
        brainstorm = { stored = 1 + 2 * 2, mult = 2 * 5 * 5 },
    },
})

