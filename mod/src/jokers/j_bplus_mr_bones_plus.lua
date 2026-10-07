-- Spec: plannig/specs/jokers/j_mr_bones.yaml
-- Same save as Mr. Bones, but it only self destructs on a failed odds roll.
BPlus.Joker({
    key = 'mr_bones_plus',
    loc_txt = {
        name = 'Lich',
        text = {
            'Prevents Death',
            'if chips scored',
            'are at least {C:attention}25%',
            'of required chips',
            '{C:green}#1# in #2#{} chance to',
            '{S:1.1,C:red,E:2}self destruct{}',
        },
    },
    config = { extra = { odds = 2 } },
    blueprint_compat = false, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_mr_bones', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_lich')
        return { vars = { num, den } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'active_text' },
                { text = ')' },
            },
            calc_function = function(card)
                local ratio = (G.GAME.chips or 0) / ((G.GAME.blind or {}).chips or 1)
                card.joker_display_values.is_active = ratio >= 0.25 and (G.GAME.chips or 0) > 0
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
        if context.end_of_round and context.main_eval and context.game_over
            and G.GAME.chips / G.GAME.blind.chips >= 0.25 then
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.hand_text_area.blind_chips:juice_up()
                    G.hand_text_area.game_chips:juice_up()
                    return true
                end,
            }))
            if SMODS.pseudorandom_probability(card, 'bplus_lich', 1, card.ability.extra.odds) then
                SMODS.destroy_cards(card, nil, nil, nil)
            end
            return { message = localize('k_saved_ex'), saved = true, colour = G.C.RED }
        end
    end,
})
