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

T.test('Nine Nines JokerDisplay: 4 nines in deck -> +$12 (Round); vanilla forced to "+" +$12; "+" forced to base +$4', function()
    T.start_run({ jokers = { 'bplus_cloud_9_plus', 'cloud_9' } })
    local n = 0
    for _, c in ipairs(G.playing_cards) do if c:get_id() == 9 then n = n + 1 end end
    T.eq(n, 4)
    local d = T.joker_display('bplus_cloud_9_plus')
    T.eq(d.text, '+$' .. (3 * 4))
    T.eq(d.reminder, '(Round)')
    T.eq(T.joker_display('cloud_9').text, '+$' .. (1 * 4))
    T.force_behavior('cloud_9', 'plus')
    T.eq(T.joker_display('cloud_9').text, '+$' .. (3 * 4))
    T.force_behavior('bplus_cloud_9_plus', 'base')
    T.eq(T.joker_display('bplus_cloud_9_plus').text, '+$' .. (1 * 4))
end)
