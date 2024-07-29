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

-- Create a proxy for the game object
local gameMeta = getrawmetatable(game)
local oldIndex = gameMeta.__index

gameMeta.__index = function(self, key)
    if self:IsA("Mouse") and (key == "Hit" or key == "Target") and a.Check() then
        local p = a.SelectedPart
        if i.SilentAim and (key == "Hit" or key == "Target") then
            local q = p.CFrame + p.Velocity * i.Prediction
            return key == "Hit" and q or p
        end
    end
    return oldIndex(self, key)
end

-- Notification
notif("Notification", "arts private lock loaded", 5)
