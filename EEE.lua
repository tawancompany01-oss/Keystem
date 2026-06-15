-- ⚡ Demonser Hub | Grow a Garden 2 | v5 Fixed
-- Auto Buy Seed/Pet | Auto Plant | Auto Harvest | Auto Sell | Discord Webhook

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local RS               = game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")

local lp = Players.LocalPlayer

-- GUARD
local ex = lp:WaitForChild("PlayerGui"):FindFirstChild("DemonserHub")
if ex then ex:Destroy() task.wait(0.1) end

-- ===== DATA =====
local SEEDS = {
    "Carrot","Strawberry","Blueberry","Tulip","Tomato","Apple","Bamboo","Corn",
    "Cactus","Pineapple","Baby Cactus","Horned Melon","Mushroom","Green Bean",
    "Banana","Grape","Coconut","Mango","Glow Mushroom","Dragon Fruit","Cherry",
    "Acorn","Sunflower","Poison Ivy","Venus Fly Trap","Pomegranate","Poison Apple",
    "Ghost Pepper","Moon Bloom","Dragon's Breath"
}
local PETS = {
    "Frog","Bunny","Owl","Deer","Robin","Bee","Monkey",
    "Golden Dragonfly","Unicorn","Raccoon","Black Dragon","Ice Serpent"
}

local SELL_POS  = Vector3.new(269.75, 149, -127.07)
local SEEDS_POS = Vector3.new(263.94, 149, -145.07)

-- ===== STATE =====
local selectedSeeds  = {}
local selectedPets   = {}
local autoBuySeed    = false
local autoBuyPet     = false
local autoPlant      = false
local autoHarvest    = false
local autoSell       = false
local toggleKey      = Enum.KeyCode.RightShift
local isBindingKey   = false
local seedBusy       = false
local petBusy        = false
local plantBusy      = false
local harvestBusy    = false
local sellBusy       = false
local webhookURL     = ""
local plantPositions  = {}
local selectedPlantSeed = nil
local plantPosLabel   = nil
local plantPosContainer = nil

-- ===== HELPERS =====
local function make(class, props, parent)
    local obj = Instance.new(class)
    for k,v in pairs(props) do obj[k]=v end
    if parent then obj.Parent=parent end
    return obj
end
local function corner(r,p) make("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function tw(o,props,t)
    if o and o.Parent then
        TweenService:Create(o,TweenInfo.new(t or 0.15,Enum.EasingStyle.Quad),props):Play()
    end
end
local function getRoot()
    local c = lp.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function isAlive()
    local c = lp.Character
    if not c then return false end
    local h = c:FindFirstChild("Humanoid")
    return h and h.Health > 0
end
local function tpTo(pos)
    local root = getRoot()
    if not root or not isAlive() then return false end
    root.CFrame = CFrame.new(pos)
    task.wait(0.4)
    return isAlive()
end

-- ===== WEBHOOK =====
local function webhook(title, desc, color)
    if webhookURL == "" then return end
    task.spawn(function()
        pcall(function()
            HttpService:PostAsync(webhookURL, HttpService:JSONEncode({
                embeds = {{
                    title = "⚡ Demonser Hub | "..title,
                    description = desc,
                    color = color or 7419530,
                    footer = {text = "Demonser Hub • Grow a Garden 2"},
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }}
            }), Enum.HttpContentType.ApplicationJson, false)
        end)
    end)
end

-- ===== PACKET =====
local packetRemote
pcall(function() packetRemote = RS.SharedModules.Packet.RemoteEvent end)
local function firePacket(...)
    if packetRemote then pcall(function() packetRemote:FireServer(...) end) end
end

-- ===== PET NAME MAP =====
local petNameMap = {
    ["Golden Dragonfly"]="goldendragonfly",
    ["Black Dragon"]="blackdragon",
    ["Ice Serpent"]="iceserpent",
}
local function petSearch(n)
    return petNameMap[n] or n:lower():gsub(" ","")
end

-- ===== GARDEN DETECTION =====
-- Workspace.Gardens.PlotX — player's own plot has Edit PP Enabled=true
local function getMyPlotModel()
    local gardens = workspace:FindFirstChild("Gardens")
    if not gardens then return nil end
    for _, plot in ipairs(gardens:GetChildren()) do
        if plot:IsA("Model") and plot.Name:find("Plot") then
            local ok, result = pcall(function()
                local pp = plot.Signs.Garden.CorePart.CustomiseTheme
                return pp:IsA("ProximityPrompt") and pp.Enabled
            end)
            if ok and result then return plot end
        end
    end
    return nil
end

local function getMyPlotCenter()
    local plot = getMyPlotModel()
    if not plot then return nil end
    local ok1, ref = pcall(function() return plot.PlotSizeReference end)
    if ok1 and ref and ref:IsA("BasePart") then return ref.Position end
    local ok2, zone = pcall(function() return plot.Visual.GardenZonePart end)
    if ok2 and zone and zone:IsA("BasePart") then return zone.Position end
    return nil
end

-- ===== BUY SEED =====
local function buySeed(seedName, qty)
    tpTo(SEEDS_POS)
    task.wait(0.3)
    firePacket("BuySeed", seedName, qty)
    firePacket("BuySeed", {name=seedName, amount=qty})
    firePacket("PurchaseSeed", seedName, qty)
    pcall(function()
        RS.RemoteEvents.ReplicaSignal:FireServer("BuySeed", seedName, qty)
    end)
end

-- ===== SEED TOOL =====
local function findSeedTool(seedName)
    local sources = {}
    if lp.Character then table.insert(sources, lp.Character) end
    local bp = lp:FindFirstChild("Backpack")
    if bp then table.insert(sources, bp) end
    for _, src in ipairs(sources) do
        for _, t in ipairs(src:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                local s = (seedName or ""):lower()
                if s ~= "" and n:find(s, 1, true) then return t end
                if s == "" and (n:find("seed") or n:find("bulb")) then return t end
            end
        end
    end
    return nil
end

local function equipSeed(tool)
    if not tool or not isAlive() then return false end
    if tool.Parent ~= lp.Character then
        local char = lp.Character
        if char then
            tool.Parent = char
            task.wait(0.35)
        end
    end
    return tool.Parent == lp.Character
end

-- ===== AUTO PLANT =====
local function plantAt(worldPos)
    if not isAlive() then return false end
    local root = getRoot()
    if not root then return false end
    root.CFrame = CFrame.new(worldPos + Vector3.new(0, 3, 0))
    task.wait(0.3)
    if not isAlive() then return false end
    local char = lp.Character
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local toolRemote = tool:FindFirstChildOfClass("RemoteEvent")
    if toolRemote then
        pcall(function() toolRemote:FireServer(worldPos, Vector3.new(0,1,0)) end)
    end
    firePacket("Plant", worldPos)
    firePacket("UseTool", tool.Name, worldPos)
    firePacket("PlaceSeed", tool.Name, worldPos)
    pcall(function() tool:Activate() end)
    task.wait(0.2)
    return true
end

local function doAutoPlant()
    if #plantPositions == 0 then return end
    if not isAlive() then return end
    local gardenCenter = getMyPlotCenter()
    if gardenCenter then
        tpTo(gardenCenter + Vector3.new(0, 3, 0))
        task.wait(0.5)
    end
    local searchName = selectedPlantSeed or ""
    local tool = findSeedTool(searchName)
    if not tool then print("[Plant] No seed tool found!") return end
    if not equipSeed(tool) then print("[Plant] Failed to equip") return end
    local planted = 0
    for i, pos in ipairs(plantPositions) do
        if not autoPlant or not isAlive() then break end
        local char = lp.Character
        if not (char and char:FindFirstChildOfClass("Tool")) then
            tool = findSeedTool(searchName)
            if not tool then print("[Plant] Out of seeds at #"..i) break end
            if not equipSeed(tool) then break end
        end
        local targetPos = Vector3.new(pos.x, pos.y, pos.z)
        if plantAt(targetPos) then
            planted += 1
            print("[Plant] Planted #"..i)
        end
        task.wait(0.7)
    end
    print("[Plant] Done: "..planted.."/"..#plantPositions)
end

-- ===== AUTO HARVEST =====
local function doAutoHarvest()
    if not isAlive() then return end
    local gardenCenter = getMyPlotCenter()
    if not gardenCenter then print("[Harvest] Garden not found!") return end
    print("[Harvest] Warping to garden...")
    tpTo(gardenCenter + Vector3.new(0, 3, 0))
    task.wait(0.6)
    if not isAlive() then return end
    local myPlot = getMyPlotModel()
    if not myPlot then print("[Harvest] Plot not found!") return end
    local collected = 0
    local root = getRoot()
    for _, obj in ipairs(myPlot:GetDescendants()) do
        if not autoHarvest or not isAlive() then break end
        if obj:IsA("ClickDetector") then
            local parent = obj.Parent
            if parent and parent:IsA("BasePart") then
                if root then
                    root.CFrame = CFrame.new(parent.Position + Vector3.new(0,3,2))
                    task.wait(0.2)
                end
                pcall(function() fireclickdetector(obj) end)
                collected += 1
                task.wait(0.25)
            end
        elseif obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("fruit") or n:find("crop") or n:find("harvest") then
                if root then
                    root.CFrame = CFrame.new(obj.Position + Vector3.new(0,3,2))
                    task.wait(0.2)
                end
                firePacket("Collect", obj)
                firePacket("Harvest", obj.Position)
                firePacket("CollectFruit", obj.Position)
                collected += 1
                task.wait(0.25)
            end
        end
    end
    firePacket("HarvestAll")
    firePacket("CollectAll")
    print("[Harvest] Done. Interacted: "..collected)
end

-- ===== AUTO SELL =====
local function doAutoSell()
    if not isAlive() then return end
    print("[Sell] Warping to sell area...")
    tpTo(SELL_POS)
    task.wait(0.8)
    if not isAlive() then return end
    firePacket("SellAll")
    firePacket("Sell", "all")
    firePacket("SellInventory")
    pcall(function() RS.RemoteEvents.ReplicaSignal:FireServer("SellAll") end)
    print("[Sell] Sell packets fired!")
end

-- ===================================================
-- GUI
-- ===================================================
local screen = make("ScreenGui",{
    Name="DemonserHub", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
},lp:WaitForChild("PlayerGui"))

local main = make("Frame",{
    Size=UDim2.new(0,470,0,660),
    Position=UDim2.new(0.5,-235,0.5,-330),
    BackgroundColor3=Color3.fromRGB(14,14,20),
    BorderSizePixel=0, ClipsDescendants=true, Active=true,
},screen)
corner(10,main)
make("UIStroke",{Color=Color3.fromRGB(130,80,220),Thickness=1.5},main)

-- DRAG
local dragging, dragStart, startPos
main.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = main.Position
    end
end)
main.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

-- BANNER
local banner = make("Frame",{Size=UDim2.new(1,0,0,32),
    BackgroundColor3=Color3.fromRGB(55,20,110),BorderSizePixel=0},main)
corner(10,banner)
make("Frame",{Size=UDim2.new(1,0,0,15),Position=UDim2.new(0,0,1,-15),
    BackgroundColor3=Color3.fromRGB(55,20,110),BorderSizePixel=0},banner)
make("TextLabel",{Size=UDim2.new(1,-40,1,0),BackgroundTransparency=1,
    Text="⚡ DEMONSER HUB  |  Grow a Garden 2  |  v5",
    TextColor3=Color3.fromRGB(255,255,255),TextSize=13,
    Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Center},banner)
local closeBtn = make("TextButton",{Size=UDim2.new(0,28,0,22),
    Position=UDim2.new(1,-32,0,5),BackgroundColor3=Color3.fromRGB(180,40,60),
    BorderSizePixel=0,Text="✕",TextColor3=Color3.fromRGB(255,255,255),
    TextSize=12,Font=Enum.Font.GothamBold},banner)
corner(5,closeBtn)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

-- SCROLL
local scroll = make("ScrollingFrame",{
    Size=UDim2.new(1,-10,1,-92),Position=UDim2.new(0,5,0,36),
    BackgroundTransparency=1,BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(130,80,220),
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
},main)
make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,8)},scroll)
make("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},scroll)

-- ===== UI HELPERS =====
local function sectionLabel(parent, text)
    local l = make("TextLabel",{
        Size=UDim2.new(1,0,0,22),BackgroundColor3=Color3.fromRGB(55,20,110),
        BorderSizePixel=0,Text="  "..text,
        TextColor3=Color3.fromRGB(220,180,255),TextSize=11,
        Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left},parent)
    corner(6,l)
    return l
end

local function makeToggleRow(parent, labelText, callback)
    local row = make("Frame",{Size=UDim2.new(1,0,0,34),
        BackgroundColor3=Color3.fromRGB(22,22,32),BorderSizePixel=0},parent)
    corner(6,row)
    make("UIStroke",{Color=Color3.fromRGB(70,40,130),Thickness=1},row)
    local dot = make("Frame",{Size=UDim2.new(0,8,0,8),
        Position=UDim2.new(0,8,0.5,-4),
        BackgroundColor3=Color3.fromRGB(80,80,80),BorderSizePixel=0},row)
    corner(4,dot)
    make("TextLabel",{Size=UDim2.new(0.72,0,1,0),Position=UDim2.new(0,22,0,0),
        BackgroundTransparency=1,Text=labelText,
        TextColor3=Color3.fromRGB(220,220,220),TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left},row)
    local state = false
    local btn = make("TextButton",{Size=UDim2.new(0,32,0,20),
        Position=UDim2.new(1,-42,0.5,-10),
        BackgroundColor3=Color3.fromRGB(55,55,70),BorderSizePixel=0,Text=""},row)
    corner(6,btn)
    local function setState(v)
        state = v
        tw(btn,{BackgroundColor3=v and Color3.fromRGB(120,60,220) or Color3.fromRGB(55,55,70)})
        tw(dot,{BackgroundColor3=v and Color3.fromRGB(80,220,100) or Color3.fromRGB(80,80,80)})
        if callback then callback(v) end
    end
    btn.MouseButton1Click:Connect(function() setState(not state) end)
    return row
end

local function makeInputRow(parent, labelText, default)
    local row = make("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1},parent)
    make("TextLabel",{Size=UDim2.new(0.62,0,1,0),BackgroundTransparency=1,
        Text="  "..labelText,TextColor3=Color3.fromRGB(180,180,180),
        TextSize=10,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left},row)
    local box = make("TextBox",{
        Size=UDim2.new(0,60,0,22),Position=UDim2.new(0.64,0,0.5,-11),
        BackgroundColor3=Color3.fromRGB(22,22,32),BorderSizePixel=0,
        Text=tostring(default),TextColor3=Color3.fromRGB(220,220,220),
        TextSize=10,Font=Enum.Font.Code,ClearTextOnFocus=false},row)
    corner(5,box)
    make("UIStroke",{Color=Color3.fromRGB(70,40,130),Thickness=1},box)
    return box
end

local function makeWideInput(parent, ph)
    local box = make("TextBox",{
        Size=UDim2.new(1,0,0,28),
        BackgroundColor3=Color3.fromRGB(22,22,32),BorderSizePixel=0,
        Text="",PlaceholderText=ph,
        TextColor3=Color3.fromRGB(220,220,220),
        PlaceholderColor3=Color3.fromRGB(80,80,80),
        TextSize=9,Font=Enum.Font.Code,ClearTextOnFocus=false,
        TextXAlignment=Enum.TextXAlignment.Left},parent)
    corner(5,box)
    make("UIStroke",{Color=Color3.fromRGB(70,40,130),Thickness=1},box)
    make("UIPadding",{PaddingLeft=UDim.new(0,6)},box)
    return box
end

local function makeBtn(parent, text, col, callback)
    local btn = make("TextButton",{
        Size=UDim2.new(1,0,0,30),
        BackgroundColor3=col or Color3.fromRGB(60,30,120),BorderSizePixel=0,
        Text=text,TextColor3=Color3.fromRGB(240,220,255),
        TextSize=11,Font=Enum.Font.GothamBold},parent)
    corner(6,btn)
    make("UIStroke",{Color=Color3.fromRGB(100,55,190),Thickness=1},btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local function makeCheckGrid(parent, items, selectedTable)
    local gf = make("Frame",{Size=UDim2.new(1,0,0,0),
        BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},parent)
    make("UIGridLayout",{
        CellSize=UDim2.new(0.5,-6,0,26),
        CellPadding=UDim2.new(0,4,0,4),
        SortOrder=Enum.SortOrder.LayoutOrder},gf)
    for _, item in ipairs(items) do
        local checked = false
        local cell = make("TextButton",{Size=UDim2.new(0,100,0,26),
            BackgroundColor3=Color3.fromRGB(22,22,32),BorderSizePixel=0,Text=""},gf)
        corner(5,cell)
        local stroke = make("UIStroke",{Color=Color3.fromRGB(70,40,130),Thickness=1},cell)
        local icon = make("TextLabel",{Size=UDim2.new(0,20,1,0),BackgroundTransparency=1,
            Text="[ ]",TextColor3=Color3.fromRGB(130,80,220),
            TextSize=11,Font=Enum.Font.GothamBold},cell)
        make("TextLabel",{Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,22,0,0),
            BackgroundTransparency=1,Text=item,TextColor3=Color3.fromRGB(200,200,200),
            TextSize=9,Font=Enum.Font.GothamMedium,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd},cell)
        cell.MouseButton1Click:Connect(function()
            checked = not checked
            if checked then
                selectedTable[item] = true
                icon.Text = "[X]"
                tw(cell,{BackgroundColor3=Color3.fromRGB(45,20,90)})
                stroke.Color = Color3.fromRGB(130,80,220)
                stroke.Thickness = 1.5
            else
                selectedTable[item] = nil
                icon.Text = "[ ]"
                tw(cell,{BackgroundColor3=Color3.fromRGB(22,22,32)})
                stroke.Color = Color3.fromRGB(70,40,130)
                stroke.Thickness = 1
            end
        end)
    end
    return gf
end

local function makeSelectRow(parent, items, selectedTable, grid)
    local row = make("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},parent)
    local function sb(text, xpos, cb)
        local b = make("TextButton",{Size=UDim2.new(0.48,0,0,22),
            Position=UDim2.new(xpos,0,0,1),
            BackgroundColor3=Color3.fromRGB(45,20,90),BorderSizePixel=0,
            Text=text,TextColor3=Color3.fromRGB(200,180,255),
            TextSize=9,Font=Enum.Font.GothamBold},row)
        corner(4,b)
        b.MouseButton1Click:Connect(cb)
    end
    local function refresh(st)
        for _, cell in ipairs(grid:GetChildren()) do
            if cell:IsA("TextButton") then
                for _, ch in ipairs(cell:GetChildren()) do
                    if ch:IsA("TextLabel") then ch.Text = st and "[X]" or "[ ]" end
                end
                cell.BackgroundColor3 = st and Color3.fromRGB(45,20,90) or Color3.fromRGB(22,22,32)
                local s = cell:FindFirstChildOfClass("UIStroke")
                if s then
                    s.Color = st and Color3.fromRGB(130,80,220) or Color3.fromRGB(70,40,130)
                    s.Thickness = st and 1.5 or 1
                end
            end
        end
    end
    sb("Select All", 0, function()
        for _, i in ipairs(items) do selectedTable[i] = true end
        refresh(true)
    end)
    sb("Clear All", 0.52, function()
        for k in pairs(selectedTable) do selectedTable[k] = nil end
        refresh(false)
    end)
end

local function rebuildPosList()
    if not plantPosLabel or not plantPosContainer then return end
    plantPosLabel.Text = "Saved Positions: " .. #plantPositions
    for _, c in ipairs(plantPosContainer:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for i, pos in ipairs(plantPositions) do
        local idx = i
        local row = make("Frame",{Size=UDim2.new(1,0,0,24),
            BackgroundColor3=Color3.fromRGB(22,22,32),BorderSizePixel=0},plantPosContainer)
        corner(4,row)
        make("TextLabel",{Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,6,0,0),
            BackgroundTransparency=1,
            Text=string.format("#%d  %.0f, %.0f, %.0f  [%s]",i,pos.x,pos.y,pos.z,pos.label or "any"),
            TextColor3=Color3.fromRGB(170,170,200),TextSize=8,Font=Enum.Font.Code,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd},row)
        local del = make("TextButton",{Size=UDim2.new(0,26,0,18),
            Position=UDim2.new(1,-30,0.5,-9),
            BackgroundColor3=Color3.fromRGB(120,30,40),BorderSizePixel=0,
            Text="X",TextColor3=Color3.fromRGB(255,180,180),
            TextSize=8,Font=Enum.Font.GothamBold},row)
        corner(4,del)
        del.MouseButton1Click:Connect(function()
            table.remove(plantPositions, idx)
            rebuildPosList()
        end)
    end
end

-- ===================================================
-- BUILD UI
-- ===================================================

sectionLabel(scroll,"🔔 DISCORD WEBHOOK")
local webhookBox = makeWideInput(scroll,"Paste Discord Webhook URL here...")
webhookBox:GetPropertyChangedSignal("Text"):Connect(function()
    webhookURL = webhookBox.Text
end)

sectionLabel(scroll,"🌱 AUTO BUY SEED")
makeToggleRow(scroll,"Enable Auto Buy Seed",function(v) autoBuySeed=v end)
local seedQtyBox   = makeInputRow(scroll,"Buy quantity per cycle:",1)
local seedDelayBox = makeInputRow(scroll,"Delay between buys (sec):",3)
sectionLabel(scroll,"  Select Seeds to Buy:")
local seedGrid = makeCheckGrid(scroll,SEEDS,selectedSeeds)
makeSelectRow(scroll,SEEDS,selectedSeeds,seedGrid)

sectionLabel(scroll,"🐾 AUTO BUY PET")
makeToggleRow(scroll,"Enable Auto Buy Pet",function(v) autoBuyPet=v end)
local petDelayBox = makeInputRow(scroll,"Delay between buys (sec):",3)
sectionLabel(scroll,"  Select Pets to Buy:")
local petGrid = makeCheckGrid(scroll,PETS,selectedPets)
makeSelectRow(scroll,PETS,selectedPets,petGrid)

sectionLabel(scroll,"🌾 AUTO PLANT")
makeToggleRow(scroll,"Enable Auto Plant",function(v) autoPlant=v end)
local plantDelayBox = makeInputRow(scroll,"Plant cycle delay (sec):",5)

local infoBox = make("Frame",{Size=UDim2.new(1,0,0,56),
    BackgroundColor3=Color3.fromRGB(14,28,14),BorderSizePixel=0},scroll)
corner(6,infoBox)
make("UIStroke",{Color=Color3.fromRGB(40,100,40),Thickness=1},infoBox)
make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    Text="HOW TO USE:\n1. Stand on each soil spot in your garden\n2. Click 'Save Position' for each spot\n3. Select seed, then enable toggle",
    TextColor3=Color3.fromRGB(100,200,100),TextSize=9,Font=Enum.Font.GothamMedium,
    TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},infoBox)
make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingTop=UDim.new(0,6)},infoBox)

-- Seed dropdown
local seedSelectRow = make("Frame",{Size=UDim2.new(1,0,0,32),
    BackgroundColor3=Color3.fromRGB(22,22,32),BorderSizePixel=0},scroll)
corner(6,seedSelectRow)
make("UIStroke",{Color=Color3.fromRGB(70,40,130),Thickness=1},seedSelectRow)
make("TextLabel",{Size=UDim2.new(0.38,0,1,0),Position=UDim2.new(0,8,0,0),
    BackgroundTransparency=1,Text="Seed to plant:",
    TextColor3=Color3.fromRGB(200,180,255),TextSize=10,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left},seedSelectRow)
local seedDropBtn = make("TextButton",{
    Size=UDim2.new(0.58,0,0,24),Position=UDim2.new(0.4,0,0.5,-12),
    BackgroundColor3=Color3.fromRGB(45,20,90),BorderSizePixel=0,
    Text="(any seed in backpack)",
    TextColor3=Color3.fromRGB(180,220,180),TextSize=8,Font=Enum.Font.GothamMedium,
    TextTruncate=Enum.TextTruncate.AtEnd},seedSelectRow)
corner(5,seedDropBtn)

local seedDropFrame = make("ScrollingFrame",{
    Size=UDim2.new(1,0,0,140),
    BackgroundColor3=Color3.fromRGB(18,18,28),BorderSizePixel=0,
    ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(130,80,220),
    CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
    Visible=false,ZIndex=10},scroll)
corner(6,seedDropFrame)
make("UIStroke",{Color=Color3.fromRGB(100,60,180),Thickness=1},seedDropFrame)
make("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder},seedDropFrame)

local function addDropOption(name, col)
    local b = make("TextButton",{
        Size=UDim2.new(1,0,0,24),
        BackgroundColor3=Color3.fromRGB(28,22,44),BorderSizePixel=0,
        Text="  "..name,TextColor3=col or Color3.fromRGB(200,200,200),
        TextSize=9,Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11},seedDropFrame)
    make("UIPadding",{PaddingLeft=UDim.new(0,4)},b)
    b.MouseEnter:Connect(function() tw(b,{BackgroundColor3=Color3.fromRGB(45,30,80)}) end)
    b.MouseLeave:Connect(function() tw(b,{BackgroundColor3=Color3.fromRGB(28,22,44)}) end)
    b.MouseButton1Click:Connect(function()
        selectedPlantSeed = (name == "(any)") and nil or name
        seedDropBtn.Text = name
        seedDropBtn.TextColor3 = (name == "(any)")
            and Color3.fromRGB(180,220,180) or Color3.fromRGB(220,180,255)
        seedDropFrame.Visible = false
    end)
end
addDropOption("(any)", Color3.fromRGB(150,230,150))
for _, s in ipairs(SEEDS) do addDropOption(s) end
seedDropBtn.MouseButton1Click:Connect(function()
    seedDropFrame.Visible = not seedDropFrame.Visible
end)

plantPosLabel = make("TextLabel",{
    Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,
    Text="Saved Positions: 0",
    TextColor3=Color3.fromRGB(150,120,220),TextSize=10,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left},scroll)

plantPosContainer = make("Frame",{
    Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
    BackgroundColor3=Color3.fromRGB(18,18,26),BorderSizePixel=0},scroll)
corner(5,plantPosContainer)
make("UIPadding",{PaddingLeft=UDim.new(0,5),PaddingRight=UDim.new(0,5),
    PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)},plantPosContainer)
make("UIListLayout",{Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder},plantPosContainer)

makeBtn(scroll,"📍 Save Current Position (stand on soil spot)",
    Color3.fromRGB(30,90,40), function()
        local root = getRoot()
        if root then
            local pos = root.Position
            table.insert(plantPositions,{
                x=pos.X, y=pos.Y-3, z=pos.Z,
                label=selectedPlantSeed or "any"
            })
            rebuildPosList()
            print("[Plant] Saved #"..#plantPositions)
        end
    end)

makeBtn(scroll,"🗑️ Clear All Saved Positions",
    Color3.fromRGB(90,25,25), function()
        plantPositions = {}
        rebuildPosList()
    end)

sectionLabel(scroll,"🪴 AUTO HARVEST")
makeToggleRow(scroll,"Enable Auto Harvest (warps to your garden first)",
    function(v) autoHarvest=v end)
local harvestDelayBox = makeInputRow(scroll,"Harvest cycle delay (sec):",5)

sectionLabel(scroll,"💰 AUTO SELL ALL")
makeToggleRow(scroll,"Enable Auto Sell All (warps to sell area)",
    function(v) autoSell=v end)
local sellDelayBox = makeInputRow(scroll,"Sell cycle delay (sec):",8)

-- STATUS
sectionLabel(scroll,"📊 STATUS")
local statusFrame = make("Frame",{Size=UDim2.new(1,0,0,50),
    BackgroundColor3=Color3.fromRGB(18,18,28),BorderSizePixel=0},scroll)
corner(6,statusFrame)
make("UIStroke",{Color=Color3.fromRGB(70,40,130),Thickness=1},statusFrame)
make("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingTop=UDim.new(0,6)},statusFrame)
make("UIListLayout",{Padding=UDim.new(0,2)},statusFrame)
local gardenStatus = make("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
    Text="Garden: Searching...",
    TextColor3=Color3.fromRGB(180,180,200),TextSize=9,Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left},statusFrame)
local systemStatus = make("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
    Text="Active: None",
    TextColor3=Color3.fromRGB(180,180,200),TextSize=9,Font=Enum.Font.GothamMedium,
    TextXAlignment=Enum.TextXAlignment.Left},statusFrame)

-- TOGGLE KEY
sectionLabel(scroll,"⌨️ TOGGLE KEY")
local keyRow = make("Frame",{Size=UDim2.new(1,0,0,36),
    BackgroundColor3=Color3.fromRGB(22,22,32),BorderSizePixel=0},scroll)
corner(6,keyRow)
make("UIStroke",{Color=Color3.fromRGB(70,40,130),Thickness=1},keyRow)
make("TextLabel",{Size=UDim2.new(0.55,0,1,0),Position=UDim2.new(0,12,0,0),
    BackgroundTransparency=1,Text="GUI Toggle Key:",
    TextColor3=Color3.fromRGB(215,215,215),TextSize=11,Font=Enum.Font.GothamBold,
    TextXAlignment=Enum.TextXAlignment.Left},keyRow)
local keyBtn = make("TextButton",{Size=UDim2.new(0,130,0,24),
    Position=UDim2.new(1,-136,0.5,-12),
    BackgroundColor3=Color3.fromRGB(45,20,90),BorderSizePixel=0,
    Text="RightShift",TextColor3=Color3.fromRGB(220,180,255),
    TextSize=10,Font=Enum.Font.GothamBold},keyRow)
corner(5,keyBtn)
make("UIStroke",{Color=Color3.fromRGB(130,80,220),Thickness=1},keyBtn)
keyBtn.MouseButton1Click:Connect(function()
    if isBindingKey then return end
    isBindingKey = true
    keyBtn.Text = "[ Press any key... ]"
    keyBtn.TextColor3 = Color3.fromRGB(255,220,80)
    local conn
    conn = UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if inp.UserInputType == Enum.UserInputType.Keyboard then
            toggleKey = inp.KeyCode
            keyBtn.Text = inp.KeyCode.Name
            keyBtn.TextColor3 = Color3.fromRGB(220,180,255)
            isBindingKey = false
            conn:Disconnect()
        end
    end)
end)

local footer = make("Frame",{Size=UDim2.new(1,0,0,30),
    Position=UDim2.new(0,0,1,-30),
    BackgroundColor3=Color3.fromRGB(10,10,16),BorderSizePixel=0},main)
make("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
    Text="⚡ Demonser Hub v5  |  Drag to move  |  ✕ or key to close",
    TextColor3=Color3.fromRGB(100,70,160),TextSize=8,Font=Enum.Font.Code,
    TextXAlignment=Enum.TextXAlignment.Center},footer)

UserInputService.InputBegan:Connect(function(inp, gp)
    if gp or isBindingKey then return end
    if inp.KeyCode == toggleKey then main.Visible = not main.Visible end
end)

-- ===================================================
-- BACKGROUND LOOPS (no 'continue' keyword used)
-- ===================================================

-- STATUS UPDATE
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            local plot = getMyPlotModel()
            if plot then
                gardenStatus.Text = "Garden: Found ("..plot.Name..")"
                gardenStatus.TextColor3 = Color3.fromRGB(100,220,100)
            else
                gardenStatus.Text = "Garden: Not found (stand near your plot)"
                gardenStatus.TextColor3 = Color3.fromRGB(220,120,80)
            end
            local active = {}
            if autoBuySeed then table.insert(active,"BuySeed") end
            if autoBuyPet  then table.insert(active,"BuyPet") end
            if autoPlant   then table.insert(active,"Plant") end
            if autoHarvest then table.insert(active,"Harvest") end
            if autoSell    then table.insert(active,"Sell") end
            systemStatus.Text = "Active: "..(#active > 0 and table.concat(active,", ") or "None")
            systemStatus.TextColor3 = #active > 0
                and Color3.fromRGB(100,220,100) or Color3.fromRGB(180,180,180)
        end)
    end
end)

-- AUTO BUY SEED
task.spawn(function()
    while task.wait(0.5) do
        if autoBuySeed and not seedBusy then
            local hasAny = false
            for _ in pairs(selectedSeeds) do hasAny = true break end
            if hasAny then
                seedBusy = true
                local qty   = tonumber(seedQtyBox.Text)   or 1
                local delay = tonumber(seedDelayBox.Text)  or 3
                for seedName in pairs(selectedSeeds) do
                    if not autoBuySeed then break end
                    buySeed(seedName, qty)
                    task.wait(0.5)
                    webhook("Seed Purchased",
                        "**"..seedName.."** x"..qty.." — attempt sent!", 3066993)
                    task.wait(delay)
                end
                seedBusy = false
            end
        end
    end
end)

-- AUTO BUY PET
task.spawn(function()
    while task.wait(0.5) do
        if autoBuyPet and not petBusy then
            local hasAny = false
            for _ in pairs(selectedPets) do hasAny = true break end
            if hasAny then
                petBusy = true
                local delay = tonumber(petDelayBox.Text) or 3
                local spawnFolder = workspace:FindFirstChild("Map")
                    and workspace.Map:FindFirstChild("WildPetSpawns")
                if spawnFolder then
                    for _, model in ipairs(spawnFolder:GetChildren()) do
                        if not autoBuyPet then break end
                        if model:IsA("Model") then
                            local mLow = model.Name:lower()
                            for petName in pairs(selectedPets) do
                                if mLow:find(petSearch(petName)) then
                                    local root = model:FindFirstChild("RootPart")
                                    if root then
                                        local pp = root:FindFirstChild("BuyPrompt")
                                        if pp and pp:IsA("ProximityPrompt") then
                                            local hrp = getRoot()
                                            if hrp then
                                                hrp.CFrame = CFrame.new(root.Position + Vector3.new(0,3,0))
                                                task.wait(0.3)
                                            end
                                            if fireproximityprompt then
                                                pcall(fireproximityprompt, pp)
                                            else
                                                pcall(function()
                                                    local pps = game:GetService("ProximityPromptService")
                                                    pps:PromptButtonHoldBegin(pp)
                                                    task.wait(0.2)
                                                    pps:PromptButtonHoldEnd(pp)
                                                end)
                                            end
                                            webhook("Pet Tamed",
                                                "**"..petName.."** tame attempt sent!", 16750848)
                                            task.wait(delay)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                petBusy = false
            end
        end
    end
end)

-- AUTO PLANT
task.spawn(function()
    while true do
        local delay = tonumber(plantDelayBox.Text) or 5
        task.wait(delay)
        if autoPlant and not plantBusy then
            plantBusy = true
            pcall(doAutoPlant)
            plantBusy = false
        end
    end
end)

-- AUTO HARVEST
task.spawn(function()
    while true do
        local delay = tonumber(harvestDelayBox.Text) or 5
        task.wait(delay)
        if autoHarvest and not harvestBusy then
            harvestBusy = true
            pcall(doAutoHarvest)
            harvestBusy = false
        end
    end
end)

-- AUTO SELL
task.spawn(function()
    while true do
        local delay = tonumber(sellDelayBox.Text) or 8
        task.wait(delay)
        if autoSell and not sellBusy then
            sellBusy = true
            pcall(doAutoSell)
            sellBusy = false
        end
    end
end)

print("[ ⚡ Demonser Hub v5 Fixed ] Loaded! Press "..toggleKey.Name.." to toggle")
