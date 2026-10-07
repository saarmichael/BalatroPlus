-- Spec: plannig/specs/jokers/j_dusk.yaml
BPlus.Joker({
    key = 'dusk_plus',
    loc_txt = {
        name = 'Twilight',
        text = {
            'Retrigger all played',
            'cards in {C:attention}final',
            '{C:attention}hand{} of round,',
            '{C:green}#1# in #2#{} chance to',
            'retrigger them again',
        },
    },
    config = { extra = { retriggers = 1, odds = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_dusk', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'active_text' },
                { text = ')' },
            },
            calc_function = function(card)
                card.joker_display_values.is_active = G.GAME.current_round.hands_left <= 1
                card.joker_display_values.active_text = localize('jdis_' ..
                    (card.joker_display_values.is_active and 'active' or 'inactive'))
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN
                        or G.C.UI.TEXT_INACTIVE
                end
            end,
            retrigger_function = function(playing_card, scoring_hand, held_in_hand, joker_card)
                if held_in_hand then return 0 end
                return JokerDisplay.in_scoring(playing_card, scoring_hand) and G.GAME.current_round.hands_left <= 1
                    and joker_card.ability.extra.retriggers * JokerDisplay.calculate_joker_triggers(joker_card) or 0
            end,
        }
    end,

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_twilight')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and G.GAME.current_round.hands_left == 0 then
            local bonus = SMODS.pseudorandom_probability(card, 'bplus_twilight', 1, card.ability.extra.odds)
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.retriggers + (bonus and 1 or 0),
                card = card,
            }
        end
    end,
})
