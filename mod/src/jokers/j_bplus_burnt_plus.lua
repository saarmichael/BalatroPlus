-- Spec: plannig/specs/jokers/j_burnt.yaml
BPlus.Joker({
    key = 'burnt_plus',
    loc_txt = {
        name = 'Scorched Joker',
        text = {
            'Upgrade the level of',
            'the first {C:attention}discarded',
            'poker hand each round',
            'by {C:attention}#1#{} levels',
        },
    },
    config = { extra = { levels = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_burnt', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.levels } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'active_text' },
                { text = ')' },
            },
            calc_function = function(card)
                local in_blind = G.GAME.blind and G.GAME.blind.in_blind or G.STATE == G.STATES.SELECTING_HAND or
                    G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND
                card.joker_display_values.is_active = in_blind and
                    G.GAME.current_round.discards_used <= 0 and G.GAME.current_round.discards_left > 0 or false
                card.joker_display_values.active_text = localize(card.joker_display_values.is_active and 'jdis_active' or 'jdis_inactive')
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN or
                        G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.pre_discard and G.GAME.current_round.discards_used <= 0 and not context.hook then
            local text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, { message = localize('k_upgrade_ex') })
            level_up_hand(context.blueprint_card or card, text, nil, card.ability.extra.levels)
        end
    end,
})
