-- M9: Veteran Deck. Spec: plannig/specs/mechanics/M9_veteran_deck.yaml
local T = BPlus.test

local function with_rounds(n, fn)
    local old = BPlus.balance.veteran_deck.rounds
    BPlus.balance.veteran_deck.rounds = n
    local ok, err = pcall(fn)
    BPlus.balance.veteran_deck.rounds = old
    if not ok then error(err, 0) end
end

T.test('Veteran Deck: a Joker is upgraded after exactly 6 rounds', function()
    T.start_run({ deck = 'b_bplus_veteran', jokers = { 'joker', 'four_fingers' } })
    T.to_shop()
    for round = 2, 5 do
        T.leave_shop(); T.to_shop()
        T.eq(G.jokers.cards[1].config.center.key, 'j_joker', 'still vanilla after round ' .. round)
    end
    T.eq(G.jokers.cards[1].ability.bplus_veteran_rounds, 5)
    T.leave_shop(); T.to_shop()
    T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_joker_plus', 'upgraded at round 6')
    T.eq(G.jokers.cards[2].config.center.key, 'j_four_fingers', 'ineligible Joker untouched')
end)

T.test('Veteran Deck: each Joker counts its own rounds', function()
    with_rounds(2, function()
        T.start_run({ deck = 'b_bplus_veteran', dollars = 20, jokers = { 'joker' }, shop_queue = { 'greedy_joker' } })
        T.to_shop()
        local bought = T.buy('j_greedy_joker')
        T.leave_shop(); T.to_shop()
        T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_joker_plus', 'first upgraded after 2 rounds')
        T.eq(bought.config.center.key, 'j_greedy_joker', 'second has only 1 round')
        T.eq(bought.ability.bplus_veteran_rounds, 1)
        T.leave_shop(); T.to_shop()
        T.truthy(BPlus.is_plus(bought), 'second upgraded one round later')
    end)
end)

T.test('Veteran Deck: Ride the Bus keeps +2 Mult and gains at the + rate', function()
    with_rounds(2, function()
        T.start_run({ deck = 'b_bplus_veteran', ante = 3, jokers = { 'ride_the_bus' } })
        local function hand() T.set_hand({ '2S', '3H', '5C', '7D', '9H' }); return T.play({ '9H' }) end
        T.select_blind()
        T.eq(hand().mult, 1 + 1)
        T.win_blind(); T.cash_out(); T.leave_shop()
        T.select_blind()
        T.eq(hand().mult, 1 + 2)
        T.win_blind()
        T.eq(G.jokers.cards[1].config.center.key, 'j_bplus_ride_the_bus_plus', 'upgraded after round 2')
        T.eq(G.jokers.cards[1].ability.extra.mult, 2, 'value kept')
        T.cash_out(); T.leave_shop()
        T.select_blind()
        T.eq(hand().mult, 1 + 2 + 2)
    end)
end)
