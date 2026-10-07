-- Spec: plannig/specs/jokers/j_crafty.yaml
BPlus.Joker({
    key = 'crafty_plus',
    loc_txt = {
        name = 'Shrewd Joker',
        text = { '{C:chips}+#1#{} Chips if played', 'hand contains', '{C:attention}#2#{}' },
    },
    config = { extra = { t_chips = 140, type = 'Flush' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_crafty', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_chips, localize(card.ability.extra.type, 'poker_hands') } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { chips = card.ability.extra.t_chips }
        end
    end,
})
