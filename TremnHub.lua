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
    loadstring(game:HttpGet('https://raw.githubusercontent.com/TremnDevelopment/TremnHub/main/MurderMystery2.lua',true))()
end)

Notification:Notification("Tremn Hub","Loaded!","GothamSemibold","Gotham",3)
