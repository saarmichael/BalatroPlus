local T = BPlus.test

local HAND = { '7S', '7H', '2C', '3C', '4D', '5D', '9S', 'KC' }

local function list_seven()
    G.GAME.current_round.mail_card = { rank = '7', id = 7 }
end

T.test('Cashback: listed rank 7, discard two 7s -> +$6 + $6 (vanilla: +$5 + $5)', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_mail_plus' } })
    T.select_blind()
    list_seven()
    T.set_hand(HAND)
    T.discard({ '7S', '7H' })
    T.eq(G.GAME.dollars, 6 + 6)
end)

T.test('Cashback: vanilla Mail-In Rebate pays $5 + $5', function()
    T.start_run({ dollars = 0, jokers = { 'mail' } })
    T.select_blind()
    list_seven()
    T.set_hand(HAND)
    T.discard({ '7S', '7H' })
    T.eq(G.GAME.dollars, 5 + 5)
end)

T.test('Cashback: discard other ranks -> $0', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_mail_plus' } })
    T.select_blind()
    list_seven()
    T.set_hand(HAND)
    T.discard({ '2C', '3C' })
    T.eq(G.GAME.dollars, 0)
end)

T.test('Cashback: Mail-In Rebate forced to "+" pays $6 + $6', function()
    T.start_run({ dollars = 0, jokers = { 'mail' } })
    T.force_behavior('mail', 'plus')
    T.select_blind()
    list_seven()
    T.set_hand(HAND)
    T.discard({ '7S', '7H' })
    T.eq(G.GAME.dollars, 6 + 6)
end)
