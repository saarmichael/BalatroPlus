-- Spec: plannig/specs/jokers/j_idol.yaml
-- Reuses vanilla's G.GAME.current_round.idol_card (reset every round by reset_idol_card); matches rank only.
BPlus.Joker({
    key = 'idol_plus',
    loc_txt = {
        name = 'The Deity',
        text = {
            'Each played card of',
            'rank {C:attention}#2#{} gives',
            '{X:mult,C:white} X#1# {} Mult when scored',
            '{s:0.8}Rank changes every round',
        },
    },
    config = { extra = { Xmult = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_idol', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local idol = G.GAME and G.GAME.current_round and G.GAME.current_round.idol_card
        return { vars = { card.ability.extra.Xmult, localize(idol and idol.rank or 'Ace', 'ranks') } }
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
                { ref_table = 'card.joker_display_values', ref_value = 'idol_card', colour = G.C.FILTER },
                { text = ')' },
            },
            calc_function = function(card)
                local count = 0
                local idol = G.GAME.current_round.idol_card
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' and idol and idol.id then
                    for _, sc in pairs(scoring_hand) do
                        if sc:get_id() == idol.id then
                            count = count + JokerDisplay.calculate_card_triggers(sc, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.x_mult = card.ability.extra.Xmult ^ count
                card.joker_display_values.idol_card = localize(idol and idol.rank or 'Ace', 'ranks')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local idol = G.GAME.current_round.idol_card
            if idol and idol.id and context.other_card:get_id() == idol.id then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
