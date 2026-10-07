-- Spec: plannig/specs/jokers/j_scholar.yaml
BPlus.Joker({
    key = 'scholar_plus',
    loc_txt = {
        name = 'Professor',
        text = {
            'Played {C:attention}Aces{}',
            'give {C:chips}+#1#{} Chips',
            'and {C:mult}+#2#{} Mult',
            'when scored',
        },
    },
    config = { extra = { chips = 40, mult = 10 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_scholar', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 14 then
            return { chips = card.ability.extra.chips, mult = card.ability.extra.mult }
        end
    end,
})
