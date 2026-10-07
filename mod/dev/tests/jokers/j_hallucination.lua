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
