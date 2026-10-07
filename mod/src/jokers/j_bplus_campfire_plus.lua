-- Spec: plannig/specs/jokers/j_campfire.yaml
BPlus.Joker({
    key = 'campfire_plus',
    loc_txt = {
        name = 'Burning Man',
        text = {
            'This Joker gains {X:mult,C:white}X#1#{} Mult',
            'for each card {C:attention}sold{}, resets',
            'when {C:attention}Boss Blind{} is defeated',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 0.4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_campfire', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.ability.extra', ref_value = 'Xmult', retrigger_type = 'exp' },
                    },
                },
            },
        }
    end,

    calculate = function(self, card, context)
        if context.selling_card and not context.blueprint and card ~= context.card then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod', message_colour = G.C.FILTER })
        end
        if context.end_of_round and context.main_eval and not context.blueprint and G.GAME.blind.boss and card.ability.extra.Xmult > 1 then
            SMODS.reset_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', reset_value = 1, message_colour = G.C.RED })
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
