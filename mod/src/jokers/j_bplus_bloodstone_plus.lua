-- Spec: plannig/specs/jokers/j_bloodstone.yaml
BPlus.Joker({
    key = 'bloodstone_plus',
    loc_txt = {
        name = 'Fire Opal',
        text = {
            '{C:green}#1# in #2#{} chance for',
            'played cards with',
            '{C:hearts}Heart{} suit to give',
            '{X:mult,C:white} X#3# {} Mult when scored',
        },
    },
    config = { extra = { num = 2, odds = 3, Xmult = 1.5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_bloodstone', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local a, b = SMODS.get_probability_vars(card, card.ability.extra.num, card.ability.extra.odds, 'bplus_fire_opal')
        return { vars = { a, b, card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'count', retrigger_type = 'mult' },
                { text = 'x', scale = 0.35 },
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.ability.extra', ref_value = 'Xmult' },
                    },
                },
            },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
                { text = ')' },
            },
            extra = {
                {
                    { text = '(' },
                    { ref_table = 'card.joker_display_values', ref_value = 'odds' },
                    { text = ')' },
                },
            },
            extra_config = { colour = G.C.GREEN, scale = 0.3 },
            calc_function = function(card)
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local count = 0
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_suit('Hearts') then
                            count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.count = count
                local numerator, denominator = SMODS.get_probability_vars(card, card.ability.extra.num, card.ability.extra.odds, 'bplus_fire_opal')
                card.joker_display_values.odds = localize { type = 'variable', key = 'jdis_odds', vars = { numerator, denominator } }
                card.joker_display_values.localized_text = localize('Hearts', 'suits_plural')
            end,
            style_function = function(card, text, reminder_text, extra)
                local suit_node = reminder_text and reminder_text.children and reminder_text.children[2]
                if suit_node then suit_node.config.colour = lighten(G.C.SUITS['Hearts'], 0.35) end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Hearts')
            and SMODS.pseudorandom_probability(card, 'bplus_fire_opal', card.ability.extra.num, card.ability.extra.odds) then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
