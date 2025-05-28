local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()

local games = "https://raw.githubusercontent.com/Actufe/AtlasWare/main/Games"

local local_player = cloneref(game:GetService("Players").LocalPlayer)
local market = cloneref(game:GetService("MarketplaceService"))
local info = market:GetProductInfo(game.PlaceId)

-- Executor kontrolü
if getthreadcontext() > 7 then
    print("Executor Supported")
else
    local_player:Kick(identifyexecutor().."You are getting banned and busted..")
end

-- Özel game ID kontrolü (manuel override gibi)
if game.GameId == 7546582051 and game.PlaceId == 94845773826960 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Actufe/AtlasWare/refs/heads/main/Games/Games/dungeon%20heroes.lua", true))()
    library:Notify("Supported Game Loading: "..info.Name)
    return
end

-- Genel destek kontrolü
local function check_supported()
    local success, result = pcall(function()
        return game:HttpGet(games.."/"..game.PlaceId..".lua")
    end)
    if not success or result == "404: Not Found" then
        library:Notify("Unsupported Game: "..info.Name.." — If you want it supported, join the Discord. Link copied.")
        setclipboard("https://discord.gg/vqKfva9e")
        return false
    end
    return true
end

-- Destekli ise yükle
if check_supported() then
    loadstring(game:HttpGet(games.."/"..game.PlaceId..".lua", true))()
    library:Notify("Supported Game Loading: "..info.Name)
end
