-- Spec: plannig/specs/jokers/j_certificate.yaml
BPlus.Joker({
    key = 'certificate_plus',
    loc_txt = {
        name = 'Diploma',
        text = {
            'When round begins,',
            'add {C:attention}#1#{} random {C:attention}playing',
            '{C:attention}cards{} with random',
            '{C:attention}seals{} to your hand',
        },
    },
    config = { extra = { cards = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_certificate', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {} -- vanilla Certificate shows nothing either
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,

    calculate = function(self, card, context)
        if context.first_hand_drawn then
            local blueprint_card = context.blueprint_card
            local count = card.ability.extra.cards
            G.E_MANAGER:add_event(Event({ func = function()
                local created = {}
                for _ = 1, count do
                    local _card = create_playing_card({
                        front = pseudorandom_element(G.P_CARDS, pseudoseed('bplus_diploma_fr')),
                        center = G.P_CENTERS.c_base }, G.hand, nil, nil, { G.C.SECONDARY_SET.Enhanced })
                    _card:set_seal(SMODS.poll_seal({ type_key = 'bplus_diploma', guaranteed = true }), nil, true)
                    G.GAME.blind:debuff_card(_card)
                    created[#created + 1] = _card
                end
                G.hand:sort()
                if blueprint_card then blueprint_card:juice_up() else card:juice_up() end
                playing_card_joker_effects(created)
                save_run()
                return true
            end }))
            return nil, true
        end
    end,
})
