local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local function begin(main, n)
    T.start_run({ jokers = { main, 'joker', 'joker', 'joker' }, ante = 3 })
end
local function gain(n)
    for _ = 1, n do
        next_round()
        T.select_blind()
    end
end
local function count_jokers() return #G.jokers.cards end

T.test('Lunacy: select Small Blind with 2 other jokers -> X(1 + 0.75) = X1.75, one other joker destroyed (vanilla: X1.5)', function()
    T.start_run({ jokers = { 'bplus_madness_plus', 'joker', 'joker' } })
    T.select_blind()
    T.wait_idle()
    near(T.joker(1).ability.extra.Xmult, 1 + 0.75)
    T.eq(count_jokers(), 1 + 1)
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    near(T.play({ '2S' }).mult, 1 * (1 + 0.75) + 4, 'X1.75 on the base 1 Mult, then the remaining Joker +4 Mult')
end)

T.test('Lunacy: select Boss Blind -> no gain, nothing destroyed', function()
    T.start_run({ jokers = { 'bplus_madness_plus', 'joker' } })
    T.skip_blind()
    T.skip_blind()
    T.select_blind()
    T.wait_idle()
    near(T.joker(1).ability.extra.Xmult, 1)
    T.eq(count_jokers(), 2)
end)

T.test('Lunacy: only Eternal jokers besides it -> gains, nothing destroyed', function()
    T.start_run({ jokers = { 'bplus_madness_plus', { key = 'joker', stickers = { 'eternal' } } } })
    T.select_blind()
    T.wait_idle()
    near(T.joker(1).ability.extra.Xmult, 1 + 0.75)
    T.eq(count_jokers(), 2)
end)

T.test('Lunacy: Madness at X1.5, upgrade -> Lunacy keeps X1.5, next gain +0.75: X(1.5 + 0.75)', function()
    begin({ key = 'madness', edition = 'foil' }, 3)
    gain(1)
    near(T.joker('madness').ability.x_mult, 1 + 0.5 * 1, 'vanilla value')
    local card = T.upgrade('madness')
    near(card.ability.extra.Xmult, 1 + 0.5 * 1, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.5 * 1 + 0.75)
end)

T.test('Lunacy: madness forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'madness' }, 3)
    gain(1)
    near(T.joker('madness').ability.x_mult, 1 + 0.5)
    T.force_behavior('madness', 'plus')
    gain(1)
    near(T.joker('madness').ability.x_mult, 1 + 0.5 + 0.75, 'stored on the vanilla card')
end)

T.test('Lunacy: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_madness_plus' }, 3)
    gain(1)
    near(T.joker('bplus_madness_plus').ability.extra.Xmult, 1 + 0.75)
    T.force_behavior('bplus_madness_plus', 'base')
    gain(1)
    near(T.joker('bplus_madness_plus').ability.extra.Xmult, 1 + 0.75 + 0.5)
end)

T.test('Lunacy JokerDisplay: X2.5 stored; vanilla forced to "+" shows its stored X1.5; "+" forced to base shows X2.5', function()
    T.start_run({ jokers = { 'bplus_madness_plus', 'madness' }, ante = 3 })
    T.joker(1).ability.extra.Xmult = 2.5   -- setup: stored value
    T.joker(2).ability.x_mult = 1.5
    T.eq(T.joker_display('bplus_madness_plus').text, 'X2.5')
    T.eq(T.joker_display('madness').text, 'X1.5')
    T.force_behavior('madness', 'plus')
    T.eq(T.joker_display('madness').text, 'X1.5')   -- stored value kept, shown through the "+" definition
    T.force_behavior('bplus_madness_plus', 'base')
    T.eq(T.joker_display('bplus_madness_plus').text, 'X2.5')   -- stored value kept, vanilla definition
end)
