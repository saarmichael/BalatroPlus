local T = BPlus.test

-- The Idol's card is rolled when the blind starts; pin it to the 7 of Spades for exact scoring.
local function pin_seven()
    G.GAME.current_round.idol_card = { rank = '7', suit = 'Spades', id = 7 }
end

local function pair_of_sevens()
    T.set_hand({ '7S', '7H', '2D', '3C', '5H' })
    return T.play({ '7S', '7H' })
end

T.test('The Deity: chosen card is a 7 -> a Pair of 7s in two suits gives X2 * X2', function()
    T.start_run({ jokers = { 'bplus_idol_plus' }, ante = 3 })
    T.select_blind()
    pin_seven()
    local r = pair_of_sevens()
    T.eq(r.hand, 'Pair')
    T.eq(r.chips, 10 + 7 + 7)
    T.eq(r.mult, 2 * 2 * 2)
end)

T.test('The Deity: vanilla The Idol only counts the 7 of Spades -> X2 once', function()
    T.start_run({ jokers = { 'idol' }, ante = 3 })
    T.select_blind()
    pin_seven()
    T.eq(pair_of_sevens().mult, 2 * 2)
end)

T.test('The Deity: playing a different rank -> no effect', function()
    T.start_run({ jokers = { 'bplus_idol_plus' }, ante = 3 })
    T.select_blind()
    pin_seven()
    T.set_hand({ '2D', '3C', '5H', '9S', 'JD' })
    T.eq(T.play({ '2D' }).mult, 1)
end)

T.test('The Deity: vanilla The Idol forced to "+" -> both 7s score X2', function()
    T.start_run({ jokers = { 'idol' }, ante = 3 })
    T.force_behavior('idol', 'plus')
    T.select_blind()
    pin_seven()
    T.eq(pair_of_sevens().mult, 2 * 2 * 2)
end)

T.test('The Deity: the card is rolled by vanilla every round', function()
    T.start_run({ jokers = { 'bplus_idol_plus' }, ante = 3 })
    T.select_blind()
    local idol = G.GAME.current_round.idol_card
    T.truthy(idol.id and idol.id >= 2 and idol.id <= 14, 'a rank id was chosen at round start')
end)

T.test('The Deity JokerDisplay: chosen 7, pair of 7s highlighted -> X4 (7); vanilla forced to "+" shows X4; "+" forced to base shows X2 (7 of Spades)', function()
    T.start_run({ jokers = { 'bplus_idol_plus', 'idol' }, ante = 3 })
    T.select_blind()
    pin_seven()
    T.set_hand({ '7S', '7H', '2D', '3C', '5H' })
    G.hand:unhighlight_all()
    for _, c in ipairs(T.hand_cards({ '7S', '7H' })) do G.hand:add_to_highlighted(c, true) end
    local d = T.joker_display('bplus_idol_plus')
    T.eq(d.text, 'X' .. (2 * 2))
    T.eq(d.reminder, '(7)')
    d = T.joker_display('idol')
    T.eq(d.text, 'X2')
    T.eq(d.reminder, '(7 of Spades)')
    T.force_behavior('idol', 'plus')
    d = T.joker_display('idol')
    T.eq(d.text, 'X' .. (2 * 2))
    T.eq(d.reminder, '(7)')
    T.force_behavior('bplus_idol_plus', 'base')
    d = T.joker_display('bplus_idol_plus')
    T.eq(d.text, 'X2')
    T.eq(d.reminder, '(7 of Spades)')
end)
