-- Spec: plannig/specs/jokers/j_chicot.yaml
BPlus.Joker({
    key = 'chicot_plus',
    loc_txt = {
        name = 'Chicot+',
        text = {
            'Disables effect of',
            'every {C:attention}Boss Blind{}.',
            'All {C:attention}Blinds{} require',
            '{C:attention}#1#%{} fewer chips',
        },
    },
    config = { extra = { blind_reduction = 0.25 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_chicot', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.blind_reduction * 100 } }
    end,

    -- like vanilla Chicot: disables a Boss Blind that is already active when it is added
    add_to_deck = function(self, card, from_debuff)
        if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
            G.GAME.blind:disable()
            play_sound('timpani')
            card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('ph_boss_disabled') })
        end
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(', colour = G.C.UI.TEXT_INACTIVE },
                { ref_table = 'card.joker_display_values', ref_value = 'active_text' },
                { text = ')', colour = G.C.UI.TEXT_INACTIVE },
            },
            calc_function = function(card)
                local disableable = G.GAME.blind and G.GAME.blind.get_type and (G.GAME.blind:get_type() == 'Boss')
                card.joker_display_values.active = disableable
                card.joker_display_values.active_text = localize(disableable and 'jdis_active' or 'jdis_inactive')
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.active and G.C.GREEN
                        or G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and not card.getting_sliced then
            if context.blind.boss then
                G.E_MANAGER:add_event(Event({ func = function()
                    G.E_MANAGER:add_event(Event({ func = function()
                        G.GAME.blind:disable()
                        play_sound('timpani')
                        delay(0.4)
                        return true
                    end }))
                    card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('ph_boss_disabled') })
                    return true
                end }))
            end
            local blind = G.GAME.blind
            blind.chips = math.floor(blind.chips * (1 - card.ability.extra.blind_reduction))
            blind.chip_text = number_format(blind.chips)
        end
    end,
})
