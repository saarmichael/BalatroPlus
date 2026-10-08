-- Spec: plannig/specs/mechanics/M1_carpenter.yaml (D22)
local T = BPlus.test

local function keys()
    local list = {}
    for i, c in ipairs(G.jokers.cards) do list[i] = c.config.center.key end
    return list
end

T.test('Carpenter: the human example (sell Joker, buy Carpenter, sell Carpenter -> Joker+ is added)', function()
    T.start_run({ jokers = { 'joker' }, shop_queue = { 'carpenter' }, dollars = 50 })
    T.to_shop()
    T.sell('joker')
    T.eq(G.GAME.bplus_last_sold, 'j_joker')
    T.buy('carpenter')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'Joker+ added')
    T.eq(keys(), { 'j_bplus_joker_plus' })
    T.eq(G.GAME.bplus_last_sold, nil, 'record consumed')
end)

T.test('Carpenter: Joker+ is fresh and works (+20 Mult)', function()
    T.start_run({ jokers = { 'joker', 'carpenter' }, ante = 3 })
    T.sell('joker')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'Joker+ added')
    T.select_blind()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    T.eq(T.play({ '2S', '2H' }).mult, 2 + 20)
end)

T.test('Carpenter: a sold "+" joker comes back as a fresh "+" joker', function()
    T.start_run({ jokers = { 'bplus_joker_plus', 'carpenter' } })
    T.sell('bplus_joker_plus')
    T.eq(G.GAME.bplus_last_sold, 'j_bplus_joker_plus')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'Joker+ added')
    T.eq(keys(), { 'j_bplus_joker_plus' })
end)

T.test('Carpenter: using it consumes the record (a second Carpenter does nothing)', function()
    T.start_run({ jokers = { 'joker', 'carpenter', 'carpenter' } })
    T.sell('joker')
    T.sell(1) -- first Carpenter
    T.wait_until(function() return #G.jokers.cards == 2 end, 'Joker+ added')
    T.sell('carpenter')
    T.wait_frames(60)
    T.eq(keys(), { 'j_bplus_joker_plus' })
end)

T.test('Carpenter: selling a Carpenter does not record it', function()
    T.start_run({ jokers = { 'joker', 'carpenter', 'carpenter' } })
    T.sell('joker')
    T.sell(1) -- Carpenter consumes the record
    T.wait_until(function() return #G.jokers.cards == 2 end, 'Joker+ added')
    T.eq(G.GAME.bplus_last_sold, nil)
    T.sell('carpenter')
    T.wait_frames(30)
    T.eq(G.GAME.bplus_last_sold, nil, 'Carpenter is never the last sold joker')
end)

T.test('Carpenter: nothing sold yet -> nothing happens', function()
    T.start_run({ jokers = { 'carpenter', 'four_fingers' } })
    T.sell('carpenter')
    T.wait_frames(60)
    T.eq(keys(), { 'j_four_fingers' })
end)

T.test('Carpenter: a joker without a "+" version (Four Fingers) -> nothing, record kept', function()
    T.start_run({ jokers = { 'four_fingers', 'carpenter', 'carpenter' } })
    T.sell('four_fingers')
    T.sell(1)
    T.wait_frames(60)
    T.eq(#G.jokers.cards, 1, 'nothing created')
    T.eq(G.GAME.bplus_last_sold, 'j_four_fingers', 'record kept')
end)

T.test('Carpenter: the created joker has no edition even if the sold one was Foil', function()
    T.start_run({ jokers = { { key = 'j_joker', edition = 'foil' }, 'carpenter' } })
    T.sell('joker')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'Joker+ added')
    T.falsy(G.jokers.cards[1].edition, 'no edition')
end)

T.test('Carpenter: the created joker has no stickers', function()
    T.start_run({ jokers = { { key = 'j_joker', stickers = { 'perishable' } }, 'carpenter' } })
    T.sell('joker')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'Joker+ added')
    local c = G.jokers.cards[1]
    T.falsy(c.ability.perishable)
    T.falsy(c.ability.rental)
    T.falsy(c.ability.eternal)
end)

T.test('Carpenter: a grown joker sold with value 5 comes back as a fresh Express Bus (0)', function()
    T.start_run({ jokers = { 'ride_the_bus', 'carpenter' } })
    T.joker('ride_the_bus').ability.mult = 5
    T.sell('ride_the_bus')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'Express Bus added')
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(G.jokers.cards[1].ability.extra.mult, 0)
end)

T.test('Carpenter: the record survives shop and round transitions', function()
    T.start_run({ jokers = { 'joker', 'carpenter' }, ante = 3 })
    T.to_shop()
    T.sell('joker')
    T.leave_shop()
    T.to_shop()
    T.eq(G.GAME.bplus_last_sold, 'j_joker')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'Joker+ added')
    T.eq(keys(), { 'j_bplus_joker_plus' })
end)

T.test('Carpenter: the last sold joker is the most recent one', function()
    T.start_run({ jokers = { 'joker', 'greedy_joker', 'carpenter' } })
    T.sell('joker')
    T.sell('greedy_joker')
    T.sell('carpenter')
    T.wait_until(function() return #G.jokers.cards == 1 end, 'added')
    T.eq(keys(), { 'j_bplus_greedy_joker_plus' })
end)

T.test('Carpenter: no room (Negative Carpenter, slots still full) -> nothing, record kept', function()
    T.start_run({ jokers = { { key = 'j_bplus_carpenter', edition = 'negative' }, 'four_fingers', 'joker' }, joker_slots = 2 })
    G.GAME.bplus_last_sold = 'j_greedy_joker'
    T.sell('carpenter')
    T.wait_frames(60)
    T.eq(#G.jokers.cards, 2)
    T.eq(G.GAME.bplus_last_sold, 'j_greedy_joker', 'record kept')
end)

T.test('Carpenter: is never eligible for an upgrade', function()
    T.start_run({ jokers = { 'carpenter' } })
    T.falsy(BPlus.is_eligible(T.joker('carpenter')))
    T.falsy(BPlus.upgrade_card(T.joker('carpenter')))
end)

T.test('Carpenter: no behaviour switching (neighbour stays vanilla)', function()
    T.start_run({ jokers = { 'carpenter', 'joker' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    T.eq(T.play({ '2S', '2H' }).mult, 2 + 4)
    T.eq(T.joker('joker').ability.bplus_behaving, nil)
end)

local function tooltip_text(card)
    local out = {}
    local function walk(n)
        if type(n) ~= 'table' then return end
        if n.config and n.config.text then out[#out + 1] = n.config.text end
        for _, c in ipairs(n.nodes or {}) do walk(c) end
    end
    local aut = card:generate_UIBox_ability_table()
    for _, line in ipairs(aut.main or {}) do
        for _, part in ipairs(line) do
            if part.config and part.config.text then out[#out + 1] = part.config.text end
            if part.config and part.config.ref_table and part.config.ref_value then
                out[#out + 1] = tostring(part.config.ref_table[part.config.ref_value])
            end
        end
    end
    return table.concat(out, ' ')
end

T.test('Carpenter tooltip: shows the joker it would create, or none', function()
    T.start_run({ jokers = { 'carpenter', 'joker' } })
    T.truthy(tooltip_text(T.joker('carpenter')):find('none', 1, true), 'tooltip says none')
    T.sell('joker')
    local text = tooltip_text(T.joker('carpenter'))
    T.truthy(text:find('Joker+', 1, true), 'tooltip names Joker+: ' .. text)
end)

T.test('Carpenter JokerDisplay: (none) at first, then the name of the "+" joker it would create', function()
    T.start_run({ jokers = { 'carpenter', 'joker' } })
    T.wait_frames(3)
    T.eq(T.joker_display('carpenter').reminder, '(none)')
    T.sell('joker')
    T.wait_frames(3)
    T.eq(T.joker_display('carpenter').reminder, '(Joker+)')
end)

T.test('Carpenter JokerDisplay: a joker without a "+" version shows (none)', function()
    T.start_run({ jokers = { 'carpenter', 'four_fingers' } })
    T.sell('four_fingers')
    T.wait_frames(3)
    T.eq(T.joker_display('carpenter').reminder, '(none)')
end)
