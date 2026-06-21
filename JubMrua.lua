local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== DEFAULTS =====
local WEBHOOK = "https://discord.com/api/webhooks/1437790888729382953/_PPWpXUN_f2XrMuqB-ubLaWBpD86YSuB5LzcyOpGKs752vTEWN8c6GmYlqMXbCJ2qCPa"
local GUI_TOGGLE_KEY = Enum.KeyCode.K

local stats = { 
    spawnsDetected = 0, 
    alertsSent = 0, 
    soulsConsumed = 0 
}

-- ESP Drawing
local espDrawings = {}

-- ===== HELPER FUNCTIONS =====
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
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

local function httpPost(url, body)
    if syn and syn.request then
        pcall(function() syn.request({ Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body }) end)
    elseif http and http.request then
        pcall(function() http.request({ Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body }) end)
    elseif request then
        pcall(function() request({ Url=url, Method="POST", Headers={["Content-Type"]="application/json"}, Body=body }) end)
    end
end

-- ===== GUI ROOT =====
local screenGui = make("ScreenGui", {
    Name = "LopperHubPro",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)

-- ===== MAIN WINDOW =====
local win = make("Frame", {
    Size = UDim2.new(0, 400, 0, 900),
    Position = UDim2.new(0.5, -200, 0.5, -450),
    BackgroundColor3 = Color3.fromRGB(12, 12, 18),
    BorderSizePixel = 0,
    ClipsDescendants = true,
}, screenGui)
corner(16, win)
make("UIStroke", { Color=Color3.fromRGB(55, 75, 140), Thickness=1.2, Transparency=0.4 }, win)

-- ===== TITLE BAR =====
local titleBar = make("Frame", {
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BorderSizePixel = 0,
}, win)
corner(16, titleBar)
make("Frame", {
    Size = UDim2.new(1, 0, 0, 16),
    Position = UDim2.new(0, 0, 1, -16),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BorderSizePixel = 0,
}, titleBar)
make("Frame", {
    Size = UDim2.new(1, 0, 0, 2),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = Color3.fromRGB(60, 100, 220),
    BorderSizePixel = 0,
}, titleBar)

local dot = make("Frame", {
    Size = UDim2.new(0, 10, 0, 10),
    Position = UDim2.new(0, 18, 0.5, -5),
    BackgroundColor3 = Color3.fromRGB(80, 220, 120),
    BorderSizePixel = 0,
}, titleBar)
corner(999, dot)

make("TextLabel", {
    Size = UDim2.new(0.7, 0, 1, 0),
    Position = UDim2.new(0, 38, 0, 0),
    BackgroundTransparency = 1,
    Text = "LOPPER HUB PRO",
    TextColor3 = Color3.fromRGB(220, 225, 255),
    TextSize = 15,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, titleBar)

local keyDisplayLabel = make("TextLabel", {
    Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(1, -110, 0, 0),
    BackgroundTransparency = 1,
    Text = "K · HIDE",
    TextColor3 = Color3.fromRGB(70, 80, 115),
    TextSize = 11,
    Font = Enum.Font.GothamMedium,
    TextXAlignment = Enum.TextXAlignment.Right,
}, titleBar)

-- ===== CONTENT =====
local content = make("ScrollingFrame", {
    Size = UDim2.new(1, 0, 1, -56),
    Position = UDim2.new(0, 0, 0, 56),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ScrollBarThickness = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, win)
make("UIListLayout", { Padding=UDim.new(0, 8), SortOrder=Enum.SortOrder.LayoutOrder }, content)
make("UIPadding", {
    PaddingLeft=UDim.new(0,14), PaddingRight=UDim.new(0,14),
    PaddingTop=UDim.new(0,14), PaddingBottom=UDim.new(0,14),
}, content)

-- ===== STATS ROW =====
local statsRow = make("Frame", {
    Size = UDim2.new(1, 0, 0, 64),
    BackgroundColor3 = Color3.fromRGB(20, 20, 32),
    BorderSizePixel = 0,
    LayoutOrder = 0,
}, content)
corner(10, statsRow)
make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder }, statsRow)

local function statBox(label, order)
    local box = make("Frame", {
        Size = UDim2.new(0.333, 0, 1, 0),
        BackgroundTransparency = 1,
        LayoutOrder = order,
    }, statsRow)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0.45, 0),
        Position = UDim2.new(0, 0, 0.1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Color3.fromRGB(75, 85, 115),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, box)
    local val = make("TextLabel", {
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Text = "0",
        TextColor3 = Color3.fromRGB(195, 205, 255),
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, box)
    return val
end

local spawnVal  = statBox("SPAWNS", 1)
local alertVal  = statBox("ALERTS", 2)
local soulVal = statBox("SOULS", 3)
make("Frame", { Size=UDim2.new(0,1,0.5,0), Position=UDim2.new(0.333,0,0.25,0), BackgroundColor3=Color3.fromRGB(35,35,55), BorderSizePixel=0 }, statsRow)
make("Frame", { Size=UDim2.new(0,1,0.5,0), Position=UDim2.new(0.666,0,0.25,0), BackgroundColor3=Color3.fromRGB(35,35,55), BorderSizePixel=0 }, statsRow)

-- ===== SECTION LABELS =====
local function sectionLabel(text, order)
    make("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(55, 65, 95),
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = order,
    }, content)
end

-- ===== KEY BINDING CONFIG =====
sectionLabel("KEY SETTINGS", 1)

local keyConfigBg = make("Frame", {
    Size = UDim2.new(1, 0, 0, 56),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BorderSizePixel = 0,
    LayoutOrder = 2,
}, content)
corner(10, keyConfigBg)
make("UIStroke", { Color=Color3.fromRGB(50, 75, 150), Thickness=1, Transparency=0.5 }, keyConfigBg)

make("TextLabel", {
    Size = UDim2.new(0.5, 0, 0.5, 0),
    Position = UDim2.new(0, 14, 0, 8),
    BackgroundTransparency = 1,
    Text = "GUI Toggle Key",
    TextColor3 = Color3.fromRGB(100, 130, 200),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, keyConfigBg)

local keyDisplayBtn = make("TextButton", {
    Size = UDim2.new(0.45, 0, 0, 28),
    Position = UDim2.new(1, -100, 0, 10),
    BackgroundColor3 = Color3.fromRGB(30, 30, 50),
    BorderSizePixel = 0,
    Text = "K",
    TextColor3 = Color3.fromRGB(150, 200, 255),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
}, keyConfigBg)
corner(6, keyDisplayBtn)
make("UIStroke", { Color=Color3.fromRGB(60, 100, 180), Thickness=1, Transparency=0.4 }, keyDisplayBtn)

local isListeningForKey = false
keyDisplayBtn.MouseButton1Click:Connect(function()
    isListeningForKey = not isListeningForKey
    if isListeningForKey then
        keyDisplayBtn.Text = "..."
        tween(keyDisplayBtn, { BackgroundColor3 = Color3.fromRGB(50, 50, 80) })
    else
        tween(keyDisplayBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 50) })
    end
end)

local function updateKeyDisplay()
    local keyName = tostring(GUI_TOGGLE_KEY):gsub("Enum.KeyCode.", "")
    keyDisplayBtn.Text = keyName
    keyDisplayLabel.Text = keyName .. " · HIDE"
end

-- ===== WEBHOOK CONFIG =====
sectionLabel("WEBHOOK SETTINGS", 3)

local webhookInputBg = make("Frame", {
    Size = UDim2.new(1, 0, 0, 100),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BorderSizePixel = 0,
    LayoutOrder = 4,
}, content)
corner(10, webhookInputBg)
make("UIStroke", { Color=Color3.fromRGB(50, 75, 150), Thickness=1, Transparency=0.5 }, webhookInputBg)

make("TextLabel", {
    Size = UDim2.new(1, -14, 0, 18),
    Position = UDim2.new(0, 7, 0, 7),
    BackgroundTransparency = 1,
    Text = "Webhook URL",
    TextColor3 = Color3.fromRGB(100, 130, 200),
    TextSize = 10,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, webhookInputBg)

local webhookTextBox = make("TextBox", {
    Size = UDim2.new(1, -14, 0, 28),
    Position = UDim2.new(0, 7, 0, 28),
    BackgroundColor3 = Color3.fromRGB(15, 15, 25),
    BorderSizePixel = 0,
    Text = "",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    PlaceholderColor3 = Color3.fromRGB(50, 60, 100),
    TextColor3 = Color3.fromRGB(200, 210, 255),
    TextSize = 10,
    Font = Enum.Font.GothamMedium,
    TextWrapped = true,
}, webhookInputBg)
corner(6, webhookTextBox)

local webhookApplyBtn = make("TextButton", {
    Size = UDim2.new(0.48, 0, 0, 24),
    Position = UDim2.new(0, 7, 0, 62),
    BackgroundColor3 = Color3.fromRGB(50, 100, 220),
    BorderSizePixel = 0,
    Text = "UPDATE",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
}, webhookInputBg)
corner(6, webhookApplyBtn)

local webhookTestBtn = make("TextButton", {
    Size = UDim2.new(0.48, 0, 0, 24),
    Position = UDim2.new(0.52, 0, 0, 62),
    BackgroundColor3 = Color3.fromRGB(80, 140, 255),
    BorderSizePixel = 0,
    Text = "TEST",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
}, webhookInputBg)
corner(6, webhookTestBtn)

webhookApplyBtn.MouseButton1Click:Connect(function()
    if webhookTextBox.Text ~= "" then
        WEBHOOK = webhookTextBox.Text
        tween(webhookApplyBtn, { BackgroundColor3 = Color3.fromRGB(50, 200, 100) })
        task.wait(0.4)
        tween(webhookApplyBtn, { BackgroundColor3 = Color3.fromRGB(50, 100, 220) })
    end
end)

webhookTestBtn.MouseButton1Click:Connect(function()
    tween(webhookTestBtn, { BackgroundColor3 = Color3.fromRGB(255, 200, 50) })
    task.spawn(function()
        httpPost(WEBHOOK, HttpService:JSONEncode({
            content = "🧪 **TEST — Webhook Working!**",
            embeds = {{
                title = "✅ Lopper Hub Pro — Test Success",
                description = "Webhook connection verified.",
                color = 3066993,
                fields = {
                    { name="Player", value=player.Name, inline=true },
                    { name="Time", value=os.date("%H:%M:%S"), inline=true }
                }
            }}
        }))
        task.wait(1)
        tween(webhookTestBtn, { BackgroundColor3 = Color3.fromRGB(80, 140, 255) })
    end)
end)

webhookApplyBtn.MouseEnter:Connect(function() tween(webhookApplyBtn, { BackgroundColor3 = Color3.fromRGB(70, 120, 240) }) end)
webhookApplyBtn.MouseLeave:Connect(function() tween(webhookApplyBtn, { BackgroundColor3 = Color3.fromRGB(50, 100, 220) }) end)
webhookTestBtn.MouseEnter:Connect(function() tween(webhookTestBtn, { BackgroundColor3 = Color3.fromRGB(100, 160, 255) }) end)
webhookTestBtn.MouseLeave:Connect(function() tween(webhookTestBtn, { BackgroundColor3 = Color3.fromRGB(80, 140, 255) }) end)

-- ===== TOGGLES =====
local toggleStates = {}
local function createToggle(label, sublabel, defaultOn, order)
    local row = make("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Color3.fromRGB(18, 18, 28),
        BorderSizePixel = 0,
        LayoutOrder = order,
    }, content)
    corner(10, row)
    make("TextLabel", {
        Size = UDim2.new(0.65, 0, 0.5, 0),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Color3.fromRGB(210, 215, 235),
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    make("TextLabel", {
        Size = UDim2.new(0.65, 0, 0.4, 0),
        Position = UDim2.new(0, 14, 0.55, 0),
        BackgroundTransparency = 1,
        Text = sublabel,
        TextColor3 = Color3.fromRGB(65, 75, 105),
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
    local stateLabel = make("TextLabel", {
        Size = UDim2.new(0, 28, 0, 16),
        Position = UDim2.new(1, -102, 0.5, -8),
        BackgroundTransparency = 1,
        Text = defaultOn and "ON" or "OFF",
        TextColor3 = defaultOn and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 110),
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, row)
    local pillBg = make("Frame", {
        Size = UDim2.new(0, 46, 0, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BackgroundColor3 = defaultOn and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(38, 38, 58),
        BorderSizePixel = 0,
    }, row)
    corner(999, pillBg)
    local knob = make("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = defaultOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
    }, pillBg)
    corner(999, knob)
    local isOn = defaultOn
    toggleStates[label] = isOn
    local btn = make("TextButton", { Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="" }, row)
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn
        toggleStates[label] = isOn
        tween(pillBg, { BackgroundColor3 = isOn and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(38, 38, 58) })
        tween(knob, { Position = isOn and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9) })
        stateLabel.Text = isOn and "ON" or "OFF"
        stateLabel.TextColor3 = isOn and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 110)
    end)
    btn.MouseEnter:Connect(function() tween(row, { BackgroundColor3=Color3.fromRGB(22,22,36) }) end)
    btn.MouseLeave:Connect(function() tween(row, { BackgroundColor3=Color3.fromRGB(18,18,28) }) end)
    return function() return toggleStates[label] end
end

sectionLabel("SPAWN DETECTION", 5)
local getSpawnDetection = createToggle("Spawn Detection", "Scan for spawn text", false, 6)
local getDiscordAlerts  = createToggle("Discord Alerts",  "Send webhook on spawn", true,  7)
local getSoundAlert     = createToggle("Sound Alert",     "Play sound on detect",  true,  8)

sectionLabel("ANTI-AFK GUARDIAN", 9)
local getAntiAfk = createToggle("Anti-AFK Guardian", "Auto-respond when idle", false, 10)

-- ===== ANTI-AFK STATUS =====
local statusCard = make("Frame", {
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = Color3.fromRGB(16, 16, 28),
    BorderSizePixel = 0,
    LayoutOrder = 11,
}, content)
corner(10, statusCard)
make("UIStroke", { Color = Color3.fromRGB(80, 80, 120), Thickness = 1, Transparency = 0.4 }, statusCard)

local statusDot = make("Frame", {
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0, 14, 0.5, -4),
    BackgroundColor3 = Color3.fromRGB(80, 80, 120),
    BorderSizePixel = 0,
}, statusCard)
corner(999, statusDot)

local statusLabel = make("TextLabel", {
    Size = UDim2.new(0.7, 0, 1, 0),
    Position = UDim2.new(0, 30, 0, 0),
    BackgroundTransparency = 1,
    Text = "GUARDIAN SLEEPING",
    TextColor3 = Color3.fromRGB(100, 100, 150),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, statusCard)

-- ===== FPS CAP SECTION =====
sectionLabel("PERFORMANCE", 12)

local fpsRow = make("Frame", {
    Size = UDim2.new(1, 0, 0, 80),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28),
    BorderSizePixel = 0,
    LayoutOrder = 13,
}, content)
corner(10, fpsRow)
make("UIStroke", { Color=Color3.fromRGB(80, 140, 255), Thickness=1, Transparency=0.65 }, fpsRow)

local fpsCurrentLabel = make("TextLabel", {
    Size = UDim2.new(1, -14, 0, 22),
    Position = UDim2.new(0, 14, 0, 8),
    BackgroundTransparency = 1,
    Text = "FPS Cap: 60",
    TextColor3 = Color3.fromRGB(80, 160, 255),
    TextSize = 13,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, fpsRow)

local fpsInputBg = make("Frame", {
    Size = UDim2.new(1, -14, 0, 34),
    Position = UDim2.new(0, 7, 0, 36),
    BackgroundColor3 = Color3.fromRGB(20, 20, 32),
    BorderSizePixel = 0,
}, fpsRow)
corner(8, fpsInputBg)
make("UIStroke", { Color=Color3.fromRGB(50, 60, 100), Thickness=1, Transparency=0.5 }, fpsInputBg)

make("TextLabel", {
    Size = UDim2.new(0, 36, 1, 0),
    Position = UDim2.new(0, 10, 0, 0),
    BackgroundTransparency = 1,
    Text = "FPS",
    TextColor3 = Color3.fromRGB(60, 70, 110),
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
}, fpsInputBg)

local fpsTextBox = make("TextBox", {
    Size = UDim2.new(1, -110, 1, 0),
    Position = UDim2.new(0, 44, 0, 0),
    BackgroundTransparency = 1,
    Text = "",
    PlaceholderText = "Enter number...",
    PlaceholderColor3 = Color3.fromRGB(50, 58, 90),
    TextColor3 = Color3.fromRGB(200, 210, 255),
    TextSize = 14,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = true,
}, fpsInputBg)

local fpsOkBtn = make("TextButton", {
    Size = UDim2.new(0, 56, 1, -8),
    Position = UDim2.new(1, -62, 0, 4),
    BackgroundColor3 = Color3.fromRGB(50, 100, 220),
    BorderSizePixel = 0,
    Text = "SET",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.GothamBold,
}, fpsInputBg)
corner(6, fpsOkBtn)

local function applyFps()
    local val = tonumber(fpsTextBox.Text)
    if val and val >= 0 then
        local fps = math.floor(val)
        if setfpscap then
            setfpscap(fps)
        end
        fpsCurrentLabel.Text = fps == 0 and "FPS Cap: UNLIMITED" or ("FPS Cap: " .. fps)
        fpsCurrentLabel.TextColor3 = fps == 0 and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(80, 160, 255)
        fpsTextBox.Text = ""
        tween(fpsOkBtn, { BackgroundColor3 = Color3.fromRGB(50, 200, 100) })
        task.wait(0.4)
        tween(fpsOkBtn, { BackgroundColor3 = Color3.fromRGB(50, 100, 220) })
    else
        tween(fpsInputBg, { BackgroundColor3 = Color3.fromRGB(60, 15, 15) })
        task.wait(0.3)
        tween(fpsInputBg, { BackgroundColor3 = Color3.fromRGB(20, 20, 32) })
    end
end

fpsOkBtn.MouseButton1Click:Connect(applyFps)
fpsTextBox.FocusLost:Connect(function(enter) if enter then applyFps() end end)
fpsOkBtn.MouseEnter:Connect(function() tween(fpsOkBtn, { BackgroundColor3 = Color3.fromRGB(70, 120, 240) }) end)
fpsOkBtn.MouseLeave:Connect(function() tween(fpsOkBtn, { BackgroundColor3 = Color3.fromRGB(50, 100, 220) }) end)

if setfpscap then
    setfpscap(60)
end

-- ===== ESP SECTION =====
sectionLabel("ESP", 14)
local getESP = createToggle("ESP Display", "Show player names and HP", false, 15)

local function createESPDrawing(targetPlayer)
    if targetPlayer == player then return nil end
    
    local nameText = Drawing.new("Text")
    nameText.Text = targetPlayer.Name
    nameText.Size = 16
    nameText.Color = Color3.fromRGB(100, 200, 255)
    nameText.Center = true
    nameText.Outline = true
    nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    nameText.Visible = false
    
    local hpText = Drawing.new("Text")
    hpText.Text = "HP: 100"
    hpText.Size = 14
    hpText.Color = Color3.fromRGB(100, 255, 100)
    hpText.Center = true
    hpText.Outline = true
    hpText.OutlineColor = Color3.fromRGB(0, 0, 0)
    hpText.Visible = false
    
    return {
        name = nameText,
        hp = hpText,
        player = targetPlayer
    }
end

local espTexts = {}

local function updateESP()
    if not getESP() then
        for _, esp in pairs(espTexts) do
            esp.name:Remove()
            esp.hp:Remove()
        end
        espTexts = {}
        return
    end
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            if not espTexts[targetPlayer.Name] then
                espTexts[targetPlayer.Name] = createESPDrawing(targetPlayer)
            end
            
            local esp = espTexts[targetPlayer.Name]
            if esp and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") and targetPlayer.Character:FindFirstChild("Humanoid") then
                local rootPart = targetPlayer.Character.HumanoidRootPart
                local humanoid = targetPlayer.Character.Humanoid
                local screenPos = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
                
                esp.name.Position = Vector2.new(screenPos.X, screenPos.Y - 15)
                esp.hp.Position = Vector2.new(screenPos.X, screenPos.Y + 5)
                
                local distance = (rootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                local hpPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                
                esp.name.Text = targetPlayer.Name .. " [" .. math.floor(distance) .. "m]"
                esp.hp.Text = "HP: " .. hpPercent .. "%"
                
                -- Color based on HP
                if hpPercent > 50 then
                    esp.hp.Color = Color3.fromRGB(100, 255, 100)
                elseif hpPercent > 25 then
                    esp.hp.Color = Color3.fromRGB(255, 255, 100)
                else
                    esp.hp.Color = Color3.fromRGB(255, 100, 100)
                end
                
                esp.name.Visible = screenPos.Z > 0
                esp.hp.Visible = screenPos.Z > 0
            end
        end
    end
    
    for name, esp in pairs(espTexts) do
        if not Players:FindFirstChild(name) then
            esp.name:Remove()
            esp.hp:Remove()
            espTexts[name] = nil
        end
    end
end

-- ===== SPAWN LOGIC =====
local function scanForSpawn()
    for _, gui in ipairs(player:GetDescendants()) do  
        if (gui:IsA("TextLabel") or gui:IsA("TextButton"))
            and gui.Text and string.find(gui.Text, "IT APPEARS ONCE AGAIN") then
            return true
        end
    end
    return false
end

local function sendDiscordAlert()
    task.spawn(function()
        httpPost(WEBHOOK, HttpService:JSONEncode({
            content = "🎯 **SPAWN DETECTED!**",
            embeds = {{
                title = "✨ IT APPEARS ONCE AGAIN!",
                description = "ของมาละไอสัส",
                color = 16776960,
                fields = {
                    { name="Player", value=player.Name, inline=true },
                    { name="Time", value=os.date("%H:%M:%S"), inline=true }
                }
            }}
        }))
    end)
end

local function playSound()
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = "rbxassetid://12221967"
        s.Volume = 1
        s.Parent = workspace
        s:Play()
        game:GetService("Debris"):AddItem(s, 3)
    end)
end

-- ===== ANTI-AFK LOGIC =====
local isAntiAFKActive = false
local antiAFKConnection = nil

local function setAntiAFKStatus(state)
    isAntiAFKActive = state
    if state then
        tween(statusDot, { BackgroundColor3 = Color3.fromRGB(220, 120, 50) })
        tween(statusLabel, { TextColor3 = Color3.fromRGB(220, 150, 80) })
        statusLabel.Text = "GUARDIAN ACTIVE"

        task.spawn(function()
            while isAntiAFKActive do
                tween(statusDot, { BackgroundColor3 = Color3.fromRGB(255, 150, 80) }, 0.5)
                task.wait(0.5)
                if not isAntiAFKActive then break end
                tween(statusDot, { BackgroundColor3 = Color3.fromRGB(200, 100, 30) }, 0.5)
                task.wait(0.5)
            end
        end)

        if antiAFKConnection then antiAFKConnection:Disconnect() end
        antiAFKConnection = player.Idled:Connect(function()
            if isAntiAFKActive then
                VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(0.5)
                VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                stats.soulsConsumed += 1
                soulVal.Text = tostring(stats.soulsConsumed)
            end
        end)
    else
        tween(statusDot, { BackgroundColor3 = Color3.fromRGB(80, 80, 120) })
        tween(statusLabel, { TextColor3 = Color3.fromRGB(100, 100, 150) })
        statusLabel.Text = "GUARDIAN SLEEPING"
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
    end
end

-- ===== MAIN LOOP =====
local wasDetected = false
local lastAlert   = 0
local startTime   = tick()
local lastScan    = 0
local lastESPUpdate = 0

RunService.Heartbeat:Connect(function()
    local now = tick()

    -- Update anti-AFK state from toggle
    local antiAFKToggleState = getAntiAfk()
    if antiAFKToggleState ~= isAntiAFKActive then
        setAntiAFKStatus(antiAFKToggleState)
    end

    -- Update ESP every 0.1 seconds
    if (now - lastESPUpdate) >= 0.1 then
        updateESP()
        lastESPUpdate = now
    end

    -- Scan for spawns every 0.5 seconds
    if (now - lastScan) < 0.5 then return end
    lastScan = now

    if getSpawnDetection() and scanForSpawn() and not wasDetected then
        if (now - lastAlert) >= 3 then
            stats.spawnsDetected += 1
            spawnVal.Text = tostring(stats.spawnsDetected)
            if getSoundAlert() then playSound() end
            if getDiscordAlerts() then
                sendDiscordAlert()
                stats.alertsSent += 1
                alertVal.Text = tostring(stats.alertsSent)
            end
            wasDetected = true
            lastAlert = now
        end
    elseif not scanForSpawn() then
        wasDetected = false
    end
end)

-- ===== KEY BINDINGS =====
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if isListeningForKey then
        GUI_TOGGLE_KEY = input.KeyCode
        isListeningForKey = false
        updateKeyDisplay()
        tween(keyDisplayBtn, { BackgroundColor3 = Color3.fromRGB(30, 30, 50) })
    elseif input.KeyCode == GUI_TOGGLE_KEY then
        win.Visible = not win.Visible
    end
end)

-- ===== DRAG FUNCTIONALITY =====
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
        win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

print("✅ Lopper Hub Pro v2 — Spawn + Anti-AFK Guardian + FPS + ESP + Key Binding")
