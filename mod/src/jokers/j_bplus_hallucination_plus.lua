-- Spec: plannig/specs/jokers/j_hallucination.yaml
BPlus.Joker({
    key = 'hallucination_plus',
    loc_txt = {
        name = 'Fever Dream',
        text = {
            'Create a {C:tarot}Tarot{} card when any',
            '{C:attention}Booster Pack{} is opened',
            '{C:inactive}(Must have room)',
        },
    },
    config = { extra = {} },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_hallucination', state_transfer = {}, carpenter_compat = true },

    calculate = function(self, card, context)
        if context.open_booster
            and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    local c = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'bplus_fever_dream')
                    c:add_to_deck()
                    G.consumeables:emplace(c)
                    G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                    return true
                end,
            }))
            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil,
                { message = localize('k_plus_tarot'), colour = G.C.PURPLE })
            return nil, true
        end
    end,
})
