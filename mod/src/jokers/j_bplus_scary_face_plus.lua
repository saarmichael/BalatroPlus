-- Spec: plannig/specs/jokers/j_scary_face.yaml
BPlus.Joker({
    key = 'scary_face_plus',
    loc_txt = {
        name = 'Nightmare',
        text = {
            'Played {C:attention}face{} cards',
            'give {C:chips}+#1#{} Chips',
            'when scored',
        },
    },
    config = { extra = { chips = 60 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_scary_face', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return { chips = card.ability.extra.chips }
        end
    end,
})
