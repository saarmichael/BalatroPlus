-- Spec: plannig/specs/jokers/j_ramen.yaml
BPlus.Joker({
    key = 'ramen_plus',
    loc_txt = {
        name = 'Tonkotsu',
        text = {
            '{X:mult,C:white} X#1# {} Mult,',
            'loses {X:mult,C:white} X#2# {} Mult',
            'per {C:attention}card{} discarded',
        },
    },
    config = { extra = { Xmult = 3, Xmult_mod = 0.01 } },
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_ramen', state_transfer = {}, carpenter_compat = false },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.Xmult_mod } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
        if context.discard and not context.blueprint then
            -- small epsilon so float drift (3 - 200 * 0.01) cannot keep it alive one card too long
            if card.ability.extra.Xmult - card.ability.extra.Xmult_mod <= 1 + 1e-9 then
                SMODS.destroy_cards(card, nil, nil, true)
                return { card = card, message = localize('k_eaten_ex'), colour = G.C.FILTER }
            else
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod',
                    operation = '-', message_key = 'a_xmult_minus', colour = G.C.RED, message_delay = 0.2,
                })
            end
        end
    end,
})
