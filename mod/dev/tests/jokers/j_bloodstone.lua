local T = BPlus.test

local HEARTS = { 'AH', 'KH', '9H', '5H', '2H' }

T.test('Fire Opal: with Oops! All 6s (4 in 3), 5 Hearts -> X1.5 five times', function()
    T.start_run({ jokers = { 'bplus_bloodstone_plus', 'oops' }, ante = 8 })
    T.select_blind()
    T.set_hand(HEARTS)
    local r = T.play(HEARTS)
    T.eq(r.hand, 'Flush')
    T.near(r.mult, 4 * 1.5 ^ 5, 0.01)
end)

T.test('Fire Opal: description shows 2 in 3 (4 in 3 with Oops! All 6s)', function()
    T.start_run({ jokers = { 'bplus_bloodstone_plus' }, ante = 8 })
    local card = T.joker(1)
    local v = card.config.center:loc_vars({}, card).vars
    T.eq({ v[1], v[2], v[3] }, { 2, 3, 1.5 })
    T.start_run({ jokers = { 'bplus_bloodstone_plus', 'oops' }, ante = 8 })
    card = T.joker(1)
    v = card.config.center:loc_vars({}, card).vars
    T.eq({ v[1], v[2], v[3] }, { 4, 3, 1.5 })
end)

T.test('Fire Opal: seeded run, 30 scored Hearts -> both hits and misses occur', function()
    T.start_run({ jokers = { 'bplus_bloodstone_plus' }, ante = 8, hands = 6 })
    T.select_blind()
    local hits = 0
    for _ = 1, 6 do
        T.set_hand(HEARTS)
        local r = T.play(HEARTS)
        hits = hits + math.floor(math.log(r.mult / 4) / math.log(1.5) + 0.5)
    end
    T.truthy(hits > 0 and hits < 30, 'hits = ' .. hits)
end)

T.test('Fire Opal: vanilla forced to "+" with Oops! All 6s hits every Heart', function()
    T.start_run({ jokers = { 'bloodstone', 'oops' }, ante = 8 })
    T.select_blind()
    T.force_behavior('bloodstone', 'plus')
    T.set_hand(HEARTS)
    T.near(T.play(HEARTS).mult, 4 * 1.5 ^ 5, 0.01)
end)
