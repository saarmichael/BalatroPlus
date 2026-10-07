-- M4: Apotheosis. Spec: plannig/specs/mechanics/M4_apotheosis.yaml
local T = BPlus.test

-- Uses Apotheosis and waits until `remaining` Jokers are left (default 1).
local function apotheosis(remaining)
    T.use('c_bplus_apotheosis')
    T.wait_until(function() return #G.jokers.cards <= (remaining or 1) end, 'Jokers to dissolve', 10)
    T.wait_idle()
end

T.test('Apotheosis: upgrades one eligible Joker and destroys all the others', function()
    T.start_run({ jokers = { 'joker', 'greedy_joker', 'four_fingers' }, consumables = { 'c_bplus_apotheosis' } })
    apotheosis()
    T.eq(#G.jokers.cards, 1)
    T.truthy(BPlus.is_plus(G.jokers.cards[1]), 'survivor is a + joker')
    T.falsy(T.consumable('c_bplus_apotheosis'), 'consumed')
end)

T.test('Apotheosis: Eternal Jokers survive', function()
    T.start_run({ jokers = { 'joker', { key = 'four_fingers', stickers = { 'eternal' } }, 'greedy_joker' },
        consumables = { 'c_bplus_apotheosis' } })
    apotheosis(2)
    T.eq(#G.jokers.cards, 2)
    T.truthy(T.joker('four_fingers'), 'Four Fingers (Eternal) survives')
    local plus = 0
    for _, c in ipairs(G.jokers.cards) do if BPlus.is_plus(c) then plus = plus + 1 end end
    T.eq(plus, 1)
end)

T.test('Apotheosis: cannot be used without an eligible Joker', function()
    T.start_run({ jokers = { 'four_fingers', 'bplus_joker_plus' }, consumables = { 'c_bplus_apotheosis' } })
    T.errors(function() T.use('c_bplus_apotheosis') end)
    T.eq(#G.jokers.cards, 2)
end)

T.test('Apotheosis: costs the same as Hex', function()
    T.eq(G.P_CENTERS.c_bplus_apotheosis.cost, G.P_CENTERS.c_hex.cost)
    T.eq(G.P_CENTERS.c_bplus_apotheosis.set, 'Spectral')
end)

T.test('Apotheosis: Ride the Bus keeps +2 Mult and then gains at the + rate', function()
    T.start_run({ ante = 3, hands = 6, jokers = { 'ride_the_bus', 'four_fingers' }, consumables = { 'c_bplus_apotheosis' } })
    T.select_blind()
    local function hand() T.set_hand({ '2S', '3H', '5C', '7D', '9H' }); return T.play({ '9H' }) end
    T.eq(hand().mult, 1 + 1)
    T.eq(hand().mult, 1 + 2)
    apotheosis()
    T.eq(#G.jokers.cards, 1)
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(G.jokers.cards[1].ability.extra.mult, 2, 'value kept')
    T.eq(hand().mult, 1 + 2 + 2)
end)

T.test('Apotheosis: Ice Cream upgraded -> Chocolate Bar starts fresh at +150 Chips', function()
    T.start_run({ ante = 3, hands = 6, jokers = { 'ice_cream' }, consumables = { 'c_bplus_apotheosis' } })
    T.select_blind()
    local function hand() T.set_hand({ '2S', '3H', '5C', '7D', '9H' }); return T.play({ '9H' }) end
    T.eq(hand().chips, 5 + 9 + 100)
    apotheosis()
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_ice_cream_plus')
    T.eq(hand().chips, 5 + 9 + 150)
end)
