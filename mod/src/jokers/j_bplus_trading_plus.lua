-- Spec: plannig/specs/jokers/j_trading.yaml
BPlus.Joker({
    key = 'trading_plus',
    loc_txt = {
        name = 'Chase Card',
        text = {
            'If {C:attention}first discard{} of round',
            'has only {C:attention}1{} card, destroy',
            'it and earn {C:money}$#1#',
        },
    },
    config = { extra = { dollars = 6 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_trading', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { ref_table = 'card.joker_display_values', ref_value = 'dollars', colour = G.C.GOLD, retrigger_type = 'mult' },
            },
            reminder_text = {
                { text = '(', colour = G.C.UI.TEXT_INACTIVE },
                { ref_table = 'card.joker_display_values', ref_value = 'active_text' },
                { text = ')', colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                local in_blind = G.GAME.blind and G.GAME.blind.in_blind or G.STATE == G.STATES.SELECTING_HAND
                    or G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND
                local highlighted = in_blind and G.hand and G.hand.highlighted or {}
                local v = card.joker_display_values
                v.active = in_blind and G.GAME.current_round.discards_used == 0 and G.GAME.current_round.discards_left > 0
                v.is_active = v.active
                v.active_text = localize(v.is_active and 'jdis_active' or 'jdis_inactive')
                v.dollars = v.active
                    and ('+$' .. (#highlighted == 1 and JokerDisplay.number_format(card.ability.extra.dollars) or 0))
                    or '-'
            end,
            style_function = function(card, text, reminder_text, extra)
                if text and text.children[1] then
                    text.children[1].config.colour = card.joker_display_values.active and G.C.GOLD or G.C.UI.TEXT_INACTIVE
                end
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint
            and G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 then
            return { dollars = card.ability.extra.dollars, remove = true }
        end
    end,
})
