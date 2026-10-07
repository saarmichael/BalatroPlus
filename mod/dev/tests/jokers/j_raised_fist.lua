local T = BPlus.test

T.test('Coup: hold a 3 and a King -> +4 * 3 = 12 Mult', function()
    T.start_run({ jokers = { 'bplus_raised_fist_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '3H', 'KS', 'AS', '7C', '9D' })
    T.eq(T.play({ 'AS' }).mult, 1 + 4 * 3)
end)

T.test('Coup: hold only Aces -> +4 * 11 = 44 Mult', function()
    T.start_run({ jokers = { 'bplus_raised_fist_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ 'AH', 'AD', 'AC', '2S' })
    T.eq(T.play({ '2S' }).mult, 1 + 4 * 11)
end)

T.test('Coup: lowest held card debuffed -> +0 Mult', function()
    T.start_run({ jokers = { 'bplus_raised_fist_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '3H', 'KS', 'AS', '7C', '9D' })
    for _, c in ipairs(G.hand.cards) do
        if c.base.id == 3 then c.ability.perma_debuff = true; c:set_debuff(true) end
    end
    T.eq(T.play({ 'AS' }).mult, 1 + 0)
end)

T.test('Coup: Raised Fist forced to "+" gives quadruple (vanilla double)', function()
    T.start_run({ jokers = { 'raised_fist' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '3H', 'KS', 'AS', '7C', '9D' })
    T.eq(T.play({ 'AS' }).mult, 1 + 2 * 3)
    T.force_behavior('raised_fist', 'plus')
    T.set_hand({ '3H', 'KS', 'AS', '7C', '9D' })
    T.eq(T.play({ 'AS' }).mult, 1 + 4 * 3)
end)

T.test('Coup JokerDisplay: holding a 3 and a King -> +12; vanilla forced to "+" shows +12; "+" forced to base shows +6', function()
    T.start_run({ jokers = { 'bplus_raised_fist_plus', 'raised_fist' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '3H', 'KS', 'AS', '7C', '9D' })
    T.eq(T.joker_display('bplus_raised_fist_plus').text, '+' .. 4 * 3)
    T.eq(T.joker_display('raised_fist').text, '+' .. 2 * 3)
    T.force_behavior('raised_fist', 'plus')
    T.eq(T.joker_display('raised_fist').text, '+' .. 4 * 3)
    T.force_behavior('bplus_raised_fist_plus', 'base')
    T.eq(T.joker_display('bplus_raised_fist_plus').text, '+' .. 2 * 3)
end)
