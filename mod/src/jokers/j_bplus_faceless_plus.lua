-- Spec: plannig/specs/jokers/j_faceless.yaml
BPlus.Joker({
    key = 'faceless_plus',
    loc_txt = {
        name = 'Undercover Joker',
        text = {
            'Earn {C:money}$#1#{} if {C:attention}#2#{} or',
            'more {C:attention}face cards{}',
            'are discarded',
            'at the same time',
        },
    },
    config = { extra = { dollars = 6, faces = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_faceless', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars, card.ability.extra.faces } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+$' },
                { ref_table = 'card.joker_display_values', ref_value = 'dollars', retrigger_type = 'mult' },
            },
        text_config = { colour = G.C.GOLD },
            calc_function = function(card)
                local count = 0
                local in_blind = G.GAME.blind and G.GAME.blind.in_blind or G.STATE == G.STATES.SELECTING_HAND
                    or G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND
                local hand = in_blind and G.hand.highlighted or {}
                for _, c in pairs(hand) do
                    if c.facing and c.facing ~= 'back' and c:is_face() then count = count + 1 end
                end
                card.joker_display_values.dollars = (G.GAME.current_round.discards_left > 0
                    and count >= card.ability.extra.faces) and card.ability.extra.dollars or 0
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.discard and context.other_card == context.full_hand[#context.full_hand] then
            local faces = 0
            for _, c in ipairs(context.full_hand) do
                if c:is_face() then faces = faces + 1 end
            end
            if faces >= card.ability.extra.faces then
                return { dollars = card.ability.extra.dollars }
            end
        end
    end,
})
