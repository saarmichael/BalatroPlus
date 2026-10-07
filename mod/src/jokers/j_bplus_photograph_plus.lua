-- Spec: plannig/specs/jokers/j_photograph.yaml
BPlus.Joker({
    key = 'photograph_plus',
    loc_txt = {
        name = 'Selfie',
        text = {
            'First played {C:attention}face',
            'card gives {X:mult,C:white} X#1# {} Mult',
            'when scored',
        },
    },
    config = { extra = { Xmult = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_photograph', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local first_face
            for _, c in ipairs(context.scoring_hand) do
                if c:is_face() then first_face = c; break end
            end
            if context.other_card == first_face then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
