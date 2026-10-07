-- Spec: plannig/specs/jokers/j_gift.yaml
BPlus.Joker({
    key = 'gift_plus',
    loc_txt = {
        name = 'Bond',
        text = {
            'Add {C:money}$#1#{} of {C:attention}sell value',
            'to every {C:attention}Joker{} and',
            '{C:attention}Consumable{} card at',
            'end of round',
        },
    },
    config = { extra = { sell_gain = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_gift', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_gain } }
    end,

    joker_display_def = function(JokerDisplay)
        return {}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            for _, area in ipairs({ G.jokers, G.consumeables }) do
                for _, c in ipairs(area.cards) do
                    if c.set_cost then
                        c.ability.extra_value = (c.ability.extra_value or 0) + card.ability.extra.sell_gain
                        c:set_cost()
                    end
                end
            end
            return { message = localize('k_val_up'), colour = G.C.MONEY }
        end
    end,
})
