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

-- Function to set a table as read-only or writable
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
local originalIndex
originalIndex = hookmetamethod(game, "__index", function(instance, property)
    -- Check if the instance is of type "Mouse" and the property is either "Hit" or "Target"
    if instance:IsA("Mouse") and (property == "Hit" or property == "Target") and a.Check() then
        local selectedPart = a.SelectedPart
        if i.SilentAim then
            -- Calculate the new CFrame or part to return
            local predictedCFrame = selectedPart.CFrame + selectedPart.Velocity * i.Prediction
            if property == "Hit" then
                return predictedCFrame
            else
                return selectedPart
            end
        end
    end
    -- Fallback to the original behavior if the conditions are not met
    return originalIndex(instance, property)
end)

-- Display notification
notif("Notification", "arts private lock loaded", 5)
