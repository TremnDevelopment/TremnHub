local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId)

local function createKavoLibrary(libraryInfo: table): table?
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

    local LibraryWindow = Library.CreateLib(libraryInfo["LibraryName"], libraryInfo["LibraryTheme"])

    return LibraryWindow
end

local function createLibraryTab(library: table, tabName: string)
    return library:NewTab(tabName)
end

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

    local KavoUI = createKavoLibrary({
        ["LibraryName"] = "[☀️] Grow a Garden 🍏",
        ["LibraryTheme"] = "Sentinel"
    })

    local Main = createLibraryTab(KavoUI, "Main")

    local PlayerSection = Main:NewSection("Player Optimizations")
    local OtherSection = Main:NewSection("Others")

    local CurrentEvents = createLibraryTab(KavoUI, "Active Events")

    local SummerHarvest = CurrentEvents:NewSection("Summer Harvest")
    
    local AutoSummerHarvest, AutoSummerHarvestMode, InsertOnlyFull

    SummerHarvest:NewDropdown("Auto Summer Harvest Mode", "The mode of the summer harvest mode", {"Slow", "Fast", "Instant"}, function(currentOption)
        AutoSummerHarvestMode = currentOption
    end)
    
    
    SummerHarvest:NewToggle("Auto Summer Harvest", "Automatically puts fruits into the summer harvest cart", function(state)
        while RunService.Heartbeat:Wait() do
            if not state then break end

            if AutoSummerHarvestMode == "Slow" then
                
            elseif AutoSummerHarvestMode == "Fast" then
                for _, fruit in pairs(LocalPlayer.Backpack:GetChildren()) do

                end
            elseif AutoSummerHarvestMode == "Instant" then
                if InsertOnlyFull and InventoryService:IsMaxInventory() then
                    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent"):FireServer("SubmitAllPlants")
                else
                    ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("SummerHarvestRemoteEvent"):FireServer("SubmitAllPlants")
                end
            end
        end
    end)

    --[[task.spawn(function()
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
    end)]]
end
