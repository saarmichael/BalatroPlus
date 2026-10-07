local T = BPlus.test

-- Hand of 10 cards, the first `n` of them Bonus cards (an Enhancement); play the first, a Bonus card
-- when n > 0 (+30 chips when scored).
local RANKS = { '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J' }
local function enhanced_hand(n)
    local specs = {}
    for i, r in ipairs(RANKS) do
        specs[i] = (i <= n) and { r .. 'S', enhancement = 'bonus' } or (r .. 'S')
    end
    T.set_hand(specs)
    return T.play({ '2S' })
end

local function start(joker)
    T.start_run({ jokers = { joker }, hand_size = 10, ante = 3 })
    T.select_blind()
end

T.test('Fake ID: 10 Enhanced cards in deck -> X3 (vanilla needs 16)', function()
    start('bplus_drivers_license_plus')
    local r = enhanced_hand(10)
    T.eq(r.chips, 5 + 2 + 30)
    T.eq(r.mult, 1 * 3)
end)

T.test('Fake ID: 9 Enhanced cards -> no effect', function()
    start('bplus_drivers_license_plus')
    T.eq(enhanced_hand(9).mult, 1)
end)

T.test("Fake ID: vanilla Driver's License with 10 Enhanced cards -> no effect", function()
    start('drivers_license')
    T.eq(enhanced_hand(10).mult, 1)
end)

T.test("Fake ID: vanilla Driver's License forced to '+' with 10 Enhanced cards -> X3", function()
    T.start_run({ jokers = { 'drivers_license' }, hand_size = 10, ante = 3 })
    T.force_behavior('drivers_license', 'plus')
    T.select_blind()
    T.eq(enhanced_hand(10).mult, 1 * 3)
end)
