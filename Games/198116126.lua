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
    Title = 'Atlas Ware | Made By @dayumduh Tradelands',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local tabs = {
    main = window:AddTab('Main'),
    ['ui settings'] = window:AddTab('UI Settings')
}

local game_group = tabs.main:AddLeftGroupbox('Game Settings')
local player_group = tabs.main:AddRightGroupbox('Player Settings')
local teleport_group = tabs.main:AddLeftGroupbox('Teleport Settings')
local menu_group = tabs['ui settings']:AddLeftGroupbox('Menu')

local replicated_storage = cloneref(game:GetService("ReplicatedStorage"))
local tween_service = cloneref(game:GetService("TweenService"))
local market = cloneref(game:GetService("MarketplaceService"))
local run_service = cloneref(game:GetService("RunService"))
local workspace = cloneref(game:GetService("Workspace"))
local players = cloneref(game:GetService("Players"))
local stats = cloneref(game:GetService("Stats"))
local info = market:GetProductInfo(game.PlaceId)
local local_player = players.LocalPlayer

local tree = workspace.Trees
local ore = workspace.OreNodes

local trees = {}
local ores = {}

local selected_tree = ""
local selected_ore = ""

local tween_speed = 100

local goto_nearest_tree = false
local goto_nearest_ore = false
local staff_check = false
local auto_swing = false

for _, v in next, tree:GetChildren() do
    if v.Name:find("Trees") then
        table.insert(trees, v.Name)
    end
end

for _, v in next, ore:GetChildren() do
    table.insert(ores, v.Name)
end

function closest_tree()
    local treee = nil
    local distance = math.huge
    for _, v in next, tree:FindFirstChild(selected_tree):GetChildren() do
        if v:IsA("Model") then
            local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
            if dist < distance then
                distance = dist
                treee = v
            end
        end
    end
    return treee
end

function closest_ore()
    local oree = nil
    local distance = math.huge
    for _, v in next, ore:FindFirstChild(selected_ore):GetChildren() do
        if v:IsA("MeshPart") then
            local dist = (v:GetPivot().Position - local_player.Character:GetPivot().Position).Magnitude
            if dist < distance then
                distance = dist
                oree = v
            end
        end
    end
    return oree
end

players.PlayerAdded:Connect(function(v)
    if staff_check then
        if v ~= local_player then
            local group = v:GetRankInGroup(2769167)
            if group > 1 then
                local_player:Kick("Staff detected! Username: "..v.DisplayName)
            end
        end
    end
end)

game_group:AddDivider()

game_group:AddToggle('auto_swing', {
    Text = 'Auto Swing',
    Default = auto_swing,
    Tooltip = 'Automatically swings for you',

    Callback = function(Value)
        auto_swing = Value
        if Value then
            repeat
                if local_player.Character and local_player.Character:FindFirstChildOfClass("Tool") then -- Didnt add stamina checks as it dosent take away stamina
                    local_player.Character:FindFirstChildOfClass("Tool").ToolScript.Swing:FireServer("left", nil, 64)
                    task.wait(.25)
                    local_player.Character:FindFirstChildOfClass("Tool").ToolScript.Swing:FireServer("right", nil, 64)
                end
                task.wait()
            until not auto_swing
        end
    end
})

player_group:AddDivider()

player_group:AddButton({
    Text = 'Break Stamina',
    Func = function()
        if local_player.PlayerGui:FindFirstChild("GameGui") and local_player.PlayerGui.GameGui:FindFirstChild("Stamina") then
            local_player.PlayerGui.GameGui.Stamina:Destroy()
            library:Notify("Stamina Broken")
        else
            library:Notify("Already Broken")
        end
    end,
    DoubleClick = false,
    Tooltip = 'Gives inf stamina [Rejoin To Fix]'
})

player_group:AddDivider()

player_group:AddToggle('staff_check', {
    Text = 'Staff Check',
    Default = staff_check,
    Tooltip = 'Check if staff joined/are in server',

    Callback = function(Value)
        staff_check = Value
        if Value then
            for _, v in next, players:GetPlayers() do
                if v ~= local_player then
                    local group = v:GetRankInGroup(2769167)
                    if group > 1 then
                        local_player:Kick("Staff detected! Username: "..v.DisplayName)
                    end
                end
            end
        end
    end
})

teleport_group:AddDivider()

teleport_group:AddDropdown('tree_selector', {
    Values = trees,
    Default = selected_tree,
    Multi = false,

    Text = 'Select Tree To Teleport To:',
    Tooltip = 'Teleports you to selected tree',

    Callback = function(Value)
        selected_tree = Value
    end
})

teleport_group:AddButton({
    Text = 'Teleport To Tree',
    Func = function()
        if selected_tree == "" then
            library:Notify("Select Tree Before Teleporting")
            return
        end

        if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
            local tree = closest_tree()
            if tree then
                local velocity_connection = run_service.Heartbeat:Connect(function()
                    if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                        local_player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        local_player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
                local to = tree:GetPivot().Position
                local distance = (to - local_player.Character:GetPivot().Position).Magnitude
                local tween = tween_service:Create(local_player.Character.HumanoidRootPart, TweenInfo.new(distance / tween_speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = CFrame.new(tree:GetPivot().Position) + Vector3.new(0, -10, 3)})
                tween:Play()
                tween.Completed:Wait()
                if velocity_connection then
                    velocity_connection:Disconnect()
                end
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleports you to selected tree'
})

teleport_group:AddToggle('auto_goto_tree', {
    Text = 'Auto Goto Tree',
    Default = goto_nearest_tree,
    Tooltip = 'Automatically goes to closest tree',

    Callback = function(Value)
        goto_nearest_tree = Value
        if Value then
            if selected_tree == "" then
                library:Notify("Select Tree Before Teleporting")
                goto_nearest_tree = false
                return
            end

            repeat
                if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                    local tree = closest_tree()
                    if tree then
                        local velocity_connection = run_service.Heartbeat:Connect(function()
                            if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                                local_player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                local_player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                            end
                        end)
                        local to = tree:GetPivot().Position
                        local distance = (to - local_player.Character:GetPivot().Position).Magnitude
                        local tween = tween_service:Create(local_player.Character.HumanoidRootPart, TweenInfo.new(distance / tween_speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = CFrame.new(tree:GetPivot().Position) + Vector3.new(0, -10, 3)})
                        tween:Play()
                        tween.Completed:Wait()
                        if velocity_connection then
                            velocity_connection:Disconnect()
                        end
                    end
                end
                task.wait()
            until not goto_nearest_tree
        end
    end
})

teleport_group:AddDivider()

teleport_group:AddDropdown('ore_selector', {
    Values = ores,
    Default = selected_ore,
    Multi = false,

    Text = 'Select Ore To Teleport To:',
    Tooltip = 'Teleports you to selected ore',

    Callback = function(Value)
        selected_ore = Value
    end
})

teleport_group:AddButton({
    Text = 'Teleport To Ore',
    Func = function()
        if selected_ore == "" then
            library:Notify("Select Ore Before Teleporting")
            return
        end

        if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
            local ore = closest_ore()
            if ore then
                local velocity_connection = run_service.Heartbeat:Connect(function()
                    if local_player.Character and local_player.Character:FindFirstChild("HumanoidRootPart") then
                        local_player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                        local_player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    end
                end)
                local to = ore:GetPivot().Position
                local distance = (to - local_player.Character:GetPivot().Position).Magnitude
                local tween = tween_service:Create(local_player.Character.HumanoidRootPart, TweenInfo.new(distance / tween_speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {CFrame = CFrame.new(ore:GetPivot().Position) + Vector3.new(0, 0, 2.5)})
                tween:Play()
                tween.Completed:Wait()
                if velocity_connection then
                    velocity_connection:Disconnect()
                end
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Teleports you to selected Ore'
})

teleport_group:AddToggle('auto_goto_ore', {
    Text = 'Auto Goto Ore',
    Default = goto_nearest_ore,
    Tooltip = 'Automatically goes to closest ore',

    Callback = function(Value)
        goto_nearest_ore = Value
        if Value then
            if selected_ore == "" then
                library:Notify("Select Ore Before Teleporting")
                goto_nearest_ore = false
                return
            end

            task.spawn(function()
                local Players = game:GetService("Players")
                local TweenService = game:GetService("TweenService")
                local LocalPlayer = Players.LocalPlayer

                local function getClosestOreNode()
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local root = character:WaitForChild("HumanoidRootPart")

                    local closestNode
                    local shortestDistance = math.huge

                    for _, folder in pairs(workspace:WaitForChild("OreNodes"):GetChildren()) do
                        for _, ore in pairs(folder:GetChildren()) do
                            if ore:IsA("BasePart") and ore.Transparency == 0 then
                                local dist = (root.Position - ore.Position).Magnitude
                                if dist < shortestDistance then
                                    shortestDistance = dist
                                    closestNode = ore
                                end
                            end
                        end
                    end
                    return closestNode
                end

                local function tweenTo(target)
                    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    local root = character:WaitForChild("HumanoidRootPart")

                    local offsetDirection = (root.Position - target.Position).Unit
                    local offset = offsetDirection * 5
                    local goalPosition = target.Position + offset

                    local lookAtCFrame = CFrame.new(goalPosition, target.Position)
                    local tweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear)
                    local tween = TweenService:Create(root, tweenInfo, {CFrame = lookAtCFrame})
                    tween:Play()
                    tween.Completed:Wait()
                end

                while goto_nearest_ore do
                    local ore = getClosestOreNode()
                    if ore then
                        tweenTo(ore)
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})


teleport_group:AddDivider()

teleport_group:AddSlider('speed_slider', {
    Text = 'Select Tween Speed:',
    Default = tween_speed,
    Min = 50,
    Max = 500,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        tween_speed = Value
    end
})

local FrameTimer = tick()
local FrameCounter = 0;
local FPS = 60;

local watermark_connection = run_service.RenderStepped:Connect(function()
    FrameCounter += 1;

    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter;
        FrameTimer = tick();
        FrameCounter = 0;
    end;

    library:SetWatermark(('Atlas Ware | %s fps | %s ms | game: ' .. info.Name .. ''):format(
        math.floor(FPS),
        math.floor(stats.Network.ServerStatsItem['Data Ping']:GetValue())
    ));
end);

menu_group:AddButton('Unload', function()
    goto_nearest_tree = false
    goto_nearest_ore = false
    staff_check = false
    auto_swing = false
    if velocity_connection then
        velocity_connection:Disconnect()
    end
    watermark_connection:Disconnect()
    library:Unload()
end)

menu_group:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
library.ToggleKeybind = Options.MenuKeybind
theme_manager:SetLibrary(library)
save_manager:SetLibrary(library)
save_manager:IgnoreThemeSettings()
save_manager:SetIgnoreIndexes({ 'MenuKeybind' })
theme_manager:SetFolder('Atlas Ware')
save_manager:SetFolder('Atlas Ware/Tradelands')
save_manager:BuildConfigSection(tabs['ui settings'])
theme_manager:ApplyToTab(tabs['ui settings'])
save_manager:LoadAutoloadConfig()
