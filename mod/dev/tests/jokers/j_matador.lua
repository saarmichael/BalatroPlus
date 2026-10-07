local T = BPlus.test

local function to_psychic(key)
    T.start_run({ dollars = 0, ante = 3, boss = 'psychic', jokers = { key } })
    T.skip_blind(); T.skip_blind()
    T.select_blind()
end

local FIVE = { 'KS', 'KH', '9D', '5C', '2D' }

T.test('Toreador: play a hand that triggers The Psychic (fewer than 5 cards) -> +$20 (vanilla: +$8)', function()
    to_psychic('bplus_matador_plus')
    T.set_hand(FIVE)
    T.eq(T.play({ 'KS' }).dollars, 20)
end)

T.test('Toreador: vanilla Matador pays $8', function()
    to_psychic('matador')
    T.set_hand(FIVE)
    T.eq(T.play({ 'KS' }).dollars, 8)
end)

T.test('Toreador: boss ability not triggered (5 cards) -> $0', function()
    to_psychic('bplus_matador_plus')
    T.set_hand(FIVE)
    T.eq(T.play(FIVE).dollars, 0)
end)

T.test('Toreador: Matador forced to "+" pays $20', function()
    to_psychic('matador')
    T.force_behavior('matador', 'plus')
    T.set_hand(FIVE)
    T.eq(T.play({ 'KS' }).dollars, 20)
end)
