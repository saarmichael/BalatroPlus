local T = BPlus.test

-- 9 cards in hand, one is played (a 2 of Diamonds), 8 are held.
local function play_with_held(held)
    local specs = { '2D' }
    for _, s in ipairs(held) do specs[#specs + 1] = s end
    T.set_hand(specs)
    return T.play({ '2D' })
end

local function start(joker)
    T.start_run({ jokers = { joker }, ante = 3, hand_size = 9 })
    T.select_blind()
end

-- High Card: 1 Mult base
T.test('Smartboard: hold 5 Spades/Clubs + 3 Hearts -> X4', function()
    start('bplus_blackboard_plus')
    local r = play_with_held({ 'AS', 'KS', 'QC', 'JC', '9S', '3H', '4H', '5H' })
    T.eq(r.mult, 1 * 4)
end)

T.test('Smartboard: hold 4 Spades + 4 Hearts (exactly half) -> no trigger', function()
    start('bplus_blackboard_plus')
    local r = play_with_held({ 'AS', 'KS', 'QS', 'JS', '3H', '4H', '5H', '6H' })
    T.eq(r.mult, 1)
end)

T.test('Smartboard: hold only Hearts -> no trigger', function()
    start('bplus_blackboard_plus')
    local r = play_with_held({ 'AH', 'KH', 'QH', 'JH', '3H', '4H', '5H', '6H' })
    T.eq(r.mult, 1)
end)

T.test('Smartboard: hold all Spades -> X4 (vanilla Blackboard: X3)', function()
    start('bplus_blackboard_plus')
    local r = play_with_held({ 'AS', 'KS', 'QS', 'JS', '3S', '4S', '5S', '6S' })
    T.eq(r.mult, 1 * 4)
    start('blackboard')
    r = play_with_held({ 'AS', 'KS', 'QS', 'JS', '3S', '4S', '5S', '6S' })
    T.eq(r.mult, 1 * 3)
end)

T.test('Smartboard: vanilla forced to "+" triggers on a majority', function()
    start('blackboard')
    T.force_behavior('blackboard', 'plus')
    local r = play_with_held({ 'AS', 'KS', 'QC', 'JC', '9S', '3H', '4H', '5H' })
    T.eq(r.mult, 1 * 4)
end)

T.test('Smartboard: "+" forced to base needs every held card black', function()
    start('bplus_blackboard_plus')
    T.force_behavior(1, 'base')
    local r = play_with_held({ 'AS', 'KS', 'QC', 'JC', '9S', '3H', '4H', '5H' })
    T.eq(r.mult, 1)
end)

local function highlight(...)
    for _, c in ipairs(T.hand_cards({ ... })) do G.hand:add_to_highlighted(c, true) end
end

T.test('Smartboard JokerDisplay: "+" shows X4; vanilla forced to "+" matches; "+" forced to base shows vanilla X3', function()
    T.start_run({ jokers = { 'bplus_blackboard_plus', 'blackboard' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KS', 'KC', '2S', '3C', '5S' })
    highlight()
    local d = T.joker_display('bplus_blackboard_plus')
    T.eq(d.text, 'X4')
    T.eq(d.reminder, '')
    local v = T.joker_display('blackboard')
    T.eq(v.text, 'X3')
    T.eq(v.reminder, '')
    T.force_behavior('blackboard', 'plus')
    v = T.joker_display('blackboard')
    T.eq(v.text, 'X4')
    T.eq(v.reminder, '')
    T.force_behavior('bplus_blackboard_plus', 'base')
    d = T.joker_display('bplus_blackboard_plus')
    T.eq(d.text, 'X3')
    T.eq(d.reminder, '')
    G.hand:unhighlight_all()
end)
