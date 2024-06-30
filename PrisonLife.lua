local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/dirt",true))()
local notif = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/notiflib/main/main"))()

local Players = game:GetService('Players')
local Player = Players.LocalPlayer

local Table = {}

local window = Lib:CreateWindow("Main")
window:Section("Main")

window:Button("Shutdown game",function()
    game:Shutdown()
end)

window:Toggle("Auto Respawn",{location = Table, flag = "Toggle"},function()
    if Table["Toggle"] then
        Table.AutoRespawnBool = Table['Toggle']
        print(Table.AutoRespawnBool)
    end
end)

window:Slider("Walkspeed",{location = Table, min = 16, max = 200, default = Table['WalkspeedSliderValue'], precise = true --[[ 0.00 instead of 0 ]], flag = "Slider"},function()
    local WalkspeedService

    if WalkspeedService then 
        WalkspeedService:Destroy()
        WalkspeedService = nil
        return
    end
    WalkspeedService = game:GetService('RunService').RenderStepped:Connect(function()
        if Player.Character.Humanoid.WalkSpeed == Table['Slider'] then return end
        Table['WalkspeedSliderValue'] = Table['Slider']
        Player.Character.Humanoid.WalkSpeed = Table['Slider']
    end)
end)

window:Dropdown("Give Item",{location = Table,flag = "Dropdown",search = true --[[AddsSearchBar]], list = {'M9','Remington 870','AK-47','M4A1'}, PlayerList = false},function()
    Table.GiveItemDropdownValue = Table['Dropdown']
    local ITEM_NAME = Table['Dropdown']
    local ItemHandler = workspace.Remote:WaitForChild("ItemHandler")
    local Position = Player.Character.HumanoidRootPart.Position

    if Player.Character:FindFirstChild(ITEM_NAME) or Player.Backpack:FindFirstChild(ITEM_NAME) then
        notif:Notification('Item Giver', ITEM_NAME..' is already in your inventory.','GothamSemibold','Gotham',4)
    end

    ItemHandler:InvokeServer({ Position = Position, Parent = workspace.Prison_ITEMS:FindFirstChild(ITEM_NAME, true)})
    if Player.Character:FindFirstChild(ITEM_NAME) or Player.Backpack:FindFirstChild(ITEM_NAME) then
        notif:Notification('Item Giver', 'Succesfully got '..ITEM_NAME..'.','GothamSemibold','Gotham',4)
    else
        notif:Notification('Item Giver', 'Unable to get '..ITEM_NAME..' because you were probably dead or was a gamepasss','GothamSemibold','Gotham',4)
    end
    task.wait(1)
end)
