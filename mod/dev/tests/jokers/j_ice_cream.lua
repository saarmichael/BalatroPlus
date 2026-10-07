local T = BPlus.test

local function hand()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    return T.play({ '2S' })
end

T.test('Chocolate Bar: play 3 hands -> 150, then 145, then 140 Chips', function()
    T.start_run({ jokers = { 'bplus_ice_cream_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.eq(hand().chips, 5 + 2 + 150)
    T.eq(hand().chips, 5 + 2 + 145)
    T.eq(hand().chips, 5 + 2 + 140)
    T.eq(T.joker(1).ability.extra.chips, 150 - 5 - 5 - 5)
end)

T.test('Chocolate Bar: melts when chips would reach 0 (150 / 5 = 30 hands)', function()
    T.start_run({ jokers = { 'bplus_ice_cream_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    local c = T.joker(1)
    T.eq(c.ability.extra.chips / c.ability.extra.chip_mod, 30)
    c.ability.extra.chips = 10   -- as if 28 hands were already played
    hand()
    T.eq(T.joker(1).ability.extra.chips, 10 - 5)
    hand()
    T.falsy(T.joker(1), 'melted')
end)

T.test('Chocolate Bar: Ice Cream partly used up, upgrade -> starts fresh at +150 Chips', function()
    T.start_run({ jokers = { 'ice_cream' }, hands = 5, ante = 3 })
    T.select_blind()
    hand(); hand()
    T.eq(T.joker(1).ability.extra.chips, 100 - 5 - 5, 'vanilla value')
    local card = T.upgrade('ice_cream')
    T.eq(card.ability.extra.chips, 150, 'reset')
    T.eq(hand().chips, 5 + 2 + 150)
end)

T.test('Chocolate Bar: Carpenter cannot switch Ice Cream (carpenter_compat false)', function()
    T.start_run({ jokers = { 'ice_cream' }, hands = 5, ante = 3 })
    T.select_blind()
    T.errors(function() T.force_behavior('ice_cream', 'plus') end)
    T.eq(hand().chips, 5 + 2 + 100)
end)
