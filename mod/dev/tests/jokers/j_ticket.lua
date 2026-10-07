local T = BPlus.test

local GOLD = { { 'KH', enhancement = 'gold' }, { 'KS', enhancement = 'gold' }, '9D', '5C', '2D' }

T.test('Goldbars: score 2 Gold cards -> +$5 + $5 (vanilla: +$4 + $4)', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'bplus_ticket_plus' } })
    T.select_blind()
    T.set_hand(GOLD)
    T.eq(T.play({ 'KH', 'KS' }).dollars, 5 + 5)
end)

T.test('Goldbars: vanilla Golden Ticket pays $4 + $4', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'ticket' } })
    T.select_blind()
    T.set_hand(GOLD)
    T.eq(T.play({ 'KH', 'KS' }).dollars, 4 + 4)
end)

T.test('Goldbars: non-Gold cards earn nothing', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'bplus_ticket_plus' } })
    T.select_blind()
    T.set_hand(GOLD)
    T.eq(T.play({ '9D', '5C' }).dollars, 0)
end)

T.test('Goldbars: Golden Ticket forced to "+" pays $5 + $5', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'ticket' } })
    T.force_behavior('ticket', 'plus')
    T.select_blind()
    T.set_hand(GOLD)
    T.eq(T.play({ 'KH', 'KS' }).dollars, 5 + 5)
end)
