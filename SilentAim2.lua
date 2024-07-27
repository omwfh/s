local a = loadstring(game:HttpGet("https://raw.githubusercontent.com/omwfh/sj0wjg0w/main/AimingModule.lua"))()
a.TeamCheck(false)

local function notif(Title, Text, Duration)
	local CoreGUI = game:GetService("StarterGui")
	if not CoreGUI then
		warn("Failed to get StarterGui service.")
		return
	end

	local success, result = pcall(function()
		CoreGUI:SetCore("SendNotification", {
			Title = Title;
			Text = Text;
			Duration = Duration;
		})
	end)
	if not success then
		warn("Failed to send notification: " .. tostring(result))
	end
end

local b = game:GetService("Workspace")
local c = game:GetService("Players")
local d = game:GetService("RunService")
local e = game:GetService("UserInputService")

if not b or not c or not d or not e then
	warn("Failed to get one or more necessary services.")
	return
end

local f = c.LocalPlayer
if not f then
	warn("Failed to get LocalPlayer.")
	return
end

local g = f:GetMouse()
if not g then
	warn("Failed to get Mouse.")
	return
end

local h = b.CurrentCamera
if not h then
	warn("Failed to get CurrentCamera.")
	return
end

local i = { SilentAim = true, AimLock = true, Prediction = 0.165 }
getgenv().DaHoodSettings = i

function a.Check()
	if not (a.Enabled == true and a.Selected ~= f and a.SelectedPart ~= nil) then
		return false 
	end

	local success, result = pcall(function()
		local j = a.Character(a.Selected)
		if not j then return false end

		local k = j:WaitForChild("BodyEffects")["K.O"].Value
		local l = j:FindFirstChild("GRABBING_CONSTRAINT") ~= nil
		
		if k or l then return false end
	end)
	
	if not success then
		warn("Error in a.Check: " .. tostring(result))
		return false
	end

	return true
end

local originalMouse = g
local proxyMouse = {}

local metatable = {
	__index = function(t, k)
		if k == "Hit" or k == "Target" then
			local success, result = pcall(function()
				if a.Check() then
					local p = a.SelectedPart
					if i.SilentAim and k == "Hit" or k == "Target" then
						local q = p.CFrame + p.Velocity * i.Prediction
						return k == "Hit" and q or p
					end
				end
			end)
			if not success then
				warn("Error in __index metamethod: " .. tostring(result))
			end
		end
		return originalMouse[k]
	end,
	
	__newindex = function(t, k, v)
		local success, result = pcall(function()
			originalMouse[k] = v
		end)
		if not success then
			warn("Error in __newindex metamethod: " .. tostring(result))
		end
	end
}

local success, result = pcall(function()
	setmetatable(proxyMouse, metatable)
end)
if not success then
	warn("Failed to set metatable: " .. tostring(result))
end

notif("Notification", "arts private lock loaded", 5)
