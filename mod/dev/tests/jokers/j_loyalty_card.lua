local T = BPlus.test

-- A single-card High Card: mult 1, so the mult shown is exactly the joker's X.
local function hand() return T.play({ 1 }) end

local function start(jokers)
    T.start_run({ jokers = jokers, hands = 6, ante = 3 })
    T.select_blind()
end

T.test('Membership Card: play 3 hands -> X4 on hand 3 only', function()
    start({ 'bplus_loyalty_card_plus' })
    T.eq(hand().mult, 1)
    T.eq(hand().mult, 1)
    T.eq(hand().mult, 1 * 4)
    T.eq(hand().mult, 1)
end)

T.test('Membership Card: play 6 hands -> X4 on hands 3 and 6', function()
    start({ 'bplus_loyalty_card_plus' })
    local mults = {}
    for i = 1, 6 do mults[i] = hand().mult end
    T.eq(mults, { 1, 1, 1 * 4, 1, 1, 1 * 4 })
end)

T.test('Membership Card: vanilla Loyalty Card triggers on hand 6, not hand 3', function()
    start({ 'loyalty_card' })
    local mults = {}
    for i = 1, 6 do mults[i] = hand().mult end
    T.eq(mults, { 1, 1, 1, 1, 1, 1 * 4 })
end)

T.test('Membership Card: Loyalty Card played 2 hands, then upgraded -> the 3rd hand overall gives X4 (count kept)', function()
    T.start_run({ jokers = { { key = 'loyalty_card', edition = 'holo' } }, hands = 6, ante = 3 })
    T.select_blind()
    T.eq(hand().mult, 1 + 10, 'holo +10')
    T.eq(hand().mult, 1 + 10, 'holo +10')
    local card = T.upgrade('loyalty_card')
    T.eq(card.ability.hands_played_at_create, 0, 'creation count restored')
    T.truthy(card.edition and card.edition.holo, 'holo kept')
    T.eq(hand().mult, (1 + 10) * 4, 'holo +10 Mult first, then the joker X4')
end)

T.test('Membership Card: Loyalty Card forced to "+" triggers on hand 3', function()
    start({ 'loyalty_card' })
    T.force_behavior('loyalty_card', 'plus')
    T.eq(hand().mult, 1)
    T.eq(hand().mult, 1)
    T.eq(hand().mult, 1 * 4)
end)

T.test('Membership Card: forced to base keeps its count and triggers every 6th hand', function()
    start({ 'bplus_loyalty_card_plus' })
    local mults = {}
    for i = 1, 3 do mults[i] = hand().mult end
    T.eq(mults, { 1, 1, 1 * 4 })
    T.force_behavior(1, 'base')
    mults = {}
    for i = 4, 6 do mults[#mults + 1] = hand().mult end
    T.eq(mults, { 1, 1, 1 * 4 }, 'base fires when (played - created) hits 5, i.e. on hand 6')
end)

T.test('Membership Card JokerDisplay: X1 (2 remaining) -> after 2 hands X4 (Active!); vanilla forced to "+" matches; "+" forced to base shows vanilla', function()
    start({ 'bplus_loyalty_card_plus', 'loyalty_card' })
    local d = T.joker_display('bplus_loyalty_card_plus')
    T.eq(d.text, 'X1')
    T.eq(d.reminder, '(2 remaining)')
    T.eq(T.joker_display('loyalty_card').reminder, '(5 remaining)')
    hand(); hand()
    d = T.joker_display('bplus_loyalty_card_plus')
    T.eq(d.text, 'X4')
    T.eq(d.reminder, '(Active!)')
    T.force_behavior('loyalty_card', 'plus')
    d = T.joker_display('loyalty_card')
    T.eq(d.text, 'X4')
    T.eq(d.reminder, '(Active!)')
    T.force_behavior('bplus_loyalty_card_plus', 'base')
    d = T.joker_display('bplus_loyalty_card_plus')
    T.eq(d.text, 'X1')
    T.eq(d.reminder, '(3 remaining)') -- vanilla: every 5, 2 hands played -> 5 - 2
end)
