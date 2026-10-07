local T = BPlus.test

local function pair()
    T.set_hand({ 'KS', 'KS', '2H', '3H', '5H' })
    return T.play({ 1, 2 })
end

T.test('Spearhead: Pair of Spades -> +80 + 80 Chips (vanilla: +50 + 50)', function()
    T.start_run({ jokers = { 'bplus_arrowhead_plus' }, ante = 3 })
    T.select_blind()
    local r = pair()
    T.eq(r.chips, 10 + 10 + 10 + 80 + 80)
end)

T.test('Spearhead: vanilla Arrowhead gives +50 + 50 Chips', function()
    T.start_run({ jokers = { 'arrowhead' }, ante = 3 })
    T.select_blind()
    T.eq(pair().chips, 10 + 10 + 10 + 50 + 50)
end)

T.test('Spearhead: vanilla forced to "+" gives +80 + 80 Chips', function()
    T.start_run({ jokers = { 'arrowhead' }, ante = 3 })
    T.select_blind()
    T.force_behavior('arrowhead', 'plus')
    T.eq(pair().chips, 10 + 10 + 10 + 80 + 80)
end)
