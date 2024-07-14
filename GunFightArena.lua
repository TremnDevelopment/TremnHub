local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local GunFightArena = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window
if game.PlaceId == 15514727567 then
    Window = GunFightArena:MakeWindow({Name = "Gunfight Arena | Tutorial", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})
elseif game.PlaceId == 14518422161 then
    Window = GunFightArena:MakeWindow({Name = "Gunfight Arena | KEYBINDS", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})
end

local Main = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MainFeatures = Main:AddSection({Name = "Main Features"})
local Configuration = Window:MakeTab({Name = "Configuration", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local AimbotConfiguration = Configuration:AddSection({Name = "Aimbot Configuration"})
local ESPConfiguration = Configuration:AddSection({Name = "ESP Configuration"})

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
    NameTag.BorderColor3 = Color3.new(1, 1, 1)
    NameTag.BorderSizePixel = 0
    NameTag.Font = "GothamSemibold"
    NameTag.TextSize = 8
    NameTag.TextColor3 = Color3.fromRGB(255, 0, 0)
end)
    
local function createBotChams(Bot)
    if Workspace[Bot.Name]:FindFirstChild('BotHighlight') == nil then
        if Players[Bot.Name]:GetAttribute('Team') == LocalPlayer:GetAttribute('Team') then return end
        if Workspace[Bot.Name]:FindFirstChild('Humanoid').Health < 0 then return end
        local highlight = Instance.new('Highlight')
        highlight.Name = 'BotHighlight'
        highlight.DepthMode = "AlwaysOnTop"
        highlight.FillColor = Color3.new(0,0,0)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = Workspace[Bot.Name]

        NameTag.Text = "{"..Bot.Name.."}"
        NametagStore:Clone().Parent = Workspace[Bot.Name].Head
        return highlight
    end
end
    
local function createPlayerChams(player)
    if player.Character:FindFirstChild("PlayerHighlight") == nil then
        if player.Team == LocalPlayer.Team or player == LocalPlayer then return end
        if player.Character:FindFirstChild('Humanoid').Health < 0 then return end
        local highlight = Instance.new('Highlight')
        highlight.Name = 'PlayerHighlight'
        highlight.DepthMode = "AlwaysOnTop"
        highlight.FillColor = Color3.new(1,1,1)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.new(0,0,0)
        highlight.Parent = player.Character

        NameTag.Text = "{"..player.Name.."}"
        NametagStore:Clone().Parent = player.Character.Head
        return highlight
    end
end

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
            createPlayerChams(player)
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            local bodyTarget = player.Character and player.Character:FindFirstChild(_G.selectedTargetBody)
            
            if humanoid and bodyTarget and player.Team ~= LocalPlayer.Team then
                local screenPos, onScreen = camera:WorldToViewportPoint(bodyTarget.Position)
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

local function findNearestBot()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return nil end
    
    local nearestBot = nil
    local minDistance = math.huge
    
    for _, player in ipairs(Players:GetChildren()) do
        if player:IsA('Folder') then
            createBotChams(player)
            local humanoid = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild("Humanoid")
            local bodyTarget = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild(_G.selectedTargetBody)
            
            if humanoid and bodyTarget and LocalPlayer:GetAttribute('Team') ~= player:GetAttribute('Team') then
                local screenPos, onScreen = camera:WorldToViewportPoint(bodyTarget.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - FOVCircle.Position).magnitude
                    if distance <= FOVCircle.Radius and distance < minDistance then
                        nearestBot = Workspace[player.Name]
                        minDistance = distance
                    end
                end
            end
        end
    end
    return nearestBot
end

local function findNearestTarget()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return nil end
    
    local nearestTarget = nil
    local minDistance = math.huge
    
    for _, player in ipairs(Players:GetChildren()) do
        local humanoid
        local bodyTarget
        if player:IsA('Folder') then
            createBotChams(player)
            humanoid = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild("Humanoid")
            bodyTarget = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild(_G.selectedTargetBody)
        elseif player:IsA('Player') then
            createPlayerChams(player)
            humanoid = Players[player.Name].Character and Players[player.Name].Character:FindFirstChild("Humanoid")
            bodyTarget = Players[player.Name].Character and Players[player.Name].Character:FindFirstChild(_G.selectedTargetBody)
        end
        if humanoid and bodyTarget and LocalPlayer:GetAttribute('Team') ~= player:GetAttribute('Team') then
            local screenPos, onScreen = camera:WorldToViewportPoint(bodyTarget.Position)
            if onScreen then
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - FOVCircle.Position).magnitude
                if distance <= FOVCircle.Radius and distance < minDistance then
                    nearestTarget = Workspace[player.Name]
                    minDistance = distance
                end
            end
        end
    end
    return nearestTarget
end

_G.AimbotEnabled = false
MainFeatures:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        _G.AimbotEnabled = Value
    end
})

_G.FOVCircleEnabled = false
AimbotConfiguration:AddToggle({
    Name = "Enable Field of View Circle",
    Default = false,
    Callback = function(Value)
        _G.FOVCircleEnabled = Value
    end
})

_G.selectedTarget = 'Both'
AimbotConfiguration:AddDropdown({
    Name = "Aimbot Target",
    Default = "Both",
    Options = {"Players", "Bots", "Both"},
    Callback = function(Value)
        _G.selectedTarget = Value
    end
})

_G.selectedTargetBody = 'Head'
AimbotConfiguration:AddDropdown({
    Name = "Target Body",
    Default = "Head",
    Options = {"Head", "Humanoid", "HumanoidRootPart"},
    Callback = function(Value)
        _G.selectedTargetBody = Value
    end
})

_G.ChamEnabled = false
MainFeatures:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        _G.ChamEnabled = Value
    end
})

_G.selectedChamTarget = 'Both'
ESPConfiguration:AddDropdown({
    Name = "ESP Target",
    Default = "Both",
    Options = {"Players", "Bots", "Both"},
    Callback = function(Value)
        _G.selectedChamTarget = Value
    end
})

local currentTarget = nil

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not _G.AimbotEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = true
        if _G.FOVCircleEnabled then updateFOVCircle() end
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if not _G.AimbotEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
        if _G.FOVCircleEnabled then updateFOVCircle() end
        currentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.AimbotEnabled then return end
    if Aiming then
        if not LocalPlayer then return nil end
        if _G.selectedTarget == "Players" then
            local nearestPlayer = findNearestPlayer()
            if nearestPlayer then
                if currentTarget == nil or currentTarget ~= nearestPlayer then
                    currentTarget = nearestPlayer
                end
                
                local bodyTarget = currentTarget.Character and currentTarget.Character:FindFirstChild(_G.selectedTargetBody)
                if bodyTarget then
                    local direction = (bodyTarget.Position - camera.CFrame.Position).unit
                    local newCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction * 10)
                    camera.CFrame = newCFrame
                end
            end
        elseif _G.selectedTarget == 'Bots' then
            local nearestBot = findNearestBot()
            if nearestBot then
                if currentTarget == nil or currentTarget ~= nearestBot then
                    currentTarget = nearestBot
                end
                
                local bodyTarget = currentTarget and currentTarget:FindFirstChild(_G.selectedTargetBody)
                if bodyTarget then
                    local direction = (bodyTarget.Position - camera.CFrame.Position).unit
                    local newCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction * 10)
                    camera.CFrame = newCFrame
                end
            end
        elseif _G.selectedTarget == 'Both' then
            local nearestTarget = findNearestTarget()
            if nearestTarget then
                if currentTarget == nil or currentTarget ~= nearestTarget then
                    currentTarget = nearestTarget
                end
                
                local bodyTarget = currentTarget and currentTarget:FindFirstChild(_G.selectedTargetBody)
                if bodyTarget then
                    local direction = (bodyTarget.Position - camera.CFrame.Position).unit
                    local newCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction * 10)
                    camera.CFrame = newCFrame
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not _G.ChamEnabled then return end
    for _, player in ipairs(Players:GetChildren()) do
        if _G.selectedChamTarget == 'Players' and player:IsA('Player') then
            createPlayerChams(player)
        elseif _G.selectedChamTarget == 'Bots' and player:IsA('Folder') then
            createBotChams(player)
        elseif _G.selectedChamTarget == 'Both' then
            if player:IsA('Player') then
                createPlayerChams(player)
            elseif player:IsA('Folder') then
                createBotChams(player)
            end
        end
    end
end)
GunFightArena:Init()
