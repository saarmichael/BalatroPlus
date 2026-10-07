-- Spec: plannig/specs/jokers/j_smiley.yaml
BPlus.Joker({
    key = 'smiley_plus',
    loc_txt = {
        name = 'Hugging Face',
        text = {
            'Played {C:attention}face{} cards',
            'give {C:mult}+#1#{} Mult',
            'when scored',
        },
    },
    config = { extra = { mult = 10 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_smiley', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return { mult = card.ability.extra.mult }
        end
    end,
})
