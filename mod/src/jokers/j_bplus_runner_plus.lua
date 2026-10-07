-- Spec: plannig/specs/jokers/j_runner.yaml
BPlus.Joker({
    key = 'runner_plus',
    loc_txt = {
        name = 'Sprinter',
        text = {
            'Gains {C:chips}+#1#{} Chips',
            'if played hand',
            'contains a {C:attention}Straight{}',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        },
    },
    config = { extra = { chips = 0, chip_mod = 30 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_runner', state_transfer = { ['extra.chips'] = 'extra.chips' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chip_mod, card.ability.extra.chips } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint and next(context.poker_hands['Straight']) then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'chips', scalar_value = 'chip_mod' })
        end
        if context.joker_main and card.ability.extra.chips > 0 then
            return { chips = card.ability.extra.chips }
        end
    end,
})
