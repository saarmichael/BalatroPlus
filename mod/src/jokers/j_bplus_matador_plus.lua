-- Spec: plannig/specs/jokers/j_matador.yaml
BPlus.Joker({
    key = 'matador_plus',
    loc_txt = {
        name = 'Toreador',
        text = { 'Earn {C:money}$#1#{} if played', 'hand triggers the', '{C:attention}Boss Blind{} ability' },
    },
    config = { extra = { dollars = 20 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_matador', state_transfer = {}, carpenter_compat = true },

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
                { text = '(', colour = G.C.UI.TEXT_INACTIVE },
                { ref_table = 'card.joker_display_values', ref_value = 'active_text' },
                { text = ')', colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                local dollars = 0
                local text, poker_hands, scoring_hand = JokerDisplay.evaluate_hand()
                local boss_active = G.GAME.blind and G.GAME.blind.get_type
                    and ((not G.GAME.blind.disabled) and (G.GAME.blind:get_type() == 'Boss'))
                card.joker_display_values.active = boss_active
                if boss_active then
                    local triggers = JokerDisplay.triggers_blind(G.GAME.blind, text, poker_hands, scoring_hand, JokerDisplay.current_hand)
                    if triggers then
                        dollars = card.ability.extra.dollars
                    elseif triggers == nil then
                        dollars = card.ability.extra.dollars .. '?'
                    end
                end
                card.joker_display_values.dollars = dollars
                card.joker_display_values.active_text = localize(boss_active and 'jdis_active' or 'jdis_inactive')
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] and card.joker_display_values then
                    reminder_text.children[2].config.colour = card.joker_display_values.active and G.C.GREEN or G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end,

    calculate = function(self, card, context)
        if (context.joker_main or context.debuffed_hand) and G.GAME.blind.triggered then
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
