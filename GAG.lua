local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)

-- Validate we're in the correct game
if game.PlaceId == 126884695634066 and GameInfo.Name == "[☀️] Grow a Garden 🍏" then
    local InventoryService = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("InventoryService"))

    local function GetAllGardens(): { Folder }
        local gardens = {}
        local farm = workspace:WaitForChild("Farm")

        for _, plot in pairs(farm:GetChildren()) do
            if plot:GetAttribute("Loaded") then
                table.insert(gardens, plot)
            end
        end
        return gardens
    end

    local function GetGardenOwner(plot: Folder): string?
        if not plot:GetAttribute("Loaded") then return nil end

        local important = plot:FindFirstChild("Important")
        if not important then return nil end

        local data = important:FindFirstChild("Data")
        local owner = data and data:FindFirstChild("Owner")

        if owner and owner:IsA("StringValue") then
            return owner.Value
        end
        return nil
    end

    local function GetPlayerGarden(playerName: string): Folder?
        for _, plot in pairs(GetAllGardens()) do
            if GetGardenOwner(plot) == playerName then
                return plot
            end
        end
        return nil
    end

    local function FindFirstProximityPrompt(obj: Instance): ProximityPrompt?
        for _, descendant in ipairs(obj:GetDescendants()) do
            if descendant:IsA("ProximityPrompt") then
                return descendant
            end
        end
        return nil
    end

    -- Harvesting logic
    task.spawn(function()
        local garden = GetPlayerGarden(LocalPlayer.Name)
        if not garden then
            warn("No garden found for player.")
            return
        end

        local plantFolder = garden:WaitForChild("Important"):WaitForChild("Plants_Physical")

        while RunService.Heartbeat:Wait() do
            if InventoryService:IsMaxInventory() then
                -- // Submit all plants if inventory is full
                ReplicatedStorage:WaitForChild("GameEvents")
                    :WaitForChild("SummerHarvestRemoteEvent")
                    :FireServer("SubmitAllPlants")
                continue
            end

            for _, plantTree in pairs(plantFolder:GetChildren()) do
                if InventoryService:IsMaxInventory() then break end

                local fruitsFolder = plantTree:FindFirstChild("Fruits")
                if fruitsFolder then
                    for _, fruit in pairs(fruitsFolder:GetChildren()) do
                        if InventoryService:IsMaxInventory() then break end

                        local prompt = FindFirstProximityPrompt(fruit)
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                        task.wait()
                    end
                end
            end
        end
    end)
end
