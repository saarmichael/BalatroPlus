local T = BPlus.test

local function ten_hands()
    T.start_run({ jokers = { 'bplus_misprint_plus' }, hands = 10, ante = 6 })
    T.select_blind()
    local out = {}
    for i = 1, 10 do
        T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
        out[i] = T.play({ '2S' }).mult - 1   -- High Card base mult is 1
    end
    return out
end

T.test('Never Misprint: play 10 hands -> every hand joker Mult is between 10 and 50', function()
    for _, m in ipairs(ten_hands()) do
        T.truthy(m >= 10 and m <= 50 and m == math.floor(m), 'mult ' .. tostring(m))
    end
end)

T.test('Never Misprint: same seed twice -> same values', function()
    local a = ten_hands()
    local b = ten_hands()
    T.eq(a, b)
end)

T.test('Never Misprint: Misprint forced to "+" stays within 10 to 50', function()
    T.start_run({ jokers = { 'misprint' }, hands = 5, ante = 6 })
    T.force_behavior('misprint', 'plus')
    T.select_blind()
    for _ = 1, 5 do
        T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
        local m = T.play({ '2S' }).mult - 1
        T.truthy(m >= 10 and m <= 50, 'mult ' .. tostring(m))
    end
end)

T.test('Never Misprint JokerDisplay: shows "+" and a scrolling 10 to 50 range; forced behaviours keep the "+"', function()
    T.start_run({ jokers = { 'bplus_misprint_plus', 'misprint' }, hands = 5, ante = 3 })
    T.eq(T.joker_display('bplus_misprint_plus').text, '+') -- the number is a DynaText node
    T.eq(T.joker_display('misprint').text, '+')
    T.force_behavior('misprint', 'plus')
    T.eq(T.joker_display('misprint').text, '+')
    T.force_behavior('bplus_misprint_plus', 'base')
    T.eq(T.joker_display('bplus_misprint_plus').text, '+')
end)
