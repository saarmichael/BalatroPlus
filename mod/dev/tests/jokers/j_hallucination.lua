local T = BPlus.test

local function open_first_pack()
    T.to_shop()
    local key = G.shop_booster.cards[1].config.center.key
    T.buy(key)
end

T.test('Fever Dream: open a Booster Pack with a free slot -> 1 Tarot created', function()
    T.start_run({ ante = 3, dollars = 50, jokers = { 'bplus_hallucination_plus' } })
    local before = #G.consumeables.cards
    open_first_pack()
    local tarots = 0
    for _, c in ipairs(G.consumeables.cards) do if c.ability.set == 'Tarot' then tarots = tarots + 1 end end
    T.eq(tarots, 1)
    T.eq(#G.consumeables.cards, before + 1)
end)

T.test('Fever Dream: open a Booster Pack with full slots -> nothing created', function()
    T.start_run({ ante = 3, dollars = 50, consumables = { 'pluto', 'mercury' }, jokers = { 'bplus_hallucination_plus' } })
    open_first_pack()
    T.eq(#G.consumeables.cards, 2)
    T.eq(G.consumeables.cards[1].ability.set, 'Planet')
    T.eq(G.consumeables.cards[2].ability.set, 'Planet')
end)

T.test('Fever Dream JokerDisplay: shows nothing (guaranteed, no odds)', function()
    T.start_run({ dollars = 6, jokers = { 'bplus_hallucination_plus', 'hallucination' } })
    T.eq(T.joker_display('bplus_hallucination_plus').extra[1], nil)
    T.force_behavior('hallucination', 'plus')
    T.eq(T.joker_display('hallucination').extra[1], nil)
    T.force_behavior('bplus_hallucination_plus', 'base')
    T.eq(T.joker_display('bplus_hallucination_plus').extra[1], '(1 in 2)')
end)
