local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local FOUR = { '2S', '2H', '3C', '3D' }
local function begin(main, n)
    T.start_run({ jokers = { main }, hands = 6, ante = 3 })
    T.select_blind()
end
local function gain(n)
    for _ = 1, n do
        T.set_hand({ '2S', '2H', '3C', '3D', '7D' })
        T.play(FOUR)
    end
end

T.test('Square Joker Squared: play 4 cards twice -> +16 + 16 = 32 Chips (vanilla: 4 + 4)', function()
    begin('bplus_square_plus', 2)
    T.set_hand({ '2S', '2H', '3C', '3D', '7D' })
    T.eq(T.play(FOUR).chips, 20 + (2 + 2 + 3 + 3) + 16, 'Two Pair + 4 cards + first gain')
    T.set_hand({ '2S', '2H', '3C', '3D', '7D' })
    T.eq(T.play(FOUR).chips, 20 + (2 + 2 + 3 + 3) + 16 + 16)
    T.eq(T.joker(1).ability.extra.chips, 16 + 16)
end)

T.test('Square Joker Squared: play 5 cards -> no gain', function()
    begin('bplus_square_plus', 1)
    T.set_hand({ '2S', '2H', '3C', '3D', '3H' })
    T.play({ '2S', '2H', '3C', '3D', '3H' })
    T.eq(T.joker(1).ability.extra.chips, 0)
end)

T.test('Square Joker Squared: Square Joker at +8 Chips, upgrade -> Square Joker Squared keeps +8, next gain +16: 8 + 16', function()
    begin({ key = 'square', edition = 'holo' }, 3)
    gain(2)
    near(T.joker('square').ability.extra.chips, 0 + 4 * 2, 'vanilla value')
    local card = T.upgrade('square')
    near(card.ability.extra.chips, 0 + 4 * 2, 'carried over')
    T.truthy(card.edition and card.edition.holo, 'holo kept')
    gain(1)
    near(card.ability.extra.chips, 0 + 4 * 2 + 16)
end)

T.test('Square Joker Squared: square forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'square' }, 3)
    gain(1)
    near(T.joker('square').ability.extra.chips, 0 + 4)
    T.force_behavior('square', 'plus')
    gain(1)
    near(T.joker('square').ability.extra.chips, 0 + 4 + 16, 'stored on the vanilla card')
    T.force_behavior('square', nil)
    gain(1)
    near(T.joker('square').ability.extra.chips, 0 + 4 + 16 + 4)
end)

T.test('Square Joker Squared: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_square_plus' }, 3)
    gain(1)
    near(T.joker('bplus_square_plus').ability.extra.chips, 0 + 16)
    T.force_behavior('bplus_square_plus', 'base')
    gain(1)
    near(T.joker('bplus_square_plus').ability.extra.chips, 0 + 16 + 4)
    T.force_behavior('bplus_square_plus', nil)
    gain(1)
    near(T.joker('bplus_square_plus').ability.extra.chips, 0 + 16 + 4 + 16)
end)

T.test('Square Joker Squared JokerDisplay: +40 stored; vanilla forced to "+" shows its stored +24; "+" forced to base shows +40', function()
    T.start_run({ jokers = { 'bplus_square_plus', 'square' }, ante = 3 })
    T.joker(1).ability.extra.chips = 40   -- setup: stored value
    T.joker(2).ability.extra.chips = 24
    T.eq(T.joker_display('bplus_square_plus').text, '+40')
    T.eq(T.joker_display('square').text, '+24')
    T.force_behavior('square', 'plus')
    T.eq(T.joker_display('square').text, '+24')
    T.force_behavior('bplus_square_plus', 'base')
    T.eq(T.joker_display('bplus_square_plus').text, '+40')
end)
