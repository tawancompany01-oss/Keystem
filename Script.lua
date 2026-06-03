--[[
    ================================================================
    [ SCRIPT INFORMATION ]
    Project: Custom Script
    Author: OYB
    YouTube: https://www.youtube.com/channel/UCAlXXV1Hbvf7WbfXARuVtiQ
    
    [ TERMS AND CONDITIONS ]
    - You ARE allowed to use and modify this script for your own games.
    - You ARE NOT allowed to re-upload, redistribute, or claim 
      ownership of this script.
    - Removing or altering these credits is strictly prohibited.
    
    Copyright (c) 2026 OYB. All rights reserved.
    ================================================================
]]

-- ⚠️ IMPORTANT: Put this code at the VERY TOP of your Main Script (before obfuscating) ⚠️

local ProtectionConfig = {
    -- 🔴 CRITICAL: This MUST exactly match the 'Secret' value in your Key System's Config!
    -- If your Key System has: Secret = "Test"
    -- Then this must also be: SecretKey = "Test"
    SecretKey = "589452",
    
    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "OYB HUB"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if not _G[ProtectionConfig.SecretKey] then
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------
-- Demonser Hub v2 | Anti-AFK + NPC Logger + Position Copier
-- RightShift = ซ่อน/แสดง

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer

-- ===== GUARD: ลบ GUI เก่าก่อนรันใหม่ =====
local existingGui = localPlayer:WaitForChild("PlayerGui"):FindFirstChild("DemonserHubV2")
if existingGui then
    existingGui:Destroy()
    task.wait(0.1)
end

local function make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end
local function corner(r, parent)
    make("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end
local function tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quad), props):Play()
end

local screenGui = make("ScreenGui", {
    Name = "DemonserHubV2",
    ResetOnSpawn = false,
}, localPlayer:WaitForChild("PlayerGui"))

local win = make("Frame", {
    Size = UDim2.new(0, 340, 0, 480),
    Position = UDim2.new(0.5, -170, 0.5, -240),
    BackgroundColor3 = Color3.fromRGB(8, 4, 4),
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, screenGui)
corner(14, win)
make("UIStroke", { Color = Color3.fromRGB(160, 20, 20), Thickness = 1.5, Transparency = 0.3 }, win)
make("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = Color3.fromRGB(200, 20, 20),
    BorderSizePixel = 0,
}, win)

local titleBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 52),
    BackgroundColor3 = Color3.fromRGB(14, 6, 6),
    BorderSizePixel = 0,
}, win)
corner(14, titleBar)
make("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Color3.fromRGB(14, 6, 6),
    BorderSizePixel = 0,
}, titleBar)

local eyeDot = make("Frame", {
    Size = UDim2.new(0, 10, 0, 10),
    Position = UDim2.new(0, 14, 0.5, -5),
    BackgroundColor3 = Color3.fromRGB(220, 30, 30),
    BorderSizePixel = 0,
}, titleBar)
corner(999, eyeDot)
task.spawn(function()
    while true do
        tween(eyeDot, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }, 0.8)
        task.wait(0.8)
        tween(eyeDot, { BackgroundColor3 = Color3.fromRGB(120, 10, 10) }, 0.8)
        task.wait(0.8)
    end
end)

make("TextLabel", {
    Size = UDim2.new(0, 180, 1, 0),
    Position = UDim2.new(0, 32, 0, 0),
    BackgroundTransparency = 1,
    Text = "DEMONSER HUB  v2",
    TextColor3 = Color3.fromRGB(220, 40, 40),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)
make("TextLabel", {
    Size = UDim2.new(0, 80, 1, 0),
    Position = UDim2.new(1, -88, 0, 0),
    BackgroundTransparency = 1,
    Text = "RShift - HIDE",
    TextColor3 = Color3.fromRGB(80, 30, 30),
    TextSize = 9,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Right,
}, titleBar)

local tabFrame = make("Frame", {
    Size = UDim2.new(1, -24, 0, 32),
    Position = UDim2.new(0, 12, 0, 58),
    BackgroundTransparency = 1,
}, win)
make("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    Padding = UDim.new(0, 6),
}, tabFrame)

local tabNames = { "DAEMON", "NPC LOG", "POSITION" }
local tabs = {}
local tabContents = {}

local activeTabColor = Color3.fromRGB(160, 20, 20)
local inactiveTabColor = Color3.fromRGB(24, 8, 8)

for i, name in ipairs(tabNames) do
    local btn = make("TextButton", {
        Size = UDim2.new(0, 94, 1, 0),
        BackgroundColor3 = i == 1 and activeTabColor or inactiveTabColor,
        BorderSizePixel = 0,
        Text = name,
        TextColor3 = i == 1 and Color3.fromRGB(255, 200, 200) or Color3.fromRGB(100, 40, 40),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
    }, tabFrame)
    corner(6, btn)
    tabs[i] = btn
end

for i = 1, 3 do
    local content = make("Frame", {
        Size = UDim2.new(1, -24, 0, 370),
        Position = UDim2.new(0, 12, 0, 98),
        BackgroundTransparency = 1,
        Visible = i == 1,
    }, win)
    tabContents[i] = content
end

local function switchTab(idx)
    for i, btn in ipairs(tabs) do
        local active = i == idx
        tween(btn, {
            BackgroundColor3 = active and activeTabColor or inactiveTabColor,
            TextColor3 = active and Color3.fromRGB(255, 200, 200) or Color3.fromRGB(100, 40, 40),
        })
        tabContents[i].Visible = active
    end
end
for i, btn in ipairs(tabs) do
    btn.MouseButton1Click:Connect(function() switchTab(i) end)
end

-- ========================================
-- TAB 1: DAEMON (Anti-AFK)
-- ========================================
local t1 = tabContents[1]

local statusCard = make("Frame", {
    Size = UDim2.new(1, 0, 0, 50),
    BackgroundColor3 = Color3.fromRGB(16, 6, 6),
    BorderSizePixel = 0,
}, t1)
corner(10, statusCard)
make("UIStroke", { Color = Color3.fromRGB(80, 10, 10), Thickness = 1, Transparency = 0.4 }, statusCard)

local statusDot = make("Frame", {
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0, 14, 0.5, -4),
    BackgroundColor3 = Color3.fromRGB(60, 10, 10),
    BorderSizePixel = 0,
}, statusCard)
corner(999, statusDot)

local statusLabel = make("TextLabel", {
    Size = UDim2.new(1, -90, 1, 0),
    Position = UDim2.new(0, 30, 0, 0),
    BackgroundTransparency = 1,
    Text = "SLEEPING...",
    TextColor3 = Color3.fromRGB(100, 30, 30),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, statusCard)

local countLabel = make("TextLabel", {
    Size = UDim2.new(0, 70, 1, 0),
    Position = UDim2.new(1, -74, 0, 0),
    BackgroundTransparency = 1,
    Text = "0 SOUL",
    TextColor3 = Color3.fromRGB(80, 20, 20),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Right,
}, statusCard)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 58),
    BackgroundTransparency = 1,
    Text = "-- ACTIVITY LOG",
    TextColor3 = Color3.fromRGB(100, 20, 20),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, t1)

local afkLog = make("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 200),
    Position = UDim2.new(0, 0, 0, 78),
    BackgroundColor3 = Color3.fromRGB(12, 4, 4),
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(120, 20, 20),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, t1)
corner(8, afkLog)
make("UIStroke", { Color = Color3.fromRGB(70, 10, 10), Thickness = 1, Transparency = 0.5 }, afkLog)
make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingRight = UDim.new(0, 8) }, afkLog)
make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, afkLog)

local afkLogCount = 0
local function addAfkLog(msg)
    afkLogCount += 1
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "[" .. os.date("%H:%M:%S") .. "] " .. msg,
        TextColor3 = Color3.fromRGB(160, 50, 50),
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = afkLogCount,
    }, afkLog)
    task.wait()
    afkLog.CanvasPosition = Vector2.new(0, afkLog.AbsoluteCanvasSize.Y)
end

local toggleBtn = make("TextButton", {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 290),
    BackgroundColor3 = Color3.fromRGB(100, 10, 10),
    BorderSizePixel = 0,
    Text = "> AWAKEN DAEMON",
    TextColor3 = Color3.fromRGB(255, 200, 200),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
}, t1)
corner(10, toggleBtn)
make("UIStroke", { Color = Color3.fromRGB(200, 30, 30), Thickness = 1, Transparency = 0.5 }, toggleBtn)

local isActive = false
local soulCount = 0
local afkConnection

local function setActive(state)
    isActive = state
    if state then
        tween(statusDot, { BackgroundColor3 = Color3.fromRGB(220, 30, 30) })
        statusLabel.Text = "DAEMON AWAKE"
        tween(statusLabel, { TextColor3 = Color3.fromRGB(220, 60, 60) })
        tween(toggleBtn, { BackgroundColor3 = Color3.fromRGB(40, 8, 8) })
        toggleBtn.Text = "[] PUT DAEMON TO SLEEP"
        addAfkLog("Daemon awakened.")

        task.spawn(function()
            while isActive do
                tween(statusDot, { BackgroundColor3 = Color3.fromRGB(255, 60, 60) }, 0.5)
                task.wait(0.5)
                if not isActive then break end
                tween(statusDot, { BackgroundColor3 = Color3.fromRGB(100, 10, 10) }, 0.5)
                task.wait(0.5)
            end
        end)

        afkConnection = localPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(0.5)
            VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            soulCount += 1
            countLabel.Text = soulCount .. " SOUL"
            addAfkLog("Soul consumed. (" .. soulCount .. " total)")
        end)
    else
        tween(statusDot, { BackgroundColor3 = Color3.fromRGB(60, 10, 10) })
        statusLabel.Text = "SLEEPING..."
        tween(statusLabel, { TextColor3 = Color3.fromRGB(100, 30, 30) })
        tween(toggleBtn, { BackgroundColor3 = Color3.fromRGB(100, 10, 10) })
        toggleBtn.Text = "> AWAKEN DAEMON"
        addAfkLog("Daemon returned to darkness.")
        if afkConnection then afkConnection:Disconnect() afkConnection = nil end
    end
end

toggleBtn.MouseButton1Click:Connect(function() setActive(not isActive) end)
toggleBtn.MouseEnter:Connect(function()
    tween(toggleBtn, { BackgroundColor3 = isActive and Color3.fromRGB(60,10,10) or Color3.fromRGB(130,15,15) })
end)
toggleBtn.MouseLeave:Connect(function()
    tween(toggleBtn, { BackgroundColor3 = isActive and Color3.fromRGB(40,8,8) or Color3.fromRGB(100,10,10) })
end)

-- ========================================
-- TAB 2: NPC LOGGER
-- ========================================
local t2 = tabContents[2]

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "-- NPC DETECTOR  (range: 15 studs)",
    TextColor3 = Color3.fromRGB(100, 20, 20),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, t2)

local npcLog = make("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 240),
    Position = UDim2.new(0, 0, 0, 24),
    BackgroundColor3 = Color3.fromRGB(12, 4, 4),
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(120, 20, 20),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, t2)
corner(8, npcLog)
make("UIStroke", { Color = Color3.fromRGB(70, 10, 10), Thickness = 1, Transparency = 0.5 }, npcLog)
make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingRight = UDim.new(0, 8) }, npcLog)
make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, npcLog)

local npcLogCount = 0
local function addNpcLog(msg, color)
    npcLogCount += 1
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = color or Color3.fromRGB(160, 50, 50),
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = npcLogCount,
        TextWrapped = true,
    }, npcLog)
    task.wait()
    npcLog.CanvasPosition = Vector2.new(0, npcLog.AbsoluteCanvasSize.Y)
end

local scanBtn = make("TextButton", {
    Size = UDim2.new(1, 0, 0, 36),
    Position = UDim2.new(0, 0, 0, 272),
    BackgroundColor3 = Color3.fromRGB(100, 10, 10),
    BorderSizePixel = 0,
    Text = "SCAN NEARBY NPCs",
    TextColor3 = Color3.fromRGB(255, 200, 200),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
}, t2)
corner(10, scanBtn)

local autoTalkBtn = make("TextButton", {
    Size = UDim2.new(1, 0, 0, 36),
    Position = UDim2.new(0, 0, 0, 314),
    BackgroundColor3 = Color3.fromRGB(60, 8, 8),
    BorderSizePixel = 0,
    Text = "AUTO TALK (nearest NPC)",
    TextColor3 = Color3.fromRGB(200, 160, 160),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
}, t2)
corner(10, autoTalkBtn)
make("UIStroke", { Color = Color3.fromRGB(140, 20, 20), Thickness = 1, Transparency = 0.5 }, autoTalkBtn)

local function isNPC(model)
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    return true
end

local function getPlayerRoot()
    local char = localPlayer.Character
    if char then return char:FindFirstChild("HumanoidRootPart") end
    return nil
end

local function getNearbyNPCs(range)
    local root = getPlayerRoot()
    if not root then return {} end
    local found = {}
    for _, model in ipairs(workspace:GetDescendants()) do
        if model:IsA("Model") and isNPC(model) then
            local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist <= range then
                    table.insert(found, { name = model.Name, dist = math.floor(dist), model = model })
                end
            end
        end
    end
    table.sort(found, function(a, b) return a.dist < b.dist end)
    return found
end

scanBtn.MouseButton1Click:Connect(function()
    addNpcLog("-- SCANNING... --", Color3.fromRGB(180, 60, 60))
    local npcs = getNearbyNPCs(15)
    if #npcs == 0 then
        addNpcLog("  No NPCs found within 15 studs.", Color3.fromRGB(100, 40, 40))
    else
        for _, data in ipairs(npcs) do
            addNpcLog(string.format("  [NPC] %-20s | %.0f studs", data.name, data.dist), Color3.fromRGB(200, 80, 80))
        end
    end
    addNpcLog("-- DONE (" .. #npcs .. " found) --", Color3.fromRGB(180, 60, 60))
end)

autoTalkBtn.MouseButton1Click:Connect(function()
    local npcs = getNearbyNPCs(15)
    if #npcs == 0 then
        addNpcLog("[AUTO] No NPC nearby to talk to.", Color3.fromRGB(100, 40, 40))
        return
    end
    local nearest = npcs[1]
    addNpcLog("[AUTO] Talking to: " .. nearest.name, Color3.fromRGB(220, 100, 100))

    local prompt = nearest.model:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        fireproximityprompt(prompt)
        addNpcLog("[AUTO] Fired ProximityPrompt on " .. nearest.name, Color3.fromRGB(220, 120, 120))
        return
    end

    local click = nearest.model:FindFirstChildWhichIsA("ClickDetector", true)
    if click then
        fireclickdetector(click)
        addNpcLog("[AUTO] Fired ClickDetector on " .. nearest.name, Color3.fromRGB(220, 120, 120))
        return
    end

    addNpcLog("[AUTO] No interact found on " .. nearest.name, Color3.fromRGB(120, 40, 40))
end)

-- ========================================
-- TAB 3: POSITION
-- ========================================
local t3 = tabContents[3]

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "-- POSITION TOOLS",
    TextColor3 = Color3.fromRGB(100, 20, 20),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, t3)

local posCard = make("Frame", {
    Size = UDim2.new(1, 0, 0, 70),
    Position = UDim2.new(0, 0, 0, 24),
    BackgroundColor3 = Color3.fromRGB(16, 6, 6),
    BorderSizePixel = 0,
}, t3)
corner(10, posCard)
make("UIStroke", { Color = Color3.fromRGB(80, 10, 10), Thickness = 1, Transparency = 0.4 }, posCard)

local xLabel = make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 8),
    BackgroundTransparency = 1,
    Text = "X :  0.000",
    TextColor3 = Color3.fromRGB(220, 60, 60),
    TextSize = 13,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
}, posCard)
local yLabel = make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 26),
    BackgroundTransparency = 1,
    Text = "Y :  0.000",
    TextColor3 = Color3.fromRGB(180, 50, 50),
    TextSize = 13,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
}, posCard)
local zLabel = make("TextLabel", {
    Size = UDim2.new(1, -20, 0, 18),
    Position = UDim2.new(0, 10, 0, 44),
    BackgroundTransparency = 1,
    Text = "Z :  0.000",
    TextColor3 = Color3.fromRGB(140, 40, 40),
    TextSize = 13,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
}, posCard)

RunService.Heartbeat:Connect(function()
    local char = localPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = hrp.Position
            xLabel.Text = string.format("X :  %.3f", p.X)
            yLabel.Text = string.format("Y :  %.3f", p.Y)
            zLabel.Text = string.format("Z :  %.3f", p.Z)
        end
    end
end)

local copyBtn = make("TextButton", {
    Size = UDim2.new(1, 0, 0, 36),
    Position = UDim2.new(0, 0, 0, 102),
    BackgroundColor3 = Color3.fromRGB(100, 10, 10),
    BorderSizePixel = 0,
    Text = "COPY POSITION",
    TextColor3 = Color3.fromRGB(255, 200, 200),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
}, t3)
corner(10, copyBtn)

make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0, 146),
    BackgroundTransparency = 1,
    Text = "-- SAVED POSITIONS",
    TextColor3 = Color3.fromRGB(100, 20, 20),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, t3)

local posLog = make("ScrollingFrame", {
    Size = UDim2.new(1, 0, 0, 170),
    Position = UDim2.new(0, 0, 0, 166),
    BackgroundColor3 = Color3.fromRGB(12, 4, 4),
    BorderSizePixel = 0,
    ScrollBarThickness = 2,
    ScrollBarImageColor3 = Color3.fromRGB(120, 20, 20),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, t3)
corner(8, posLog)
make("UIStroke", { Color = Color3.fromRGB(70, 10, 10), Thickness = 1, Transparency = 0.5 }, posLog)
make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 6), PaddingRight = UDim.new(0, 8) }, posLog)
make("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }, posLog)

local posLogCount = 0
local savedPositions = {}

local function addPosLog(msg, color)
    posLogCount += 1
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = msg,
        TextColor3 = color or Color3.fromRGB(160, 50, 50),
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = posLogCount,
    }, posLog)
    task.wait()
    posLog.CanvasPosition = Vector2.new(0, posLog.AbsoluteCanvasSize.Y)
end

copyBtn.MouseButton1Click:Connect(function()
    local char = localPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local p = hrp.Position
    local str = string.format("Vector3.new(%.3f, %.3f, %.3f)", p.X, p.Y, p.Z)
    table.insert(savedPositions, str)
    setclipboard(str)
    tween(copyBtn, { BackgroundColor3 = Color3.fromRGB(60, 120, 40) })
    copyBtn.Text = "COPIED!"
    task.wait(0.8)
    tween(copyBtn, { BackgroundColor3 = Color3.fromRGB(100, 10, 10) })
    copyBtn.Text = "COPY POSITION"
    addPosLog(string.format("[#%d] %s", #savedPositions, str), Color3.fromRGB(200, 80, 80))
end)

-- ===== RightShift TOGGLE =====
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        win.Visible = not win.Visible
    end
end)

-- ===== DRAG =====
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = win.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- ===== INIT =====
addAfkLog("Demonser Hub v2 loaded.")
addAfkLog("3 modules ready.")
addNpcLog("Ready. Press SCAN to detect NPCs.", Color3.fromRGB(120, 40, 40))
addPosLog("Ready. Press COPY to save position.", Color3.fromRGB(120, 40, 40))
print("Demonser Hub v2 | RightShift = toggle")
