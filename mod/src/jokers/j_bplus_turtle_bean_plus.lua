-- Spec: plannig/specs/jokers/j_turtle_bean.yaml
-- Shrinking joker: starts fresh on upgrade (state_transfer {}), ignored by Carpenter / The Rust.
BPlus.Joker({
    key = 'turtle_bean_plus',
    loc_txt = {
        name = 'Magic Bean',
        text = {
            '{C:attention}+#1#{} hand size,',
            'reduces by {C:red}#2#{}',
            'every {C:attention}#3#{} rounds',
        },
    },
    config = { extra = { h_size = 5, h_mod = 1, every = 2, rounds = 0 } },
    blueprint_compat = false, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_turtle_bean', state_transfer = {}, carpenter_compat = false },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size, card.ability.extra.h_mod, card.ability.extra.every } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.main_eval and not context.blueprint then
            local e = card.ability.extra
            e.rounds = e.rounds + 1
            if e.rounds % e.every ~= 0 then return end
            if e.h_size - e.h_mod <= 0 then
                SMODS.destroy_cards(card, nil, nil, true)
                return { message = localize('k_eaten_ex'), colour = G.C.FILTER }
            end
            SMODS.scale_card(card, {
                ref_table = e, ref_value = 'h_size', scalar_value = 'h_mod',
                message_key = 'a_handsize_minus',
                operation = function(ref_table, ref_value, initial, change)
                    ref_table[ref_value] = initial - change
                    G.hand:change_size(-change)
                end,
            })
        end
    end,
})
