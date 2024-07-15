local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local PrisonEscapeV2 = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
Window = PrisonEscapeV2:MakeWindow({Name = "Prison Escape V2", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Main = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local MainFeatures = Main:AddSection({Name = "Main Features"})
local PlayerFeatures = Main:AddSection({Name = "Player Features"})

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

local function checkChamExistance(player)
    if player.Character:FindFirstChild("PlayerHighlight") ~= nil then
        return true
    end
    return false
end

local function destroyPlayerChams(player)
    if checkChamExistance(player) then
        player.Character:FindFirstChild("PlayerHighlight"):Destroy()
        return
    end
end

local function createPlayerChams(player)
    if player.Character:FindFirstChild("PlayerHighlight") == nil then
        if player.Team == LocalPlayer.Team or player == LocalPlayer then destroyPlayerChams(player) return end
        if player.Character:FindFirstChild('Humanoid').Health < 0 then destroyPlayerChams(player) return end
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
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            local bodyTarget = player.Character and player.Character:FindFirstChild('Head')
            
            if humanoid and bodyTarget and player.Team ~= LocalPlayer.Team and humanoid.Health > 0 then
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

MainFeatures:AddButton({
	Name = "Give All Items",
	Callback = function()
        for _, item in game.Workspace.AllGiversForEverything:GetChildren() do
            if item:FindFirstChildWhichIsA('ClickDetector') then
                fireclickdetector(item:FindFirstChildWhichIsA('ClickDetector'))
                wait(0.01)
            end
        end
  	end
})

_G.AimbotEnabled = false
MainFeatures:AddToggle({
	Name = "Aimbot",
	Default = false,
	Callback = function(Value)
		_G.AimbotEnabled = Value
	end
})

_G.ESPEnabled = false
MainFeatures:AddToggle({
	Name = "ESP",
	Default = false,
	Callback = function(Value)
		_G.ESPEnabled = Value
	end
})

local currentTarget = nil
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = true
        updateFOVCircle()
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        Aiming = false
        updateFOVCircle()
        currentTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.AimbotEnabled then return end
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
    if not _G.ESPEnabled then return end
    for _, player in ipairs(Players:GetChildren()) do
        createPlayerChams(player)
    end
end)
