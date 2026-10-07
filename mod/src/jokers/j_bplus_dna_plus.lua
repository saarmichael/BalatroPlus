-- Spec: plannig/specs/jokers/j_dna.yaml
BPlus.Joker({
    key = 'dna_plus',
    loc_txt = {
        name = 'Mitosis',
        text = {
            'If {C:attention}first hand{} of round',
            'has only {C:attention}1{} card, add',
            '{C:attention}#1#{} permanent copies to deck',
            'and draw them to {C:attention}hand',
        },
    },
    config = { extra = { copies = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_dna', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.copies } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn and not context.blueprint then
            local eval = function() return G.GAME.current_round.hands_played == 0 end
            juice_card_until(card, eval, true)
        end
        if context.before and G.GAME.current_round.hands_played == 0 and #context.full_hand == 1 then
            local created = {}
            for _ = 1, card.ability.extra.copies do
                G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                local _card = copy_card(context.full_hand[1], nil, nil, G.playing_card)
                _card:add_to_deck()
                G.deck.config.card_limit = G.deck.config.card_limit + 1
                table.insert(G.playing_cards, _card)
                G.hand:emplace(_card)
                _card.states.visible = nil
                G.E_MANAGER:add_event(Event({ func = function()
                    _card:start_materialize()
                    return true
                end }))
                created[#created + 1] = _card
            end
            return {
                message = localize('k_copied_ex'),
                colour = G.C.CHIPS,
                card = card,
                playing_cards_created = created,
            }
        end
    end,
})
