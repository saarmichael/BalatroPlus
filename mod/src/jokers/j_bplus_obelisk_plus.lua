-- Spec: plannig/specs/jokers/j_obelisk.yaml
BPlus.Joker({
    key = 'obelisk_plus',
    loc_txt = {
        name = 'Pyramid',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'per {C:attention}consecutive{} hand played',
            'without playing your',
            'most played {C:attention}poker hand',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 0.4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_obelisk', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            calc_function = function(card)
                local in_blind = G.GAME.blind and G.GAME.blind.in_blind or G.STATE == G.STATES.SELECTING_HAND or
                    G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND
                local hand = in_blind and G.hand.highlighted or {}
                local text, _, _ = JokerDisplay.evaluate_hand(hand)
                local play_more_than = 0
                local hand_exists = text ~= 'Unknown' and G.GAME.hands and G.GAME.hands[text]
                if hand_exists then
                    for _, poker_hand in pairs(G.GAME.hands) do
                        if poker_hand.played and poker_hand.played >= play_more_than and poker_hand.visible then
                            play_more_than = poker_hand.played
                        end
                    end
                end
                card.joker_display_values.x_mult = (hand_exists and (G.GAME.hands[text].played >= play_more_than
                    and 1 or card.ability.extra.Xmult + card.ability.extra.Xmult_mod) or card.ability.extra.Xmult)
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local reset = true
            local played = G.GAME.hands[context.scoring_name].played or 0
            for k, v in pairs(G.GAME.hands) do
                if k ~= context.scoring_name and v.played >= played and SMODS.is_poker_hand_visible(k) then
                    reset = false
                end
            end
            if reset then
                if card.ability.extra.Xmult > 1 then
                    SMODS.reset_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', reset_value = 1 })
                end
            else
                SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod', no_message = true })
            end
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
