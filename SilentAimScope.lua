local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

RunService.Heartbeat:Connect(function()
    Camera.FieldOfView = 105
end)

local ESPName = "CustomHighlight"
local RainbowSpeed = 5

local function CreateHighlight(player, rainbow)
    if player.Character and not player.Character:FindFirstChild(ESPName) then
        local highlight = Instance.new("Highlight")
        highlight.Name = ESPName
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.Parent = player.Character
        highlight.Adornee = player.Character

        if rainbow then
            RunService.Heartbeat:Connect(function()
                if not highlight or not highlight.Parent then return end
                local hue = tick() % RainbowSpeed / RainbowSpeed
                highlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
            end)
        else
            highlight.OutlineColor = Color3.new(1, 0, 0)
        end
    end
end

local function RemoveInvalidHighlights()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild(ESPName) then
            if not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                player.Character:FindFirstChild(ESPName):Destroy()
            end
        end
    end
end

local function UpdateHighlights(rainbow)
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            CreateHighlight(player, rainbow)
        end
    end
end

task.spawn(function()
    while true do
        UpdateHighlights(getgenv().Settings.RainbowESP)
        RemoveInvalidHighlights()
        task.wait(0.1)
    end
end)

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {Character, targetPart.Parent}
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, params)
    if result then
        return false
    end
    return true
end

local function GetClosest(Fov)
    local Target, Closest = nil, math.huge

    for i, v in pairs(Players:GetPlayers()) do
        if (v.Name ~= LocalPlayer.Name and v.Character and v.Character:FindFirstChild("HumanoidRootPart")) then
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude

            if (Distance < Closest and Distance <= Fov and IsVisible(v.Character.HumanoidRootPart)) then
                Closest = Distance
                Target = v
            end
        end
    end

    return Target
end

local Target
local CircleInline = Drawing.new("Circle")
local CircleOutline = Drawing.new("Circle")

RunService.Stepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local velocity = Vector3.new(0, 0, 0)
        
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        velocity = LocalPlayer.Character.HumanoidRootPart.Velocity
    end
        
    local speed = velocity.Magnitude
    local baseFov = getgenv().Settings.Fov
    local dynamicRadius = baseFov + math.clamp(speed / 5, 0, 50)
    local dynamicColor = Color3.fromHSV((speed % 100) / 100, 1, 1)

    CircleInline.Radius = dynamicRadius
    CircleInline.Thickness = 2
    CircleInline.Position = screenCenter
    CircleInline.Transparency = 1
    CircleInline.Color = dynamicColor
    CircleInline.Visible = getgenv().Settings.FovCircle
    CircleInline.ZIndex = 2

    CircleOutline.Radius = dynamicRadius + 2
    CircleOutline.Thickness = 3
    CircleOutline.Position = screenCenter
    CircleOutline.Transparency = 0.8
    CircleOutline.Color = Color3.new(0, 0, 0)
    CircleOutline.Visible = getgenv().Settings.FovCircle
    CircleOutline.ZIndex = 1

    Target = GetClosest(getgenv().Settings.Fov)
end)


local Old
Old = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = { ... }
    local Method = getnamecallmethod()

    if (not checkcaller() and Method == "FireServer") then
        if (Self.Name == "0+.") then
            Args[1].MessageWarning = {}
            Args[1].MessageError = {}
            Args[1].MessageOutput = {}
            Args[1].MessageInfo = {}
        elseif (Self.Name == "RemoteEvent" and Args[2] == "Bullet" and Method == "FireServer") then
            if (Target and Target.Character and Target.Character.Humanoid and Target.Character.Humanoid.Health ~= 0) then
                local Hitbox = nil

                for _, partName in pairs(getgenv().Settings.Hitbox) do
                    local part = Target.Character:FindFirstChild(partName)
                    if part then
                        Hitbox = part
                        break
                    end
                end

                if (Hitbox) then
                    Args[3] = Target.Character
                    Args[4] = Hitbox
                    Args[5] = Hitbox.Position
                end
            end
        end
    end

    return Old(Self, unpack(Args))
end)
