-- Spec: plannig/specs/jokers/j_baron.yaml
BPlus.Joker({
    key = 'baron_plus',
    loc_txt = {
        name = 'Duke',
        text = {
            'Each {C:attention}King{}',
            'held in hand',
            'gives {X:mult,C:white} X#1# {} Mult',
        },
    },
    config = { extra = { Xmult = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_baron', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:get_id() == 13 then
            if context.other_card.debuff then
                return { message = localize('k_debuffed'), colour = G.C.RED }
            end
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
