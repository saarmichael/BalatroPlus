-- Spec: plannig/specs/jokers/j_swashbuckler.yaml
-- Vanilla recomputes ability.mult in Card:update every frame. Here the sum is computed on demand
-- (calculate and loc_vars), so it also works when a vanilla Swashbuckler behaves as this joker.
local function sell_sum(card)
    local total = 0
    for _, j in ipairs(G.jokers and G.jokers.cards or {}) do
        if j ~= card and j.area == G.jokers then total = total + j.sell_cost end
    end
    return total
end

BPlus.Joker({
    key = 'swashbuckler_plus',
    loc_txt = {
        name = 'Buccaneer',
        text = {
            'Adds {C:attention}double{} the sell value',
            'of all other owned',
            '{C:attention}Jokers{} to Mult',
            '{C:inactive}(Currently {C:mult}+#1#{C:inactive} Mult)',
        },
    },
    config = { extra = { sell_mult = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_swashbuckler', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_mult * sell_sum(card) } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local mult = card.ability.extra.sell_mult * sell_sum(card)
            if mult > 0 then return { mult = mult } end
        end
    end,
})
