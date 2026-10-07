-- Assertions. A failed assertion aborts the current test only and is reported with the
-- test-file line that made it.

local T = BPlus.test

local Failure = {}
Failure.__tostring = function(f) return f.message end

function T.is_failure(err)
    return getmetatable(err) == Failure
end

-- First stack frame that belongs to a test file (chunk names look like `[SMODS BalatroPlus "dev/tests/x.lua"]`).
function T.test_location(start_level)
    for level = start_level or 3, 30 do
        local info = debug.getinfo(level, 'Sl')
        if not info then return nil end
        local file = info.source:match('"(dev/tests/.-)"')
        if file then return file .. ':' .. info.currentline end
    end
end

function T.fail(message)
    error(setmetatable({ message = message, where = T.test_location() }, Failure), 0)
end

local function show(value)
    return BPlus.dev.inspect(value, 3)
end

local function prefix(what)
    return what and (what .. ': ') or ''
end

local function deep_equal(a, b)
    if a == b then return true end
    if type(a) ~= 'table' or type(b) ~= 'table' then return false end
    for k, v in pairs(a) do
        if not deep_equal(v, b[k]) then return false end
    end
    for k in pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

-- Deep equality for tables, == for everything else.
function T.eq(actual, expected, what)
    if not deep_equal(actual, expected) then
        T.fail(('%sexpected %s, got %s'):format(prefix(what), show(expected), show(actual)))
    end
end

function T.near(actual, expected, tolerance, what)
    tolerance = tolerance or 1e-6
    if type(actual) ~= 'number' or math.abs(actual - expected) > tolerance then
        T.fail(('%sexpected %s (±%s), got %s'):format(prefix(what), show(expected), tolerance, show(actual)))
    end
end

function T.truthy(value, what)
    if not value then T.fail(prefix(what) .. 'expected a truthy value, got ' .. show(value)) end
end

function T.falsy(value, what)
    if value then T.fail(prefix(what) .. 'expected a falsy value, got ' .. show(value)) end
end

function T.contains(list, value, what)
    for _, v in ipairs(list or {}) do
        if deep_equal(v, value) then return end
    end
    T.fail(('%sexpected %s to contain %s'):format(prefix(what), show(list), show(value)))
end

-- Run fn and assert it fails (a T.fail or a Lua error). Returns the failure message.
function T.errors(fn, what)
    local ok, err = pcall(fn)
    if ok then T.fail(prefix(what) .. 'expected an error, but none was raised') end
    return T.is_failure(err) and err.message or tostring(err)
end
