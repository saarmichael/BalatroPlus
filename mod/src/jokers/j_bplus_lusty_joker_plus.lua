-- Spec: plannig/specs/jokers/j_lusty_joker.yaml
BPlus.Joker({
    key = 'lusty_joker_plus',
    loc_txt = {
        name = 'Lascivious Joker',
        text = {
            'Played cards with',
            '{C:hearts}#2#{} suit give',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    config = { extra = { s_mult = 5, suit = 'Hearts' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_lusty_joker', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.s_mult, localize(card.ability.extra.suit, 'suits_singular') } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
                { text = ')' },
            },
            calc_function = function(card)
                local total = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local suit = card.ability.extra.suit
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_suit(suit) then
                            total = total + card.ability.extra.s_mult * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.mult = total
                card.joker_display_values.localized_text = localize(suit, 'suits_plural')
            end,
            style_function = function(card, text, reminder_text, extra)
                local suit_node = reminder_text and reminder_text.children and reminder_text.children[2]
                if suit_node then suit_node.config.colour = lighten(G.C.SUITS[card.ability.extra.suit], 0.35) end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit(card.ability.extra.suit) then
            return { mult = card.ability.extra.s_mult }
        end
    end,
})
