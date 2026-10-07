local T = BPlus.test

-- Three Steel cards are played (a played Steel card does nothing; held ones would give X1.5).
local function steel_hand(n)
    local specs = {}
    for i, c in ipairs({ 'AS', 'KS', '9S' }) do
        specs[i] = (i <= n) and { c, enhancement = 'steel' } or c
    end
    specs[4], specs[5] = '2C', '3D'
    T.set_hand(specs)
    return T.play({ 'AS', 'KS', '9S' })
end

T.test('Stainless Steel Joker: 3 Steel cards in deck -> X(1 + 0.4 * 3) = X2.2 (vanilla: X1.6)', function()
    T.start_run({ jokers = { 'bplus_steel_joker_plus' }, ante = 3 })
    T.select_blind()
    local r = steel_hand(3)
    T.eq(r.hand, 'High Card')
    T.near(r.mult, 1 * (1 + 0.4 * 3), 1e-6)
end)

T.test('Stainless Steel Joker: vanilla Steel Joker with 3 Steel cards -> X(1 + 0.2 * 3)', function()
    T.start_run({ jokers = { 'steel_joker' }, ante = 3 })
    T.select_blind()
    T.near(steel_hand(3).mult, 1 * (1 + 0.2 * 3), 1e-6)
end)

T.test('Stainless Steel Joker: no Steel cards -> no effect', function()
    T.start_run({ jokers = { 'bplus_steel_joker_plus' }, ante = 3 })
    T.select_blind()
    T.eq(steel_hand(0).mult, 1)
end)

T.test('Stainless Steel Joker: vanilla Steel Joker forced to "+" -> X2.2', function()
    T.start_run({ jokers = { 'steel_joker' }, ante = 3 })
    T.force_behavior('steel_joker', 'plus')
    T.select_blind()
    T.near(steel_hand(3).mult, 1 * (1 + 0.4 * 3), 1e-6)
end)

T.test('Stainless Steel Joker JokerDisplay: 3 Steel cards -> X2.2; vanilla forced to "+" shows X2.2; "+" forced to base shows X1.6', function()
    T.start_run({ jokers = { 'bplus_steel_joker_plus', 'steel_joker' }, ante = 3 })
    T.select_blind()
    steel_hand(3)
    T.eq(T.joker_display('bplus_steel_joker_plus').text, 'X' .. (1 + 0.4 * 3))
    T.eq(T.joker_display('steel_joker').text, 'X' .. (1 + 0.2 * 3))
    T.force_behavior('steel_joker', 'plus')
    T.eq(T.joker_display('steel_joker').text, 'X' .. (1 + 0.4 * 3))
    T.force_behavior('bplus_steel_joker_plus', 'base')
    T.eq(T.joker_display('bplus_steel_joker_plus').text, 'X' .. (1 + 0.2 * 3))
end)
