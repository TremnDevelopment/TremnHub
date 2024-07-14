local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

if game.PlaceId == 15514727567 or game.PlaceId == 14518422161 then
    local GunFightArena = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
    local Window = GunFightArena:MakeWindow({Name = "Gunfight Arena | KEYBINDS", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

    local Main = Window:MakeTab({Name = "Main", Icon = "rbxassetid://4483345998", PremiumOnly = false})
    local MainSection = Main:AddSection({Name = "Main Features"})

    local Aiming = false
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = Color3.fromRGB(255, 0, 0)
    FOVCircle.Thickness = 2
    FOVCircle.NumSides = 32
    FOVCircle.Visible = false
    
    local function createBotChams(Bot)
        if game.Workspace[Bot.Name]:FindFirstChild('BotHighlight') == nil then
            local highlight = Instance.new('Highlight')
            highlight.Name = 'BotHighlight'
            highlight.DepthMode = "AlwaysOnTop"
            highlight.FillColor = Color3.new(0,0,0)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.Parent = Workspace[Bot.Name]
            return highlight
        end
    end
    
    local function createPlayerChams(player)
        if player.Character:FindFirstChild("PlayerHighlight") == nil then
            local highlight = Instance.new('Highlight')
            highlight.Name = 'PlayerHighlight'
            highlight.DepthMode = "AlwaysOnTop"
            highlight.FillColor = Color3.new(1,1,1)
            highlight.FillTransparency = 0.5
            highlight.OutlineColor = Color3.new(0,0,0)
            highlight.Parent = player.Character
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
                local head = player.Character and player.Character:FindFirstChild("Head")
                
                if humanoid and head and player.Team ~= LocalPlayer.Team then
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

    local function findNearestBot()
        local localPlayer = Players.LocalPlayer
        if not localPlayer then return nil end
        
        local nearestBot = nil
        local minDistance = math.huge
        
        for _, player in ipairs(Players:GetChildren()) do
            if player:IsA('Folder') then
                createBotChams(player)
                local humanoid = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild("Humanoid")
                local head = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild("Head")
                
                if humanoid and head and LocalPlayer:GetAttribute('Team') ~= player:GetAttribute('Team') then
                    local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
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
            local head
            if player:IsA('Folder') then
                createBotChams(player)
                humanoid = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild("Humanoid")
                head = Workspace[player.Name] and Workspace[player.Name]:FindFirstChild("Head")
            elseif player:IsA('Player') then
                createPlayerChams(player)
                humanoid = Players[player.Name].Character and Players[player.Name].Character:FindFirstChild("Humanoid")
                head = Players[player.Name].Character and Players[player.Name].Character:FindFirstChild("Head")
            end
            if humanoid and head and LocalPlayer:GetAttribute('Team') ~= player:GetAttribute('Team') then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
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
    MainSection:AddToggle({
        Name = "Enable Aimbot",
        Default = false,
        Callback = function(Value)
            _G.AimbotEnabled = Value
        end
    })
    
    _G.FOVCircleEnabled = false
    MainSection:AddToggle({
        Name = "Enable Field of View Circle",
        Default = false,
        Callback = function(Value)
            _G.FOVCircleEnabled = Value
        end
    })

    _G.selectedTarget = 'Players'
    MainSection:AddDropdown({
        Name = "Target",
        Default = "Players",
        Options = {"Players", "Bots", "Both"},
        Callback = function(Value)
            _G.selectedTarget = Value
        end
    })
    
    _G.ChamEnabled = false
    MainSection:AddToggle({
        Name = "Enable Chams",
        Default = false,
        Callback = function(Value)
            _G.ChamEnabled = Value
        end
    })
    
    _G.selectedChamTarget = 'Player'
    MainSection:AddDropdown({
        Name = "Chams Target",
        Default = "Players",
        Options = {"Players", "Bots", "Both"},
        Callback = function(Value)
            _G.selectedChamTarget = Value
        end
    })
    
    RunService.Heartbeat:Connect(function()
        if not _G.ChamEnabled then return end
        for _, player in ipairs(Players:GetChildren()) do
            if _G.selectedChamTarget == 'Players' and player:IsA('Player') and player.Character:FindFirstChild('Humanoid').Health > 0 then
                createPlayerChams(player)
            elseif _G.selectedChamTarget == 'Bots' and player:IsA('Folder') and Workspace[player.Name]:FindFirstChild('Humanoid').Health > 0 then
                createBotChams(player)
            elseif _G.selectedChamTarget == 'Both' then
                if player:IsA('Player') and player ~= LocalPlayer and player.Character:FindFirstChild('Humanoid').Health > 0 then
                    createPlayerChams(player)
                elseif player:IsA('Folder') and Workspace[player.Name]:FindFirstChild('Humanoid').Health > 0 then
                    createBotChams(player)
                end
            end
        end
    end)

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
                    
                    local head = currentTarget.Character and currentTarget.Character:FindFirstChild("Head")
                    if head then
                        local direction = (head.Position - camera.CFrame.Position).unit
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
                    
                    local head = currentTarget and currentTarget:FindFirstChild("Head")
                    if head then
                        local direction = (head.Position - camera.CFrame.Position).unit
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
                    
                    local head = currentTarget and currentTarget:FindFirstChild("Head")
                    if head then
                        local direction = (head.Position - camera.CFrame.Position).unit
                        local newCFrame = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + direction * 10)
                        camera.CFrame = newCFrame
                    end
                end
            end
        end
    end)
end
