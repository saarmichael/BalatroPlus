local T = BPlus.test

T.test('Jerry Seinfeld: with Oops! All 6s, a scored 5 scores 1 + 2 times', function()
    T.start_run({ jokers = { 'oops', 'bplus_hack_plus' } })
    T.select_blind()
    T.set_hand({ '5S', '9H' })
    local r = T.play({ '5S' })
    T.eq(r.chips, 5 + 5 * 3)
end)

T.test('Jerry Seinfeld: a scored 6 -> no retrigger', function()
    T.start_run({ jokers = { 'oops', 'bplus_hack_plus' } })
    T.select_blind()
    T.set_hand({ '6S', '9H' })
    local r = T.play({ '6S' })
    T.eq(r.chips, 5 + 6)
end)

T.test('Jerry Seinfeld: Hack forced to "+" with Oops! All 6s -> a scored 2 scores 1 + 2 times', function()
    T.start_run({ jokers = { 'oops', 'hack' } })
    T.select_blind()
    T.force_behavior('hack', 'plus')
    T.set_hand({ '2S', '9H' })
    local r = T.play({ '2S' })
    T.eq(r.chips, 5 + 2 * 3)
end)

T.test('Jerry Seinfeld JokerDisplay: reminder (2,3,4,5); scored 2 triggers 1 + 1 times, scored 9 once', function()
    T.start_run({ jokers = { 'bplus_hack_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '9H', '4C', '5D', '7D' })
    local two, nine
    for _, c in ipairs(G.hand.cards) do
        if c:get_id() == 2 then two = c elseif c:get_id() == 9 then nine = c end
    end
    T.eq(T.joker_display('bplus_hack_plus').reminder, '(2,3,4,5)')
    T.eq(rawget(_G, 'JokerDisplay').calculate_card_triggers(two, { two, nine }, false), 1 + 1)
    T.eq(rawget(_G, 'JokerDisplay').calculate_card_triggers(nine, { two, nine }, false), 1)
end)
