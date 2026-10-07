local T = BPlus.test

T.test('Abstract Abstract Joker: 3 jokers incl. this one -> +10 * 3 = 30 Mult', function()
    T.start_run({ jokers = { 'bplus_abstract_plus', 'greedy_joker', 'banner' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    -- Banner: +30 Chips per discard left is chips only; the mult is base 1 + 30
    T.eq(T.play({ '2S' }).mult, 1 + 10 * 3)
end)

T.test('Abstract Abstract Joker: alone -> +10 * 1 = 10 Mult', function()
    T.start_run({ jokers = { 'bplus_abstract_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 10 * 1)
end)

T.test('Abstract Abstract Joker: vanilla Abstract Joker forced to "+" gives +10 per joker (vanilla +3)', function()
    T.start_run({ jokers = { 'abstract', 'banner' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 3 * 2)
    T.force_behavior('abstract', 'plus')
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 10 * 2)
end)
