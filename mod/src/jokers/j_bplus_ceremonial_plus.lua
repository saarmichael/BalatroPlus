-- Spec: plannig/specs/jokers/j_ceremonial.yaml
BPlus.Joker({
    key = 'ceremonial_plus',
    loc_txt = {
        name = 'Sacrificial Dagger',
        text = {
            'When {C:attention}Blind{} is selected,',
            'destroy Joker to the right',
            'and permanently add {C:attention}#1#X{} its',
            'sell value to this {C:red}Mult',
            '{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)',
        },
    },
    config = { extra = { sell_mult = 3, mult = 0 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_ceremonial', state_transfer = { ['mult'] = 'extra.mult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.sell_mult, card.ability.extra.mult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
        }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint then
            local my_pos
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            local target = my_pos and G.jokers.cards[my_pos + 1]
            if target and not card.getting_sliced and not SMODS.is_eternal(target, card) and not target.getting_sliced then
                target.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                G.E_MANAGER:add_event(Event({ func = function()
                    G.GAME.joker_buffer = 0
                    card:juice_up(0.8, 0.8)
                    target:start_dissolve({ HEX('57ecab') }, nil, 1.6)
                    play_sound('slice1', 0.96 + math.random() * 0.08)
                    return true
                end }))
                local e = card.ability.extra
                SMODS.scale_card(card, {
                    ref_table = e,
                    ref_value = 'mult',
                    scalar_table = target,
                    scalar_value = 'sell_cost',
                    scalar_factor = e.sell_mult,
                    scaling_message = {
                        message = localize { type = 'variable', key = 'a_mult', vars = { e.mult + e.sell_mult * target.sell_cost } },
                        colour = G.C.RED,
                        no_juice = true,
                    },
                })
                return nil, true
            end
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
    end,
})
