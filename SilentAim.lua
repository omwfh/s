local a = loadstring(game:HttpGet("https://raw.githubusercontent.com/omwfh/sj0wjg0w/main/AimingModule.lua"))()

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

local Heartbeat, RStepped, Stepped = d.Heartbeat, d.RenderStepped, d.Stepped
local RVelocity, YVelocity = nil, 0.1

e.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Z then
        if VelocityChanger == false then
            notif("Notification", "ANTI OFF", 2)
        elseif VelocityChanger == true then
            notif("Notification", "ANTI ON", 2)
        end
    end
end)

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
m = hookmetamethod(game, "__index", function(n,o) if n:IsA("Mouse") and (o == "Hit" or o == "Target") and a.Check() then
		local p = a.SelectedPart
		if i.SilentAim and (o == "Hit" or o == "Target") then
			local q = p.CFrame + p.Velocity * i.Prediction
			return o == "Hit" and q or p 
		end 
	end
	return m(n, o)
end)

local Character = f.Character
local RootPart = Character:FindFirstChild("HumanoidRootPart")

e.InputBegan:Connect(function(input)
    if not (e:GetFocusedTextBox()) then
        if input.KeyCode == Enum.KeyCode.Z then
            if VelocityChanger then
                VelocityChanger = false
            else
                VelocityChanger = true
                task.spawn(function()
                        while VelocityChanger do
                            if (not RootPart) or (not RootPart.Parent) or (not RootPart.Parent.Parent) then
                                repeat task.wait() RootPart = Character:FindFirstChild("HumanoidRootPart") until RootPart ~= nil
                            else
                                RVelocity = RootPart.Velocity
    
                                RootPart.Velocity = type(Velocity) == "vector" and Velocity or Velocity(RVelocity)
    
                                RStepped:wait()
    
                                RootPart.Velocity = RVelocity
                            end
                        Heartbeat:wait()
                    end
                end)
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
