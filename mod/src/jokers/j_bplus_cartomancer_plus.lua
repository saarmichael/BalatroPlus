-- Spec: plannig/specs/jokers/j_cartomancer.yaml
local function make_tarot(card)
    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
    G.E_MANAGER:add_event(Event({
        func = function()
            G.E_MANAGER:add_event(Event({
                func = function()
                    local c = create_card('Tarot', G.consumeables, nil, nil, nil, nil, nil, 'bplus_clairvoyant')
                    c:add_to_deck()
                    G.consumeables:emplace(c)
                    G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                    return true
                end,
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil,
                { message = localize('k_plus_tarot'), colour = G.C.PURPLE })
            return true
        end,
    }))
end

BPlus.Joker({
    key = 'cartomancer_plus',
    loc_txt = {
        name = 'Clairvoyant',
        text = {
            'Create a {C:tarot}Tarot{} card when',
            '{C:attention}Blind{} is selected and when',
            '{C:attention}Blind{} is defeated',
            '{C:inactive}(Must have room)',
        },
    },
    config = { extra = {} },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_cartomancer', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {}
    end,

    calculate = function(self, card, context)
        local room = #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit
        if context.setting_blind and not (context.blueprint_card or card).getting_sliced and room then
            make_tarot(context.blueprint_card or card)
            return nil, true
        end
        if context.end_of_round and context.main_eval and room then
            make_tarot(context.blueprint_card or card)
            return nil, true
        end
    end,
})
