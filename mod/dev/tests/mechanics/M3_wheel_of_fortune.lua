-- M3: The Wheel of Fortune with the upgrade outcome. Spec: plannig/specs/mechanics/M3_wheel_of_fortune.yaml
local T = BPlus.test

-- Runs fn with the Wheel's success chance and outcome roll forced.
local function forced(success, roll, fn)
    local real_prob, real_random = SMODS.pseudorandom_probability, pseudorandom
    SMODS.pseudorandom_probability = function(card, seed, ...)
        if seed == 'wheel_of_fortune' then return success end
        return real_prob(card, seed, ...)
    end
    pseudorandom = function(seed, ...)
        if seed == 'bplus_wheel_outcome' then return roll end
        return real_random(seed, ...)
    end
    local ok, err = pcall(fn)
    SMODS.pseudorandom_probability, pseudorandom = real_prob, real_random
    if not ok then error(err, 0) end
end

local function wheel() T.use('wheel_of_fortune') end

T.test('Wheel of Fortune: outcome shares upgrade 25% / foil 37.5% / holo 26.25% / polychrome 11.25%', function()
    local all = { upgrade = {}, foil = {}, holo = {}, polychrome = {} }
    T.eq(BPlus.wheel_pick_outcome(all, 0.10), 'upgrade')
    T.eq(BPlus.wheel_pick_outcome(all, 0.25), 'foil')
    T.eq(BPlus.wheel_pick_outcome(all, 0.624), 'foil')
    T.eq(BPlus.wheel_pick_outcome(all, 0.63), 'holo')
    T.eq(BPlus.wheel_pick_outcome(all, 0.8875), 'polychrome')
    T.eq(BPlus.wheel_pick_outcome(all, 0.999), 'polychrome')
    -- no upgrade candidate: renormalised over 0.375 + 0.2625 + 0.1125 = 0.75
    local editions = { foil = {}, holo = {}, polychrome = {} }
    T.eq(BPlus.wheel_pick_outcome(editions, 0.49), 'foil')   -- 0.49 * 0.75 = 0.3675 < 0.375
    T.eq(BPlus.wheel_pick_outcome(editions, 0.51), 'holo')   -- 0.51 * 0.75 = 0.3825 > 0.375
    T.eq(BPlus.wheel_pick_outcome({ upgrade = {} }, 0.99), 'upgrade')
    T.eq(BPlus.wheel_pick_outcome({}, 0.5), nil)
end)

T.test('Wheel of Fortune: success with the upgrade outcome upgrades the eligible Joker', function()
    T.start_run({ jokers = { 'joker' }, consumables = { 'wheel_of_fortune' } })
    forced(true, 0.10, wheel)
    T.eq(T.joker('bplus_joker_plus') ~= nil, true, 'Joker+ exists')
    T.falsy(T.joker('j_joker'), 'vanilla Joker gone')
    T.falsy(G.jokers.cards[1].edition, 'no edition added')
end)

T.test('Wheel of Fortune: success with the foil / holo / polychrome outcome adds that edition', function()
    for _, case in ipairs({ { 0.30, 'foil' }, { 0.70, 'holo' }, { 0.95, 'polychrome' } }) do
        T.start_run({ jokers = { 'joker' }, consumables = { 'wheel_of_fortune' } })
        forced(true, case[1], wheel)
        local joker = G.jokers.cards[1]
        T.eq(joker.config.center.key, 'j_joker', 'still vanilla')
        T.truthy(joker.edition and joker.edition[case[2]], case[2])
    end
end)

T.test('Wheel of Fortune: with no Joker lacking an edition the only outcome is the upgrade', function()
    T.start_run({ jokers = { { key = 'joker', edition = 'foil' } }, consumables = { 'wheel_of_fortune' } })
    forced(true, 0.99, wheel)
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_joker_plus')
    T.truthy(G.jokers.cards[1].edition and G.jokers.cards[1].edition.foil, 'edition kept')
end)

T.test('Wheel of Fortune: with no eligible Joker the outcome is always an edition', function()
    T.start_run({ jokers = { 'four_fingers' }, consumables = { 'wheel_of_fortune' } })
    forced(true, 0.01, wheel)   -- 0.01 would be the upgrade outcome if it were offered
    T.truthy(G.jokers.cards[1].edition and G.jokers.cards[1].edition.foil, 'foil, not upgrade')
end)

T.test('Wheel of Fortune: failure shows Nope! and changes nothing', function()
    T.start_run({ jokers = { 'joker' }, consumables = { 'wheel_of_fortune' } })
    forced(false, 0.10, wheel)
    T.eq(G.jokers.cards[1].config.center.key, 'j_joker')
    T.falsy(G.jokers.cards[1].edition, 'no edition')
    T.falsy(T.consumable('wheel_of_fortune'), 'consumed')
end)

T.test('Wheel of Fortune: cannot be used without a valid Joker', function()
    T.start_run({ consumables = { 'wheel_of_fortune' } })
    T.errors(wheel)
    T.start_run({ jokers = { { key = 'four_fingers', edition = 'foil' } }, consumables = { 'wheel_of_fortune' } })
    T.errors(wheel)
end)

T.test('Wheel of Fortune: Ride the Bus keeps +2 Mult when upgraded and then gains at the + rate', function()
    T.start_run({ ante = 3, hands = 6, jokers = { 'ride_the_bus' }, consumables = { 'wheel_of_fortune' } })
    T.select_blind()
    local function hand() T.set_hand({ '2S', '3H', '5C', '7D', '9H' }); return T.play({ '9H' }) end
    T.eq(hand().mult, 1 + 1)
    T.eq(hand().mult, 1 + 2)
    forced(true, 0.10, wheel)
    local bus = G.jokers.cards[1]
    T.eq(bus.config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(bus.ability.extra.mult, 2, 'value kept')
    T.eq(hand().mult, 1 + 2 + 2)
end)

T.test('Wheel of Fortune: Ice Cream upgraded -> Chocolate Bar starts fresh at +150 Chips', function()
    T.start_run({ ante = 3, hands = 6, jokers = { 'ice_cream' }, consumables = { 'wheel_of_fortune' } })
    T.select_blind()
    local function hand() T.set_hand({ '2S', '3H', '5C', '7D', '9H' }); return T.play({ '9H' }) end
    T.eq(hand().chips, 5 + 9 + 100)
    forced(true, 0.10, wheel)
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_ice_cream_plus')
    T.eq(hand().chips, 5 + 9 + 150)
end)
