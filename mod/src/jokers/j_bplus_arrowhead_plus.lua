-- Spec: plannig/specs/jokers/j_arrowhead.yaml
BPlus.Joker({
    key = 'arrowhead_plus',
    loc_txt = {
        name = 'Spearhead',
        text = {
            'Played cards with',
            '{C:spades}Spade{} suit give',
            '{C:chips}+#1#{} Chips when scored',
        },
    },
    config = { extra = { chips = 80 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_arrowhead', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
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
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
                { text = ')' },
            },
            calc_function = function(card)
                local total = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local suit = 'Spades'
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_suit(suit) then
                            total = total + card.ability.extra.chips * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.chips = total
                card.joker_display_values.localized_text = localize(suit, 'suits_plural')
            end,
            style_function = function(card, text, reminder_text, extra)
                local suit_node = reminder_text and reminder_text.children and reminder_text.children[2]
                if suit_node then suit_node.config.colour = lighten(G.C.SUITS['Spades'], 0.35) end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Spades') then
            return { chips = card.ability.extra.chips }
        end
    end,
})
