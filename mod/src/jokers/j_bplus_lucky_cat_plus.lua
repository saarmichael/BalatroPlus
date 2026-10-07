-- Spec: plannig/specs/jokers/j_lucky_cat.yaml
BPlus.Joker({
    key = 'lucky_cat_plus',
    loc_txt = {
        name = 'Maneki-neko',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'every time a {C:attention}Lucky{} card',
            '{C:green}successfully{} triggers',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 0.4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_lucky_cat', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

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
        if context.individual and context.cardarea == G.play and not context.blueprint and context.other_card.lucky_trigger then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod', no_message = true })
            return {
                extra = { focus = card, message = localize('k_upgrade_ex'), colour = G.C.MULT },
                card = card,
            }
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
