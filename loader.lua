local expectedHex = "747269706C65376C6F61646572"
local url = "https://raw.githubusercontent.com/triple7distro/root/refs/heads/main/hex/6C6F61646572"

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local success, rawContent = pcall(function()
    return game:HttpGet(url)
end)

if not success or not rawContent then
    if LocalPlayer then
        LocalPlayer:Kick("fetch fail")
    end
    return
end

rawContent = rawContent:gsub("^%s+", ""):gsub("%s+$", "")

local hexValue = rawContent:match("[Hh][Ee][Xx]%s*=%s*[\"']?([%w_]+)[\"']?")
if not hexValue then
    hexValue = rawContent:match("hex%s*=%s*([%w_]+)")
end

if not hexValue or hexValue ~= expectedHex then
    if LocalPlayer then
        LocalPlayer:Kick("invalid")
    end
    return
end

local placeId = game.PlaceId

if placeId == 7336302630 or placeId == 7336302631 then
    StarterGui:SetCore("SendNotification", {
        Title = "triple7 loader",
        Text = "project delta detected - loading",
        Duration = 1
    })
    loadstring(game:HttpGet("https://raw.githubusercontent.com/triple7distro/root/refs/heads/main/scripts/70726F6A6563742064656C7461.lua"))()
    
elseif placeId == 404 then
    StarterGui:SetCore("SendNotification", {
        Title = "triple7 loader",
        Text = "404",
        Duration = 1
    })
    loadstring(game:HttpGet("https://github.com/"))()
    
else
    StarterGui:SetCore("SendNotification", {
        Title = "triple7 loader",
        Text = "game not supported",
        Duration = 10
    })
end