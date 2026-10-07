-- Spec: plannig/specs/jokers/j_marble.yaml
BPlus.Joker({
    key = 'marble_plus',
    loc_txt = {
        name = 'Medusa',
        text = {
            'If {C:attention}first hand{} of round',
            'has only {C:attention}1{} card, turn it',
            'into a {C:attention}Stone{} card',
        },
    },
    config = { extra = {} },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_marble', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {} -- vanilla Marble Joker shows nothing either
    end,

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_stone
        return { vars = {} }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint
            and G.GAME.current_round.hands_played == 0 and #context.full_hand == 1 then
            local target = context.full_hand[1]
            target:set_ability(G.P_CENTERS.m_stone, nil, true)
            G.E_MANAGER:add_event(Event({ func = function()
                target:juice_up()
                return true
            end }))
            return { message = localize('k_stone'), colour = G.C.SECONDARY_SET.Enhanced, card = card }
        end
    end,
})
