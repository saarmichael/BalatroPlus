-- Spec: plannig/specs/jokers/j_chaos.yaml
-- smods' SMODS.change_free_rerolls edits round_resets.free_rerolls, which the game copies into
-- current_round.free_rerolls at every new shop, so no extra hook is needed.
BPlus.Joker({
    key = 'chaos_plus',
    loc_txt = {
        name = 'Krusty the Clown',
        text = { '{C:attention}#1#{} free {C:green}Rerolls', 'per shop' },
    },
    config = { extra = { rerolls = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_chaos', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rerolls } }
    end,

    joker_display_def = function(JokerDisplay)
        return {}
    end,

    add_to_deck = function(self, card, from_debuff)
        SMODS.change_free_rerolls(card.ability.extra.rerolls)
        calculate_reroll_cost(true)
    end,

    remove_from_deck = function(self, card, from_debuff)
        SMODS.change_free_rerolls(-card.ability.extra.rerolls)
        calculate_reroll_cost(true)
    end,
})
