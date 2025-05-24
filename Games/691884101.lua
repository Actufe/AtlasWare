if not game:IsLoaded() then
    print("Waiting for game to load...")
    game.Loaded:Wait()
    print("Loaded Game")
end

local repo = 'https://raw.githubusercontent.com/KINGHUB01/Gui/main/'

local library = loadstring(game:HttpGet(repo .. 'Gui%20Lib%20%5BLibrary%5D'))()
local theme_manager = loadstring(game:HttpGet(repo .. 'Gui%20Lib%20%5BThemeManager%5D'))()
local save_manager = loadstring(game:HttpGet(repo .. 'Gui%20Lib%20%5BSaveManager%5D'))()

local window = library:CreateWindow({
    Title = 'Atlas Ware | Turkiye Numero One | discord.gg/vqKfva9e ',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local tabs = {
    main = window:AddTab('Main'),
    ['ui settings'] = window:AddTab('UI Settings')
}

local menu_group = tabs['ui settings']:AddLeftGroupbox('Menu')

-- Ayarları başta yükle
theme_manager:SetLibrary(library)
save_manager:SetLibrary(library)
save_manager:IgnoreThemeSettings()
save_manager:SetIgnoreIndexes({ 'MenuKeybind' })
theme_manager:SetFolder('Astolfo Ware')
save_manager:SetFolder('Astolfo Ware/Tradelands')
save_manager:BuildConfigSection(tabs['ui settings'])
theme_manager:ApplyToTab(tabs['ui settings'])
save_manager:LoadAutoloadConfig()

-- Diğer UI öğeleri
local game_group = tabs.main:AddLeftGroupbox('Game Settings')
local teleport_group = tabs.main:AddLeftGroupbox('Autofarm')
local credits_group = tabs.main:AddRightGroupbox('Credits')

local replicated_storage = cloneref(game:GetService("ReplicatedStorage"))
local tween_service = cloneref(game:GetService("TweenService"))
local market = cloneref(game:GetService("MarketplaceService"))
local run_service = cloneref(game:GetService("RunService"))
local workspace = cloneref(game:GetService("Workspace"))
local players = cloneref(game:GetService("Players"))
local stats = cloneref(game:GetService("Stats"))
local info = market:GetProductInfo(game.PlaceId)
local local_player = players.LocalPlayer

local LocalShips = replicated_storage:WaitForChild("LocalShips")

local selected_ships = nil
local selectedDockLoad = nil
local selectedDockUnload = nil

local docks = {
    ["RO/RODock1"] = Vector3.new(-6810, 31, 24511),
    ["RO/RODock3"] = Vector3.new(-14417, 30, -43390),
    ["FerryDock4"] = Vector3.new(-15042, 31, -43761),
    ["FerryDock2"] = Vector3.new(-7011, 30, 24685),
    ["GeneralDock7"] = Vector3.new(49181, 10, -3344),
    ["GeneralDock8"] = Vector3.new(29080, 20, -23004),
    ["ContainerDock4"] = Vector3.new(-14376, 41, -43586),
    ["ContainerDock3"] = Vector3.new(-5978, 41, 26999),
}

local function getShipNames()
    local ships = {}
    for _, ship in ipairs(LocalShips:GetChildren()) do
        if ship:IsA("Model") or ship:IsA("Folder") then
            table.insert(ships, ship.Name)
        end
    end
    return ships
end

local shipNames = getShipNames()

local dockNames = {}
for name, _ in pairs(docks) do
    table.insert(dockNames, name)
end

teleport_group:AddDivider()

teleport_group:AddDropdown('ship_selector', {
    Values = shipNames,
    Default = shipNames[1] or "",
    Multi = false,
    Text = 'Select ship for autofarm:',
    Tooltip = 'Select the ship to autofarm with',
    Callback = function(Value)
        selected_ships = Value
        print("Selected ship: " .. tostring(Value))
    end
})

teleport_group:AddDropdown('dock_load_selector', {
    Values = dockNames,
    Default = dockNames[1],
    Multi = false,
    Text = 'Select dock for loading:',
    Callback = function(value)
        selectedDockLoad = value
        print("Selected load dock: " .. tostring(value))
    end
})

teleport_group:AddDropdown('dock_unload_selector', {
    Values = dockNames,
    Default = dockNames[2] or dockNames[1],
    Multi = false,
    Text = 'Select dock for unloading:',
    Callback = function(value)
        selectedDockUnload = value
        print("Selected unload dock: " .. tostring(value))
    end
})

local function notify(text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "DSS3 Gaming Autofarm",
        Text = text,
        Duration = 3
    })
end

local function findPlayerShip(shipName)
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == shipName and v:FindFirstChild("Regen") then
            local owner = v.Regen:FindFirstChild("Gunboat") 
                and v.Regen.Gunboat:FindFirstChild("VehicleSeat") 
                and v.Regen.Gunboat.VehicleSeat:FindFirstChild("ShipControl")
                and v.Regen.Gunboat.VehicleSeat.ShipControl:FindFirstChild("OWNER")
            if owner and owner.Value.Name == local_player.Name then
                return v
            end
        end
    end
    return nil
end

local function moveShipToPos(ship, pos)
    if ship and ship.PrimaryPart then
        ship:SetPrimaryPartCFrame(CFrame.new(pos))
    end
end

local running = false

local function startAutoFarm()
    if running then
        notify("Autofarm zaten çalışıyor!")
        return
    end

    if not selected_ships or not selectedDockLoad or not selectedDockUnload then
        notify("Lütfen gemi ve dockları seçin!")
        return
    end

    running = true
    notify("Autofarm başladı!")

    spawn(function()
        while running do
            local ship = findPlayerShip(selected_ships)
            if not ship then
                notify("Gemi bulunamadı!")
                wait(5)
                continue
            end

            ship.PrimaryPart = ship.Regen.Gunboat.Base

            local loadPos = docks[selectedDockLoad]
            local unloadPos = docks[selectedDockUnload]

            notify("Yükleme noktasına gidiliyor")
            moveShipToPos(ship, loadPos)
            wait(5)
            workspace.HandleCargoEvent:FireServer("load", ship, workspace:FindFirstChild(selectedDockLoad))
            notify("Yük alındı")

            wait(300) -- yükleme süresi

            notify("Boşaltma noktasına gidiliyor")
            moveShipToPos(ship, unloadPos)
            wait(5)
            workspace.HandleCargoEvent:FireServer("sell", ship, workspace:FindFirstChild(selectedDockUnload))
            notify("Yük satıldı")

            wait(5)
        end
    end)
end

game_group:AddButton("Start Autofarm", function()
    startAutoFarm()
end)

game_group:AddButton("Stop Autofarm", function()
    if running then
        running = false
        notify("Autofarm durduruldu!")
    else
        notify("Autofarm zaten durdurulmuş!")
    end
end)

credits_group:AddLabel('@zelvednpervet: Who made the script', true)

credits_group:AddButton({
    Text = 'Join our discord!',
    Func = function()
        setclipboard('https://discord.gg/vqKfva9e')
    end,
    DoubleClick = false,
    Tooltip = 'Join our official discord server.'
})

credits_group:AddButton({
    Text = 'Scriptblox profile',
    Func = function()
        setclipboard('https://scriptblox.com/u/redogurt')
    end,
    DoubleClick = false,
    Tooltip = 'My scriptblox profile'
})

local menuKeybindOption = menu_group:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

if type(menuKeybindOption.Get) == 'function' then
    library.ToggleKeybind = menuKeybindOption:Get()
elseif type(menuKeybindOption.GetValue) == 'function' then
    library.ToggleKeybind = menuKeybindOption:GetValue()
elseif menuKeybindOption.Value then
    library.ToggleKeybind = menuKeybindOption.Value
else
    library.ToggleKeybind = 'End'
end

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local watermark_connection = run_service.RenderStepped:Connect(function()
    FrameCounter += 1

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end

    library:SetWatermark(('Atlas Ware | %s fps | %s ms | game: ' .. info.Name .. ''):format(
        math.floor(FPS),
        math.floor(stats.Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

menu_group:AddButton('Unload', function()
    watermark_connection:Disconnect()
    library:Unload()
end)
