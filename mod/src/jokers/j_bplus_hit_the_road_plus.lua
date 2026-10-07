-- Spec: plannig/specs/jokers/j_hit_the_road.yaml
BPlus.Joker({
    key = 'hit_the_road_plus',
    loc_txt = {
        name = 'Hit the Road+',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'for every {C:attention}Jack{}',
            'discarded this round',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 1 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_hit_the_road', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint and not context.other_card.debuff and context.other_card:get_id() == 11 then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod',
                message_key = 'a_xmult', message_colour = G.C.RED, message_delay = 0.45 })
            return nil, true
        end
        if context.end_of_round and context.main_eval and not context.blueprint and card.ability.extra.Xmult > 1 then
            SMODS.reset_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', reset_value = 1, message_colour = G.C.RED })
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
