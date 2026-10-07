-- Spec: plannig/specs/jokers/j_to_the_moon.yaml
BPlus.Joker({
    key = 'to_the_moon_plus',
    loc_txt = {
        name = 'To the Stars',
        text = {
            'Earn an extra {C:money}$#1#{} of',
            '{C:attention}interest{} for every {C:money}$5{} you',
            'have at end of round',
        },
    },
    config = { extra = { interest = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_to_the_moon', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.interest } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+$' },
                { ref_table = 'card.joker_display_values', ref_value = 'dollars' },
            },
        text_config = { colour = G.C.GOLD },
        reminder_text = {
            { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
        },
            calc_function = function(card)
                card.joker_display_values.dollars = math.max(
                    math.min(math.floor(G.GAME.dollars / 5), G.GAME.interest_cap / 5), 0) * card.ability.extra.interest
                card.joker_display_values.localized_text = '(' .. localize('k_round') .. ')'
            end,
        }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount + card.ability.extra.interest
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount - card.ability.extra.interest
    end,
})
