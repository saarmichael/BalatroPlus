-- Spec: plannig/specs/jokers/j_fortune_teller.yaml
local function tarots_used()
    return G.GAME and G.GAME.consumeable_usage_total and G.GAME.consumeable_usage_total.tarot or 0
end

BPlus.Joker({
    key = 'fortune_teller_plus',
    loc_txt = {
        name = 'Oracle',
        text = {
            '{C:red}+#1#{} Mult per {C:purple}Tarot{}',
            'card used this run',
            '{C:inactive}(Currently {C:red}+#2#{C:inactive})',
        },
    },
    config = { extra = { mult_per = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_fortune_teller', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_per, card.ability.extra.mult_per * tarots_used() } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                card.joker_display_values.mult = card.ability.extra.mult_per * tarots_used()
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.set == 'Tarot' then
            local per = card.ability.extra.mult_per
            G.E_MANAGER:add_event(Event({ func = function()
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize { type = 'variable', key = 'a_mult', vars = { per * tarots_used() } } })
                return true
            end }))
            return nil, true
        end
        if context.joker_main and tarots_used() > 0 then
            return { mult = card.ability.extra.mult_per * tarots_used() }
        end
    end,
})
