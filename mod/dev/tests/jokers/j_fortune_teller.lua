local T = BPlus.test

-- The Hermit (no targets, harmless at $0) is a Tarot that counts toward consumeable_usage_total.
local function use_hermits(n)
    for _ = 1, n do T.use('hermit') end
end

local function start(joker, tarots)
    local consumables = {}
    for i = 1, tarots do consumables[i] = 'hermit' end
    T.start_run({ jokers = { joker }, consumables = consumables, consumable_slots = 3, dollars = 0, ante = 3 })
end

T.test('Oracle: used 3 Tarot cards this run -> +2 * 3 = 6 Mult (vanilla: +3)', function()
    start('bplus_fortune_teller_plus', 3)
    use_hermits(3)
    T.eq(G.GAME.consumeable_usage_total.tarot, 3)
    T.select_blind()
    T.eq(T.play({ 1 }).mult, 1 + 2 * 3)
end)

T.test('Oracle: no Tarots used -> no effect', function()
    start('bplus_fortune_teller_plus', 0)
    T.select_blind()
    T.eq(T.play({ 1 }).mult, 1)
end)

T.test('Oracle: vanilla Fortune Teller with 3 Tarots used -> +3 Mult', function()
    start('fortune_teller', 3)
    use_hermits(3)
    T.select_blind()
    T.eq(T.play({ 1 }).mult, 1 + 1 * 3)
end)

T.test('Oracle: vanilla Fortune Teller forced to "+" with 3 Tarots used -> +6 Mult', function()
    start('fortune_teller', 3)
    T.force_behavior('fortune_teller', 'plus')
    use_hermits(3)
    T.select_blind()
    T.eq(T.play({ 1 }).mult, 1 + 2 * 3)
end)
