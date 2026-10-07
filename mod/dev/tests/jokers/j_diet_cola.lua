local T = BPlus.test

local function double_tags()
    local n = 0
    for _, t in ipairs(G.GAME.tags) do if t.key == 'tag_double' then n = n + 1 end end
    return n
end

T.test('Cola Zero: sell it -> 2 Double Tags added (vanilla: 1)', function()
    T.start_run({ jokers = { 'bplus_diet_cola_plus' } })
    T.eq(double_tags(), 0)
    T.sell('bplus_diet_cola_plus')
    T.eq(double_tags(), 2)
end)

T.test('Cola Zero: vanilla Diet Cola forced to "+" gives 2 Double Tags', function()
    T.start_run({ jokers = { 'diet_cola' } })
    T.force_behavior('diet_cola', 'plus')
    T.sell('diet_cola')
    T.eq(double_tags(), 2)
end)
