local T = BPlus.test

T.test('Joker+: alone, play a Pair of 2s -> +20 Mult (vanilla Joker: +4)', function()
    T.start_run({ jokers = { 'bplus_joker_plus' } })
    T.select_blind()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    local r = T.play({ '2S', '2H' })
    T.eq(r.hand, 'Pair')
    T.eq(r.chips, 10 + 2 + 2)
    T.eq(r.mult, 2 + 20)
end)
