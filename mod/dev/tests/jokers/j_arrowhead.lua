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

local function highlight(...)
    for _, c in ipairs(T.hand_cards({ ... })) do G.hand:add_to_highlighted(c, true) end
end

T.test('Spearhead JokerDisplay: "+" shows +160(Spades); vanilla forced to "+" matches; "+" forced to base shows vanilla +100', function()
    T.start_run({ jokers = { 'bplus_arrowhead_plus', 'arrowhead' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KS', 'KS', '2D', '3D', '5D' })
    highlight(1, 2)
    local d = T.joker_display('bplus_arrowhead_plus')
    T.eq(d.text, '+160')
    T.eq(d.reminder, '(Spades)')
    local v = T.joker_display('arrowhead')
    T.eq(v.text, '+100')
    T.eq(v.reminder, '(Spades)')
    T.force_behavior('arrowhead', 'plus')
    v = T.joker_display('arrowhead')
    T.eq(v.text, '+160')
    T.eq(v.reminder, '(Spades)')
    T.force_behavior('bplus_arrowhead_plus', 'base')
    d = T.joker_display('bplus_arrowhead_plus')
    T.eq(d.text, '+100')
    T.eq(d.reminder, '(Spades)')
    G.hand:unhighlight_all()
end)
