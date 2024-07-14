-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Load External Modules
local gameModule = loadstring(game:HttpGet('https://raw.githubusercontent.com/TremnDevelopment/Status.lua/main/gameName.lua'))()
local Status = loadstring(game:HttpGet('https://raw.githubusercontent.com/TremnDevelopment/Status.lua/main/gameScriptStatus.lua'))()

-- Load Orion Library
local HorrorRNG = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

---------------------------------------------
local nebula = {AutoUsePotion = false, AutoWish = false}

-- Functions
local function usePotion()
    local potionsToEquip = {"Super Luck Potion", "Luck Potion"}
    local potionName = potionsToEquip[math.random(1, 2)]

    local event = ReplicatedStorage.Events.InventoryEvent
    
    task.spawn(function()
        for _ = 1, 1 do
            event:FireServer("Equip", "Super Luck Potion", "Usable")
        end
    end)
    return potionName
end

local function makeWish()
    if not nebula.AutoWish then return end
    local success, error_message = pcall(function()
        ReplicatedStorage.Events.RollWish:FireServer()
    end)
    if not success then
        ReplicatedStorage.Events.InventoryEvent:FireServer("Equip", "Wish x2", "Usable")
    end
end

-- make orion window
local Window = HorrorRNG:MakeWindow({Name = gameModule[tostring(game.PlaceId)].Name, HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})
local AutoFarmTab = Window:MakeTab({Name = "AutoFarm", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local Farm = AutoFarmTab:AddSection({Name = "Farming Section"})
local Information = Window:MakeTab({Name = "Information", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local PlayerInfo = Information:AddSection({Name = "Player Information"});
local ScriptInfo = Information:AddSection({Name = "Script Information"});

-- make orion options
Farm:AddToggle({
    Name = "Auto Use Potion",
    Default = false,
    Callback = function(Value)
        nebula.AutoUsePotion = Value
        while true do
            if not nebula.AutoUsePotion then return end
            usePotion()
            RunService.Stepped:Wait()
        end
    end
})

Farm:AddToggle({
    Name = "Auto Wish",
    Default = false,
    Callback = function(Value)
        nebula.AutoWish = Value
        while true do
            if not nebula.AutoWish then return end
            makeWish()
            RunService.Stepped:Wait()
        end
    end
})

task.spawn(function()
    -- Informations
    task.spawn(function()
        local PlayerName = PlayerInfo:AddLabel('Player Name: '..LocalPlayer.Name)
        local PlayerUserId = PlayerInfo:AddLabel('Player UserId: '..LocalPlayer.UserId)
        local CooldownUpgrade = PlayerInfo:AddLabel('Current Cooldown Upgrade: '..LocalPlayer.MoneyUpgrade.Value)
        local MoneyUpgrade = PlayerInfo:AddLabel('Current Money Upgrade: '..LocalPlayer.MoneyUpgrade.Value)
        local LuckUpgrade = PlayerInfo:AddLabel('Current Luck Upgrade: '..LocalPlayer.LuckUpgrade.Value)
        local ScriptStatus = ScriptInfo:AddLabel('Script is: '..Status[tostring(game.PlaceId)].Status)
        local gameName = ScriptInfo:AddLabel('Game name: '..gameModule[tostring(game.PlaceId)].Name)
    
        -- repeatedly updating the informations
        RunService.Heartbeat:Connect(function()
            PlayerName:Set('Player Name: '..LocalPlayer.Name)
            PlayerUserId:Set('Player UserId: '..LocalPlayer.UserId)
            CooldownUpgrade:Set('Current Cooldown Upgrade: '..LocalPlayer.CooldownUpgrade.Value)
            MoneyUpgrade:Set('Current Money Upgrade: '..LocalPlayer.MoneyUpgrade.Value)
            LuckUpgrade:Set('Current Luck Upgrade: '..LocalPlayer.LuckUpgrade.Value)
            ScriptStatus:Set('Script is: '..Status[tostring(game.PlaceId)].Status)
            gameName:Set('Game name: '..gameModule[tostring(game.PlaceId)].Name)
            RunService.Heartbeat:Wait()
        end)
    end)

    -- Lag Reducer
    task.spawn(function ()
        -- repeatedly hiding and destroying anything found in temp boosts frame that isn't a UIListLayout for less lag
        RunService.Heartbeat:Connect(function()
            for _, value in ipairs(LocalPlayer.PlayerGui.Main.TempBoosts:GetChildren()) do
                if value.Name ~= "UIListLayout" or not value:IsA('UIListLayout') then
                    value.Visible = false
                    value:Destroy()
                end
            end
            RunService.Heartbeat:Wait()
        end)
        
        -- Hiding the stars for less lag
        if LocalPlayer and LocalPlayer.PlayerGui and LocalPlayer.PlayerGui.Main then
            local specialEffect = LocalPlayer.PlayerGui.Main:FindFirstChild("SpecialEffect")
            if specialEffect then
                local function onVisibleChanged()
                    if specialEffect.ViewportFrame.Visible then
                        specialEffect.ViewportFrame.Visible = false
                    end
                end

                specialEffect.ViewportFrame:GetPropertyChangedSignal("Visible"):Connect(onVisibleChanged)

                local childrenToDestroy = {"Piece1", "Piece2", "White", "Star", "UIAspectRatioConstraint", "UIGradient"}
                for _, childName in ipairs(childrenToDestroy) do
                    local child = specialEffect:FindFirstChild(childName)
                    if child then
                        child:Destroy()
                    end
                end
            end
        end
        local Terrain = game.Workspace.Terrain
        local Lighting = game:GetService("Lighting")

        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 0

        for _, child in pairs(game.Workspace:GetDescendants()) do
            if child:IsA("BasePart") and child.Name ~= "Terrain" then
                child.Material = Enum.Material.Plastic
                child.Reflectance = 0
            elseif child:IsA("Decal") or child:IsA("Texture") then
                child:Destroy()
            elseif child:IsA("ParticleEmitter") or child:IsA("Fire") or child:IsA("Smoke") then
                child.Enabled = false
            elseif child:IsA("Explosion") then
                child.Visible = false
            end
        end
    end)
end)
HorrorRNG:Init()
