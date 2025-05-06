if getgenv().Aiming then return getgenv().Aiming end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector2new = Vector2.new
local GetGuiInset = GuiService.GetGuiInset
local Randomnew = Random.new
local mathfloor = math.floor
local CharacterAdded = LocalPlayer.CharacterAdded
local CharacterAddedWait = CharacterAdded.Wait
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local IsDescendantOf = Instancenew("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local tableremove = table.remove
local tableinsert = table.insert

getgenv().Aiming = {
	Enabled = true,
	ShowFOV = _G.ShowFov,
	FOV = _G.Fov,
	FOVSides = _G.Sides,
	FOVColour = Color3fromRGB(255, 77, 77),
	VisibleCheck = true,
	HitChance = _G.HitChance,
	ResolverEnabled = true,
	Selected = nil,
	SelectedPart = nil,
	TargetPart = _G.TargetPart,
	Ignored = {
		Teams = {
			{
				Team = LocalPlayer.Team,
				TeamColor = LocalPlayer.TeamColor,
			},
		},
		Players = {
			LocalPlayer,
		}
	}
}

local Aiming = getgenv().Aiming
local circle = Drawingnew("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = Aiming.FOVColour
circle.Filled = false
Aiming.FOVCircle = circle

local function UpdateFOV(): nil
	circle.Visible = Aiming.ShowFOV
	circle.Radius = (Aiming.FOV * 3)
	circle.Position = Vector2new(Mouse.X, Mouse.Y + GetGuiInset(GuiService).Y)
	circle.NumSides = Aiming.FOVSides
	circle.Color = Aiming.FOVColour
	return nil
end

Aiming.UpdateFOV = UpdateFOV

local function CalcChance(percentage: number): boolean
	percentage = mathfloor(percentage)
	local rng = Randomnew()
	local chance = mathfloor(rng:NextNumber(0, 1) * 100) / 100
	return chance <= percentage / 100
end

local PingSamples: {number} = {}
local MaxSamples: number = 10

local function GetPlayerPing(): number
	local Ping: number = StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
	tableinsert(PingSamples, Ping)
	if #PingSamples > MaxSamples then tableremove(PingSamples, 1) end
	local Sum: number = 0
	for _, v: number in ipairs(PingSamples) do
		Sum += v
	end
	return Sum / #PingSamples
end

local function GetDynamicPrediction(): number
	local ping: number = GetPlayerPing()
	local base: number = 0.045
	local multiplier: number = 0.0013
	return math.clamp(base + math.max(0, ping - 30) * multiplier, 0.045, 0.2)
end

Aiming.GetDynamicPrediction = GetDynamicPrediction

local CachedPrediction: number = 0
RunService.Heartbeat:Connect(function()
	CachedPrediction = GetDynamicPrediction()
end)

local function ResolveTarget(Part: BasePart): Vector3
	if not Aiming.ResolverEnabled then
		return Part.Position
	end
	local velocity: Vector3 = Part.Velocity
	return Part.Position + (velocity * CachedPrediction)
end

Aiming.ResolveTarget = ResolveTarget

local function IsPartVisible(Part: BasePart, Descendant: Instance): boolean
	local Character = LocalPlayer.Character or CharacterAddedWait(CharacterAdded)
	local Origin = CurrentCamera.CFrame.Position
	local _, OnScreen = WorldToViewportPoint(CurrentCamera, Part.Position)
	if OnScreen then
		local raycastParams = RaycastParamsnew()
		raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
		raycastParams.FilterDescendantsInstances = {Character, CurrentCamera}
		local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)
		if Result then
			local HitPart = Result.Instance
			return not HitPart or IsDescendantOf(HitPart, Descendant)
		end
	end
	return false
end

Aiming.IsPartVisible = IsPartVisible

local function IgnorePlayer(Player: Player): boolean
	for _, IgnoredPlayer in ipairs(Aiming.Ignored.Players) do
		if IgnoredPlayer == Player then return false end
	end
	tableinsert(Aiming.Ignored.Players, Player)
	return true
end

Aiming.IgnorePlayer = IgnorePlayer

local function UnIgnorePlayer(Player: Player): boolean
	for i, IgnoredPlayer in ipairs(Aiming.Ignored.Players) do
		if IgnoredPlayer == Player then
			tableremove(Aiming.Ignored.Players, i)
			return true
		end
	end
	return false
end

Aiming.UnIgnorePlayer = UnIgnorePlayer

local function IgnoreTeam(Team: Team, TeamColor: BrickColor): boolean
	for _, t in ipairs(Aiming.Ignored.Teams) do
		if t.Team == Team and t.TeamColor == TeamColor then return false end
	end
	tableinsert(Aiming.Ignored.Teams, {Team = Team, TeamColor = TeamColor})
	return true
end

Aiming.IgnoreTeam = IgnoreTeam

local function UnIgnoreTeam(Team: Team, TeamColor: BrickColor): boolean
	for i, t in ipairs(Aiming.Ignored.Teams) do
		if t.Team == Team and t.TeamColor == TeamColor then
			tableremove(Aiming.Ignored.Teams, i)
			return true
		end
	end
	return false
end

Aiming.UnIgnoreTeam = UnIgnoreTeam

local function TeamCheck(Toggle: boolean): boolean
	if Toggle then
		return IgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
	else
		return UnIgnoreTeam(LocalPlayer.Team, LocalPlayer.TeamColor)
	end
end

Aiming.TeamCheck = TeamCheck

local function IsIgnoredTeam(Player: Player): boolean
	for _, t in ipairs(Aiming.Ignored.Teams) do
		if Player.Team == t.Team and Player.TeamColor == t.TeamColor then return true end
	end
	return false
end

Aiming.IsIgnoredTeam = IsIgnoredTeam

local function IsIgnored(Player: Player): boolean
	for _, p in ipairs(Aiming.Ignored.Players) do
		if typeof(p) == "number" and Player.UserId == p then return true end
		if p == Player then return true end
	end
	return IsIgnoredTeam(Player)
end

Aiming.IsIgnored = IsIgnored

local function RaycastDirection(Origin: Vector3, Destination: Vector3, UnitMultiplier: number?): (Vector3?, Vector3?, Enum.Material?)
	if typeof(Origin) == "Vector3" and typeof(Destination) == "Vector3" then
		UnitMultiplier = UnitMultiplier or 1
		local Direction = (Destination - Origin).Unit * UnitMultiplier
		local Result = Raycast(Workspace, Origin, Direction)
		if Result then
			return Direction, Result.Normal, Result.Material
		end
	end
	return nil
end

Aiming.Raycast = RaycastDirection

local function Character(Player: Player): Model?
	return Player.Character
end

Aiming.Character = Character

local function CheckHealth(Player: Player): boolean
	local Character = Aiming.Character(Player)
	local Humanoid = FindFirstChildWhichIsA(Character, "Humanoid")
	local Health = Humanoid and Humanoid.Health or 0
	return Health > 0
end

Aiming.CheckHealth = CheckHealth

local function Check(): boolean
	return Aiming.Enabled and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil
end

Aiming.Check = Check
Aiming.checkSilentAim = Check

local function GetClosestTargetPartToCursor(Character: Model): (BasePart?, Vector3?, boolean, number?)
	local TargetParts = Aiming.TargetPart
	local ClosestPart = nil
	local ClosestPartPosition = nil
	local ClosestPartOnScreen = false
	local ClosestPartMagnitudeFromMouse = nil
	local ShortestDistance = 1 / 0

	local function CheckTargetPart(TargetPart)
		if typeof(TargetPart) == "string" then
			TargetPart = FindFirstChild(Character, TargetPart)
		end
		if not TargetPart then return end
		local PartPos, onScreen = WorldToViewportPoint(CurrentCamera, TargetPart.Position)
		if not onScreen then return end
		local GuiInset = GetGuiInset(GuiService)
		local Magnitude = (Vector2new(PartPos.X, PartPos.Y - GuiInset.Y) - Vector2new(Mouse.X, Mouse.Y)).Magnitude
		if Magnitude < ShortestDistance then
			ClosestPart = TargetPart
			ClosestPartPosition = PartPos
			ClosestPartOnScreen = true
			ClosestPartMagnitudeFromMouse = Magnitude
			ShortestDistance = Magnitude
		end
	end

	if typeof(TargetParts) == "string" then
		if TargetParts == "All" then
			for _, v in ipairs(Character:GetChildren()) do
				if v:IsA("BasePart") then CheckTargetPart(v) end
			end
		else
			CheckTargetPart(TargetParts)
		end
	elseif typeof(TargetParts) == "table" then
		for _, PartName in ipairs(TargetParts) do
			CheckTargetPart(PartName)
		end
	end

	return ClosestPart, ClosestPartPosition, ClosestPartOnScreen, ClosestPartMagnitudeFromMouse
end

Aiming.GetClosestTargetPartToCursor = GetClosestTargetPartToCursor

local function GetClosestPlayerToCursor(): Player?
	local TargetPart = nil
	local ClosestPlayer = nil
	local Chance = CalcChance(Aiming.HitChance)
	local ShortestDistance = 1 / 0

	if not Chance then
		Aiming.Selected = LocalPlayer
		Aiming.SelectedPart = nil
		return LocalPlayer
	end

	for _, Player in ipairs(GetPlayers()) do
		local Character = Aiming.Character(Player)
		if Character and not Aiming.IsIgnored(Player) and Aiming.CheckHealth(Player) then
			local Part, _, _, Magnitude = Aiming.GetClosestTargetPartToCursor(Character)
			if Part and circle.Radius > Magnitude and Magnitude < ShortestDistance then
				if Aiming.VisibleCheck and not Aiming.IsPartVisible(Part, Character) then continue end
				local Distance = (Character.PrimaryPart.Position - CurrentCamera.CFrame.Position).Magnitude
				if Distance > 300 then continue end
				ClosestPlayer = Player
				TargetPart = Part
				ShortestDistance = Magnitude
			end
		end
	end

	Aiming.Selected = ClosestPlayer
	Aiming.SelectedPart = TargetPart
	return ClosestPlayer
end

Aiming.GetClosestPlayerToCursor = GetClosestPlayerToCursor

Heartbeat:Connect(function()
	Aiming.UpdateFOV()
	Aiming.GetClosestPlayerToCursor()
end)

return Aiming
