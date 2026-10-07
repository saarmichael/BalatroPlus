-- Spec: plannig/specs/mechanics/M1_carpenter.yaml
-- Carpenter: the joker to its right behaves as its "+" version (temporary, nothing is changed on the card).
local cfg = BPlus.balance.carpenter
local CARPENTER_KEY = 'j_bplus_carpenter'

-- The card directly to the left of `card` in the joker area, or nil.
local function left_neighbour(card)
    if not (G.jokers and card.area == G.jokers) then return nil end
    local cards = G.jokers.cards
    for i, c in ipairs(cards) do
        if c == card then return cards[i - 1] end
    end
end

-- Would a working Carpenter make `other` behave as "+"?
local function carpenter_can_upgrade(other)
    if not BPlus.is_eligible(other) then return false end
    local plus = G.P_CENTERS[BPlus.upgrade_map[other.config.center.key]]
    return plus.bplus.carpenter_compat and true or false
end

BPlus.add_behavior_provider(100, function(card)
    local left = left_neighbour(card)
    if left and left.config.center.key == CARPENTER_KEY and not left.debuff then return 'plus' end
end)

SMODS.Joker({
    key = 'carpenter',
    loc_txt = {
        name = 'Carpenter',
        text = {
            'Joker to the right',
            'acts as its {C:attention}upgraded{}',
            'version',
        },
    },
    rarity = cfg.rarity, cost = cfg.cost,
    atlas = 'placeholder', pos = { x = 0, y = 0 },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    unlocked = true, discovered = false,
    config = {},

    -- Blueprint-style compatible / incompatible tag (same UI code as Blueprint).
    loc_vars = function(self, info_queue, card)
        card.ability.blueprint_compat_ui = card.ability.blueprint_compat_ui or ''
        card.ability.blueprint_compat_check = nil
        return {
            main_end = (card.area and card.area == G.jokers) and {
                { n = G.UIT.C, config = { align = 'bm', minh = 0.4 }, nodes = {
                    { n = G.UIT.C, config = { ref_table = card, align = 'm', colour = G.C.JOKER_GREY, r = 0.05, padding = 0.06, func = 'blueprint_compat' }, nodes = {
                        { n = G.UIT.T, config = { ref_table = card.ability, ref_value = 'blueprint_compat_ui', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                    } },
                } },
            } or nil,
        }
    end,

    update = function(self, card, dt)
        if not (G.jokers and card.area == G.jokers) then return end
        local other
        for i, c in ipairs(G.jokers.cards) do
            if c == card then other = G.jokers.cards[i + 1] end
        end
        card.ability.blueprint_compat = (other and not card.debuff and carpenter_can_upgrade(other))
            and 'compatible' or 'incompatible'
    end,
})

-- "+" badge on a joker that currently behaves as its "+" version -------------------------

local process_loc_ref = BPlus.process_loc_text
function BPlus.process_loc_text()
    process_loc_ref()
    G.localization.misc.labels.bplus_plus = '+'
end

local badge_colour_ref = get_badge_colour
function get_badge_colour(key)
    if key == 'bplus_plus' then return G.C.PURPLE end
    return badge_colour_ref(key)
end

local aut_ref = Card.generate_UIBox_ability_table
function Card:generate_UIBox_ability_table(...)
    local aut = aut_ref(self, ...)
    if type(aut) == 'table' and type(aut.badges) == 'table'
        and self.ability and self.ability.bplus_behaving and BPlus.is_eligible(self) then
        table.insert(aut.badges, 'bplus_plus')
    end
    return aut
end
