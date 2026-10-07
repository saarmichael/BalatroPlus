local T = BPlus.test

local function use_planets()
    T.use('mercury'); T.use('mercury'); T.use('venus')
end

T.test('Space Station: used Mercury, Venus, Mercury -> 2 unique, end round -> $2 * 2 = $4 (vanilla: $2)', function()
    T.start_run({ dollars = 0, consumable_slots = 3, consumables = { 'mercury', 'venus', 'mercury' },
        jokers = { 'bplus_satellite_plus' } })
    use_planets()
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 2 * 2)
end)

T.test('Space Station: vanilla Satellite pays $1 * 2', function()
    T.start_run({ dollars = 0, consumable_slots = 3, consumables = { 'mercury', 'venus', 'mercury' },
        jokers = { 'satellite' } })
    use_planets()
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 1 * 2)
end)

T.test('Space Station: no Planet used -> $0', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_satellite_plus' } })
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4)
end)

T.test('Space Station: Satellite forced to "+" pays $2 * 2', function()
    T.start_run({ dollars = 0, consumable_slots = 3, consumables = { 'mercury', 'venus', 'mercury' },
        jokers = { 'satellite' } })
    T.force_behavior('satellite', 'plus')
    use_planets()
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 2 * 2)
end)

T.test('Space Station JokerDisplay: 2 unique Planets used -> +$4 (Round); vanilla forced to "+" +$4; "+" forced to base +$2', function()
    T.start_run({ dollars = 0, consumable_slots = 3, consumables = { 'mercury', 'venus', 'mercury' },
        jokers = { 'bplus_satellite_plus', 'satellite' } })
    use_planets()
    local d = T.joker_display('bplus_satellite_plus')
    T.eq(d.text, '+$' .. (2 * 2))
    T.eq(d.reminder, '(Round)')
    T.eq(T.joker_display('satellite').text, '+$' .. (1 * 2))
    T.force_behavior('satellite', 'plus')
    T.eq(T.joker_display('satellite').text, '+$' .. (2 * 2))
    T.force_behavior('bplus_satellite_plus', 'base')
    T.eq(T.joker_display('bplus_satellite_plus').text, '+$' .. (1 * 2))
end)
