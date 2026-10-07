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

T.test('Cola Zero JokerDisplay: shows nothing (vanilla definition is empty)', function()
    T.start_run({ dollars = 6, jokers = { 'bplus_diet_cola_plus', 'diet_cola' } })
    T.eq(T.joker_display('bplus_diet_cola_plus').text, '')
    T.force_behavior('diet_cola', 'plus')
    T.eq(T.joker_display('diet_cola').text, '')
    T.force_behavior('bplus_diet_cola_plus', 'base')
    T.eq(T.joker_display('bplus_diet_cola_plus').text, '')
end)
