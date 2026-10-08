-- Hand-testing showcase: ./dev.sh scenario showcase  (or `bp run showcase` in the DebugPlus console)
-- Ante 1, $100, Craftsmanship redeemed (upgraded jokers can show up in the shop), two "+" jokers,
-- a foil legendary "+", a vanilla Blueprint, and two upgrade consumables.

return {
    name = 'showcase',
    seed = 'SHOWCASE',
    deck = 'b_red',
    stake = 1,
    ante = 1,
    dollars = 100,

    -- Left to right: Joker+, Ride the Bus+, Canio+ (Foil), Blueprint (vanilla).
    jokers = {
        'bplus_joker_plus',
        'bplus_ride_the_bus_plus',
        { key = 'bplus_caino_plus', edition = 'foil' },
        'blueprint',
    },
    consumables = { 'wheel_of_fortune', 'bplus_apotheosis' },
    vouchers = { 'bplus_craftsmanship' },
}
