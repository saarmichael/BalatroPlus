-- "+" joker overlay (D19): a shader drawn like an edition (stacks with Foil/Holo/Poly/Negative).
-- Shown whenever the card BEHAVES as a "+" joker (vanilla next to Carpenter: yes; "+" under The Rust: no).
-- Cards outside G.jokers (shop, collection, packs) fall back to is_plus.

SMODS.Shader({ key = 'sheen', path = 'sheen.fs' })

function BPlus.show_plus_overlay(card)
    if not (card and card.config and card.config.center and card.config.center.set == 'Joker') then return false end
    if card.ability and card.ability.set ~= 'Joker' then return false end
    local key = card.config.center.key
    if key == 'j_bplus_carpenter' or key == 'j_bplus_apprentice' then return false end
    if BPlus.behaves_as then
        local as = BPlus.behaves_as(card)
        if as ~= nil then return BPlus.base_map[as] ~= nil end
    end
    return BPlus.is_plus(card)
end

SMODS.DrawStep {
    key = 'plus_overlay',
    order = 21, -- right after the edition step
    func = function(self)
        if not BPlus.show_plus_overlay(self) then return end
        self.ARGS.send_to_shader = self.ARGS.send_to_shader or {}
        self.children.center:draw_shader('bplus_sheen', nil, self.ARGS.send_to_shader)
    end,
    conditions = { vortex = false, facing = 'front' },
}

-- Size/soul quirks in Card:set_ability are gated on center.discovered; "+" jokers stay undiscovered until seen,
-- so let those quirks (pixel_size of Wee/Half/Photograph/Square, floating soul sprite) apply anyway.
local function with_discovered(ref, center)
    if type(center) == 'table' and center.bplus and not center.discovered then
        center.discovered = true
        local ok, err = pcall(ref)
        center.discovered = false
        if not ok then error(err, 0) end
        return
    end
    return ref()
end

local set_ability_ref = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    if self.bypass_discovery_center then return set_ability_ref(self, center, initial, delay_sprites) end
    return with_discovered(function() return set_ability_ref(self, center, initial, delay_sprites) end, center)
end

local init_ref = Card.init
function Card:init(X, Y, W, H, card, center, params)
    return with_discovered(function() return init_ref(self, X, Y, W, H, card, center, params) end, center)
end
