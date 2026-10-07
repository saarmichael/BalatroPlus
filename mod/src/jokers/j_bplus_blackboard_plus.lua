-- Spec: plannig/specs/jokers/j_blackboard.yaml
BPlus.Joker({
    key = 'blackboard_plus',
    loc_txt = {
        name = 'Smartboard',
        text = {
            '{X:red,C:white} X#1# {} Mult if most',
            'cards held in hand',
            'are {C:spades}#2#{} or {C:clubs}#3#{}',
        },
    },
    config = { extra = { Xmult = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_blackboard', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, localize('Spades', 'suits_plural'), localize('Clubs', 'suits_plural') } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local black, total = 0, 0
            for _, c in ipairs(G.hand.cards) do
                total = total + 1
                if c:is_suit('Clubs', nil, true) or c:is_suit('Spades', nil, true) then black = black + 1 end
            end
            -- strict majority; an empty hand also triggers (as vanilla does)
            if total == 0 or black * 2 > total then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
