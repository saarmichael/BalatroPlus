local T = BPlus.test

local function hand() T.set_hand({ 'KS', '9H', '2C' }); return T.play({ 'KS' }) end

T.test('Fizzy Bubbelech: with Oops! All 6s, each scored card scores 1 + 2 times', function()
    T.start_run({ jokers = { 'oops', 'bplus_selzer_plus' }, hands = 12, ante = 3 })
    T.select_blind()
    T.eq(hand().chips, 5 + 10 * 3)
    T.eq(T.joker('bplus_selzer_plus').ability.extra.hands_left, 10 - 1)
end)

T.test('Fizzy Bubbelech: after 10 hands the card is destroyed', function()
    T.start_run({ jokers = { 'oops', 'bplus_selzer_plus' }, hands = 12, ante = 3 })
    T.select_blind()
    for _ = 1, 9 do hand() end
    T.truthy(T.joker('bplus_selzer_plus'), 'still there after 9 hands')
    T.eq(T.joker('bplus_selzer_plus').ability.extra.hands_left, 10 - 9)
    hand()
    T.falsy(T.joker('bplus_selzer_plus'), 'destroyed after the 10th hand')
end)

T.test('Fizzy Bubbelech: Seltzer with 4 hands left, upgrade -> 4 hands left, then counts down', function()
    T.start_run({ jokers = { 'selzer' }, hands = 12, ante = 3 })
    T.select_blind()
    for _ = 1, 6 do hand() end
    T.eq(T.joker('selzer').ability.extra, 10 - 6, 'vanilla value')
    local card = T.upgrade('selzer')
    T.eq(card.ability.extra.hands_left, 4)
    hand()
    T.eq(card.ability.extra.hands_left, 4 - 1)
end)

T.test('Fizzy Bubbelech: Carpenter-style forcing is ignored (carpenter_compat = false)', function()
    T.start_run({ jokers = { 'selzer' } })
    T.errors(function() T.force_behavior('selzer', 'plus') end)
end)
