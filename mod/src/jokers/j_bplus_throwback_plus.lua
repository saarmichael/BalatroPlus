-- Spec: plannig/specs/jokers/j_throwback.yaml
BPlus.Joker({
    key = 'throwback_plus',
    loc_txt = {
        name = 'Nostalgic Joker',
        text = {
            '{X:mult,C:white} X#1# {} Mult for each',
            '{C:attention}Blind{} skipped this run',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult_per = 1 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_throwback', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local skips = G.GAME and G.GAME.skips or 0
        return { vars = { card.ability.extra.Xmult_per, 1 + card.ability.extra.Xmult_per * skips } }
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
                card.joker_display_values.x_mult = 1 + card.ability.extra.Xmult_per * (G.GAME.skips or 0)
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.skip_blind and not context.blueprint then
            -- read the value now: the event runs after a Carpenter/Rust view swap has ended
            local value = 1 + card.ability.extra.Xmult_per * (G.GAME.skips or 0)
            G.E_MANAGER:add_event(Event({ func = function()
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize { type = 'variable', key = 'a_xmult', vars = { value } },
                    colour = G.C.RED,
                    card = card,
                })
                return true
            end }))
            return nil, true
        end
        if context.joker_main and (G.GAME.skips or 0) > 0 then
            return { xmult = 1 + card.ability.extra.Xmult_per * G.GAME.skips }
        end
    end,
})
