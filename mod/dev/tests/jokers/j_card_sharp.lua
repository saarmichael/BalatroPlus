local T = BPlus.test

local function pair()
    T.set_hand({ '2S', '2H', '5D', '7C', '9S' })
    return T.play({ '2S', '2H' })
end

local function flush()
    T.set_hand({ '2H', '5H', '7H', '9H', 'JH' })
    return T.play({ '2H', '5H', '7H', '9H', 'JH' })
end

T.test('Card Shark: play a Pair, then another Pair -> second hand X4', function()
    T.start_run({ jokers = { 'bplus_card_sharp_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair().mult, 2)
    T.eq(pair().mult, 2 * 4)
end)

T.test('Card Shark: play a Pair, then a Flush -> no effect', function()
    T.start_run({ jokers = { 'bplus_card_sharp_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair().mult, 2)
    T.eq(flush().mult, 4)
end)

T.test('Card Shark: vanilla Card Sharp gives X3 on the repeated Pair', function()
    T.start_run({ jokers = { 'card_sharp' }, ante = 3 })
    T.select_blind()
    T.eq(pair().mult, 2)
    T.eq(pair().mult, 2 * 3)
end)

T.test('Card Shark: vanilla Card Sharp forced to "+" gives X4', function()
    T.start_run({ jokers = { 'card_sharp' }, ante = 3 })
    T.force_behavior('card_sharp', 'plus')
    T.select_blind()
    pair()
    T.eq(pair().mult, 2 * 4)
end)
