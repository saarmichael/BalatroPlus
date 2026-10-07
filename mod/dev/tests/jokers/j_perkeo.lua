local T = BPlus.test

local function neg_count()
    local n = 0
    for _, c in ipairs(G.consumeables.cards) do
        if c.edition and c.edition.negative then n = n + 1 end
    end
    return n
end

T.test('Perkeo+: end shop holding 1 Tarot, with Oops! All 6s -> 2 Negative copies', function()
    T.start_run({ jokers = { 'bplus_perkeo_plus', 'oops' }, consumables = { 'fool' } })
    T.to_shop()
    T.leave_shop()
    T.eq(#G.consumeables.cards, 1 + 2)
    T.eq(neg_count(), 2)
end)

T.test('Perkeo+: seeded run, several shops -> sometimes 1 copy, sometimes 2', function()
    T.start_run({ jokers = { 'bplus_perkeo_plus' }, consumables = { 'fool' }, ante = 2 })
    local seen = {}
    for _ = 1, 8 do
        local before = neg_count()
        T.to_shop()
        T.leave_shop()
        local gained = neg_count() - before
        T.truthy(gained == 1 or gained == 2, 'gained 1 or 2, got ' .. gained)
        seen[gained] = true
    end
    T.truthy(seen[1] and seen[2], 'saw both outcomes')
end)

T.test('Perkeo+: no consumables held -> nothing', function()
    T.start_run({ jokers = { 'bplus_perkeo_plus' } })
    T.to_shop()
    T.leave_shop()
    T.eq(#G.consumeables.cards, 0)
end)

T.test('Perkeo+: vanilla Perkeo makes exactly 1 copy; forced to "+" with Oops makes 2', function()
    T.start_run({ jokers = { 'perkeo', 'oops' }, consumables = { 'fool' } })
    T.to_shop()
    T.leave_shop()
    T.eq(neg_count(), 1)
    T.start_run({ jokers = { 'perkeo', 'oops' }, consumables = { 'fool' } })
    T.force_behavior('perkeo', 'plus')
    T.to_shop()
    T.leave_shop()
    T.eq(neg_count(), 2)
end)
