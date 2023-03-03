local PlayerService = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local Client = PlayerService.LocalPlayer
local Character = Client.Character
local clientOwner = nil

local AdminInfo = {
	Prefix = ".",
	Ver = "1.0",
	Cmds = {}
}

local ClientInfo = {
	HumanoidRootPart = Client.Character:FindFirstChild("HumanoidRootPart");
	BodyPartsR6 = {
		Head = Client.Character:FindFirstChild("Head");
		Torso = Client.Character:FindFirstChild("Torso");
		LeftArm = Client.Character:FindFirstChild("Left Arm");
		RightArm = Client.Character:FindFirstChild("Right Arm");
		LeftLeg = Client.Character:FindFirstChild("Left Leg");
		RightLeg = Client.Character:FindFirstChild("Right Leg");
	},
	BodyPartsR15 = {
		Head = Client.Character:FindFirstChild("Head");
		UpperTorso = Client.Character:FindFirstChild("UpperTorso");
		LowerTorso = Client.Character:FindFirstChild("LowerTorso");
		-- im lazy
	}
}

local function AddCommand(CmdName, CmdAlias, Desc, Func)
	AdminInfo.Cmds[#AdminInfo.Cmds + 1] = {
		["Name"] = CmdName;
		["Alias"] = CmdAlias;
		["Description"] = Desc;
		["Function"] = Func;
	}
end

local function Search(CmdName)
	for _, v in pairs(AdminInfo.Cmds) do
		if v.Name == CmdName or table.find(v.Alias, CmdName) then  
			return v.Function
		end
	end
end

local function CheckCmd(Cmd)
	Cmd = string.lower(Cmd)
	if Cmd:sub(1, #AdminInfo.Prefix) == AdminInfo.Prefix then
		local args = string.split(Cmd:sub(#AdminInfo.Prefix + 1), " ")
		local CmdName = Search(table.remove(args, 1))
		if CmdName and args then
			return CmdName(args)
		end
	end
end

local function FindPlayer(Player)
	for i, v in	pairs(PlayerService:GetPlayers()) do
		if string.lower(string.sub(Player.Name, 1, string.len(Player.Name))) == string.lower(Player.Name) then
			return v
		end
	end
	return nil
end

local function Notify(Title, Text, Duration)
	StarterGui:SetCore("SendNotification", {
		Title = Title;
		Text = Text;
		Duration = Duration;
	})
end

AddCommand("Goto", { "to", "bring" }, "teleports you to" .. _G.ClientUser, function(args)
	if args[1] then
		local Target = _G.ClientUser
		if Target and Target.Character then
			Character.HumanoidRootPart.CFrame = Target.Character.Torso.CFrame + Vector3.new(0, 5, 0)
		else
			Character.Torso.CFrame = Target.Character.Head.CFrame + Vector3.new(0, 5, 0)
		end
	end
end)

_G.ClientUser.Chatted:Connect(function(msg)
	CheckCmd(msg)
end)
