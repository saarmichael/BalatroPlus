-- Spec: plannig/specs/jokers/j_wee.yaml
BPlus.Joker({
    key = 'wee_plus',
    loc_txt = {
        name = 'Wee Wee Joker',
        text = {
            'This Joker gains',
            '{C:chips}+#1#{} Chips when each',
            'played {C:attention}2{} is scored',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        },
    },
    config = { extra = { chips = 0, chip_mod = 16 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_wee', state_transfer = { ['extra.chips'] = 'extra.chips' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_mod, card.ability.extra.chips } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'chips', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and not context.blueprint and context.other_card:get_id() == 2 then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'chips', scalar_value = 'chip_mod', no_message = true })
            return {
                extra = { focus = card, message = localize('k_upgrade_ex') },
                card = card,
            }
        end
        if context.joker_main and card.ability.extra.chips > 0 then
            return { chips = card.ability.extra.chips }
        end
    end,
})
