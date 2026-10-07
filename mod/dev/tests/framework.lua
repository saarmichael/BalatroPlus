-- Self-tests for the test framework. Also the best reference for how each action is used.
local T = BPlus.test

T.test('start_run applies a scenario', function()
    local s = T.start_run({
        dollars = 25,
        jokers = { 'joker', { key = 'blueprint', edition = 'foil' } },
        consumables = { 'pluto' },
    })
    T.eq(s.state, 'BLIND_SELECT')
    T.eq(s.seed, 'BPTEST', 'tests default to a fixed seed')
    T.eq(s.dollars, 25)
    T.eq(s.jokers, { 'j_joker', 'j_blueprint [foil]' })
    T.eq(s.consumables, { 'c_pluto' })
end)

T.test('scenario can force the boss blind', function()
    T.start_run({ boss = 'hook' })
    T.eq(G.GAME.round_resets.blind_choices.Boss, 'bl_hook')
end)

T.test('set_hand + play score exactly', function()
    T.start_run()
    T.select_blind()
    T.set_hand({ 'KS', 'KH', 'JH', 'JC', '2D' })
    T.eq(#G.hand.cards, 5)
    -- Two Pair: (20 base + 10+10+10+10) chips x 2 mult
    local r = T.play({ 'KS', 'KH', 'JH', 'JC' })
    T.eq(r.hand, 'Two Pair')
    T.eq(r.chips, 60)
    T.eq(r.mult, 2)
    T.eq(r.score, 120)
    T.eq(r.state, 'SELECTING_HAND')
    T.eq(T.state().hands_left, 3)
end)

T.test('discard spends a discard and refills the hand', function()
    T.start_run()
    T.select_blind()
    local before = T.state()
    T.discard({ 1, 2, 3 })
    local after = T.state()
    T.eq(after.discards_left, before.discards_left - 1)
    T.eq(#after.hand, #before.hand)
end)

T.test('actions refuse illegal moves', function()
    T.start_run()
    local msg = T.errors(function() T.play({ 1 }) end)
    T.truthy(msg:find('needs state SELECTING_HAND', 1, true), 'play outside a blind: ' .. msg)
    T.select_blind()
    msg = T.errors(function() T.play({ 1, 2, 3, 4, 5, 6 }) end)
    T.truthy(msg:find('1-5 cards', 1, true), 'six-card play: ' .. msg)
    msg = T.errors(function() T.play({ 'AS', 'AS' }) end)
    T.truthy(msg, 'duplicate or missing card spec is rejected')
end)

T.test('win_blind + cash_out reach the shop', function()
    T.start_run()
    T.select_blind()
    T.win_blind()
    T.eq(T.state_name(), 'ROUND_EVAL')
    local gained = T.cash_out()
    T.eq(T.state_name(), 'SHOP')
    T.truthy(gained > 0, 'cash out pays the blind reward')
end)

T.test('shop queue, buy and sell', function()
    T.start_run({ dollars = 50, shop_queue = { 'ride_the_bus', 'hologram' } })
    T.to_shop()
    local shop = T.state().shop
    T.eq(shop[1], 'j_ride_the_bus')
    T.eq(shop[2], 'j_hologram')

    local money = G.GAME.dollars
    local card = T.buy('ride_the_bus')
    T.eq(G.GAME.dollars, money - card.cost, 'paid the price')
    T.truthy(T.joker('ride_the_bus'), 'joker owned after buying')

    local refund = T.sell('ride_the_bus')
    T.eq(refund, card.sell_cost)
    T.falsy(T.joker('ride_the_bus'), 'joker gone after selling')
end)

T.test('reroll and leave the shop', function()
    T.start_run({ dollars = 50, free_rerolls = true, shop_pool = { 'joker' } })
    T.to_shop()
    T.reroll()
    T.eq(G.GAME.dollars >= 50, true, 'free reroll cost nothing')
    T.eq(T.state().shop[1], 'j_joker', 'pool applies to rerolls')
    T.leave_shop()
    T.eq(T.state_name(), 'BLIND_SELECT')
    T.eq(G.GAME.blind_on_deck, 'Big')
end)

T.test('skip blind grants a tag', function()
    T.start_run()
    local tag = T.skip_blind()
    T.truthy(tag, 'a tag was added')
    T.eq(G.GAME.blind_on_deck, 'Big')
end)

T.test('use a planet', function()
    T.start_run({ consumables = { 'pluto' } })
    T.use('pluto')
    T.eq(G.GAME.hands['High Card'].level, 2)
    T.falsy(T.consumable('pluto'), 'consumed')
end)

T.test('use a tarot on selected hand cards', function()
    T.start_run({ consumables = { 'strength' } })
    T.select_blind()
    T.set_hand({ '2S', '9H', '9D', 'KC', 'AH' })
    T.use('strength', { '2S' }) -- Strength: +1 rank to selected cards
    T.contains(T.state().hand, '3 of Spades')
end)
