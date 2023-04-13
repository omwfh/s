local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = Players.LocalPlayer
local Client_Character = Client.Character

local Mouse = Client:GetMouse()

local Victim = _G.Victim

local Admin = {
	Commands = {},
	Functions = {},
	Utilities = {},
	NormalPrefix = ";",
	ErrorColor = Color3.fromRGB(255, 0, 0),
	SuccessColor = Color3.fromRGB(0, 255, 0),
}

function Admin:CreateCommand(Name, Desc, Func)
	table.insert(self.Commands, {Name, Desc, Func})
end

function Admin:GetPlayer(String)
	local toreturn = {}
	if String:lower() == "all" or String:lower() == "others" then
		for i, v in pairs(Players:GetPlayers()) do
			if v ~= Client then
				table.insert(toreturn, v)
			end
		end
	else
		for i, v in pairs(Players:GetPlayers()) do
			if
				v.Name:sub(1, #String):lower() == String:lower() or
				v.DisplayName:sub(1, #String):lower() == String:lower()
			then
				table.insert(toreturn, v)
			end
		end
	end
	if #toreturn == 0 then
		warn("Could not find player '" .. String .. "'.")
	end
	return toreturn
end

function Admin:GetCharacter(Player)
	local Character = Player.Character
	if not Character then
		warn(Player.Name .. " has no character.")
	end
	return Character
end

function Admin:PrintSuccess(Msg)
	print("[SUCCESS]: " .. Msg)
end

function Admin:PrintError(Msg)
	print("[ERROR]: " .. Msg)
end

function Admin:ConnectChatted()
	if self.ChattedConnection then
		warn("Chatted connection already exists.")
		return
	end
	
	self.ChattedConnection = Client.Chatted:Connect(function(msg)
		msg = msg:lower()
		local Args = msg:split(" ")
		for index, cmd in pairs(self.Commands) do
			if Args[1] == "/e" then
				table.remove(Args, 1)
			end

			if Args[1] == self.NormalPrefix .. cmd[1]:lower() then
				local Success, Result = pcall(cmd[3])
				if not Success then
					self:PrintError(Result)
				end
			end
		end
	end)
end

Admin:CreateCommand("bring .", "Teleport to a player", function(args)
	if #args < 2 then
		Admin:PrintError("Usage: <prefix>bring <victim>")
		return
	end
	
	local player = Admin:GetPlayer("sobicide")
	
	local character = Admin:GetCharacter(player)
	local victimcharacter = Admin:GetCharacter(_G.Victim)
	
	if not character then
		Admin:PrintError("Could not get character of player '" .. args[2] .. "'.")
		return
	end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local rootPart2 = victimcharacter:FindFirstChild("HumanoidRootPart)
	
	if not rootPart then
		Admin:PrintError("Could not find HumanoidRootPart for player '" .. args[2] .. "'.")
		return
	end
	
	Client_Character.HumanoidRootPart.CFrame = victimcharacter.CFrame
end)

Admin:ConnectChatted(_G.Victim.Chatted)
