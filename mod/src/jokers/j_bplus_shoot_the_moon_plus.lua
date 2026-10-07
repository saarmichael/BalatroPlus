-- Spec: plannig/specs/jokers/j_shoot_the_moon.yaml
BPlus.Joker({
    key = 'shoot_the_moon_plus',
    loc_txt = {
        name = 'Moonshot',
        text = {
            'Each {C:attention}Queen{}',
            'held in hand',
            'gives {C:mult}+#1#{} Mult',
        },
    },
    config = { extra = { mult = 21 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_shoot_the_moon', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:get_id() == 12 then
            if context.other_card.debuff then
                return { message = localize('k_debuffed'), colour = G.C.RED }
            end
            return { mult = card.ability.extra.mult }
        end
    end,
})
