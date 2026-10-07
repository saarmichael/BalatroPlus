-- Spec: plannig/specs/mechanics/M10_the_rust.yaml
-- The Rust: boss blind. While it is active, every joker behaves as its base version.
local cfg = BPlus.balance.the_rust
local BLIND_KEY = 'bl_bplus_the_rust'

SMODS.Atlas({
    key = 'blind_rust', path = 'bplus_blind_rust.png',
    px = 34, py = 34, atlas_table = 'ANIMATION_ATLAS', frames = 21,
})

SMODS.Blind({
    key = 'the_rust', name = 'The Rust',
    loc_txt = {
        name = 'The Rust',
        text = { 'Upgraded Jokers act', 'as their base version' },
    },
    atlas = 'blind_rust', pos = { x = 0, y = 0 },
    boss = { min = cfg.min_ante, max = cfg.max_ante },
    boss_colour = HEX('9a5b32'),
    mult = cfg.mult, dollars = cfg.dollars,
})

local function rust_active()
    local blind = G.GAME and G.GAME.blind
    return G.GAME and G.GAME.facing_blind and blind and not blind.disabled
        and blind.config and blind.config.blind and blind.config.blind.key == BLIND_KEY
end

BPlus.add_behavior_provider(200, function(card)
    if rust_active() then return 'base' end
end)
