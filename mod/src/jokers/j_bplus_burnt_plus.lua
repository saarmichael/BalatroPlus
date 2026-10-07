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

    calculate = function(self, card, context)
        if context.pre_discard and G.GAME.current_round.discards_used <= 0 and not context.hook then
            local text = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, { message = localize('k_upgrade_ex') })
            level_up_hand(context.blueprint_card or card, text, nil, card.ability.extra.levels)
        end
    end,
})
