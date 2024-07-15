local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Arsenal = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = Arsenal:MakeWindow({Name = "Arsenal | Rolve", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Main = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MainFeatures = Main:AddSection({Name = "Main Features"})
local Modification = Window:MakeTab({Name = "Modification", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local WeaponModifications = Modification:AddSection({Name = "Weapon Modifications"})
local PlayerModifications = Modification:AddSection({Name = "Player Modifications"})

local Aiming = false
local FOVCircle = Drawing.new("Circle")
local NametagStore = Instance.new("BillboardGui")
local NameTag = Instance.new("TextLabel", NametagStore)
task.spawn(function()
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 32
    FOVCircle.Visible = false

    NametagStore.Name = "Nametag ESP";
    NametagStore.ResetOnSpawn = false
    NametagStore.AlwaysOnTop = true;
    NametagStore.LightInfluence = 0;
    NametagStore.Size = UDim2.new(1.75, 0, 1.75, 0);
    NameTag.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    NameTag.Text = ""
    NameTag.Size = UDim2.new(0.0001, 0.00001, 0.0001, 0.00001);
    NameTag.BorderSizePixel = 4;
    NameTag.BorderColor3 = Color3.new(255,255,255)
    NameTag.BorderSizePixel = 0
    NameTag.Font = "GothamSemibold"
    NameTag.TextSize = 8
    NameTag.TextColor3 = Color3.fromRGB(255,255,255)
end)

local function updateFOVCircle()
    if Aiming then
        FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        FOVCircle.Radius = 360 / 2
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end

local function findNearestPlayer()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return nil end
    
    local nearestPlayer = nil
    local minDistance = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Team ~= localPlayer.Team then

            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            local head = player.Character and player.Character:FindFirstChild("Head")
            
            if humanoid and head and player.Team ~= LocalPlayer.Team and humanoid.Health > 0 then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - FOVCircle.Position).magnitude
                    if distance <= FOVCircle.Radius and distance < minDistance then
                        nearestPlayer = player
                        minDistance = distance
                    end
                end
            end
        end
    end
    return nearestPlayer
end

local function changeHitbox(player, size)
    player.Character.RightUpperLeg.CanCollide = false
    player.Character.RightUpperLeg.Transparency = 10
    player.Character.RightUpperLeg.Size = Vector3.new(size,size,size)

    player.Character.LeftUpperLeg.CanCollide = false
    player.Character.LeftUpperLeg.Transparency = 10
    player.Character.LeftUpperLeg.Size = Vector3.new(size,size,size)

    player.Character.HeadHB.CanCollide = false
    player.Character.HeadHB.Transparency = 10
    player.Character.HeadHB.Size = Vector3.new(size,size,size)

    player.Character.HumanoidRootPart.CanCollide = false
    player.Character.HumanoidRootPart.Transparency = 10
    player.Character.HumanoidRootPart.Size = Vector3.new(size,size,size)
    return player, size
end

local function getplrsname()
    for i,v in pairs(game:GetChildren()) do
        if v.ClassName == "Players" then
            return v.Name
        end
    end
end

_G.AimbotEnabled = false
MainFeatures:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        _G.AimbotEnabled = Value
    end
})

_G.HitboxSize = 13
MainFeatures:AddSlider({
	Name = "Hitbox Size",
	Min = 13,
	Max = 40,
	Default = 5,
	Color = Color3.fromRGB(55, 0, 255),
	Increment = 1,
	ValueName = "Size",
	Callback = function(Value)
		_G.HitboxSize = Value
	end
})

MainFeatures:AddButton({
	Name = "Hitbox Extender",
	Callback = function()
        local players = getplrsname()
        local plr = game[players].LocalPlayer
        coroutine.resume(coroutine.create(function()
            while wait(1) do
                coroutine.resume(coroutine.create(function()
                    for _,v in pairs(game[players]:GetPlayers()) do
                        if v.Name ~= plr.Name and v.Character then
                            changeHitbox(v, _G.HitboxSize)
                        end
                    end
                end))
            end
        end))
	end
})

_G.ChamEnabled = false
MainFeatures:AddToggle({
    Name = "Enable Chams",
    Default = false,
    Callback = function(Value)
        _G.ChamEnabled = Value
    end
})

WeaponModifications:AddButton({
	Name = "Recoil Control",
	Callback = function(value)
        while true do
            for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
                if v.Name == "RecoilControl" then
                    v.Value = 0
                end
                if v.Name == "MaxSpread" then
                    v.Value = 0
                end
            end
            wait(2)
        end
  	end
})

WeaponModifications:AddButton({
	Name = "Automatic Weapon",
	Callback = function()
        while true do
            for _, v in pairs(ReplicatedStorage.Weapons:GetDescendants()) do
                if v.Name == "Auto" then
                    v.Value = true
                end
                if v.Name == "FireRate" then
                    v.Value = 0.02
                end
            end
            wait(2)
        end
  	end
})

WeaponModifications:AddButton({
    Name = "Infinite Ammo",
    Callback = function()
        while wait() do
            LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount.Value = 999
            LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount2.Value = 999
        end
    end
})

_G.CustomWalkspeed = false
MainFeatures:AddToggle({
    Name = "Custom WalkSpeed",
    Default = false,
    Callback = function(Value)
        _G.CustomWalkspeed = Value
    end
})

_G.Walkspeed = 25
PlayerModifications:AddSlider({
	Name = "Player Walkspeed",
	Min = 25,
	Max = 150,
	Default = 25,
	Color = Color3.fromRGB(55, 55, 255),
	Increment = 1,
	ValueName = "Walkspeed",
	Callback = function(Value)
		_G.Walkspeed = Value
	end
})

PlayerModifications:AddButton({
    Name = "Infinite Jump",
    Callback = function()
        UserInputService.JumpRequest:connect(function()
            LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
        end)
    end
})

task.spawn(function()
    local currentTarget = nil
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not _G.AimbotEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Aiming = true
            updateFOVCircle()
        end
    end)

    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if not _G.AimbotEnabled then return end
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Aiming = false
            updateFOVCircle()
            currentTarget = nil
        end
    end)

    RunService.RenderStepped:Connect(function()
        if Aiming then
            local nearestPlayer = findNearestPlayer()
            if nearestPlayer then
                if currentTarget == nil or currentTarget ~= nearestPlayer then
                    currentTarget = nearestPlayer
                end
                
                local head = currentTarget.Character and currentTarget.Character:FindFirstChild("Head")
                if head then
                    local direction = (head.Position - camera.CFrame.Position).unit
                    local newCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction * 10)
                    camera.CFrame = newCFrame
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        local function espCheck(player)
            if player.Character.Head:FindFirstChild("Nametag ESP") ~= nil then
                return true
            end
            return false
        end
        local function destroyPlayerChams(player)
            if espCheck(player) then
                player.Character.Head:FindFirstChild("Nametag ESP"):Destroy()
            end
        end
        local function createPlayerChams(player)
            if not espCheck(player) then
                if player.Team == LocalPlayer.Team then
                    destroyPlayerChams(player)
                    return
                end
                NameTag.Text = "{"..player.DisplayName.."}" or "{"..player.Name.."}"
                NametagStore:Clone().Parent = player.Character.Head
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if not _G.ChamEnabled then
                destroyPlayerChams(player)
                return
            end
            createPlayerChams(player)
        end
    end)
    local Humanoid = game:GetService("Players").LocalPlayer.Character.Humanoid
    Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if not _G.CustomWalkspeed then return end
        Humanoid.WalkSpeed = _G.Walkspeed
        game.Workspace[LocalPlayer.Name].Movetitude.Value = 0
    end)

    RunService.RenderStepped:Connect(function()
        game.Workspace.RageStraight.Movetitude.Value = 0
    end)
end)
