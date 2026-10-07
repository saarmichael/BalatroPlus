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

-- Only sets the UI selection (nothing is played); JokerDisplay reads G.hand.highlighted.
local function highlight(specs)
    for _, c in ipairs(T.hand_cards(specs)) do G.hand:add_to_highlighted(c, true) end
end

T.test('Cashback JokerDisplay: listed 7, two 7s selected -> +$12 (7); vanilla forced to "+" +$12; "+" forced to base +$10', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_mail_plus', 'mail' } })
    T.select_blind()
    list_seven()
    T.set_hand(HAND)
    T.eq(T.joker_display('bplus_mail_plus').text, '+$0')
    T.eq(T.joker_display('bplus_mail_plus').reminder, '(7)')
    highlight({ '7S', '7H' })
    T.eq(T.joker_display('bplus_mail_plus').text, '+$' .. (6 + 6))
    T.eq(T.joker_display('mail').text, '+$' .. (5 + 5))
    T.force_behavior('mail', 'plus')
    T.eq(T.joker_display('mail').text, '+$' .. (6 + 6))
    T.force_behavior('bplus_mail_plus', 'base')
    T.eq(T.joker_display('bplus_mail_plus').text, '+$' .. (5 + 5))
end)
