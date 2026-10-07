-- M8 Workshop Pack. Spec: plannig/specs/mechanics/M8_workshop_pack.yaml
local T = BPlus.test
local S = BPlus.shop_upgrade

-- Make every joker the pack creates a plain Joker, so the upgrade roll is the only variable.
local create_card_ref
local function force_joker()
    create_card_ref = SMODS.create_card
    SMODS.create_card = function(args)
        if args.set == 'Joker' and args.key_append == 'bpw' then
            args = { key = 'j_joker', area = args.area, skip_materialize = true }
        end
        return create_card_ref(args)
    end
end
local function restore()
    if create_card_ref then SMODS.create_card = create_card_ref end
    create_card_ref = nil
    S.force = nil
end

-- Put a pack into the shop and open it. Returns the money paid.
local function open_pack(key)
    T.start_run({ dollars = 50, ante = 3 })
    T.to_shop()
    local pack = SMODS.create_card({ key = key, area = G.shop_booster })
    T.eq(pack.config.center.key, key, 'created')
    if pack.area ~= G.shop_booster then G.shop_booster:emplace(pack) end
    create_shop_card_ui(pack, 'Booster', G.shop_booster)
    T.wait_idle()
    local before = G.GAME.dollars
    for i, c in ipairs(G.shop_booster.cards) do
        if c == pack then T.buy(i) break end
    end
    local paid = before - G.GAME.dollars
    T.wait_until(function() return G.pack_cards and #G.pack_cards.cards >= 1 end, 'pack cards')
    T.wait_idle()
    return paid
end

T.test('Workshop Pack: normal pack costs $4, offers 2 jokers, choose 1, all upgraded on a forced roll', function()
    force_joker()
    S.force = true
    local ok, err = pcall(function()
        T.eq(open_pack('p_bplus_workshop_normal_1'), 4, 'paid $4')
        T.eq(G.GAME.pack_choices, 1)
        T.eq(#G.pack_cards.cards, 2)
        for _, c in ipairs(G.pack_cards.cards) do T.eq(c.config.center.key, 'j_bplus_joker_plus') end
        T.pick(1)
        T.eq(#G.jokers.cards, 1)
        T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_joker_plus')
    end)
    restore()
    if not ok then error(err, 0) end
end)

T.test('Workshop Pack: a failed roll leaves the jokers vanilla', function()
    force_joker()
    S.force = false
    local ok, err = pcall(function()
        open_pack('p_bplus_workshop_normal_2')
        T.eq(#G.pack_cards.cards, 2)
        for _, c in ipairs(G.pack_cards.cards) do T.eq(c.config.center.key, 'j_joker') end
    end)
    restore()
    if not ok then error(err, 0) end
end)

T.test('Workshop Pack: jumbo is $6, 4 jokers, choose 1', function()
    force_joker()
    S.force = true
    local ok, err = pcall(function()
        T.eq(open_pack('p_bplus_workshop_jumbo_1'), 6, 'paid $6')
        T.eq(G.GAME.pack_choices, 1)
        T.eq(#G.pack_cards.cards, 4)
    end)
    restore()
    if not ok then error(err, 0) end
    T.eq(G.P_CENTERS.p_bplus_workshop_jumbo_1.cost, 6)
end)

T.test('Workshop Pack: mega is $8, 4 jokers, choose 2', function()
    force_joker()
    S.force = true
    local ok, err = pcall(function()
        T.eq(open_pack('p_bplus_workshop_mega_1'), 8, 'paid $8')
        T.eq(G.GAME.pack_choices, 2)
        T.eq(#G.pack_cards.cards, 4)
        T.pick(1)
        T.pick(1)
        T.eq(#G.jokers.cards, 2)
    end)
    restore()
    if not ok then error(err, 0) end
    T.eq(G.P_CENTERS.p_bplus_workshop_mega_1.cost, 8)
    T.eq(G.P_CENTERS.p_bplus_workshop_normal_1.cost, 4)
end)

T.test('Workshop Pack: each joker is upgraded 1 in 3 of the time (statistical)', function()
    T.start_run({ ante = 3 })
    force_joker()
    local ok, err = pcall(function()
        local booster = Card(0, 0, G.CARD_W, G.CARD_H, nil, G.P_CENTERS.p_bplus_workshop_normal_1)
        local n, upgraded = 300, 0
        for i = 1, n do
            local c = G.P_CENTERS.p_bplus_workshop_normal_1:create_card(booster, i)
            if BPlus.is_plus(c) then upgraded = upgraded + 1 end
            c:remove()
        end
        booster:remove()
        -- expected 100, sd ~8.2
        T.truthy(upgraded >= 70 and upgraded <= 130, 'upgraded ' .. upgraded .. ' of ' .. n)
    end)
    restore()
    if not ok then error(err, 0) end
end)

T.test('Workshop Pack: description shows the odds from balance (1 in 3)', function()
    T.start_run({})
    local res = G.P_CENTERS.p_bplus_workshop_normal_1:loc_vars({}, nil)
    T.eq(res.vars, { 1, 2, 1, BPlus.balance.workshop_pack.odds })
end)
