-- Spec: plannig/specs/jokers/j_mail.yaml
BPlus.Joker({
    key = 'mail_plus',
    loc_txt = {
        name = 'Cashback',
        text = {
            'Earn {C:money}$#1#{} for each',
            'discarded {C:attention}#2#{}, rank',
            'changes every round',
        },
    },
    config = { extra = { dollars = 6 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_mail', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local mail = G.GAME and G.GAME.current_round and G.GAME.current_round.mail_card
        return { vars = { card.ability.extra.dollars, localize(mail and mail.rank or 'Ace', 'ranks') } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+$' },
                { ref_table = 'card.joker_display_values', ref_value = 'dollars', retrigger_type = 'mult' },
            },
        text_config = { colour = G.C.GOLD },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'mail_card_rank', colour = G.C.ORANGE },
                { text = ')' },
            },
            reminder_text_config = { scale = 0.35 },
            calc_function = function(card)
                local dollars = 0
                local in_blind = G.GAME.blind and G.GAME.blind.in_blind or G.STATE == G.STATES.SELECTING_HAND
                    or G.STATE == G.STATES.HAND_PLAYED or G.STATE == G.STATES.DRAW_TO_HAND
                local hand = in_blind and G.hand.highlighted or {}
                local mail = G.GAME.current_round.mail_card
                for _, c in pairs(hand) do
                    if c.facing and c.facing ~= 'back' and not c.debuff and c:get_id() == mail.id then
                        dollars = dollars + card.ability.extra.dollars
                    end
                end
                card.joker_display_values.dollars = G.GAME.current_round.discards_left > 0 and dollars or 0
                card.joker_display_values.mail_card_rank = localize(mail.rank, 'ranks')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff
            and context.other_card:get_id() == G.GAME.current_round.mail_card.id then
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
