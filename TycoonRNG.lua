local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))();

local TycoonRNG = OrionLib:MakeWindow({Name = "Tycoon RNG", HidePremium = false, SaveConfig = true, ConfigFolder = "NebulaHub"});
local AutoFarmTab = TycoonRNG:MakeTab({Name = "AutoFarm", Icon = "rbxassetid://4483345998", PremiumOnly = false});
local Farm = AutoFarmTab:AddSection({Name = "Farming Section"});
local MiscTab = TycoonRNG:MakeTab({Name = "Miscellaneous", Icon = "rbxassetid://4483345998", PremiumOnly = false})
local instances = MiscTab:AddSection({'Game Section'})

-- Functions
local function rejoinPlayer(placeId, Player)
    game:GetService("TeleportService"):Teleport(placeId, Player)
end

local cloneref = cloneref or function(o) return o end

local success, error_message = pcall(function()
	local VirtualUser = cloneref(game:GetService("VirtualUser"))
	game.Players.LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
	end)
    warn('anti-afk has been activated, you will no longer disconnect.')
end)
if not success then print(error_message) end

-- Farming Section
Farm:AddDropdown({
	Name = "Farm Method",
	Default = "TouchInterest",
	Options = {"TouchInterest", "Teleport"},
	Callback = function(Value)
		_G.AutoCubeMethod = Value;
	end
});

Farm:AddDropdown({
	Name = "Teleport Method",
	Default = "Tween Teleport",
	Options = {"Tween Teleport", "Instant Teleport"},
	Callback = function(Value)
		_G.TeleportMethod = Value;
	end
});

Farm:AddToggle({
	Name = "Auto Collect Cubes",
	Default = false,
	Callback = function(Value)
		_G.AutoCollectCubes = Value;
        local TweenService = game:GetService('TweenService');
        local PlayerService = game:GetService('Players');
        local RunService = game:GetService("RunService");
        local Player = PlayerService.LocalPlayer;
        local Workspace = game.Workspace;

        RunService.RenderStepped:Connect(function()
            if not _G.AutoCollectCubes then return end
            if _G.AutoCubeMethod == 'TouchInterest' then
                for _, cube in ipairs(Workspace:GetChildren()) do
                    if cube:FindFirstChild('Hitbox') and Player.Character.Humanoid.Health > 0 then
                        firetouchinterest(Player.Character.HumanoidRootPart, cube:FindFirstChild('Hitbox'), 0);
                    end
                end
            elseif _G.AutoCubeMethod == 'Teleport' then
                for _, cube in ipairs(Workspace:GetChildren()) do
                    if cube:FindFirstChild('Hitbox') and Player.Character.Humanoid.Health > 0 then
                        if _G.TeleportMethod == 'Tween Teleport' then
                            local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0);

                            TweenService:Create(Player.Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(cube.Hitbox.Position)}):Play();
                        elseif _G.TeleportMethod == 'Instant Teleport' then
                            Player.Character.HumanoidRootPart.CFrame = CFrame.new(cube:FindFirstChild('Hitbox').Position);
                        end
                    end
                end
            end
        end)
	end
});

instances:AddButton({
	Name = "Teleport To Another Server",
	Callback = function()
        rejoinPlayer(game.PlaceId, game.Players.LocalPlayer)
    end
});
OrionLib:Init()
