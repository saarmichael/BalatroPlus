local T = BPlus.test

local function sell_value(card) return card.sell_cost end

T.test('Free Range Egg: end 2 rounds -> sell value = base sell value + 5 + 5', function()
    T.start_run({ jokers = { 'bplus_egg_plus' } })
    local egg = T.joker(1)
    local base = sell_value(egg)
    T.to_shop()
    T.eq(sell_value(egg), base + 5)
    T.leave_shop()
    T.to_shop()
    T.eq(sell_value(egg), base + 5 + 5)
end)

T.test('Free Range Egg: Egg after 2 rounds (+3 + 3), upgrade -> keeps sell value, then +5 per round', function()
    T.start_run({ jokers = { 'egg' } })
    local egg = T.joker(1)
    local base = sell_value(egg)
    T.to_shop(); T.leave_shop(); T.to_shop(); T.leave_shop()
    T.eq(sell_value(egg), base + 3 + 3)
    local card = T.upgrade('egg')
    T.eq(sell_value(card), base + 3 + 3)
    T.to_shop()
    T.eq(sell_value(card), base + 3 + 3 + 5)
end)

T.test('Free Range Egg JokerDisplay: reminder shows the current sell value', function()
    T.start_run({ jokers = { 'bplus_egg_plus' } })
    local egg = T.joker(1)
    T.eq(T.joker_display('bplus_egg_plus').reminder, '($' .. egg.sell_cost .. ')')
    local base = egg.sell_cost
    T.to_shop()
    T.eq(T.joker_display('bplus_egg_plus').reminder, '($' .. (base + 5) .. ')')
end)
