-- Example named scenario: ./dev.sh scenario example  (or `bp run example` in the DebugPlus console)
-- Same fields as dev/scenario.lua; `enabled` is ignored for named scenarios.

return {
    name = 'example',
    seed = 'BPTEST1',
    deck = 'b_red',
    stake = 1,
    infinite_money = true,
    free_rerolls = true,
    joker_slots = 8,

    jokers = { 'joker', { key = 'blueprint', edition = 'foil' } },
    consumables = { 'fool' },
    vouchers = { 'overstock_norm' },

    -- First shop shows these, in order; after that only these two can appear.
    shop_queue = { 'ride_the_bus', 'hologram', 'brainstorm' },
    shop_pool = { 'ride_the_bus', 'hologram' },
}
