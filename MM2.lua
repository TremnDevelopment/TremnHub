local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function createOrUpdateRoleTag(player, role)
    local character = player.Character
    if not character or not character:FindFirstChild("Head") or not character:FindFirstChild("HumanoidRootPart") then return end

    -- Remove existing tag part if exists
    if character:FindFirstChild("RoleTagPart") then
        character.RoleTagPart:Destroy()
    end

    -- Role Colors
    local roleColors = {
        Murderer = Color3.fromRGB(255, 0, 0),     -- Red
        Sheriff = Color3.fromRGB(0, 150, 255),    -- Blue
        Innocent = Color3.fromRGB(0, 255, 0),     -- Green
        Hero = Color3.fromRGB(255, 215, 0)        -- Gold
    }

    local highlightRole = "[" .. string.upper(role) .. "]"
    local color = roleColors[role] or Color3.new(1, 1, 1)

    -- Create 3D text part
    local tagPart = Instance.new("Part")
    tagPart.Name = "RoleTagPart"
    tagPart.Size = Vector3.new(3, 1, 0.2)
    tagPart.Anchored = true
    tagPart.CanCollide = false
    tagPart.Transparency = 1
    tagPart.Parent = character

    -- Function to create a SurfaceGui on a given face
    local function addTextToFace(face)
        local surfaceGui = Instance.new("SurfaceGui")
        surfaceGui.Face = face
        surfaceGui.Adornee = tagPart
        surfaceGui.AlwaysOnTop = true
        surfaceGui.LightInfluence = 0
        surfaceGui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        surfaceGui.PixelsPerStud = 50
        surfaceGui.Parent = tagPart

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = highlightRole
        textLabel.TextColor3 = color
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = surfaceGui
    end

    addTextToFace(Enum.NormalId.Front)
    addTextToFace(Enum.NormalId.Back)

    -- Update tagPart position each frame
    RunService.RenderStepped:Connect(function()
        if character and tagPart and tagPart.Parent then
            local head = character:FindFirstChild("Head")
            local root = character:FindFirstChild("HumanoidRootPart")
            if head and root then
                local offset = Vector3.new(0, 3.2, 0)
                local basePos = head.Position + offset
                tagPart.CFrame = CFrame.new(basePos, basePos + root.CFrame.LookVector)
            end
        end
    end)
end

-- Continuously update roles in case they change mid-round
task.spawn(function()
    while true do
        local gameData = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Gameplay"):WaitForChild("GetCurrentPlayerData"):InvokeServer()

        for _, player in ipairs(Players:GetPlayers()) do
            local playerData = gameData[player.Name]
            if playerData and not playerData.Dead and player.Character then
                local currentTag = player.Character:FindFirstChild("RoleTagPart")
                local existingRole = currentTag and currentTag:FindFirstChildOfClass("SurfaceGui") and currentTag:FindFirstChildOfClass("SurfaceGui"):FindFirstChild("TextLabel") and currentTag:FindFirstChildOfClass("SurfaceGui"):FindFirstChild("TextLabel").Text
                local newRole = "[" .. string.upper(playerData.Role) .. "]"

                if not currentTag or existingRole ~= newRole then
                    createOrUpdateRoleTag(player, playerData.Role)
                end
            end
        end

        task.wait(1) -- check for changes every second
    end
end)
