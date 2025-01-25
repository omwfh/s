local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local CircleInline = Drawing.new("Circle")
local CircleOutline = Drawing.new("Circle")
local ESPName = "CustomHighlight"
local Target = nil
local IsTargetVisible = false

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * 500
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}
    params.IgnoreWater = true

    local result = Workspace:Raycast(origin, direction, params)
    return result == nil
end

local function GetClosest(Fov)
    local ClosestTarget, ClosestDistance = nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

            if Distance < ClosestDistance and Distance <= Fov then
                ClosestDistance = Distance
                ClosestTarget = player
            end
        end
    end

    return ClosestTarget
end

RunService.Stepped:Connect(function()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local velocity = Vector3.new(0, 0, 0)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        velocity = LocalPlayer.Character.HumanoidRootPart.Velocity
    end
    local speed = velocity.Magnitude
    local baseFov = getgenv().Settings.Fov
    local dynamicRadius = baseFov - math.clamp(speed / 10, 0, 40)
    dynamicRadius = math.clamp(dynamicRadius, baseFov / 2, baseFov)

    CircleInline.Radius = dynamicRadius
    CircleInline.Thickness = 2
    CircleInline.Position = screenCenter
    CircleInline.Transparency = 1
    CircleInline.Color = Color3.new(1, 1, 1)
    CircleInline.Visible = getgenv().Settings.FovCircle
    CircleInline.ZIndex = 2

    CircleOutline.Radius = dynamicRadius + 2
    CircleOutline.Thickness = 3
    CircleOutline.Position = screenCenter
    CircleOutline.Transparency = 0.8
    CircleOutline.Color = IsTargetVisible and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    CircleOutline.Visible = getgenv().Settings.FovCircle
    CircleOutline.ZIndex = 1

    Target = GetClosest(dynamicRadius)
end)

task.spawn(function()
    while true do
        if Target and Target.Character and Target.Character:FindFirstChild("HumanoidRootPart") then
            IsTargetVisible = IsVisible(Target.Character.HumanoidRootPart)
        else
            IsTargetVisible = false
        end
        task.wait(0.001)
    end
end)

local function CreateHighlight(player, rainbow)
    if player.Character and not player.Character:FindFirstChild(ESPName) then
        local highlight = Instance.new("Highlight")
        highlight.Name = ESPName
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = 0
        highlight.Adornee = player.Character
        highlight.Parent = player.Character

        if rainbow then
            RunService.Heartbeat:Connect(function()
                if highlight and highlight.Parent then
                    local hue = tick() % 5 / 5
                    highlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
                end
            end)
        else
            highlight.OutlineColor = Color3.new(1, 0, 0)
        end
    end
end

local function RemoveInvalidHighlights()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild(ESPName) then
            if not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                player.Character:FindFirstChild(ESPName):Destroy()
            end
        end
    end
end

local function UpdateHighlights(rainbow)
    for _, player in ipairs(Players:GetPlayers()) do
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

local Old
Old = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()

    if (not checkcaller() and Method == "FireServer") then
        if (Self.Name == "RemoteEvent" and Args[2] == "Bullet") then
            if (Target and Target.Character and Target.Character.Humanoid and Target.Character.Humanoid.Health > 0 and IsTargetVisible) then
                local Hitbox = nil
                for _, partName in ipairs(getgenv().Settings.Hitbox) do
                    local part = Target.Character:FindFirstChild(partName)
                    if part then
                        Hitbox = part
                        break
                    end
                end

                if not Hitbox then
                    Hitbox = Target.Character:FindFirstChild("HumanoidRootPart")
                end

                if Hitbox then
                    Args[3] = Target.Character
                    Args[4] = Hitbox
                    Args[5] = Hitbox.Position
                end
            end
        end
    end

    return Old(Self, unpack(Args))
end)
