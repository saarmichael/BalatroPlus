local T = BPlus.test

local function hand_size() return G.hand.config.card_limit end
local function round() T.to_shop(); T.leave_shop() end

T.test('Magic Bean: +5 hand size; after 2 rounds +4; after 4 rounds +3', function()
    T.start_run({ jokers = { 'bplus_turtle_bean_plus' } })
    T.eq(hand_size(), 8 + 5)
    round()
    T.eq(hand_size(), 8 + 5, 'after 1 round')
    round()
    T.eq(hand_size(), 8 + 4, 'after 2 rounds')
    round(); round()
    T.eq(hand_size(), 8 + 3, 'after 4 rounds')
end)

T.test('Magic Bean: destroyed after 10 rounds (5 * 2), hand size back to 8', function()
    T.start_run({ jokers = { 'bplus_turtle_bean_plus' } })
    for _ = 1, 9 do round() end
    T.truthy(T.joker('bplus_turtle_bean_plus'), 'still there after 9 rounds')
    T.eq(hand_size(), 8 + 1)
    T.to_shop()
    T.falsy(T.joker('bplus_turtle_bean_plus'), 'eaten after 10 rounds')
    T.eq(hand_size(), 8)
end)

T.test('Magic Bean: Turtle Bean partly used up, upgrade -> starts fresh at +5 hand size', function()
    T.start_run({ jokers = { 'turtle_bean' } })
    round(); round()
    T.eq(hand_size(), 8 + 5 - 2)
    local card = T.upgrade('turtle_bean')
    T.eq(card.ability.extra.h_size, 5)
    T.eq(card.ability.extra.rounds, 0)
    T.eq(hand_size(), 8 + 5)
    round()
    T.eq(hand_size(), 8 + 5, 'first round of the new bean')
    round()
    T.eq(hand_size(), 8 + 4)
end)

T.test('Magic Bean: ignores forced behaviour (carpenter_compat = false)', function()
    T.start_run({ jokers = { 'turtle_bean' } })
    T.errors(function() T.force_behavior('turtle_bean', 'plus') end)
end)
