-- Spec: plannig/specs/jokers/j_burglar.yaml
BPlus.Joker({
    key = 'burglar_plus',
    loc_txt = {
        name = 'Cat Burglar',
        text = {
            'When {C:attention}Blind{} is selected,',
            'gain {C:blue}+#1#{} Hands and',
            '{C:attention}lose all discards',
        },
    },
    config = { extra = { hands = 5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_burglar', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {} -- vanilla Burglar shows nothing either
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.hands } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced then
            local hands = card.ability.extra.hands
            G.E_MANAGER:add_event(Event({ func = function()
                ease_discard(-G.GAME.current_round.discards_left, nil, true)
                ease_hands_played(hands)
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_hands', vars = { hands } } })
                return true
            end }))
            return nil, true
        end
    end,
})
