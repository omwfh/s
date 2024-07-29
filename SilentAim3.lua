-- Load the aiming module
local a = loadstring(game:HttpGet("https://raw.githubusercontent.com/omwfh/sj0wjg0w/main/AimingModule.lua"))()

-- Notification function
local function notif(Title, Text, Duration)
    local CoreGUI = game:GetService("StarterGui")
    CoreGUI:SetCore("SendNotification", {
        Title = Title;
        Text = Text;
        Duration = Duration;
    })
end

-- Configure aiming module
a.TeamCheck(false)

-- Service and variable definitions
local b = game:GetService("Workspace")
local c = game:GetService("Players")
local d = game:GetService("RunService")
local e = game:GetService("UserInputService")
local f = c.LocalPlayer
local g = f:GetMouse()
local h = b.CurrentCamera
local i = { SilentAim = true, AimLock = true, Prediction = 0.165 }

-- Global settings
getgenv().DaHoodSettings = i

-- Check function
function a.Check() 
    if not (a.Enabled == true and a.Selected ~= f and a.SelectedPart ~= nil) then
        return false 
    end

    local j = a.Character(a.Selected)
    local k = j:WaitForChild("BodyEffects")["K.O"].Value
    local l = j:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

    if k or l then return false end
    return true 
end

-- Define utility functions
function getrawmetatable(obj)
    local metatable = getmetatable(obj)
    if not metatable then return nil end

    local metatables = {}
    while metatable do
        table.insert(metatables, metatable)
        metatable = getmetatable(metatable)
    end
    return metatables
end

function setrawmetatable(obj, mt)
    if type(obj) == 'table' and type(mt) == 'table' then
        setmetatable(obj, mt)
        return true
    else
        return false, "both arguments must be tables."
    end
end

function setreadonly(obj, val)
    if type(obj) == 'table' then
        local mt = getmetatable(obj) or {}
        if val then
            mt.__newindex = function(t, k, v)
                error("attempt to modify readonly table", 2)
            end
        else
            mt.__newindex = nil
        end
        setmetatable(obj, mt)
    else
        error("expected a table for the first argument", 2)
    end
end

function isreadonly(obj)
    if type(obj) == 'table' then
        local mt = getmetatable(obj)
        if mt and mt.__newindex then
            return false
        end
        return true
    else
        error("expected a table for the argument", 2)
    end
end

function make_readonly(obj)
    if type(obj) == 'table' then
        local mt = getmetatable(obj) or {}
        mt.__newindex = function(t, k, v)
            error("attempt to modify readonly table", 2)
        end
        setmetatable(obj, mt)
    else
        error("expected a table for the first argument", 2)
    end
end

function make_writeable(obj)
    if type(obj) == 'table' then
        local mt = getmetatable(obj) or {}
        mt.__newindex = nil
        setmetatable(obj, mt)
    else
        error("expected a table for the first argument", 2)
    end
end

-- Hookmetamethod function
function hookmetamethod(object, metamethod, hook)
    local mt = getmetatable(object)
    if not mt then
        error("Object does not have a metatable")
    end

    local original = mt[metamethod]

    mt[metamethod] = function(...)
        return hook(original, ...)
    end

    return original
end

-- Define the hook function
local function hookFunction(original, n, o)
    if n:IsA("Mouse") and (o == "Hit" or o == "Target") and a.Check() then
        local p = a.SelectedPart
        if i.SilentAim and (o == "Hit" or o == "Target") then
            local q = p.CFrame + p.Velocity * i.Prediction
            return o == "Hit" and q or p
        end
    end
    return original(n, o)
end

-- Hook the __index metamethod
local mt = getrawmetatable(game)
if mt then
    make_writeable(mt[1])
    hookmetamethod(game, "__index", hookFunction)
    make_readonly(mt[1])
end

-- Notification
notif("Notification", "arts private lock loaded", 5)
