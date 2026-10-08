local T = BPlus.test

-- Four Aces: Four of a Kind (60 chips x 7 mult) + 4 * 11 chips = 104 chips; the blind (300) is won.
local function final_hand()
    T.set_hand({ 'AS', 'AH', 'AD', 'AC', '2S' })
    return T.play({ 'AS', 'AH', 'AD', 'AC' })
end

T.test('Nadia Comaneci: play the last hand of the round -> X4 (vanilla Acrobat: X3)', function()
    T.start_run({ jokers = { 'bplus_acrobat_plus' }, hands = 2 })
    T.select_blind()
    T.eq(T.play({ 1 }).mult, 1)
    local r = final_hand()
    T.eq(r.hand, 'Four of a Kind')
    T.eq(r.mult, 7 * 4)
end)

T.test('Nadia Comaneci: play a hand with hands left -> no effect', function()
    T.start_run({ jokers = { 'bplus_acrobat_plus' }, hands = 3, ante = 3 })
    T.select_blind()
    T.eq(T.play({ 1 }).mult, 1)
    T.eq(T.play({ 1 }).mult, 1)
end)

T.test('Nadia Comaneci: vanilla Acrobat on the last hand -> X3', function()
    T.start_run({ jokers = { 'acrobat' }, hands = 1 })
    T.select_blind()
    T.eq(final_hand().mult, 7 * 3)
end)

T.test('Nadia Comaneci: vanilla Acrobat forced to "+" -> X4 on the last hand', function()
    T.start_run({ jokers = { 'acrobat' }, hands = 1 })
    T.force_behavior('acrobat', 'plus')
    T.select_blind()
    T.eq(final_hand().mult, 7 * 4)
end)

T.test('Nadia Comaneci JokerDisplay: X1 with hands left; X4 on the last hand; vanilla forced to "+" shows X4; "+" forced to base shows X3', function()
    T.start_run({ jokers = { 'bplus_acrobat_plus', 'acrobat' }, hands = 1, ante = 3 })
    T.select_blind()
    T.eq(T.joker_display('bplus_acrobat_plus').text, 'X4')
    T.eq(T.joker_display('acrobat').text, 'X3')
    T.force_behavior('acrobat', 'plus')
    T.eq(T.joker_display('acrobat').text, 'X4')
    T.force_behavior('bplus_acrobat_plus', 'base')
    T.eq(T.joker_display('bplus_acrobat_plus').text, 'X3')
end)
