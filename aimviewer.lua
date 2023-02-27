local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Terrain = Workspace.Terrain
local LocalPlayer = Players.LocalPlayer
local Beams = {}

local Colours = {
    At = ColorSequence.new(Color3.new(196, 40, 28), Color3.new(196, 40, 28)),
    Away = ColorSequence.new(Color3.new(194, 218, 184), Color3.new(194, 218, 184))
}

local function IsBeamHit(Beam, MousePos)
   
    local Character = LocalPlayer.Character
    local Attachment = Beam.Attachment1

    local Origin = Beam.Attachment0.WorldPosition
    local Direction = MousePos - Origin

    local raycastParms = RaycastParams.new()
    raycastParms.FilterDescendantsInstances = {Character, Workspace.CurrentCamera}
    local RaycastResult = Workspace:Raycast(Origin, Direction * 2, raycastParms) 
    if (not RaycastResult) then
        Beam.Color = Colours.Away
        Attachment.WorldPosition = MousePos
        return
    end

    if (Character) then
        Beam.Color = RaycastResult.Instance:IsDescendantOf(Character) and Colours.At or Colours.Away
    end

    Attachment.WorldPosition = RaycastResult.Position
end


local function CreateBeam(Character)
  
    local Beam = Instance.new("Beam", Character)

    Beam.Attachment0 = Character:WaitForChild("Head"):WaitForChild("FaceCenterAttachment")
    Beam.Enabled = Character:FindFirstChild("GunScript", true) ~= nil

    Beam.Width0 = 0.195
    Beam.Width1 = 0.195

    table.insert(Beams, Beam)

    return Beam
end

local function OnCharacter(Character)

    if (not Character) then
        return
    end

    local MousePos = Character:WaitForChild("BodyEffects"):WaitForChild("MousePos")

    local Beam = CreateBeam(Character)

    local Attachment = Instance.new("Attachment", Terrain)
    Beam.Attachment1 = Attachment

    IsBeamHit(Beam, MousePos.Value)
    MousePos.Changed:Connect(function()
        IsBeamHit(Beam, MousePos.Value)
    end)

    Character.DescendantAdded:Connect(function(Descendant)
        if (Descendant.Name == "GunScript") then
            Beam.Enabled = true
        end
    end)

    Character.DescendantRemoving:Connect(function(Descendant)
        if (Descendant.Name == "GunScript") then
            Beam.Enabled = false
        end
    end)
end

local function OnPlayer(Player)
    OnCharacter(Player.Character)
    Player.CharacterAdded:Connect(OnCharacter)
end

for _, v in ipairs(Players:GetPlayers()) do
    OnPlayer(v)
end

Players.PlayerAdded:Connect(OnPlayer)
