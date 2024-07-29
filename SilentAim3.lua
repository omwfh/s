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

a.TeamCheck(false)

local b = game:GetService("Workspace")
local c = game:GetService("Players")
local d = game:GetService("RunService")
local e = game:GetService("UserInputService")
local f = c.LocalPlayer
local g = f:GetMouse()
local h = b.CurrentCamera
local i = { SilentAim = true, AimLock = true, Prediction = 0.165 }

getgenv().DaHoodSettings = i

-- Check function for the aiming module
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

-- Function to set a table as read-only or writable using __index
function setreadonly(obj, val)
    if type(obj) == 'table' then
        local mt = getmetatable(obj) or {}
        if val then
            mt.__index = function(t, k)
                error("attempt to access readonly table", 2)
            end
        else
            mt.__index = nil
        end
        setmetatable(obj, mt)
    else
        error("expected a table for the first argument", 2)
    end
end

-- Function to hook metamethods
local function hookmetamethod(obj, method, newfunc)
    local mt = getrawmetatable(obj)
    local oldfunc = mt[method]
    
    setreadonly(mt, false)
    mt[method] = newfunc
    setreadonly(mt, true)
    
    return oldfunc
end

-- Hook the __index metamethod
local m
m = hookmetamethod(game, "__index", function(n, o)
    if n:IsA("Mouse") and (o == "Hit" or o == "Target") and a.Check() then
        local p = a.SelectedPart
        if i.SilentAim and (o == "Hit" or o == "Target") then
            local q = p.CFrame + p.Velocity * i.Prediction
            return o == "Hit" and q or p
        end
    end
    return m(n, o)
end)

-- Display notification
notif("Notification", "arts private lock loaded", 5)
