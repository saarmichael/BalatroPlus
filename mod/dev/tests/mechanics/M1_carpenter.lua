-- Spec: plannig/specs/mechanics/M1_carpenter.yaml
local T = BPlus.test

local function pair_of_twos()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    return T.play({ '2S', '2H' })
end

local function compat(k)
    T.wait_frames(3)
    return T.joker(k).ability.blueprint_compat
end

T.test('Carpenter: the Joker to its right scores as Joker+ (+20 instead of +4)', function()
    T.start_run({ jokers = { 'carpenter', 'joker' }, ante = 3 })
    T.select_blind()
    T.eq(pair_of_twos().mult, 2 + 20)
    T.eq(T.joker('joker').ability.bplus_behaving, 'j_bplus_joker_plus')
    T.eq(T.joker('joker').config.center.key, 'j_joker', 'the card itself is unchanged')
end)

T.test('Carpenter: the Joker to its left is unaffected', function()
    T.start_run({ jokers = { 'joker', 'carpenter' }, ante = 3 })
    T.select_blind()
    T.eq(pair_of_twos().mult, 2 + 4)
end)

T.test('Carpenter: selling it returns the Joker to base behaviour', function()
    T.start_run({ jokers = { 'carpenter', 'joker' }, ante = 3 })
    T.select_blind()
    T.eq(pair_of_twos().mult, 2 + 20)
    T.sell('carpenter')
    T.eq(pair_of_twos().mult, 2 + 4)
end)

T.test('Carpenter: a debuffed Carpenter does nothing', function()
    T.start_run({ jokers = { 'carpenter', 'joker' }, ante = 3 })
    T.select_blind()
    T.joker('carpenter'):set_debuff(true)
    T.wait_frames(3)
    T.eq(pair_of_twos().mult, 2 + 4)
    T.joker('carpenter'):set_debuff(false)
    T.wait_frames(3)
    T.eq(pair_of_twos().mult, 2 + 20)
end)

T.test('Carpenter: shows compatible / incompatible like Blueprint', function()
    T.start_run({ jokers = { 'carpenter', 'joker' } })
    T.eq(compat('carpenter'), 'compatible', 'eligible joker to the right')
    T.start_run({ jokers = { 'joker', 'carpenter' } })
    T.eq(compat('carpenter'), 'incompatible', 'last slot')
    T.start_run({ jokers = { 'carpenter', 'four_fingers' } })
    T.eq(compat('carpenter'), 'incompatible', 'no upgraded version')
    T.start_run({ jokers = { 'carpenter', 'bplus_joker_plus' } })
    T.eq(compat('carpenter'), 'incompatible', 'already upgraded')
    T.start_run({ jokers = { 'carpenter', 'ice_cream' } })
    T.eq(compat('carpenter'), 'incompatible', 'shrinking joker (carpenter_compat = false)')
    T.start_run({ jokers = { 'carpenter', 'carpenter', 'joker' } })
    T.eq(G.jokers.cards[1].ability.blueprint_compat, 'incompatible', 'Carpenter next to Carpenter')
    T.eq(G.jokers.cards[2].ability.blueprint_compat, 'compatible')
end)

T.test('Carpenter: a shrinking joker (Ice Cream) is left alone', function()
    T.start_run({ jokers = { 'carpenter', 'ice_cream' }, ante = 3 })
    T.select_blind()
    T.eq(pair_of_twos().chips, 10 + 2 + 2 + 100)
    T.eq(T.joker('ice_cream').ability.bplus_behaving, nil)
end)

T.test('Carpenter: a "+" joker to the right stays as it is', function()
    T.start_run({ jokers = { 'carpenter', 'bplus_joker_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair_of_twos().mult, 2 + 20)
    T.eq(T.joker('bplus_joker_plus').ability.bplus_behaving, nil)
end)

T.test('Carpenter: growing joker keeps its stored value, only the rate changes', function()
    T.start_run({ jokers = { 'carpenter', 'ride_the_bus' }, ante = 3, hands = 6 })
    T.select_blind()
    T.eq(pair_of_twos().mult, 2 + 2)        -- Express Bus rate: +2
    T.eq(pair_of_twos().mult, 2 + 2 + 2)    -- stored 4
    T.sell('carpenter')
    T.eq(pair_of_twos().mult, 2 + 4 + 1)    -- stored 4 kept, vanilla rate +1
    T.eq(T.joker('ride_the_bus').ability.mult, 5)
end)

T.test('Carpenter: is never eligible for an upgrade', function()
    T.start_run({ jokers = { 'carpenter' } })
    T.falsy(BPlus.is_eligible(T.joker('carpenter')))
    T.falsy(BPlus.upgrade_card(T.joker('carpenter')))
end)

T.test('Carpenter: the affected joker shows a "+" badge, others do not', function()
    T.start_run({ jokers = { 'carpenter', 'joker', 'greedy_joker' } })
    local function badges(k)
        local aut = T.joker(k):generate_UIBox_ability_table()
        return aut.badges
    end
    T.contains(badges('joker'), 'bplus_plus', 'right neighbour')
    for _, b in ipairs(badges('greedy_joker')) do T.truthy(b ~= 'bplus_plus', 'no badge on others') end
end)
