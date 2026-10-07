-- M2: Apprentice. Spec: plannig/specs/mechanics/M2_apprentice.yaml
local T = BPlus.test

local function round()
    T.to_shop()
end

local function next_round()
    T.leave_shop()
    round()
end

T.test('Apprentice: counts rounds and is active after 3', function()
    T.start_run({ jokers = { 'bplus_apprentice' } })
    local card = T.joker('bplus_apprentice')
    T.eq(card.ability.extra.count, 0)
    round()
    T.eq(card.ability.extra.count, 1)
    next_round()
    T.eq(card.ability.extra.count, 2)
    next_round()
    T.eq(card.ability.extra.count, 3)
    T.eq(card.ability.extra.rounds, 3)
end)

T.test('Apprentice: selling it before it is active upgrades nothing', function()
    T.start_run({ jokers = { 'bplus_apprentice', 'joker' } })
    round()
    T.sell('j_bplus_apprentice')
    T.eq(G.jokers.cards[1].config.center.key, 'j_joker')
end)

T.test('Apprentice: selling it when active upgrades the eligible Joker', function()
    T.start_run({ jokers = { 'bplus_apprentice', 'joker', 'four_fingers' } })
    round(); next_round(); next_round()
    T.sell('j_bplus_apprentice')
    T.wait_idle()
    T.eq(#G.jokers.cards, 2)
    T.truthy(T.joker('bplus_joker_plus'), 'Joker+')
    T.truthy(T.joker('four_fingers'), 'Four Fingers untouched')
end)

T.test('Apprentice: selling it when active with no eligible Joker does nothing', function()
    T.start_run({ jokers = { 'bplus_apprentice', 'four_fingers' } })
    round(); next_round(); next_round()
    T.sell('j_bplus_apprentice')
    T.wait_idle()
    T.eq(#G.jokers.cards, 1)
    T.eq(G.jokers.cards[1].config.center.key, 'j_four_fingers')
end)

T.test('Apprentice: is never eligible and has the declared stats', function()
    T.start_run({ jokers = { 'bplus_apprentice' } })
    local card = T.joker('bplus_apprentice')
    T.falsy(BPlus.is_eligible(card), 'not eligible')
    T.eq(card.config.center.rarity, 2)
    T.eq(card.config.center.cost, 6)
    T.falsy(card.config.center.blueprint_compat, 'blueprint_compat')
    T.falsy(card.config.center.eternal_compat, 'eternal_compat')
end)

-- Two small/big blinds with one hand each, then the boss round without a hand: Apprentice is active.
local function activate_with_hands(hand)
    T.select_blind(); hand(); T.win_blind(); T.cash_out(); T.leave_shop()
    T.select_blind(); hand(); T.win_blind(); T.cash_out(); T.leave_shop()
    T.to_shop()
end

T.test('Apprentice: Ride the Bus upgraded keeps +2 Mult and then gains at the + rate', function()
    T.start_run({ ante = 3, jokers = { 'bplus_apprentice', 'ride_the_bus' } })
    local function hand() T.set_hand({ '2S', '3H', '5C', '7D', '9H' }); return T.play({ '9H' }) end
    activate_with_hands(hand)
    T.sell('j_bplus_apprentice')
    T.wait_idle()
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_ride_the_bus_plus')
    T.eq(G.jokers.cards[1].ability.extra.mult, 2, 'value kept')
    T.leave_shop(); T.select_blind()
    T.eq(hand().mult, 1 + 2 + 2)
end)

T.test('Apprentice: Ice Cream upgraded -> Chocolate Bar starts fresh at +150 Chips', function()
    T.start_run({ ante = 3, jokers = { 'bplus_apprentice', 'ice_cream' } })
    local function hand() T.set_hand({ '2S', '3H', '5C', '7D', '9H' }); return T.play({ '9H' }) end
    activate_with_hands(hand)
    T.sell('j_bplus_apprentice')
    T.wait_idle()
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_ice_cream_plus')
    T.leave_shop(); T.select_blind()
    T.eq(hand().chips, 5 + 9 + 150)
end)
