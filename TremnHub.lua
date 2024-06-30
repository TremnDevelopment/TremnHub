local MainLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt",true))()
local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/notiflib/main/main"))()

local Players = game:GetService('Players')
local Player = Players.LocalPlayer

Notification:Notification("Tremn Hub","Loading Tremn Hub...","GothamSemibold","Gotham",3)

local InformationWindow = MainLib:CreateWindow("Information")
InformationWindow:Section("Updated 6/29/2024")
InformationWindow:Button("Update Logs",function()
    print("Tremn Hub was released during the date 6/29/2024, but wasn't public since it was still on development.")
end)

local SupportedWindow = MainLib:CreateWindow("Supported Games")
SupportedWindow:Section("Fighting Games")
SupportedWindow:Button("Information",function()
    print("Tremn Hub was still doesn't have any fighting games that are supported.")
end)
SupportedWindow:Section("Shooting Games")
SupportedWindow:Button("Murder Mystery 2",function()
    local MurderMysteryLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt",true))()

    local ConfigTable = {}

    local MurderMysteryWindow = MurderMysteryLib:CreateWindow("Main")
    MurderMysteryWindow:Section("Main")
    MurderMysteryWindow:Toggle("Auto Grab Gun", {location = ConfigTable, flag = "Toggle"} , function()
        -- Gun [Inside backpack or character], Knife [Inside backpack or character], and GunDrop [Inside workspace] --
        local currentPosition = nil
        while wait(.5) do
            if not ConfigTable['Toggle'] then return end
            for _, part in pairs(game.workspace:GetChildren()) do
                if part.Name == 'GunDrop' then
                    currentPosition = Player.Character.HumanoidRootPart.Position
                    task.wait()
                    for i = 1, 5 do
                        Player.Character.HumanoidRootPart.Position = CFrame.new(part.Position)
                        FireTouchInterest(game.Workspace:FindFirstChild('GunDrop'))
                    end
                    if Player.Character:FindFirstChild('Gun') or Player.Backpack:FindFirstChild('Gun') then
                        for i = 1, 5 do
                            Player.Character.HumanoidRootPart.Position = CFrame.new(currentPosition)
                        end
                    end
                end
            end
            currentPosition = nil
        end
    end)

    MurderMysteryWindow:Bind("Get Roles",{location = ConfigTable, flag = "KeyBind", default = Enum.KeyCode.B},function()
        if ConfigTable['KeyBind'] then
            for index, player in pairs(game:GetService("Players"):GetPlayers()) do
                wait(1)
                if player.Character:FindFirstChild('Gun') or player.Backpack:FindFirstChild('Gun') then
                    warn(player.Name.. " is the sheriff of this round.")
                    Notification:Notification("Roles", player.Name.." is the sherrif!","GothamSemibold","Gotham",.5)
                elseif player.Character:FindFirstChild('Knife') or player.Backpack:FindFirstChild('Knife') then
                    warn(player.Name.. " is the murderer of this round.")
                    Notification:Notification("Roles", player.Name.." is the murderer!","GothamSemibold","Gotham",1)
                else
                    print(player.Name.. " is an innocent this round.")
                    Notification:Notification("Roles", player.Name.." is innocent!","GothamSemibold","Gotham",1)
                end
            end
        end
    end)
end)

Notification:Notification("Tremn Hub","Loaded!","GothamSemibold","Gotham",3)
