local a = loadstring(game:HttpGet("https://raw.githubusercontent.com/omwfh/sj0wjg0w/main/AimingModule.lua"))()

local function notif(Title, Text, Duration)
	local CoreGUI = game:GetService("StarterGui")
	CoreGUI:SetCore("SendNotification", {
		Title = Title;
		Text = Text;
		Duration = Duration;
	})
end

function checkifalive(player)
    if player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health ~= 1 and player.Character:FindFirstChild("Head") then
        return true
    end
end

function cframefix()
    if checkifalive(game.Players.LocalPlayer) then
        for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
            if v:IsA("Script") and v.Name ~= "Health" and v.Name ~= "Sound" and v:FindFirstChild("LocalScript") then
                v:Destroy()
            end
        end
        game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
            repeat
                task.wait()
            until game.Players.LocalPlayer.Character
            char.ChildAdded:Connect(function(child)
                if child:IsA("Script") then 
                    if child:FindFirstChild("LocalScript") and checkifalive(game.Players.LocalPlayer) then
                        child.LocalScript:FireServer()
                    end
                end
            end)
        end)
        local glitch = false
        local clicker = false
    end
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

local Heartbeat, RStepped, Stepped = d.Heartbeat, d.RenderStepped, d.Stepped
local RVelocity, YVelocity = nil, 0.1

getgenv().DaHoodSettings = i

function a.Check() if not (a.Enabled == true and a.Selected ~= f and a.SelectedPart ~= nil) then
		return false 
	end

	local j = a.Character(a.Selected)
	local k = j:WaitForChild("BodyEffects")["K.O"].Value
	local l = j:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

	if k or l then 
        return false 
    end
	return true 
end

local m
m = hookmetamethod(game, "__index", function(n, o) if n:IsA("Mouse") and (o == "Hit" or o == "Target") and a.Check() then
		local p = a.SelectedPart
		if i.SilentAim and (o == "Hit" or o == "Target")  then
			local q = p.CFrame + p.Velocity * i.Prediction
			return o == "Hit" and q or p 
		end 
	end
	return m(n, o)
end)

local n
n = hookmetamethod(game, "__namecall", function(Self, ...)
    local NameCallMethod = getnamecallmethod()

    if tostring(string.lower(NameCallMethod)) == "kick" then
        return nil
    end
    
    return OldNameCall(Self, ...)
end)

local Character = f.Character
local RootPart = Character:FindFirstChild("HumanoidRootPart")

d.Heartbeat:Connect(function()
    if _G.VelocityChanger == false and checkifalive(game.Players.LocalPlayer) then
        local oldpos = Character.HumanoidRootPart.Velocity

        Character.HumanoidRootPart.Velocity = Vector3.new(_G.XVelocity, _G.YVelocity, _G.ZVelocity) * _G.Multply
        d.RenderStepped:Wait()
        Character.HumanoidRootPart.Velocity = oldpos
    elseif _G.VelocityChanger == true and checkifalive(game.Players.LocalPlayer) then
        local oldpos = Character.HumanoidRootPart.Velocity
        cframefix()

        Character.HumanoidRootPart.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, 360, 0)
        Character.HumanoidRootPart.Velocity = Vector3.new(oldpos.X + math.random(1000,10000), oldpos.Y + math.random(1000,1000), oldpos.Z + math.random(1000,10000))
        d.RenderStepped:Wait()
        Character.HumanoidRootPart.Velocity = oldpos
        d.RenderStepped:Wait()
    end
end)

e.InputBegan:Connect(function(input)
    if not (e:GetFocusedTextBox()) then
        if input.KeyCode == Enum.KeyCode.Z then
            if _G.VelocityChanger == false then
                _G.VelocityChanger == true
                notif("Notification", "ANTI ON", 2)
            elseif _G.VelocityChanger == true then
                _G.VelocityChanger = false
                notif("Notification", "ANTI OFF", 2)
            end
        end
    end
end)

if _G.AimViewer == true then
    pcall(function()
        wait(0.02)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/omwfh/sj0wjg0w/main/aimviewer.lua"))()
    end)
end

notif("Notification", "ruis private lock loaded", 5)
