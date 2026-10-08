local T = BPlus.test

T.test('Scenarios: showcase loads with Foil Canio+, Craftsmanship and both consumables', function()
    T.start_run(BPlus.dev.load_scenario('showcase'))
    local keys = {}
    for i, c in ipairs(G.jokers.cards) do keys[i] = c.config.center.key end
    T.eq(keys, { 'j_bplus_joker_plus', 'j_bplus_ride_the_bus_plus', 'j_bplus_caino_plus', 'j_blueprint' })
    T.eq(T.joker('j_bplus_caino_plus').edition.key, 'e_foil')
    T.eq(G.consumeables.cards[1].config.center.key, 'c_wheel_of_fortune')
    T.eq(G.consumeables.cards[2].config.center.key, 'c_bplus_apotheosis')
    T.truthy(G.GAME.used_vouchers.v_bplus_craftsmanship, 'craftsmanship redeemed')
    T.eq(G.GAME.round_resets.ante, 1)
end)
