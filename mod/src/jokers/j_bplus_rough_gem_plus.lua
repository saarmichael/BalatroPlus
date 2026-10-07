-- Spec: plannig/specs/jokers/j_rough_gem.yaml
BPlus.Joker({
    key = 'rough_gem_plus',
    loc_txt = {
        name = 'Gemstone',
        text = {
            'Played cards with',
            '{C:diamonds}Diamond{} suit earn',
            '{C:money}$#1#{} when scored',
        },
    },
    config = { extra = { dollars = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_rough_gem', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+$' },
                { ref_table = 'card.joker_display_values', ref_value = 'dollars', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.GOLD },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
                { text = ')' },
            },
            calc_function = function(card)
                local total = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local suit = 'Diamonds'
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_suit(suit) then
                            total = total + card.ability.extra.dollars * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.dollars = total
                card.joker_display_values.localized_text = localize(suit, 'suits_plural')
            end,
            style_function = function(card, text, reminder_text, extra)
                local suit_node = reminder_text and reminder_text.children and reminder_text.children[2]
                if suit_node then suit_node.config.colour = lighten(G.C.SUITS['Diamonds'], 0.35) end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Diamonds') then
            -- dollar_buffer like vanilla, so the HUD total is right while the hand is scoring
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            G.E_MANAGER:add_event(Event({ func = function() G.GAME.dollar_buffer = 0; return true end }))
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
