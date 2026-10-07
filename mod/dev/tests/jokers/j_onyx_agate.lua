local T = BPlus.test

local function pair()
    T.set_hand({ 'KC', 'KC', '2H', '3H', '5H' })
    return T.play({ 1, 2 })
end

T.test('Obsidian: Pair of Clubs -> +15 + 15 Mult (vanilla: +7 + 7)', function()
    T.start_run({ jokers = { 'bplus_onyx_agate_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair().mult, 2 + 15 + 15)
end)

T.test('Obsidian: vanilla Onyx Agate gives +7 + 7 Mult', function()
    T.start_run({ jokers = { 'onyx_agate' }, ante = 3 })
    T.select_blind()
    T.eq(pair().mult, 2 + 7 + 7)
end)

T.test('Obsidian: vanilla forced to "+" gives +15 + 15 Mult', function()
    T.start_run({ jokers = { 'onyx_agate' }, ante = 3 })
    T.select_blind()
    T.force_behavior('onyx_agate', 'plus')
    T.eq(pair().mult, 2 + 15 + 15)
end)

local function highlight(...)
    for _, c in ipairs(T.hand_cards({ ... })) do G.hand:add_to_highlighted(c, true) end
end

T.test('Obsidian JokerDisplay: "+" shows +30(Clubs); vanilla forced to "+" matches; "+" forced to base shows vanilla +14', function()
    T.start_run({ jokers = { 'bplus_onyx_agate_plus', 'onyx_agate' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KC', 'KC', '2D', '3D', '5D' })
    highlight(1, 2)
    local d = T.joker_display('bplus_onyx_agate_plus')
    T.eq(d.text, '+30')
    T.eq(d.reminder, '(Clubs)')
    local v = T.joker_display('onyx_agate')
    T.eq(v.text, '+14')
    T.eq(v.reminder, '(Clubs)')
    T.force_behavior('onyx_agate', 'plus')
    v = T.joker_display('onyx_agate')
    T.eq(v.text, '+30')
    T.eq(v.reminder, '(Clubs)')
    T.force_behavior('bplus_onyx_agate_plus', 'base')
    d = T.joker_display('bplus_onyx_agate_plus')
    T.eq(d.text, '+14')
    T.eq(d.reminder, '(Clubs)')
    G.hand:unhighlight_all()
end)
