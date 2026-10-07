-- Salesman (j_ring_master -> j_bplus_ring_master_plus). Spec: plannig/specs/jokers/j_ring_master.yaml
local T = BPlus.test
local S = BPlus.shop_upgrade

local function pool_has(key)
    local pool = get_current_pool('Joker', 0, nil, 'bplus_test')
    for _, k in ipairs(pool) do
        if k == key then return true end
    end
    return false
end

local function fresh_run(scenario)
    S.force = nil
    T.start_run(scenario)
end

T.test('Salesman: a joker you already hold can appear in the shop (Showman effect)', function()
    fresh_run({ jokers = { 'bplus_ring_master_plus', 'joker' } })
    T.truthy(pool_has('j_joker'), 'owned joker is in the pool with Salesman')
    fresh_run({ jokers = { 'joker' } })
    T.falsy(pool_has('j_joker'), 'owned joker is excluded without Showman/Salesman')
    fresh_run({ jokers = { 'ring_master', 'joker' } })
    T.truthy(pool_has('j_joker'), 'vanilla Showman still works')
end)

T.test('Salesman: without vouchers the shop upgrade rate is the base rate (4%)', function()
    fresh_run({ jokers = { 'bplus_ring_master_plus' } })
    T.near(S.rate(), 0.04, 1e-9, 'rate with Salesman only')
    fresh_run({})
    T.eq(S.rate(), 0, 'rate without any source')
end)

T.test('Salesman: forced roll upgrades a shop joker to a fresh "+" card at the base price', function()
    fresh_run({ jokers = { 'bplus_ring_master_plus' }, shop_queue = { 'ride_the_bus', 'four_fingers' }, ante = 3 })
    S.force = true
    T.to_shop()
    S.force = nil
    local first = G.shop_jokers.cards[1]
    T.eq(first.config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(first.ability.extra.mult, 0, 'fresh: starts from its own initial value')
    T.eq(first.base_cost, G.P_CENTERS.j_ride_the_bus.cost, 'base price (an edition may add its own surcharge)')
end)

T.test('Salesman: a failed roll leaves the shop joker vanilla', function()
    fresh_run({ jokers = { 'bplus_ring_master_plus' }, shop_queue = { 'ride_the_bus' }, ante = 3 })
    S.force = false
    T.to_shop()
    S.force = nil
    T.eq(G.shop_jokers.cards[1].config.center.key, 'j_ride_the_bus')
end)

T.test('Salesman: without Salesman or vouchers nothing is upgraded even with a forced roll', function()
    fresh_run({ shop_queue = { 'ride_the_bus' }, ante = 3 })
    S.force = true
    T.to_shop()
    S.force = nil
    T.eq(G.shop_jokers.cards[1].config.center.key, 'j_ride_the_bus')
end)

T.test('Salesman: rate is about 4% over many shop jokers (statistical)', function()
    fresh_run({ jokers = { 'bplus_ring_master_plus' }, ante = 3 })
    local n, upgraded = 500, 0
    for _ = 1, n do
        local card = Card(0, 0, G.CARD_W, G.CARD_H, nil, G.P_CENTERS.j_joker)
        if S.maybe(card) then upgraded = upgraded + 1 end
        card:remove()
    end
    -- expected 500 * 0.04 = 20, sd ~4.4
    T.truthy(upgraded >= 6 and upgraded <= 40, 'upgraded ' .. upgraded .. ' of ' .. n)
end)

T.test('Salesman: rate stacks with Craftsmanship (0.04 + 0.04)', function()
    fresh_run({ jokers = { 'bplus_ring_master_plus' }, vouchers = { 'v_bplus_craftsmanship' } })
    T.near(S.rate(), 0.04 + 0.04, 1e-9)
    local alone = S.rate()
    fresh_run({ vouchers = { 'v_bplus_craftsmanship' } })
    T.truthy(alone > S.rate(), 'Craftsmanship alone is lower')
end)

T.test('Salesman: rate stacks with Masterwork, which replaces Craftsmanship (0.04 + 0.08)', function()
    fresh_run({ jokers = { 'bplus_ring_master_plus' }, vouchers = { 'v_bplus_craftsmanship', 'v_bplus_masterwork' } })
    T.near(S.rate(), 0.04 + 0.08, 1e-9)
end)

T.test('Salesman: vanilla Showman forced to "+" gives the rate; "+" forced to base does not (Showman effect stays)', function()
    fresh_run({ jokers = { 'ring_master', 'joker' } })
    T.eq(S.rate(), 0)
    T.force_behavior('ring_master', 'plus')
    T.near(S.rate(), 0.04, 1e-9)
    fresh_run({ jokers = { 'bplus_ring_master_plus', 'joker' } })
    T.force_behavior('bplus_ring_master_plus', 'base')
    T.eq(S.rate(), 0)
    T.truthy(pool_has('j_joker'), 'Showman effect kept')
end)

T.test('Salesman JokerDisplay: shows nothing, like vanilla (also forced to base / plus)', function()
    T.start_run({ jokers = { 'bplus_ring_master_plus', 'ring_master' } })
    T.eq(T.joker_display('bplus_ring_master_plus').text, '')
    T.force_behavior('ring_master', 'plus')
    T.eq(T.joker_display('ring_master').text, '')
    T.force_behavior('bplus_ring_master_plus', 'base')
    T.eq(T.joker_display('bplus_ring_master_plus').text, '')
end)
