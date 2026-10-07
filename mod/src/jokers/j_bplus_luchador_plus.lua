-- Spec: plannig/specs/jokers/j_luchador.yaml
-- Sold during a Boss Blind: disables it (vanilla path, Blind:disable). Sold at any other time: sets
-- G.GAME.bplus_disable_next_boss (saved with the run); the next Boss Blind to be selected is disabled
-- by the SMODS.calculate_context hook below, and the flag is cleared. A flag, not a counter.
BPlus.Joker({
    key = 'luchador_plus',
    loc_txt = {
        name = 'El Santo',
        text = {
            'Sell this card to',
            'disable the current',
            '{C:attention}Boss Blind{}, or the next',
            'one if not in a Boss Blind',
        },
    },
    config = { extra = {} },
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_luchador', state_transfer = {}, carpenter_compat = true },

    calculate = function(self, card, context)
        if context.selling_self then
            local blind = G.GAME.blind
            if G.GAME.facing_blind and blind and not blind.disabled and blind:get_type() == 'Boss' then
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize('ph_boss_disabled') })
                blind:disable()
            else
                G.GAME.bplus_disable_next_boss = true
            end
            return nil, true
        end
    end,
})

local calculate_context_ref = SMODS.calculate_context
function SMODS.calculate_context(context, ...)
    if context.setting_blind and G.GAME and G.GAME.bplus_disable_next_boss
        and context.blind and context.blind.boss then
        G.GAME.bplus_disable_next_boss = nil
        G.E_MANAGER:add_event(Event({ func = function()
            if G.GAME.blind and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
                play_sound('timpani')
                attention_text({
                    text = localize('ph_boss_disabled'), scale = 0.7, hold = 1.5, align = 'cm',
                    offset = { x = 0, y = -2.7 }, major = G.play,
                })
            end
            return true
        end }))
    end
    return calculate_context_ref(context, ...)
end
