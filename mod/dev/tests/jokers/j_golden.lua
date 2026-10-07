local T = BPlus.test

T.test('Golden Joker+: end round -> +$8 (vanilla: +$4)', function()
    -- $0: no interest. Blind $3 + $1 per unused hand (4) + $8
    T.start_run({ dollars = 0, jokers = { 'bplus_golden_plus' } })
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 8)
end)

T.test('Golden Joker+: vanilla Golden Joker forced to "+" earns $8', function()
    T.start_run({ dollars = 0, jokers = { 'golden' } })
    T.force_behavior('golden', 'plus')
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 8)
end)

T.test('Golden Joker+ JokerDisplay: +$8 (Round); vanilla forced to "+" shows +$8; "+" forced to base shows +$4', function()
    T.start_run({ jokers = { 'bplus_golden_plus', 'golden' } })
    local d = T.joker_display('bplus_golden_plus')
    T.eq(d.text, '+$8')
    T.eq(d.reminder, '(Round)')
    T.eq(T.joker_display('golden').text, '+$4')
    T.force_behavior('golden', 'plus')
    T.eq(T.joker_display('golden').text, '+$8')
    T.force_behavior('bplus_golden_plus', 'base')
    T.eq(T.joker_display('bplus_golden_plus').text, '+$4')
end)
