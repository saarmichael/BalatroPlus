-- Spec: plannig/specs/jokers/j_blueprint.yaml (D23)
---@diagnostic disable: undefined-global
-- Architect copies the UPGRADED ability of the joker to its right. This file also holds the copy
-- machinery shared with Hive Mind (j_bplus_brainstorm_plus.lua uses BPlus.copy_plus at runtime).
--
-- Copy rule for a target joker (BPlus.copy_plus.mode):
--   1. target is a "+" joker and blueprint-compatible            -> 'direct' (copy it as it is)
--   2. target is vanilla, its "+" version is carpenter_compat (can run on the vanilla card) and
--      blueprint-compatible                                      -> 'view'   (run the "+" ability on the target)
--   3. target itself is blueprint-compatible (vanilla rule)      -> 'direct' (its regular ability)
--   4. otherwise incompatible.
BPlus.copy_plus = BPlus.copy_plus or {}
local M = BPlus.copy_plus

function M.mode(target)
    if not (target and target.config and target.config.center) then return nil end
    local center = target.config.center
    if BPlus.is_plus(target) then return center.blueprint_compat and 'direct' or nil end
    local up = BPlus.upgrade_map[center.key]
    local pc = up and G.P_CENTERS[up]
    if pc and pc.bplus and pc.bplus.carpenter_compat and pc.blueprint_compat then return 'view', pc end
    if center.blueprint_compat then return 'direct' end
    return nil
end

-- Like SMODS.blueprint_effect, but the copied effect is the target's "+" ability when the rule says so.
function M.effect(copier, target, context)
    if not target or target == copier or target.debuff or context.no_blueprint then return end
    local mode, pc = M.mode(target)
    if not mode then return end
    if (context.blueprint or 0) > #G.jokers.cards then return end

    local old_bp, old_card = context.blueprint, context.blueprint_card
    context.blueprint = (old_bp and (old_bp + 1)) or 1
    context.blueprint_card = old_card or copier
    context.blueprint_copiers_stack = context.blueprint_copiers_stack or {}
    local stack = context.blueprint_copiers_stack
    stack[#stack + 1] = copier
    context.blueprint_copier = copier
    local eff_card = context.blueprint_card

    local ok, ret
    if mode == 'view' then
        ok, ret = pcall(BPlus.plus_calculate, target, context)
    else
        ok, ret = pcall(target.calculate_joker, target, context)
    end

    context.blueprint, context.blueprint_card = old_bp, old_card
    table.remove(stack, #stack)
    context.blueprint_copier = stack[#stack]
    if not ok then error(ret, 0) end
    if ret then
        ret.card = eff_card
        return ret
    end
end

-- Blueprint-style compatibility text for a copier whose target is `target`.
function M.compat(card, target)
    return (target and target ~= card and M.mode(target)) and 'compatible' or 'incompatible'
end

-- JokerDisplay ---------------------------------------------------------------------------------
-- A vanilla target copied through its "+" ability must show the "+" display. JokerDisplay mirrors the
-- display of the copied card, so we hand it a proxy for (target, "+" center): the proxy runs the "+"
-- definition against the real target card, shaped as the "+" center, with its own value table.

M.copier_keys = M.copier_keys or {}
local proxies = setmetatable({}, { __mode = 'k' })

local function defs(key)
    local d = JokerDisplay.Definitions[key]
    if not d then
        local c = G.P_CENTERS[key]
        if c and type(c.joker_display_def) == 'function' then
            d = c.joker_display_def(JokerDisplay)
            JokerDisplay.Definitions[key] = d
        end
    end
    return d
end

local function proxy_for(target, pc)
    proxies[target] = proxies[target] or {}
    local p = proxies[target][pc.key]
    if p then return p end
    local shadow = { disabled = false, small = false }
    local function view() return target.ability.bplus_alt and target.ability.bplus_alt[pc.key] end
    local function run(fn)
        BPlus.with_center(target, pc, function()
            local real_values, real_children = target.joker_display_values, target.children
            target.joker_display_values, target.children = shadow, {}
            local ok, err = pcall(fn)
            target.joker_display_values, target.children = real_values, real_children
            if not ok then error(err, 0) end
        end)
    end
    p = setmetatable({
        joker_display_values = shadow,
        config = { center = pc },
        bplus_proxy = true,
        ability = setmetatable({}, { __index = function(_, k)
            local v = view()
            if v ~= nil and v[k] ~= nil then return v[k] end
            return target.ability[k]
        end }),
        initialize_joker_display = function(_, parent, stop) run(function() target:initialize_joker_display(parent, stop) end) end,
        calculate_joker_display = function(_, parent) run(function() target:calculate_joker_display(parent) end) end,
    }, { __index = target })
    proxies[target][pc.key] = p
    return p
end

local function resolve(card, key, depth, dbg)
    local d = defs(key)
    local getter = d and d.get_blueprint_joker
    if not getter or depth > #G.jokers.cards + 1 then return nil, false end
    local target = getter(card)
    if not target or target == card then return nil, false end
    local mode, pc
    if M.copier_keys[key] then
        mode, pc = M.mode(target)
    elseif target.config.center.blueprint_compat then
        mode = 'direct'
    end
    if not mode then return nil, false end
    dbg = dbg or target.debuff
    local tkey = mode == 'view' and pc.key or BPlus.behaves_as(target)
    local td = defs(tkey)
    if td and td.get_blueprint_joker then return resolve(target, tkey, depth + 1, dbg) end
    if mode == 'view' then return proxy_for(target, pc), dbg end
    return target, dbg
end

local installed = false
local function install_display()
    if installed or not rawget(_G, 'JokerDisplay') or not JokerDisplay.calculate_blueprint_copy then return end
    installed = true
    JokerDisplay.calculate_blueprint_copy = function(card, cycle_count, cycle_debuff)
        local joker, dbg = resolve(card, BPlus.behaves_as(card), cycle_count or 0, cycle_debuff or false)
        if joker and joker.bplus_proxy and not cycle_count then joker:calculate_joker_display(card) end
        return joker, dbg
    end
end

-- Display definition shared by Architect and Hive Mind. `get_target(card)` returns the copied card.
function M.display_def(get_target)
    install_display()
    return {
        reminder_text = {
            { text = '(' },
            { ref_table = 'card.joker_display_values', ref_value = 'blueprint_compat', colour = G.C.RED },
            { text = ')' },
        },
        calc_function = function(card)
            local copied_joker, copied_debuff = JokerDisplay.calculate_blueprint_copy(card)
            card.joker_display_values.blueprint_compat = localize('k_incompatible')
            JokerDisplay.copy_display(card, copied_joker, copied_debuff)
        end,
        get_blueprint_joker = get_target,
    }
end

-- Shared card UI (blueprint_compat badge) ----------------------------------------------------
function M.main_end(card)
    card.ability.blueprint_compat_ui = card.ability.blueprint_compat_ui or ''
    card.ability.blueprint_compat_check = nil
    return (card.area and card.area == G.jokers) and {
        { n = G.UIT.C, config = { align = 'bm', minh = 0.4 }, nodes = {
            { n = G.UIT.C, config = { ref_table = card, align = 'm', colour = G.C.JOKER_GREY, r = 0.05, padding = 0.06, func = 'blueprint_compat' }, nodes = {
                { n = G.UIT.T, config = { ref_table = card.ability, ref_value = 'blueprint_compat_ui', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
            } },
        } },
    } or nil
end

local function right_neighbour(card)
    for i, c in ipairs(G.jokers and G.jokers.cards or {}) do
        if c == card then return G.jokers.cards[i + 1] end
    end
end

BPlus.Joker({
    key = 'blueprint_plus',
    loc_txt = {
        name = 'Architect',
        text = {
            'Copies the {C:attention}upgraded{} ability',
            'of the {C:attention}Joker{} to the right',
        },
    },
    config = { extra = {} },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_blueprint', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = {}, main_end = M.main_end(card) }
    end,

    update = function(self, card, dt)
        if G.STAGE == G.STAGES.RUN and G.jokers then
            card.ability.blueprint_compat = M.compat(card, right_neighbour(card))
        end
    end,

    joker_display_def = function(JokerDisplay)
        M.copier_keys['j_bplus_blueprint_plus'] = true
        return M.display_def(right_neighbour)
    end,

    calculate = function(self, card, context)
        local ret = M.effect(card, right_neighbour(card), context)
        if ret then
            ret.colour = G.C.BLUE
            return ret
        end
    end,
})
