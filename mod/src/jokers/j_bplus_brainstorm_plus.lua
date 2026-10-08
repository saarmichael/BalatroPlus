-- Spec: plannig/specs/jokers/j_brainstorm.yaml (D23)
-- Hive Mind copies the UPGRADED ability of the leftmost Joker. Copy rule and JokerDisplay support live in
-- BPlus.copy_plus (defined in j_bplus_blueprint_plus.lua; only used at runtime here).
local function leftmost(card)
    return G.jokers and G.jokers.cards[1]
end

BPlus.Joker({
    key = 'brainstorm_plus',
    loc_txt = {
        name = 'Hive Mind',
        text = {
            'Copies the {C:attention}upgraded{} ability',
            'of the {C:attention}leftmost{} Joker',
        },
    },
    config = { extra = {} },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_brainstorm', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = {}, main_end = BPlus.copy_plus.main_end(card) }
    end,

    update = function(self, card, dt)
        if G.STAGE == G.STAGES.RUN and G.jokers then
            card.ability.blueprint_compat = BPlus.copy_plus.compat(card, leftmost(card))
        end
    end,

    joker_display_def = function(JokerDisplay)
        BPlus.copy_plus.copier_keys['j_bplus_brainstorm_plus'] = true
        return BPlus.copy_plus.display_def(leftmost)
    end,

    calculate = function(self, card, context)
        local ret = BPlus.copy_plus.effect(card, leftmost(card), context)
        if ret then
            ret.colour = G.C.RED
            return ret
        end
    end,
})
