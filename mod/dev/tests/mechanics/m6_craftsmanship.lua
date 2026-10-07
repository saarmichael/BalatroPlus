-- M6 Craftsmanship / Masterwork. Spec: plannig/specs/mechanics/M6_craftsmanship.yaml
local T = BPlus.test
local S = BPlus.shop_upgrade

T.test('Craftsmanship: rate is 4%, a forced roll turns a shop joker into a "+" at the base price', function()
    S.force = nil
    T.start_run({ vouchers = { 'v_bplus_craftsmanship' }, shop_queue = { 'ride_the_bus' }, ante = 3 })
    T.near(S.rate(), 0.04, 1e-9)
    S.force = true
    T.to_shop()
    S.force = nil
    local card = G.shop_jokers.cards[1]
    T.eq(card.config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(card.base_cost, G.P_CENTERS.j_ride_the_bus.cost, 'base price (an edition may add its own surcharge)')
end)

T.test('Craftsmanship: a failed roll leaves the joker vanilla', function()
    S.force = nil
    T.start_run({ vouchers = { 'v_bplus_craftsmanship' }, shop_queue = { 'ride_the_bus' }, ante = 3 })
    S.force = false
    T.to_shop()
    S.force = nil
    T.eq(G.shop_jokers.cards[1].config.center.key, 'j_ride_the_bus')
end)

T.test('Masterwork: replaces the Craftsmanship rate (8%, not 4% + 8%)', function()
    S.force = nil
    T.start_run({ vouchers = { 'v_bplus_craftsmanship', 'v_bplus_masterwork' } })
    T.near(S.rate(), 0.08, 1e-9)
end)

T.test('Craftsmanship: no vouchers means rate 0 and no upgrades', function()
    S.force = nil
    T.start_run({ shop_queue = { 'ride_the_bus' }, ante = 3 })
    T.eq(S.rate(), 0)
    S.force = true
    T.to_shop()
    S.force = nil
    T.eq(G.shop_jokers.cards[1].config.center.key, 'j_ride_the_bus')
end)

T.test('Masterwork: requires Craftsmanship and both cost $10', function()
    T.start_run({})
    T.eq(G.P_CENTERS.v_bplus_masterwork.requires, { 'v_bplus_craftsmanship' })
    T.eq(G.P_CENTERS.v_bplus_craftsmanship.cost, 10)
    T.eq(G.P_CENTERS.v_bplus_masterwork.cost, 10)
end)

T.test('Craftsmanship: redeemed from the shop, the next rerolled joker can be upgraded', function()
    S.force = nil
    T.start_run({ dollars = 40, ante = 3 })
    T.to_shop()
    G.shop_vouchers.cards[1]:set_ability(G.P_CENTERS.v_bplus_craftsmanship)
    T.buy('v_bplus_craftsmanship')
    T.truthy(G.GAME.used_vouchers.v_bplus_craftsmanship, 'redeemed')
    T.near(S.rate(), 0.04, 1e-9)
end)
