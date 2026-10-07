-- Spec: plannig/specs/jokers/j_misprint.yaml
-- Vanilla shows a scrolling random number (custom UI in card.lua); this one uses plain text.
BPlus.Joker({
    key = 'misprint_plus',
    loc_txt = {
        name = 'Never Misprint',
        text = {
            '{C:red}+#1#{} to {C:red}+#2#{} Mult',
            '{C:inactive}(random each hand)',
        },
    },
    config = { extra = { min = 10, max = 50 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_misprint', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.min, card.ability.extra.max } }
    end,

    joker_display_def = function(JokerDisplay)
        local range = {}
        local e = G.P_CENTERS['j_bplus_misprint_plus'].config.extra
        for i = e.min, e.max do range[#range + 1] = tostring(i) end
        return {
            text = {
                { text = '+', colour = G.C.MULT },
                {
                    dynatext = {
                        string = range,
                        colours = { G.C.MULT },
                        pop_in_rate = 9999999,
                        silent = true,
                        random_element = true,
                        pop_delay = 0.5,
                        scale = 0.4,
                        min_cycle_time = 0,
                    },
                },
            },
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { mult = pseudorandom('bplus_misprint', card.ability.extra.min, card.ability.extra.max) }
        end
    end,
})
