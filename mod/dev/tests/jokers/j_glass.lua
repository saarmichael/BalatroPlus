local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local GLASS = { 'KH', 'KS', 'KD', 'QC', 'QH' }
-- two Oops! All 6s make every Glass roll shatter (4 in 4)
local function begin(main, n)
    T.start_run({ jokers = { main, 'oops', 'oops' }, hands = 6, ante = 3 })
    T.select_blind()
end
local function gain(n)
    local specs = {}
    for i = 1, 5 do specs[i] = { GLASS[i], enhancement = 'glass' } end
    T.set_hand(specs)
    local play = {}
    for i = 1, n do play[i] = GLASS[i] end
    T.play(play)
end

T.test('Plexiglass Joker: 2 Glass cards shatter -> X(1 + 1.5 * 2) = X4 (vanilla: X2.5)', function()
    begin('bplus_glass_plus', 2)
    gain(2)
    near(T.joker(1).ability.extra.Xmult, 1 + 1.5 * 2)
end)

T.test('Plexiglass Joker: destroying Glass cards with The Hanged Man also counts', function()
    T.start_run({ jokers = { 'bplus_glass_plus' }, consumables = { 'hanged_man' }, ante = 3 })
    T.select_blind()
    T.set_hand({ { 'KH', enhancement = 'glass' }, { 'KS', enhancement = 'glass' }, '2C', '3D', '4D' })
    T.use('hanged_man', { 'KH', 'KS' })
    near(T.joker(1).ability.extra.Xmult, 1 + 1.5 * 2)
end)

T.test('Plexiglass Joker: Glass Joker at X2.5 (two Glass shattered), upgrade -> Plexiglass Joker keeps X2.5, next gain +1.5: X(2.5 + 1.5)', function()
    begin({ key = 'glass', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('glass').ability.x_mult, 1 + 0.75 * 2, 'vanilla value')
    local card = T.upgrade('glass')
    near(card.ability.extra.Xmult, 1 + 0.75 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.75 * 2 + 1.5)
end)

T.test('Plexiglass Joker: glass forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'glass' }, 3)
    gain(1)
    near(T.joker('glass').ability.x_mult, 1 + 0.75)
    T.force_behavior('glass', 'plus')
    gain(1)
    near(T.joker('glass').ability.x_mult, 1 + 0.75 + 1.5, 'stored on the vanilla card')
    T.force_behavior('glass', nil)
    gain(1)
    near(T.joker('glass').ability.x_mult, 1 + 0.75 + 1.5 + 0.75)
end)

T.test('Plexiglass Joker: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_glass_plus' }, 3)
    gain(1)
    near(T.joker('bplus_glass_plus').ability.extra.Xmult, 1 + 1.5)
    T.force_behavior('bplus_glass_plus', 'base')
    gain(1)
    near(T.joker('bplus_glass_plus').ability.extra.Xmult, 1 + 1.5 + 0.75)
    T.force_behavior('bplus_glass_plus', nil)
    gain(1)
    near(T.joker('bplus_glass_plus').ability.extra.Xmult, 1 + 1.5 + 0.75 + 1.5)
end)

T.test('Plexiglass Joker JokerDisplay: X2.5 stored; vanilla forced to "+" shows its stored X1.5; "+" forced to base shows X2.5', function()
    T.start_run({ jokers = { 'bplus_glass_plus', 'glass' }, ante = 3 })
    T.joker(1).ability.extra.Xmult = 2.5   -- setup: stored value
    T.joker(2).ability.x_mult = 1.5
    T.eq(T.joker_display('bplus_glass_plus').text, 'X2.5')
    T.eq(T.joker_display('glass').text, 'X1.5')
    T.force_behavior('glass', 'plus')
    T.eq(T.joker_display('glass').text, 'X1.5')   -- stored value kept, shown through the "+" definition
    T.force_behavior('bplus_glass_plus', 'base')
    T.eq(T.joker_display('bplus_glass_plus').text, 'X2.5')   -- stored value kept, vanilla definition
end)
