-- Spec: plannig/specs/jokers/j_blue_joker.yaml
BPlus.Joker({
    key = 'blue_joker_plus',
    loc_txt = {
        name = 'Deep Blue',
        text = {
            '{C:chips}+#1#{} Chips for each',
            'remaining card in {C:attention}deck',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        },
    },
    config = { extra = { chips_per = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_blue_joker', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_per, card.ability.extra.chips_per * ((G.deck and G.deck.cards) and #G.deck.cards or 52) } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'chips', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
            calc_function = function(card)
                card.joker_display_values.chips = card.ability.extra.chips_per * ((G.deck and G.deck.cards) and #G.deck.cards or 52)
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and #G.deck.cards > 0 then
            return { chips = card.ability.extra.chips_per * #G.deck.cards }
        end
    end,
})
