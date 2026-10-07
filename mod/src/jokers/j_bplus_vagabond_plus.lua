-- Spec: plannig/specs/jokers/j_vagabond.yaml
BPlus.Joker({
    key = 'vagabond_plus',
    loc_txt = {
        name = 'Nomad',
        text = {
            'Create a {C:purple}Tarot{} card',
            'if hand is played',
            'with {C:money}$#1#{} or less',
        },
    },
    config = { extra = { dollars = 6 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_vagabond', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'count', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.SECONDARY_SET.Tarot },
            calc_function = function(card)
                card.joker_display_values.active = G.GAME.dollars <= card.ability.extra.dollars
                card.joker_display_values.count = card.joker_display_values.active and 1 or 0
            end,
        }
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.joker_main
            and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
            and G.GAME.dollars <= card.ability.extra.dollars then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    local c = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'bplus_nomad')
                    c:add_to_deck()
                    G.consumeables:emplace(c)
                    G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                    return true
                end,
            }))
            return { message = localize('k_plus_tarot'), card = card }
        end
    end,
})
