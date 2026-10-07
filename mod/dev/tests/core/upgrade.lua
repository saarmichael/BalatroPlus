-- BPlus.upgrade_card and behaviour switching (the base for Carpenter / The Rust).
local T = BPlus.test

local function pair_of_twos()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    return T.play({ '2S', '2H' })
end

T.test('upgrade_card: Joker becomes Joker+ in place, keeps edition and stickers', function()
    T.start_run({ jokers = { 'greedy_joker', { key = 'joker', edition = 'foil', stickers = { 'eternal' } }, 'scary_face' } })
    local card = T.upgrade('joker')
    T.eq(card.config.center.key, 'j_bplus_joker_plus')
    T.eq(G.jokers.cards[2], card, 'position')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    T.truthy(card.ability.eternal, 'eternal kept')
    T.select_blind()
    local r = pair_of_twos()
    T.eq(r.mult, 2 + 20)
end)

T.test('upgrade_card: refuses "+" jokers and jokers without an upgrade', function()
    T.start_run({ jokers = { 'bplus_joker_plus', 'four_fingers' } })
    T.falsy(BPlus.upgrade_card(T.joker('bplus_joker_plus')), '"+" joker')
    T.falsy(BPlus.upgrade_card(T.joker('four_fingers')), 'not upgradable')
    T.eq(#BPlus.eligible_jokers(), 0)
end)

T.test('behaviour: vanilla Joker forced to "+" scores +20, back to normal scores +4', function()
    T.start_run({ jokers = { 'joker' }, ante = 3 })
    T.select_blind()
    T.force_behavior('joker', 'plus')
    T.eq(pair_of_twos().mult, 2 + 20)
    T.force_behavior('joker', nil)
    T.eq(pair_of_twos().mult, 2 + 4)
end)

T.test('behaviour: Joker+ forced to base scores +4', function()
    T.start_run({ jokers = { 'bplus_joker_plus' } })
    T.select_blind()
    T.force_behavior('bplus_joker_plus', 'base')
    T.eq(pair_of_twos().mult, 2 + 4)
end)

T.test('behaviour: Blueprint copies the forced "+" behaviour', function()
    T.start_run({ jokers = { 'blueprint', 'joker' } })
    T.select_blind()
    T.force_behavior('joker', 'plus')
    T.eq(pair_of_twos().mult, 2 + 20 + 20)
end)

T.test('behaviour: plus_calculate / base_calculate are callable from outside the card', function()
    T.start_run({ jokers = { 'joker', 'bplus_joker_plus' } })
    local ctx = { joker_main = true }
    T.eq(BPlus.plus_calculate(T.joker('joker'), ctx).mult, 20)
    T.eq(BPlus.base_calculate(T.joker('bplus_joker_plus'), ctx).mult_mod, 4)
    T.eq(T.joker('joker').ability.mult, 4, 'vanilla card untouched')
    T.eq(T.joker('bplus_joker_plus').ability.extra.mult, 20, '"+" card untouched')
end)
