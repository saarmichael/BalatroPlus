-- Spec: plannig/specs/jokers/j_superposition.yaml
BPlus.Joker({
    key = 'superposition_plus',
    loc_txt = {
        name = 'Superduperposition',
        text = {
            'Create {C:attention}#1#{} {C:tarot}Tarot{} cards if',
            'poker hand contains an',
            '{C:attention}Ace{} and a {C:attention}Straight{}',
            '{C:inactive}(Must have room)',
        },
    },
    config = { extra = { cards = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_superposition', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'count', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.SECONDARY_SET.Tarot },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text_ace', colour = G.C.ORANGE },
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text_straight', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local active = false
                local _, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
                if poker_hands['Straight'] and next(poker_hands['Straight']) then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:get_id() == 14 then active = true end
                    end
                end
                card.joker_display_values.count = active and 1 or 0
                card.joker_display_values.localized_text_straight = localize('Straight', 'poker_hands')
                card.joker_display_values.localized_text_ace = localize('Ace', 'ranks')
            end,
        }
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local free = G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer)
            local n = math.min(card.ability.extra.cards, free)
            if n <= 0 then return end
            local aces = 0
            for _, c in ipairs(context.scoring_hand) do
                if c:get_id() == 14 then aces = aces + 1 end
            end
            if aces >= 1 and next(context.poker_hands['Straight']) then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + n
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = function()
                        for _ = 1, n do
                            local c = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'bplus_superduperposition')
                            c:add_to_deck()
                            G.consumeables:emplace(c)
                            G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                        end
                        return true
                    end,
                }))
                return {
                    message = localize('k_plus_tarot'),
                    colour = G.C.SECONDARY_SET.Tarot,
                    card = card,
                }
            end
        end
    end,
})
