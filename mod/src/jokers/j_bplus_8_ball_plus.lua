-- Spec: plannig/specs/jokers/j_8_ball.yaml
BPlus.Joker({
    key = '8_ball_plus',
    loc_txt = {
        name = 'Magic 8 Ball',
        text = {
            'Each played {C:attention}8{} has a {C:green}#1# in #2#{}',
            'chance to create a {C:tarot}Tarot{} card or',
            'a {C:green}#1# in #2#{} chance to create a',
            '{C:spectral}Spectral{} card when scored',
            '{C:inactive}(Never both, must have room)',
        },
    },
    config = { extra = { odds = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_8_ball', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'count', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.SECONDARY_SET.Tarot },
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
                        if scoring_card:get_id() == 8 then
                            count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.count = count
                local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_magic_8_ball')
                card.joker_display_values.odds = localize { type = 'variable', key = 'jdis_odds', vars = { numerator, denominator } }
            end,
        }
    end,

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_magic_8_ball')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 8
            and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            -- One roll decides both outcomes, so one 8 never makes two cards.
            local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_magic_8_ball', true)
            local any = math.min(1, 2 * num / den)
            local u = pseudorandom('bplus_magic_8_ball')
            local set = (u < any / 2 and 'Tarot') or (u < any and 'Spectral') or nil
            SMODS.post_prob = SMODS.post_prob or {}
            SMODS.post_prob[#SMODS.post_prob + 1] = {
                pseudorandom_result = true, result = set ~= nil, trigger_obj = card,
                numerator = num, denominator = den, identifier = 'bplus_magic_8_ball',
            }
            if not set then return end
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            return {
                extra = {
                    focus = card,
                    message = localize(set == 'Tarot' and 'k_plus_tarot' or 'k_plus_spectral'),
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'before',
                            delay = 0.0,
                            func = function()
                                local c = create_card(set, G.consumeables, nil, nil, nil, nil, nil, '8ba')
                                c:add_to_deck()
                                G.consumeables:emplace(c)
                                G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                                return true
                            end,
                        }))
                    end,
                },
                colour = G.C.SECONDARY_SET[set],
                card = card,
            }
        end
    end,
})
