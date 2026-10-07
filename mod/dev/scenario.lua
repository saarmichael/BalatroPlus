-- Default dev scenario. While `enabled = true` it is applied to EVERY new run
-- (menu "Play", hold-R restart, Option+N, `bp run`, ./dev.sh scenario).
-- Named scenarios in dev/scenarios/ use the same fields and are applied only on demand.
-- Re-read on every new run: edit, then start a new run. No game restart needed.
--
-- Card keys may omit the prefix: 'blueprint' == 'j_blueprint', 'fool' == 'c_fool'.
-- Find keys in the Lovely dump: Mods/lovely/dump/game.lua (search "j_" / "c_" / "v_").

return {
    enabled = false,
    name = 'default',

    -- Run setup ---------------------------------------------------------
    -- seed = 'TEST1',            -- reproducible shops and draws
    -- deck = 'b_red',            -- only applied by dev.new_run (not the menu)
    -- stake = 1,                 -- 1 White .. 8 Gold; only applied by dev.new_run
    -- ante = 1,
    dollars = 50,
    infinite_money = true,        -- true = topped up to $1000 whenever below; or a number floor
    free_rerolls = true,
    -- hands = 4, discards = 3, hand_size = 8,
    -- joker_slots = 5, consumable_slots = 2,

    -- Starting cards ----------------------------------------------------
    jokers = {
        -- 'blueprint',
        -- { key = 'j_joker', edition = 'foil', stickers = { 'eternal' } },
    },
    consumables = {},             -- e.g. { 'fool', 'c_hex' }
    vouchers = {},                -- redeemed immediately, e.g. { 'overstock_norm' }

    -- Shop control ------------------------------------------------------
    shop_queue = {},              -- forced into the next shop joker slots in order, then normal generation
    -- shop_pool = { 'joker', 'blueprint' },  -- every shop joker slot drawn from this list
}
