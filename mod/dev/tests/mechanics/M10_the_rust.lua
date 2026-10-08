-- Spec: plannig/specs/mechanics/M10_the_rust.yaml
local T = BPlus.test

local function pair_of_twos()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    return T.play({ '2S', '2H' })
end

-- Skip Small and Big, then enter the (forced) boss blind.
local function enter_boss()
    T.skip_blind()
    T.skip_blind()
    return T.select_blind()
end

local function rust_run(jokers, extra)
    local s = { jokers = jokers, ante = 3, boss = 'bplus_the_rust' }
    for k, v in pairs(extra or {}) do s[k] = v end
    T.start_run(s)
end

T.test('The Rust: is a boss blind with normal stats from ante 2', function()
    local b = G.P_BLINDS.bl_bplus_the_rust
    T.truthy(b, 'registered')
    T.eq(b.boss.min, 2)
    T.eq(b.mult, 2)
    T.eq(b.dollars, 5)
end)

T.test('The Rust: Joker+ scores +4 instead of +20', function()
    rust_run({ 'bplus_joker_plus' })
    T.eq(enter_boss(), 'The Rust')
    T.eq(pair_of_twos().mult, 2 + 4)
end)

T.test('The Rust: Joker+ is back to +20 outside The Rust', function()
    rust_run({ 'bplus_joker_plus' })
    T.select_blind()
    T.eq(pair_of_twos().mult, 2 + 20)
end)

T.test('The Rust: Carpenter does not interact with it (neighbour is plain vanilla: +4)', function()
    rust_run({ 'carpenter', 'joker' })
    enter_boss()
    T.eq(pair_of_twos().mult, 2 + 4)
end)

T.test('The Rust: vanilla jokers are unaffected', function()
    rust_run({ 'joker' })
    enter_boss()
    T.eq(pair_of_twos().mult, 2 + 4)
end)

T.test('The Rust: growing joker keeps its stored value, only the rate changes', function()
    rust_run({ 'bplus_ride_the_bus_plus' }, { hands = 5 })
    T.joker('bplus_ride_the_bus_plus').ability.extra.mult = 6
    enter_boss()
    T.eq(pair_of_twos().mult, 2 + 6 + 1)    -- vanilla rate +1
    T.eq(T.joker('bplus_ride_the_bus_plus').ability.extra.mult, 7)
    T.eq(pair_of_twos().mult, 2 + 7 + 1)
end)

T.test('The Rust: shrinking "+" joker (Chocolate Bar) is unaffected', function()
    rust_run({ 'bplus_ice_cream_plus' })
    enter_boss()
    T.eq(pair_of_twos().chips, 10 + 2 + 2 + 150)
end)

T.test('The Rust: Chicot disables it and "+" behaviour returns', function()
    rust_run({ 'chicot', 'bplus_joker_plus' })
    enter_boss()
    T.truthy(G.GAME.blind.disabled, 'Chicot disabled the blind')
    T.eq(pair_of_twos().mult, 2 + 20)
end)
