-- Lopper Hub | VV: ULTIMATUM | Enhanced Edition
-- Cerberus-Style GUI | Sidebar Layout | B&W Theme
-- RightShift = ซ่อน/แสดง

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")

local lp = Players.LocalPlayer

-- GUARD
local ex = lp:WaitForChild("PlayerGui"):FindFirstChild("LopperHub")
if ex then ex:Destroy() task.wait(0.1) end

-- REMOTES
local Requests   = game.ReplicatedStorage:WaitForChild("Requests")
local Combat     = Requests:WaitForChild("Combat")
local UseSkill   = Requests:WaitForChild("UseSkill")
local UseAbility = Requests:WaitForChild("UseAbility")
local TakeQuest  = Requests:WaitForChild("TakeQuest")
local GetMissions= Requests:WaitForChild("GetMissions")
local ReqMission = Requests:WaitForChild("RequestMission")

-- ============================================================
-- HELPERS
-- ============================================================
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k]=v end
    if parent then obj.Parent=parent end
    return obj
end
local function corner(r, p) make("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function stroke(color, thick, p) make("UIStroke",{Color=color,Thickness=thick},p) end
local function tw(o, props, t)
    TweenService:Create(o, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad), props):Play()
end
local function getRoot()
    return lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
end
local function getTime() return os.date("%H:%M:%S") end

local function holdWeapon()
    pcall(function()
        UserInputService:SendKeyEvent(true,  Enum.KeyCode.X, false)
        task.wait(0.05)
        UserInputService:SendKeyEvent(false, Enum.KeyCode.X, false)
    end)
end

-- ============================================================
-- COLOR PALETTE (Monochrome)
-- ============================================================
local C = {
    BG         = Color3.fromRGB(8,   8,   8),
    SIDEBAR    = Color3.fromRGB(12,  12,  12),
    PANEL      = Color3.fromRGB(16,  16,  16),
    CARD       = Color3.fromRGB(20,  20,  20),
    BORDER     = Color3.fromRGB(32,  32,  32),
    BORDER2    = Color3.fromRGB(45,  45,  45),
    TEXT       = Color3.fromRGB(240, 240, 240),
    TEXT_DIM   = Color3.fromRGB(110, 110, 110),
    TEXT_MUTED = Color3.fromRGB(55,  55,  55),
    ACCENT     = Color3.fromRGB(255, 255, 255),
    ACTIVE_BG  = Color3.fromRGB(28,  28,  28),
    GREEN      = Color3.fromRGB(140, 220, 100),
    ORANGE     = Color3.fromRGB(220, 160, 60),
    BLUE       = Color3.fromRGB(120, 160, 240),
    RED        = Color3.fromRGB(220, 80,  80),
}

-- ============================================================
-- ROOT GUI
-- ============================================================
local screen = make("ScreenGui",{
    Name="LopperHub", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
}, lp:WaitForChild("PlayerGui"))

-- Main window  (sidebar 120 + content 320 = 440 wide)
local WIN_W, WIN_H = 480, 520
local win = make("Frame",{
    Size     = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = UDim2.new(0.5,-WIN_W/2, 0.5,-WIN_H/2),
    BackgroundColor3 = C.BG,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
}, screen)
corner(8, win)
stroke(C.BORDER, 1, win)

-- ============================================================
-- TOPBAR  (full width, 38px)
-- ============================================================
local topBar = make("Frame",{
    Size=UDim2.new(1,0,0,38),
    BackgroundColor3=C.SIDEBAR,
    BorderSizePixel=0,
}, win)
corner(8, topBar)
-- cover bottom corners
make("Frame",{Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),
    BackgroundColor3=C.SIDEBAR,BorderSizePixel=0},topBar)
stroke(C.BORDER, 1, topBar)

-- blinking dot
local topDot = make("Frame",{
    Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,14,0.5,-3),
    BackgroundColor3=C.ACCENT, BorderSizePixel=0,
}, topBar)
corner(999, topDot)
task.spawn(function()
    while true do
        tw(topDot,{BackgroundColor3=C.ACCENT},0.4)   task.wait(0.45)
        tw(topDot,{BackgroundColor3=C.TEXT_MUTED},0.4) task.wait(0.45)
    end
end)

make("TextLabel",{
    Size=UDim2.new(0,200,1,0), Position=UDim2.new(0,26,0,0),
    BackgroundTransparency=1,
    Text="LOPPER HUB", TextColor3=C.TEXT,
    TextSize=12, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left,
}, topBar)

make("TextLabel",{
    Size=UDim2.new(0,120,1,0), Position=UDim2.new(1,-124,0,0),
    BackgroundTransparency=1,
    Text="VV: ULTIMATUM  •  RSHIFT", TextColor3=C.TEXT_MUTED,
    TextSize=8, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Right,
}, topBar)

-- version badge
local vBadge = make("TextLabel",{
    Size=UDim2.new(0,56,0,16), Position=UDim2.new(1,-180,0.5,-8),
    BackgroundColor3=C.CARD, BorderSizePixel=0,
    Text="ENHANCED", TextColor3=C.TEXT_DIM,
    TextSize=7, Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Center,
}, topBar)
corner(3, vBadge)
stroke(C.BORDER2, 1, vBadge)

-- ============================================================
-- SIDEBAR  (left, 120px)
-- ============================================================
local SIDEBAR_W = 120
local sidebar = make("Frame",{
    Size     = UDim2.new(0, SIDEBAR_W, 1, -38),
    Position = UDim2.new(0, 0, 0, 38),
    BackgroundColor3 = C.SIDEBAR,
    BorderSizePixel  = 0,
}, win)
stroke(C.BORDER, 1, sidebar)

-- vertical divider line
make("Frame",{
    Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0),
    BackgroundColor3=C.BORDER, BorderSizePixel=0,
}, sidebar)

local sideList = make("Frame",{
    Size=UDim2.new(1,0,0,300), Position=UDim2.new(0,0,0,12),
    BackgroundTransparency=1,
}, sidebar)
make("UIListLayout",{
    Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder,
}, sideList)
make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)}, sideList)

-- sidebar footer
make("TextLabel",{
    Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,1,-28),
    BackgroundTransparency=1,
    Text="© LOPPER", TextColor3=C.TEXT_MUTED,
    TextSize=8, Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Center,
}, sidebar)

-- ============================================================
-- CONTENT AREA
-- ============================================================
local content = make("Frame",{
    Size     = UDim2.new(1,-SIDEBAR_W,1,-38),
    Position = UDim2.new(0,SIDEBAR_W,0,38),
    BackgroundColor3 = C.PANEL,
    BorderSizePixel  = 0,
    ClipsDescendants = true,
}, win)

-- ============================================================
-- TAB SYSTEM
-- ============================================================
local TAB_DEFS = {
    { name="FARM",  icon="⚔" },
    { name="BOSS",  icon="☠" },
    { name="QUEST", icon="◈" },
    { name="LOG",   icon="≡" },
}
local tabBtns, tabPages = {}, {}
local currentTab = 1

-- create pages
for i=1,#TAB_DEFS do
    local page = make("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Visible=(i==1),
    }, content)
    tabPages[i] = page
end

local function switchTab(idx)
    for i, btn in ipairs(tabBtns) do
        local active = (i == idx)
        -- sidebar button
        tw(btn, {
            BackgroundColor3 = active and C.ACTIVE_BG or C.SIDEBAR,
            TextColor3       = active and C.ACCENT     or C.TEXT_DIM,
        })
        tabPages[i].Visible = active
    end
    currentTab = idx
end

-- build sidebar buttons
for i, def in ipairs(TAB_DEFS) do
    local btn = make("TextButton",{
        Size             = UDim2.new(1,0,0,36),
        BackgroundColor3 = (i==1) and C.ACTIVE_BG or C.SIDEBAR,
        BorderSizePixel  = 0,
        Text             = def.icon.."  "..def.name,
        TextColor3       = (i==1) and C.ACCENT or C.TEXT_DIM,
        TextSize         = 10,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = i,
    }, sideList)
    corner(5, btn)

    -- active indicator bar
    local indicator = make("Frame",{
        Size=UDim2.new(0,2,0,16), Position=UDim2.new(0,-8,0.5,-8),
        BackgroundColor3=(i==1) and C.ACCENT or C.SIDEBAR,
        BorderSizePixel=0,
    }, btn)
    corner(999, indicator)
    make("UIPadding",{PaddingLeft=UDim.new(0,10)}, btn)

    btn.MouseButton1Click:Connect(function()
        for j, b in ipairs(tabBtns) do
            local a = (j == i)
            tw(b,{BackgroundColor3=a and C.ACTIVE_BG or C.SIDEBAR, TextColor3=a and C.ACCENT or C.TEXT_DIM})
            local ind = b:FindFirstChildOfClass("Frame")
            if ind then tw(ind,{BackgroundColor3=a and C.ACCENT or C.SIDEBAR}) end
            tabPages[j].Visible = a
        end
        currentTab = i
    end)
    tabBtns[i] = btn
end

-- ============================================================
-- SHARED WIDGET BUILDERS
-- ============================================================
local logCounters = {}

local function makeSection(parent, yOff, title)
    local lbl = make("TextLabel",{
        Size=UDim2.new(1,-32,0,14),
        Position=UDim2.new(0,16,0,yOff),
        BackgroundTransparency=1,
        Text=title,
        TextColor3=C.TEXT_MUTED,
        TextSize=8,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, parent)
    -- hairline below label
    make("Frame",{
        Size=UDim2.new(1,-32,0,1),
        Position=UDim2.new(0,16,0,yOff+15),
        BackgroundColor3=C.BORDER,
        BorderSizePixel=0,
    }, parent)
    return lbl
end

local function makeCard(parent, x, y, w, h)
    local c = make("Frame",{
        Size=UDim2.new(0,w,0,h),
        Position=UDim2.new(0,x,0,y),
        BackgroundColor3=C.CARD,
        BorderSizePixel=0,
    }, parent)
    corner(5, c)
    stroke(C.BORDER, 1, c)
    return c
end

local function makeScrollLog(parent, yOff, h)
    local sf = make("ScrollingFrame",{
        Size=UDim2.new(1,-32,0,h),
        Position=UDim2.new(0,16,0,yOff),
        BackgroundColor3=C.CARD,
        BorderSizePixel=0,
        ScrollBarThickness=2,
        ScrollBarImageColor3=C.BORDER2,
        CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,
    }, parent)
    corner(5, sf)
    stroke(C.BORDER, 1, sf)
    make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingTop=UDim.new(0,6),PaddingRight=UDim.new(0,8)}, sf)
    make("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder}, sf)
    return sf
end

local function addLog(sf, msg, color)
    if not logCounters[sf] then logCounters[sf]=0 end
    logCounters[sf] += 1
    make("TextLabel",{
        Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        Text="["..getTime().."]  "..msg,
        TextColor3=color or C.TEXT_DIM,
        TextSize=9, Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,
        LayoutOrder=logCounters[sf],
    }, sf)
    task.wait()
    sf.CanvasPosition = Vector2.new(0, sf.AbsoluteCanvasSize.Y)
end

-- Toggle button (ON/OFF style — fills full width of parent minus padding)
local function makeToggle(parent, yOff, onTxt, offTxt)
    local state = false
    local btn = make("TextButton",{
        Size=UDim2.new(1,-32,0,32),
        Position=UDim2.new(0,16,0,yOff),
        BackgroundColor3=C.CARD,
        BorderSizePixel=0,
        Text=offTxt,
        TextColor3=C.TEXT_DIM,
        TextSize=10,
        Font=Enum.Font.GothamBold,
    }, parent)
    corner(5, btn)
    stroke(C.BORDER2, 1, btn)

    -- status pill inside button (right side)
    local pill = make("Frame",{
        Size=UDim2.new(0,32,0,14),
        Position=UDim2.new(1,-44,0.5,-7),
        BackgroundColor3=C.BORDER2,
        BorderSizePixel=0,
    }, btn)
    corner(999, pill)
    local pillDot = make("Frame",{
        Size=UDim2.new(0,8,0,8),
        Position=UDim2.new(0,3,0.5,-4),
        BackgroundColor3=C.TEXT_MUTED,
        BorderSizePixel=0,
    }, pill)
    corner(999, pillDot)

    local function upd()
        if state then
            tw(btn,{BackgroundColor3=Color3.fromRGB(20,26,15),TextColor3=C.GREEN})
            tw(pill,{BackgroundColor3=Color3.fromRGB(30,50,20)})
            tw(pillDot,{BackgroundColor3=C.GREEN})
            btn.Text = onTxt
            stroke(Color3.fromRGB(60,90,40), 1, btn)
        else
            tw(btn,{BackgroundColor3=C.CARD,TextColor3=C.TEXT_DIM})
            tw(pill,{BackgroundColor3=C.BORDER2})
            tw(pillDot,{BackgroundColor3=C.TEXT_MUTED})
            btn.Text = offTxt
            stroke(C.BORDER2, 1, btn)
        end
    end
    btn.MouseButton1Click:Connect(function() state=not state upd() end)
    return btn, function() return state end
end

-- Input row: label left, TextBox right  (inside a card)
local function makeInputRow(card, yOff, labelTxt, default)
    make("TextLabel",{
        Size=UDim2.new(0,100,0,28), Position=UDim2.new(0,10,0,yOff),
        BackgroundTransparency=1,
        Text=labelTxt, TextColor3=C.TEXT_DIM,
        TextSize=9, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, card)
    local box = make("TextBox",{
        Size=UDim2.new(0,70,0,20), Position=UDim2.new(1,-80,0,yOff+4),
        BackgroundColor3=C.BG, BorderSizePixel=0,
        Text=default, TextColor3=C.TEXT,
        TextSize=10, Font=Enum.Font.Code,
        ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Center,
    }, card)
    corner(4, box)
    stroke(C.BORDER2, 1, box)
    return box
end

-- Status pill card (top of each tab)
local function makeStatusBar(parent, yOff)
    local card = makeCard(parent, 16, yOff, (WIN_W - SIDEBAR_W - 32), 36)
    local dot = make("Frame",{
        Size=UDim2.new(0,7,0,7),
        Position=UDim2.new(0,12,0.5,-3.5),
        BackgroundColor3=C.TEXT_MUTED,
        BorderSizePixel=0,
    }, card)
    corner(999, dot)
    local lbl = make("TextLabel",{
        Size=UDim2.new(1,-80,1,0),
        Position=UDim2.new(0,26,0,0),
        BackgroundTransparency=1,
        Text="IDLE", TextColor3=C.TEXT_DIM,
        TextSize=10, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
    }, card)
    local counter = make("TextLabel",{
        Size=UDim2.new(0,60,1,0),
        Position=UDim2.new(1,-68,0,0),
        BackgroundTransparency=1,
        Text="0 kill", TextColor3=C.TEXT_MUTED,
        TextSize=9, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,
    }, card)
    return dot, lbl, counter
end

-- ============================================================
-- TAB 1 — FARM
-- ============================================================
local t1 = tabPages[1]

makeSection(t1, 8, "MOB TARGET")

-- Preset mob buttons
local MOB_LIST    = {"Giant Dragonfly","Lizard Hollow"}
local selectedMob = MOB_LIST[1]

local mobFrame = make("Frame",{
    Size=UDim2.new(1,-32,0,28),
    Position=UDim2.new(0,16,0,30),
    BackgroundTransparency=1,
}, t1)
make("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,4)},mobFrame)

local mobBtns={}
local function updateMobBtns()
    for _,b in ipairs(mobBtns) do
        local a=(b.Text==selectedMob)
        tw(b,{
            BackgroundColor3=a and C.ACTIVE_BG or C.CARD,
            TextColor3=a and C.ACCENT or C.TEXT_DIM,
        })
    end
end
for _, name in ipairs(MOB_LIST) do
    local b = make("TextButton",{
        Size=UDim2.new(0,120,1,0),
        BackgroundColor3=(name==selectedMob) and C.ACTIVE_BG or C.CARD,
        BorderSizePixel=0,
        Text=name,
        TextColor3=(name==selectedMob) and C.ACCENT or C.TEXT_DIM,
        TextSize=9, Font=Enum.Font.GothamBold,
    }, mobFrame)
    corner(5, b)
    stroke(C.BORDER, 1, b)
    b.MouseButton1Click:Connect(function() selectedMob=name updateMobBtns() end)
    table.insert(mobBtns, b)
end

-- Custom mob
makeSection(t1, 64, "CUSTOM MOB")
local customBox = make("TextBox",{
    Size=UDim2.new(1,-32,0,26),
    Position=UDim2.new(0,16,0,84),
    BackgroundColor3=C.CARD,
    BorderSizePixel=0,
    Text="",
    PlaceholderText="leave blank to use preset above",
    TextColor3=C.TEXT,
    PlaceholderColor3=C.TEXT_MUTED,
    TextSize=9, Font=Enum.Font.Code,
    ClearTextOnFocus=false,
}, t1)
corner(5, customBox)
stroke(C.BORDER, 1, customBox)
make("UIPadding",{PaddingLeft=UDim.new(0,8)}, customBox)

-- Scan button
local scanBtn = make("TextButton",{
    Size=UDim2.new(1,-32,0,26),
    Position=UDim2.new(0,16,0,116),
    BackgroundColor3=C.CARD,
    BorderSizePixel=0,
    Text="⌕  SCAN NEARBY MOBS",
    TextColor3=C.TEXT_DIM,
    TextSize=9, Font=Enum.Font.GothamBold,
}, t1)
corner(5, scanBtn)
stroke(C.BORDER2, 1, scanBtn)
scanBtn.MouseEnter:Connect(function() tw(scanBtn,{BackgroundColor3=C.ACTIVE_BG}) end)
scanBtn.MouseLeave:Connect(function() tw(scanBtn,{BackgroundColor3=C.CARD}) end)

-- Settings card
makeSection(t1, 150, "SETTINGS")
local farmCard = makeCard(t1, 16, 170, WIN_W-SIDEBAR_W-32, 76)
local farmRangeBox   = makeInputRow(farmCard,  4, "Search Range",  "30")
local farmAttackBox  = makeInputRow(farmCard, 28, "Attack Dist",   "15")
local farmFloatBox   = makeInputRow(farmCard, 52, "Float Height Y","5")

-- second card for speed
local farmCard2 = makeCard(t1, 16, 252, WIN_W-SIDEBAR_W-32, 28)
local farmSpeedBox = makeInputRow(farmCard2, 0, "Move Speed", "0.5")

-- Status + log
local farmDot, farmLabel, farmCount = makeStatusBar(t1, 288)
local farmLog = makeScrollLog(t1, 332, 100)
local _, getFarmState = makeToggle(t1, 440, "◼  STOP FARM", "▶  START AUTO FARM")

-- Scan logic
scanBtn.MouseButton1Click:Connect(function()
    addLog(farmLog, "── SCANNING ──", C.TEXT_DIM)
    local root = getRoot()
    if not root then addLog(farmLog,"No character",C.RED) return end
    local found=0
    local living=workspace:FindFirstChild("Living")
    local container=living or workspace
    for _,v in ipairs(container:GetDescendants()) do
        if v:IsA("Model") then
            local hum=v:FindFirstChildOfClass("Humanoid")
            local hrp=v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
            if hum and hrp and hum.Health>0 then
                local isP=false
                for _,p in ipairs(Players:GetPlayers()) do
                    if p.Character==v then isP=true end
                end
                if not isP then
                    local dist=math.floor((hrp.Position-root.Position).Magnitude)
                    if dist<=200 then
                        found+=1
                        addLog(farmLog,
                            string.format("%-24s  HP:%-6d  DIST:%d",v.Name,math.floor(hum.Health),dist),
                            Color3.fromRGB(160,160,160))
                    end
                end
            end
        end
    end
    addLog(farmLog,"── DONE  "..found.." mobs ──",C.TEXT_DIM)
end)

-- Farm loop
local killCount=0

local function getMobName()
    local c=customBox.Text
    return (c~="" and c) or selectedMob
end

local function getNearestMob(name,range)
    local root=getRoot()
    if not root then return nil end
    local best,bestDist=nil,math.huge
    local living=workspace:FindFirstChild("Living")
    local list=living and living:GetChildren() or workspace:GetDescendants()
    for _,v in ipairs(list) do
        if v:IsA("Model") and v.Name:lower():find(name:lower()) then
            local hum=v:FindFirstChildOfClass("Humanoid")
            local hrp=v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso")
            if hum and hrp and hum.Health>0 then
                local dist=(hrp.Position-root.Position).Magnitude
                if dist<bestDist and dist<=range then best=v bestDist=dist end
            end
        end
    end
    return best
end

local function smoothMoveTo(mob,speed)
    local root=getRoot()
    local hrp=mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
    if not root or not hrp then return end
    local yOff=tonumber(farmFloatBox.Text) or 5
    local mt=(tonumber(speed) or 0.5)*2
    local tInfo=TweenInfo.new(mt,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut)
    local t=TweenService:Create(root,tInfo,{CFrame=CFrame.new(hrp.Position.X,hrp.Position.Y+yOff,hrp.Position.Z+5)})
    t:Play() t.Completed:Wait()
end

local function attackMob(mob,adist,abilist)
    local hrp=mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
    if not hrp then return end
    holdWeapon()
    local root=getRoot()
    if root and (hrp.Position-root.Position).Magnitude>(adist-0.5) then
        local dir=(hrp.Position-root.Position).Unit
        root.CFrame=CFrame.new(root.Position+dir*(adist-2)+Vector3.new(0,2,0))
    end
    pcall(function() Combat:FireServer(mob,hrp.Position) end)
    task.wait(0.1)
    pcall(function() UseSkill:FireServer(1,mob) end)
    task.wait(0.1)
    pcall(function() UseAbility:FireServer("1",mob) end)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if getFarmState() then
            local name=getMobName()
            local range=tonumber(farmRangeBox.Text) or 30
            local adist=tonumber(farmAttackBox.Text) or 15
            local mob=getNearestMob(name,range)
            if mob then
                local hum=mob:FindFirstChildOfClass("Humanoid")
                tw(farmDot,{BackgroundColor3=C.GREEN})
                farmLabel.Text="FARMING  "..mob.Name
                tw(farmLabel,{TextColor3=C.GREEN})
                smoothMoveTo(mob,farmSpeedBox.Text)
                attackMob(mob,adist)
                if hum then
                    local died=false
                    local conn=hum.Died:Connect(function() died=true end)
                    local t0=tick()
                    while not died and tick()-t0<8 do attackMob(mob,adist) task.wait(0.4) end
                    conn:Disconnect()
                    if died then
                        killCount+=1
                        farmCount.Text=killCount.." kill"
                        addLog(farmLog,"✓ "..mob.Name.."  ("..killCount..")",C.GREEN)
                    end
                end
            else
                tw(farmDot,{BackgroundColor3=C.TEXT_MUTED})
                farmLabel.Text="SEARCHING  "..name
                tw(farmLabel,{TextColor3=C.TEXT_DIM})
            end
        else
            tw(farmDot,{BackgroundColor3=C.TEXT_MUTED})
            farmLabel.Text="IDLE"
            tw(farmLabel,{TextColor3=C.TEXT_DIM})
        end
    end
end)

-- ============================================================
-- TAB 2 — BOSS
-- ============================================================
local t2=tabPages[2]

makeSection(t2,8,"BOSS TARGET")
local bossBox=make("TextBox",{
    Size=UDim2.new(1,-32,0,26),Position=UDim2.new(0,16,0,28),
    BackgroundColor3=C.CARD,BorderSizePixel=0,
    Text="Giant Dragonfly",TextColor3=C.TEXT,
    TextSize=10,Font=Enum.Font.Code,ClearTextOnFocus=false,
},t2)
corner(5,bossBox) stroke(C.BORDER,1,bossBox)
make("UIPadding",{PaddingLeft=UDim.new(0,8)},bossBox)

makeSection(t2,62,"SETTINGS")
local bossCard=makeCard(t2,16,80,WIN_W-SIDEBAR_W-32,76)
local bossFloatBox  =makeInputRow(bossCard, 4,"Float Height Y","5")
local bossAttackBox =makeInputRow(bossCard,28,"Attack Dist",  "15")
local bossSpeedBox  =makeInputRow(bossCard,52,"Move Speed",   "0.4")

local bossDot,bossLabel,bossCount=makeStatusBar(t2,164)
local bossLog=makeScrollLog(t2,208,200)
local _,getBossState=makeToggle(t2,416,"◼  STOP BOSS","▶  START AUTO BOSS")
local bossKills=0

local function smoothMoveToBoss(mob)
    local root=getRoot()
    local hrp=mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
    if not root or not hrp then return end
    local yOff=tonumber(bossFloatBox.Text) or 5
    local mt=(tonumber(bossSpeedBox.Text) or 0.4)*2
    local t=TweenService:Create(root,TweenInfo.new(mt,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
        {CFrame=CFrame.new(hrp.Position.X,hrp.Position.Y+yOff,hrp.Position.Z+5)})
    t:Play() t.Completed:Wait()
end

local function attackBoss(mob)
    holdWeapon()
    local hrp=mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
    if not hrp then return end
    local adist=tonumber(bossAttackBox.Text) or 15
    local root=getRoot()
    if root and (hrp.Position-root.Position).Magnitude>adist then
        local dir=(hrp.Position-root.Position).Unit
        root.CFrame=CFrame.new(root.Position+dir*(adist-2)+Vector3.new(0,2,0))
    end
    pcall(function() Combat:FireServer(mob,hrp.Position) end) task.wait(0.1)
    pcall(function() UseSkill:FireServer(1,mob) end)          task.wait(0.1)
    pcall(function() UseSkill:FireServer(2,mob) end)          task.wait(0.1)
    pcall(function() UseAbility:FireServer("1",mob) end)      task.wait(0.1)
    pcall(function() UseAbility:FireServer("2",mob) end)
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if getBossState() then
            local name=bossBox.Text
            local boss=nil
            local living=workspace:FindFirstChild("Living")
            if living then
                for _,v in ipairs(living:GetChildren()) do
                    if v:IsA("Model") and v.Name:lower():find(name:lower()) then
                        local hum=v:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health>0 then boss=v break end
                    end
                end
            end
            if boss then
                local hum=boss:FindFirstChildOfClass("Humanoid")
                tw(bossDot,{BackgroundColor3=C.ORANGE})
                bossLabel.Text="ATTACKING  "..boss.Name
                tw(bossLabel,{TextColor3=C.ORANGE})
                addLog(bossLog,"Boss: "..boss.Name.."  HP:"..math.floor(hum.Health),C.ORANGE)
                while getBossState() and hum and hum.Health>0 do
                    smoothMoveToBoss(boss)
                    attackBoss(boss)
                    task.wait(0.5)
                end
                if hum and hum.Health<=0 then
                    bossKills+=1 bossCount.Text=bossKills.." kill"
                    addLog(bossLog,"✓ Boss defeated  ("..bossKills.." total)",C.GREEN)
                    addLog(bossLog,"Waiting for respawn...",C.TEXT_DIM)
                    task.wait(8)
                end
            else
                tw(bossDot,{BackgroundColor3=C.TEXT_MUTED})
                bossLabel.Text="WAITING  "..name
                tw(bossLabel,{TextColor3=C.TEXT_DIM})
            end
        else
            tw(bossDot,{BackgroundColor3=C.TEXT_MUTED})
            bossLabel.Text="IDLE"
            tw(bossLabel,{TextColor3=C.TEXT_DIM})
        end
    end
end)

-- ============================================================
-- TAB 3 — QUEST
-- ============================================================
local t3=tabPages[3]
makeSection(t3,8,"QUEST STATUS")
local questDot,questLabel,questCount=makeStatusBar(t3,28)
local questLog=makeScrollLog(t3,72,300)

local getQBtn=make("TextButton",{
    Size=UDim2.new(1,-32,0,28),Position=UDim2.new(0,16,0,380),
    BackgroundColor3=C.CARD,BorderSizePixel=0,
    Text="⌕  GET MISSIONS",TextColor3=C.TEXT_DIM,
    TextSize=10,Font=Enum.Font.GothamBold,
},t3)
corner(5,getQBtn) stroke(C.BORDER2,1,getQBtn)
getQBtn.MouseEnter:Connect(function() tw(getQBtn,{BackgroundColor3=C.ACTIVE_BG}) end)
getQBtn.MouseLeave:Connect(function() tw(getQBtn,{BackgroundColor3=C.CARD}) end)

local _,getQuestState=makeToggle(t3,416,"◼  STOP QUEST","▶  START AUTO QUEST")
local qDone=0

getQBtn.MouseButton1Click:Connect(function()
    addLog(questLog,"Fetching missions...",C.TEXT_DIM)
    local ok,r=pcall(function() return GetMissions:InvokeServer() end)
    if ok and r then
        addLog(questLog,"Response: "..type(r),C.TEXT)
        if type(r)=="table" then
            for k,v in pairs(r) do
                addLog(questLog,"  "..tostring(k).." : "..tostring(v),Color3.fromRGB(140,140,140))
            end
        end
    else
        addLog(questLog,"Failed: "..tostring(r),C.RED)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if getQuestState() then
            tw(questDot,{BackgroundColor3=C.BLUE})
            questLabel.Text="QUESTING..."
            tw(questLabel,{TextColor3=C.BLUE})
            pcall(function() ReqMission:InvokeServer() end)
            pcall(function() TakeQuest:FireServer() end)
            qDone+=1 questCount.Text=qDone.." req"
            addLog(questLog,"Quest request sent",Color3.fromRGB(120,150,220))
            task.wait(4)
        else
            tw(questDot,{BackgroundColor3=C.TEXT_MUTED})
            questLabel.Text="IDLE"
            tw(questLabel,{TextColor3=C.TEXT_DIM})
        end
    end
end)

-- ============================================================
-- TAB 4 — LOG
-- ============================================================
local t4=tabPages[4]
makeSection(t4,8,"GLOBAL LOG")
local globalLog=makeScrollLog(t4,28,424)
local clrBtn=make("TextButton",{
    Size=UDim2.new(1,-32,0,24),Position=UDim2.new(0,16,0,460),
    BackgroundColor3=C.CARD,BorderSizePixel=0,
    Text="CLEAR LOG",TextColor3=C.TEXT_MUTED,
    TextSize=9,Font=Enum.Font.GothamBold,
},t4)
corner(5,clrBtn) stroke(C.BORDER,1,clrBtn)
clrBtn.MouseEnter:Connect(function() tw(clrBtn,{BackgroundColor3=C.ACTIVE_BG}) end)
clrBtn.MouseLeave:Connect(function() tw(clrBtn,{BackgroundColor3=C.CARD}) end)
clrBtn.MouseButton1Click:Connect(function()
    for _,c in ipairs(globalLog:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
    logCounters[globalLog]=0
end)

-- ============================================================
-- DRAG
-- ============================================================
local dragging,dragStart,startPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true dragStart=input.Position startPos=win.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
        local d=input.Position-dragStart
        win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                               startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- RSHIFT toggle
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.RightShift then
        win.Visible=not win.Visible
    end
end)

-- ============================================================
-- INIT LOGS
-- ============================================================
addLog(farmLog,  "Ready — select mob then START FARM",  C.TEXT_MUTED)
addLog(bossLog,  "Ready — set boss then START BOSS",    C.TEXT_MUTED)
addLog(questLog, "Ready",                               C.TEXT_MUTED)
addLog(globalLog,"✓  Lopper Hub [ENHANCED] loaded",    C.TEXT)
addLog(globalLog,"•  Cerberus-style GUI active",        C.TEXT_DIM)
addLog(globalLog,"•  Smooth movement enabled",          C.TEXT_DIM)
addLog(globalLog,"•  Auto weapon hold enabled",         C.TEXT_DIM)
print("[ Lopper Hub ENHANCED ] Loaded | RightShift = toggle")
