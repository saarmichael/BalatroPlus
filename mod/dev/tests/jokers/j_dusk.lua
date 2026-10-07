local T = BPlus.test

T.test('Twilight: with Oops! All 6s, final hand -> each scored card scores 1 + 2 times; hand with hands left -> no retrigger', function()
    T.start_run({ jokers = { 'oops', 'bplus_dusk_plus' }, hands = 2, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '2H', '9C', '5D', '3D' })
    local r1 = T.play({ '2S', '2H' })
    T.eq(r1.chips, 10 + 2 + 2)
    T.eq(r1.mult, 2)
    T.set_hand({ '2S', '2H', '9C', '5D', '3D' })
    local r2 = T.play({ '2S', '2H' })
    T.eq(r2.chips, 10 + 3 * (2 + 2))
    T.eq(r2.mult, 2)
end)

T.test('Twilight: without Oops!, seeded final hand of 5 cards -> each card retriggered 1 or 2 times, both seen', function()
    T.start_run({ jokers = { 'bplus_dusk_plus' }, hands = 1, ante = 3, seed = 'BBB' })
    T.select_blind()
    T.set_hand({ '2S', '3S', '4S', '5S', '7S' })
    local r = T.play({ '2S', '3S', '4S', '5S', '7S' })
    T.eq(r.hand, 'Flush')
    -- Flush: 35 chips; every card scores 2 times (1 + 1 retrigger), plus once more when the 1 in 2 roll hits
    local ranks = 2 + 3 + 4 + 5 + 7
    local extra = r.chips - 35 - 2 * ranks   -- = sum of the ranks of the cards that got the extra retrigger
    T.truthy(extra > 0 and extra < ranks, 'some but not all cards got the extra retrigger, extra chips = ' .. extra)
end)

T.test('Twilight: Dusk forced to "+" with Oops! All 6s -> final hand scores 1 + 2 times', function()
    T.start_run({ jokers = { 'oops', 'dusk' }, hands = 1, ante = 3 })
    T.select_blind()
    T.force_behavior('dusk', 'plus')
    T.set_hand({ '2S', '2H', '9C', '5D', '3D' })
    local r = T.play({ '2S', '2H' })
    T.eq(r.chips, 10 + 3 * (2 + 2))
end)
