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

T.test('Card Shark JokerDisplay: X1 before a repeat, X4 after one Pair played; vanilla forced to "+" shows X4; "+" forced to base shows X3', function()
    T.start_run({ jokers = { 'bplus_card_sharp_plus', 'card_sharp' }, ante = 3 })
    T.select_blind()
    T.eq(T.joker_display('bplus_card_sharp_plus').text, 'X1')
    pair()
    T.set_hand({ '2S', '2H', '5D', '7C', '9S' })
    G.hand:unhighlight_all()
    for _, c in ipairs(T.hand_cards({ '2S', '2H' })) do G.hand:add_to_highlighted(c, true) end
    T.eq(T.joker_display('bplus_card_sharp_plus').text, 'X4')
    T.eq(T.joker_display('card_sharp').text, 'X3')
    T.force_behavior('card_sharp', 'plus')
    T.eq(T.joker_display('card_sharp').text, 'X4')
    T.force_behavior('bplus_card_sharp_plus', 'base')
    T.eq(T.joker_display('bplus_card_sharp_plus').text, 'X3')
end)
