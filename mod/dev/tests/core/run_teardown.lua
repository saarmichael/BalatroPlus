local T = BPlus.test

T.test('Run teardown: starting a new run with cards selected and switched jokers on the table does not crash', function()
    T.start_run({ jokers = { 'bplus_half_plus', 'half' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2H', '5H', '7H', '9H', 'JH' })
    T.force_behavior('half', 'plus')
    T.force_behavior('bplus_half_plus', 'base')
    T.eq(#T.highlight({ 1, 2, 3, 4, 5 }), 5)
    T.eq(#G.hand.highlighted, 5)
    T.start_run({ jokers = { 'half' } })
    T.eq(#G.jokers.cards, 1)
    T.eq(#G.hand.highlighted, 0)
end)
