-- Spec: plannig/specs/jokers/j_bootstraps.yaml
BPlus.Joker({
    key = 'bootstraps_plus',
    loc_txt = {
        name = 'Self-Made',
        text = {
            '{C:mult}+#1#{} Mult for every',
            '{C:money}$#2#{} you have',
            '{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)',
        },
    },
    config = { extra = { mult = 2, dollars = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_bootstraps', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.mult, e.dollars, e.mult * math.floor(((G.GAME.dollars or 0) + (G.GAME.dollar_buffer or 0)) / e.dollars) } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local e = card.ability.extra
            local steps = math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / e.dollars)
            if steps >= 1 then return { mult = e.mult * steps } end
        end
    end,
})
