local T = BPlus.test

T.test('Buccaneer: with Joker (sell $1) and Golden Joker (sell $3) -> +2 * (1 + 3) = 8 Mult', function()
    T.start_run({ jokers = { 'bplus_swashbuckler_plus', 'joker', 'golden' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 4 + 2 * (1 + 3))   -- base 1, Joker +4, Buccaneer
end)

T.test('Buccaneer: alone -> +0 Mult', function()
    T.start_run({ jokers = { 'bplus_swashbuckler_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 0)
end)

T.test('Buccaneer: Swashbuckler forced to "+" doubles, forced "base" on the "+" joker halves again', function()
    T.start_run({ jokers = { 'swashbuckler', 'golden' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 3)
    T.force_behavior('swashbuckler', 'plus')
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 2 * 3)
end)

T.test('Buccaneer: "+" joker forced to "base" behaves as vanilla Swashbuckler', function()
    T.start_run({ jokers = { 'bplus_swashbuckler_plus', 'golden' }, hands = 5, ante = 3 })
    T.force_behavior(1, 'base')
    T.select_blind()
    T.wait_frames(5)
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    T.eq(T.play({ '2S' }).mult, 1 + 3)
end)
