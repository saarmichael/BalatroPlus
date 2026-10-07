local T = BPlus.test

local function pair()
    T.set_hand({ 'KD', 'KD', '2C', '3C', '5C' })
    return T.play({ 1, 2 })
end

T.test('Gemstone: Pair of Diamonds -> +$2 + $2 (vanilla: +$1 + $1)', function()
    T.start_run({ jokers = { 'bplus_rough_gem_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair().dollars, 2 + 2)
end)

T.test('Gemstone: vanilla Rough Gem gives +$1 + $1', function()
    T.start_run({ jokers = { 'rough_gem' }, ante = 3 })
    T.select_blind()
    T.eq(pair().dollars, 1 + 1)
end)

T.test('Gemstone: vanilla forced to "+" gives +$2 + $2', function()
    T.start_run({ jokers = { 'rough_gem' }, ante = 3 })
    T.select_blind()
    T.force_behavior('rough_gem', 'plus')
    T.eq(pair().dollars, 2 + 2)
end)
