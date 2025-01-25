local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = Workspace.CurrentCamera

local CircleInline = Drawing.new("Circle")
local CircleOutline = Drawing.new("Circle")
local Target = nil

getgenv().Settings = {
    Fov = 70,
    Hitbox = {"Head", "HumanoidRootPart"},
    FovCircle = true,
    RainbowESP = true,
}

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

            if Distance < ClosestDistance and Distance <= Fov and IsVisible(player.Character.HumanoidRootPart) then
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

    Target = GetClosest(dynamicRadius)
end)

local Old
Old = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()

    if (not checkcaller() and Method == "FireServer") then
        if (Self.Name == "RemoteEvent" and Args[2] == "Bullet") then
            if (Target and Target.Character and Target.Character.Humanoid and Target.Character.Humanoid.Health > 0) then
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
