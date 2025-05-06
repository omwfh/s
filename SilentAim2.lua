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
    Prediction = _G.Prediction,
    Resolver = true,
    ResolverStrength = 0.2
}

local PingSamples: {number} = {}
local MaxSamples: number = 10

local function GetPlayerPing(): number
    return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
end

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
	local BasePrediction: number = 0.05
	local PredictionPerMs: number = 0.0012

	local Prediction: number = BasePrediction + math.max(0, AveragePing - BasePing) * PredictionPerMs
	return math.clamp(Prediction, 0.045, 0.2)
end

local function ResolveTarget(TargetPart: BasePart): CFrame
	if not getgenv().DaHoodSettings.Resolver then
		return TargetPart and TargetPart.CFrame or CFrame.new()
	end

	if not TargetPart or typeof(TargetPart) ~= "Instance" or not TargetPart:IsA("BasePart") then
		return CFrame.new()
	end

	local position = TargetPart.Position
	local velocity = TargetPart.Velocity or Vector3.zero
	local cameraPos = Camera and Camera.CFrame.Position or Vector3.zero

	local distance = (cameraPos - position).Magnitude
	local baseStrength = getgenv().DaHoodSettings.ResolverStrength or 0.2
	local scaledStrength = math.clamp(baseStrength + (distance / 900), 0, 1.5)

	local predictedPosition = position + (velocity * scaledStrength)

	if typeof(predictedPosition) ~= "Vector3" or predictedPosition.Magnitude > 1e5 then
		return TargetPart.CFrame
	end

	return CFrame.new(predictedPosition)
end

RunService.Heartbeat:Connect(function()
    getgenv().DaHoodSettings.Prediction = CalculateAccuratePrediction()
end)

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
    if typeof(Object) == "Instance" and Object:IsA("Mouse") and (Property == "Hit" or Property == "Target") and Aiming.Check() then
        if getgenv().DaHoodSettings.SilentAim then
            local TargetPart: BasePart = Aiming.SelectedPart
            if TargetPart and typeof(TargetPart) == "Instance" and TargetPart:IsA("BasePart") then
                local prediction: number = getgenv().DaHoodSettings.Prediction or 0.1
                local predictedPosition: Vector3 = TargetPart.Position + (TargetPart.Velocity or Vector3.zero) * prediction
                local predictedCFrame: CFrame = CFrame.new(predictedPosition)
                return Property == "Hit" and predictedCFrame or TargetPart
            end
        end
    end
    return OldIndex(Object, Property)
end)

print("Loaded!!!!!!!!!")
