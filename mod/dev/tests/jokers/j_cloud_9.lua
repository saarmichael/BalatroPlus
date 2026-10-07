local T = BPlus.test

T.test('Nine Nines: standard deck (4 nines), end round -> $3 * 4 = $12 (vanilla: $4)', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_cloud_9_plus' } })
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 3 * 4)
end)

T.test('Nine Nines: vanilla Cloud 9 pays $4', function()
    T.start_run({ dollars = 0, jokers = { 'cloud_9' } })
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 1 * 4)
end)

T.test('Nine Nines: Cloud 9 forced to "+" pays $12', function()
    T.start_run({ dollars = 0, jokers = { 'cloud_9' } })
    T.force_behavior('cloud_9', 'plus')
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 3 * 4)
end)
