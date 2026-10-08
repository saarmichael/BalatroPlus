local T = BPlus.test

local function play_one()
    T.set_hand({ '2S', '3H', '5D', '7C', '9S' })
    return T.play({ '2S' })
end

T.test('Slabbed Baseball Card: with 2 Uncommon jokers -> X2 * X2', function()
    T.start_run({ jokers = { 'bplus_baseball_plus', 'four_fingers', 'pareidolia' }, ante = 3 })
    T.select_blind()
    T.eq(play_one().mult, 1 * 2 * 2)
end)

T.test('Slabbed Baseball Card: vanilla Baseball Card with 2 Uncommon jokers -> X1.5 * X1.5', function()
    T.start_run({ jokers = { 'baseball', 'four_fingers', 'pareidolia' }, ante = 3 })
    T.select_blind()
    T.eq(play_one().mult, 1 * 1.5 * 1.5)
end)

T.test('Slabbed Baseball Card: with only Common jokers -> no effect', function()
    T.start_run({ jokers = { 'bplus_baseball_plus', 'credit_card', 'chaos' }, ante = 3 })
    T.select_blind()
    T.eq(play_one().mult, 1)
end)

T.test("Slabbed Baseball Card: an Uncommon '+' joker also gets X2", function()
    T.start_run({ jokers = { 'bplus_baseball_plus', 'bplus_acrobat_plus' }, ante = 3 })
    T.select_blind()
    -- Nadia Comaneci is Uncommon and not on the final hand, so only the Baseball Card's X2 applies
    T.eq(play_one().mult, 1 * 2)
end)

T.test('Slabbed Baseball Card: vanilla Baseball Card forced to "+" -> X2 * X2', function()
    T.start_run({ jokers = { 'baseball', 'four_fingers', 'pareidolia' }, ante = 3 })
    T.force_behavior('baseball', 'plus')
    T.select_blind()
    T.eq(play_one().mult, 1 * 2 * 2)
end)

T.test('Slabbed Baseball Card JokerDisplay: reminder (2xUncommon); vanilla forced to "+" and "+" forced to base keep the reminder', function()
    T.start_run({ jokers = { 'bplus_baseball_plus', 'four_fingers', 'pareidolia', 'baseball' }, ante = 3 })
    T.eq(T.joker_display('bplus_baseball_plus').reminder, '(2xUncommon)')
    T.eq(T.joker_display('four_fingers').values.x_mult, nil)
    T.force_behavior('baseball', 'plus')
    T.eq(T.joker_display('baseball').reminder, '(2xUncommon)')
    T.force_behavior('bplus_baseball_plus', 'base')
    T.eq(T.joker_display('bplus_baseball_plus').reminder, '(2xUncommon)')
end)
