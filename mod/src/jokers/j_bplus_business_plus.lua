-- Spec: plannig/specs/jokers/j_business.yaml
BPlus.Joker({
    key = 'business_plus',
    loc_txt = {
        name = 'Executive Card',
        text = {
            'Played {C:attention}face{} cards have',
            'a {C:green}#1# in #2#{} chance to',
            'give {C:money}$#3#{} when scored',
        },
    },
    config = { extra = { odds = 2, dollars = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_business', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'count', retrigger_type = 'mult' },
                { text = 'x', scale = 0.35 },
                { text = '$', colour = G.C.GOLD },
                { ref_table = 'card.ability.extra', ref_value = 'dollars', colour = G.C.GOLD },
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
                local count = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_face() then
                            count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.count = count
                local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_executive_card')
                card.joker_display_values.odds = localize { type = 'variable', key = 'jdis_odds', vars = { numerator, denominator } }
            end,
        }
    end,

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_executive_card')
        return { vars = { num, den, card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face()
            and SMODS.pseudorandom_probability(card, 'bplus_executive_card', 1, card.ability.extra.odds) then
            G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + card.ability.extra.dollars
            G.E_MANAGER:add_event(Event({ func = function() G.GAME.dollar_buffer = 0; return true end }))
            return { dollars = card.ability.extra.dollars, card = card }
        end
    end,
})
