local T = BPlus.test

-- Hanged Man destroys the selected hand cards; no set_hand in between (it would create cards
-- when the hand is smaller than the spec list, which changes the deck size).
T.test('Landslide: remove 5 cards from a 52-card deck -> +8 * 5 = 40 Mult', function()
    T.start_run({ jokers = { 'bplus_erosion_plus' }, consumables = { 'hanged_man', 'hanged_man', 'hanged_man' },
        consumable_slots = 3, hands = 5, ante = 3 })
    T.select_blind()
    T.use('hanged_man', { 1, 2 })
    T.use('hanged_man', { 1, 2 })
    T.use('hanged_man', { 1 })
    T.eq(#G.playing_cards, 52 - 5)
    T.eq(T.play({ 1 }).mult, 1 + 8 * 5)
end)

T.test('Landslide: full 52-card deck -> +0 Mult', function()
    T.start_run({ jokers = { 'bplus_erosion_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.eq(T.play({ 1 }).mult, 1 + 0)
end)

T.test('Landslide: Erosion forced to "+" gives +8 per missing card (vanilla +4)', function()
    T.start_run({ jokers = { 'erosion' }, consumables = { 'hanged_man' }, hands = 5, ante = 3 })
    T.select_blind()
    T.use('hanged_man', { 1, 2 })
    T.eq(#G.playing_cards, 52 - 2)
    T.eq(T.play({ 1 }).mult, 1 + 4 * 2)
    T.force_behavior('erosion', 'plus')
    T.eq(T.play({ 1 }).mult, 1 + 8 * 2)
end)

T.test('Landslide JokerDisplay: 2 cards removed -> +16; vanilla forced to "+" shows +16; "+" forced to base shows +8', function()
    T.start_run({ jokers = { 'bplus_erosion_plus', 'erosion' }, consumables = { 'hanged_man' }, hands = 5, ante = 3 })
    T.select_blind()
    T.use('hanged_man', { 1, 2 })
    T.eq(T.joker_display('bplus_erosion_plus').text, '+' .. 8 * 2)
    T.eq(T.joker_display('erosion').text, '+' .. 4 * 2)
    T.force_behavior('erosion', 'plus')
    T.eq(T.joker_display('erosion').text, '+' .. 8 * 2)
    T.force_behavior('bplus_erosion_plus', 'base')
    T.eq(T.joker_display('bplus_erosion_plus').text, '+' .. 4 * 2)
end)
