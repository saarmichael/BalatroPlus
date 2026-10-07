-- Spec: plannig/specs/jokers/j_photograph.yaml
BPlus.Joker({
    key = 'photograph_plus',
    loc_txt = {
        name = 'Selfie',
        text = {
            'First played {C:attention}face',
            'card gives {X:mult,C:white} X#1# {} Mult',
            'when scored',
        },
    },
    config = { extra = { Xmult = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_photograph', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local face_cards = {}
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_face() then
                            table.insert(face_cards, scoring_card)
                        end
                    end
                end
                local first_face = JokerDisplay.calculate_leftmost_card(face_cards)
                card.joker_display_values.x_mult = first_face
                    and (card.ability.extra.Xmult ^ JokerDisplay.calculate_card_triggers(first_face, scoring_hand)) or 1
                card.joker_display_values.localized_text = localize('k_face_cards')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local first_face
            for _, c in ipairs(context.scoring_hand) do
                if c:is_face() then first_face = c; break end
            end
            if context.other_card == first_face then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
