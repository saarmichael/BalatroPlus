-- Spec: plannig/specs/jokers/j_sly.yaml
BPlus.Joker({
    key = 'sly_plus',
    loc_txt = {
        name = 'Foxy Joker',
        text = { '{C:chips}+#1#{} Chips if played', 'hand contains', '{C:attention}#2#{}' },
    },
    config = { extra = { t_chips = 100, type = 'Pair' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_sly', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_chips, localize(card.ability.extra.type, 'poker_hands') } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'chips', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local value = 0
                local _, poker_hands, _ = JokerDisplay.evaluate_hand()
                if poker_hands[card.ability.extra.type] and next(poker_hands[card.ability.extra.type]) then
                    value = card.ability.extra.t_chips
                end
                card.joker_display_values.chips = value
                card.joker_display_values.localized_text = localize(card.ability.extra.type, 'poker_hands')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { chips = card.ability.extra.t_chips }
        end
    end,
})
