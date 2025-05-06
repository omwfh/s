local Aiming = loadstring(game:HttpGet("https://raw.githubusercontent.com/omwfh/sj0wjg0w/main/AimingModule.lua"))()

local Workspace: Workspace = game:GetService("Workspace")
local Players: Players = game:GetService("Players")
local RunService: RunService = game:GetService("RunService")
local UserInputService: UserInputService = game:GetService("UserInputService")
local StarterGui: StarterGui = game:GetService("StarterGui")
local StatsService: Stats = game:GetService("Stats")

local LocalPlayer: Player = Players.LocalPlayer
local Mouse: Mouse = LocalPlayer:GetMouse()
local Camera: Camera = Workspace.CurrentCamera

getgenv().DaHoodSettings = {
    SilentAim = true,
    AimLock = true,
    Prediction = 0.165,
    Resolver = true,
    ResolverStrength = 0.18
}

local name = info:gsub("%b[]", ""):gsub("[^%w%s]", ""):gsub("%s+", "_"):gsub("^_+", ""):gsub("_+$", ""):lower() 

local PingSamples: {number} = {}
local MaxSamples: number = 10

local function GetPlayerPing(): number
    return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
end

local function CalculateAccuratePrediction(): number
    local function CalculateAccuratePrediction(): number
        local Ping: number = GetPlayerPing()
        table.insert(PingSamples, Ping)
        if #PingSamples > MaxSamples then
            table.remove(PingSamples, 1)
        end
    
        local Sum: number = 0
        for _, Value: number in ipairs(PingSamples) do
            Sum += Value
        end
    
        local AveragePing: number = Sum / #PingSamples
        local BasePing: number = 30
        local BasePrediction: number = 0.045
        local PredictionPerMs: number = 0.0013
    
        local Prediction: number = BasePrediction + math.max(0, AveragePing - BasePing) * PredictionPerMs
        return math.clamp(Prediction, 0.045, 0.2)
    end    
end

local function ResolveTarget(TargetPart: BasePart): CFrame
    if not getgenv().DaHoodSettings.Resolver then
        return TargetPart.CFrame
    end
    return TargetPart.CFrame + TargetPart.Velocity * getgenv().DaHoodSettings.ResolverStrength
end

RunService.Heartbeat:Connect(function()
    getgenv().DaHoodSettings.Prediction = CalculateAccuratePrediction()
end)

local function Notify(Title: string, Text: string, Duration: number)
    task.spawn(function()
        StarterGui:SetCore("SendNotification", {
            Title = Title,
            Text = Text,
            Duration = Duration
        })
    end)
end

Aiming.TeamCheck(false)

Aiming.Check = function(): boolean
	if not (Aiming.Enabled and Aiming.Selected and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart) then
		return false
	end

	local success, Character = pcall(Aiming.Character, Aiming.Selected)
	if not success or typeof(Character) ~= "Instance" or not Character:IsA("Model") then
		return false
	end

	local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
	if not Humanoid or Humanoid.Health <= 0 then
		return false
	end

	local RootPart = Character:FindFirstChild("HumanoidRootPart")
	if not RootPart or not RootPart:IsA("BasePart") then
		return false
	end

	local BodyEffects = Character:FindFirstChild("BodyEffects")
	if not BodyEffects or not BodyEffects:IsA("Folder") then
		return false
	end

	local KnockedOut = BodyEffects:FindFirstChild("K.O")
	if KnockedOut and KnockedOut:IsA("BoolValue") and KnockedOut.Value == true then
		return false
	end

	local GrabConstraint = Character:FindFirstChild("GRABBING_CONSTRAINT")
	if GrabConstraint and GrabConstraint:IsA("Instance") then
		return false
	end

	return true
end

local OldIndex
OldIndex = hookmetamethod(game, "__index", function(Object: Instance, Property: string)
    if Object:IsA("Mouse") and (Property == "Hit" or Property == "Target") and Aiming.Check() then
        local TargetPart: BasePart = Aiming.SelectedPart
        if getgenv().DaHoodSettings.SilentAim and (Property == "Hit" or Property == "Target") then
            local PredictedPosition: CFrame = ResolveTarget(TargetPart) + TargetPart.Velocity * getgenv().DaHoodSettings.Prediction
            return Property == "Hit" and PredictedPosition or TargetPart
        end
    end
    return OldIndex(Object, Property)
end)

print("Loaded!!!!!!!!!")
