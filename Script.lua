local Config = {
    -- ===== ใส่ข้อมูลของคุณตรงนี้ =====
    ApiKey          = "ff1ec911-0290-43fe-8dfe-ca72a68a275b", 
    ServiceId       = "supertoplopper", 

    MainScriptURL   = "loadstring(game:HttpGet("https://vss.pandauth.com/virtual/file/577fd986e7fb478d"))()",            
    Secret          = "Code",           

    KeyFileName     = "LopperKey.txt",
    HubName         = "Project-Lopper",
    HubDescription  = "Lopper Hub Key System",

    ShowDiscord     = false,
    DiscordURL      = "",
}

-------------------------------------------------------------------------------
-- CORE
-------------------------------------------------------------------------------
local function safeRequest(options)
    local req = request or http_request or (http and http.request)
    if not req then return nil end
    local ok, res = pcall(function() return req(options) end)
    return ok and res or nil
end

local fSetClipboard = setclipboard or toclipboard or function() end
local fGetHwid = gethwid or function()
    return game:GetService("RbxAnalyticsService"):GetClientId()
end

-- Pandauth v3 API base
local BASE = "https://pandauth.com/api/v1"

-- GET KEY LINK
local function getKeyLink()
    local res = safeRequest({
        Url = BASE .. "/getkey?service=" .. Config.ServiceId .. "&hwid=" .. fGetHwid(),
        Method = "GET",
        Headers = { ["x-api-key"] = Config.ApiKey }
    })
    if res and res.StatusCode == 200 then
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(res.Body)
        end)
        if ok and data and data.url then
            return true, data.url
        end
    end
    -- fallback: direct getkey page
    return true, "https://pandauth.com/getkey?service=" .. Config.ServiceId .. "&hwid=" .. fGetHwid()
end

-- VERIFY KEY
local function verifyKey(key)
    local HttpService = game:GetService("HttpService")
    local res = safeRequest({
        Url = BASE .. "/verify",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["x-api-key"] = Config.ApiKey
        },
        Body = HttpService:JSONEncode({
            service  = Config.ServiceId,
            key      = key,
            hwid     = fGetHwid()
        })
    })

    if res and res.StatusCode == 200 then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(res.Body)
        end)
        if ok and data then
            if data.valid == true or data.success == true then
                if writefile then writefile(Config.KeyFileName, key) end
                return true, "Success"
            end
            return false, data.message or "Invalid Key"
        end
    elseif res and res.StatusCode == 401 then
        return false, "Key Expired or Invalid"
    elseif res and res.StatusCode == 403 then
        return false, "HWID Mismatch"
    end
    return false, "Server Error (" .. tostring(res and res.StatusCode or "No Response") .. ")"
end

-- RUN MAIN SCRIPT
local function StartMainScript()
    _G[Config.Secret] = true
    loadstring(game:HttpGet(Config.MainScriptURL))()
end

-------------------------------------------------------------------------------
-- GUI
-------------------------------------------------------------------------------
local function CreateGUI()
    local player = game:GetService("Players").LocalPlayer
    local gui = game:GetService("CoreGui")

    if gui:FindFirstChild("PandaKeySystem") then
        gui.PandaKeySystem:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui", gui)
    ScreenGui.Name = "PandaKeySystem"
    ScreenGui.ResetOnSpawn = false

    -- Main Frame
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 340, 0, 220)
    Main.Position = UDim2.new(0.5, -170, 0.5, -110)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    Main.Active = true
    Main.Draggable = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = Color3.fromRGB(40, 40, 60)
    stroke.Thickness = 1.5

    -- Title
    local Title = Instance.new("Frame", Main)
    Title.Size = UDim2.new(1, 0, 0, 48)
    Title.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)
    -- fix bottom corners of title
    Instance.new("Frame", Title).Size = UDim2.new(1,0,0,12)
    Main:FindFirstChild("Frame").Position = UDim2.new(0,0,1,-12)
    Main:FindFirstChild("Frame").BackgroundColor3 = Color3.fromRGB(18,18,28)
    Main:FindFirstChild("Frame").BorderSizePixel = 0

    -- accent line
    local accent = Instance.new("Frame", Title)
    accent.Size = UDim2.new(1, 0, 0, 2)
    accent.Position = UDim2.new(0, 0, 1, -1)
    accent.BackgroundColor3 = Color3.fromRGB(60, 100, 220)
    accent.BorderSizePixel = 0

    -- Rainbow accent
    task.spawn(function()
        while accent and accent.Parent do
            accent.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            task.wait()
        end
    end)

    local TitleLabel = Instance.new("TextLabel", Title)
    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 14, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Config.HubName
    TitleLabel.TextColor3 = Color3.fromRGB(220, 225, 255)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Close
    local CloseBtn = Instance.new("TextButton", Title)
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -14)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 60, 60)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Description
    local Desc = Instance.new("TextLabel", Main)
    Desc.Size = UDim2.new(1, -28, 0, 28)
    Desc.Position = UDim2.new(0, 14, 0, 54)
    Desc.BackgroundTransparency = 1
    Desc.Text = Config.HubDescription
    Desc.TextColor3 = Color3.fromRGB(80, 90, 130)
    Desc.TextSize = 11
    Desc.Font = Enum.Font.GothamMedium
    Desc.TextXAlignment = Enum.TextXAlignment.Left

    -- Key Input
    local InputBg = Instance.new("Frame", Main)
    InputBg.Size = UDim2.new(1, -28, 0, 40)
    InputBg.Position = UDim2.new(0, 14, 0, 88)
    InputBg.BackgroundColor3 = Color3.fromRGB(20, 20, 32)
    InputBg.BorderSizePixel = 0
    Instance.new("UICorner", InputBg).CornerRadius = UDim.new(0, 8)
    local istroke = Instance.new("UIStroke", InputBg)
    istroke.Color = Color3.fromRGB(50, 60, 100)
    istroke.Thickness = 1

    local KeyBox = Instance.new("TextBox", InputBg)
    KeyBox.Size = UDim2.new(1, -16, 1, 0)
    KeyBox.Position = UDim2.new(0, 8, 0, 0)
    KeyBox.BackgroundTransparency = 1
    KeyBox.PlaceholderText = "PANDA-XXXX-XXXX-XXXX"
    KeyBox.PlaceholderColor3 = Color3.fromRGB(50, 58, 90)
    KeyBox.Text = ""
    KeyBox.TextColor3 = Color3.fromRGB(200, 210, 255)
    KeyBox.TextSize = 13
    KeyBox.Font = Enum.Font.GothamBold
    KeyBox.ClearTextOnFocus = true

    -- Buttons
    local VerifyBtn = Instance.new("TextButton", Main)
    VerifyBtn.Size = UDim2.new(0.48, -7, 0, 36)
    VerifyBtn.Position = UDim2.new(0, 14, 0, 136)
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
    VerifyBtn.Text = "VERIFY"
    VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyBtn.TextSize = 13
    VerifyBtn.Font = Enum.Font.GothamBold
    VerifyBtn.BorderSizePixel = 0
    Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 8)

    local GetKeyBtn = Instance.new("TextButton", Main)
    GetKeyBtn.Size = UDim2.new(0.48, -7, 0, 36)
    GetKeyBtn.Position = UDim2.new(0.52, 0, 0, 136)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    GetKeyBtn.Text = "GET KEY"
    GetKeyBtn.TextColor3 = Color3.fromRGB(180, 190, 230)
    GetKeyBtn.TextSize = 13
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.BorderSizePixel = 0
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", GetKeyBtn).Color = Color3.fromRGB(50, 60, 100)

    -- Status
    local Status = Instance.new("TextLabel", Main)
    Status.Size = UDim2.new(1, -28, 0, 24)
    Status.Position = UDim2.new(0, 14, 0, 182)
    Status.BackgroundTransparency = 1
    Status.Text = "กรอก key แล้วกด Verify"
    Status.TextColor3 = Color3.fromRGB(80, 90, 120)
    Status.TextSize = 11
    Status.Font = Enum.Font.GothamMedium
    Status.TextXAlignment = Enum.TextXAlignment.Center

    -- TweenService
    local TweenService = game:GetService("TweenService")
    local function tw(obj, props)
        TweenService:Create(obj, TweenInfo.new(0.15), props):Play()
    end

    VerifyBtn.MouseEnter:Connect(function() tw(VerifyBtn, {BackgroundColor3=Color3.fromRGB(70,120,240)}) end)
    VerifyBtn.MouseLeave:Connect(function() tw(VerifyBtn, {BackgroundColor3=Color3.fromRGB(50,100,220)}) end)
    GetKeyBtn.MouseEnter:Connect(function() tw(GetKeyBtn, {BackgroundColor3=Color3.fromRGB(35,35,55)}) end)
    GetKeyBtn.MouseLeave:Connect(function() tw(GetKeyBtn, {BackgroundColor3=Color3.fromRGB(25,25,40)}) end)

    -- VERIFY LOGIC
    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyBox.Text
        if key == "" then
            Status.Text = "กรอก key ก่อนนะครับ!"
            Status.TextColor3 = Color3.fromRGB(255, 150, 50)
            return
        end
        Status.Text = "กำลัง verify..."
        Status.TextColor3 = Color3.fromRGB(150, 150, 200)
        VerifyBtn.Text = "..."

        task.spawn(function()
            local success, msg = verifyKey(key)
            if success then
                Status.Text = "✅ สำเร็จ! กำลังโหลด..."
                Status.TextColor3 = Color3.fromRGB(50, 220, 100)
                task.wait(0.8)
                ScreenGui:Destroy()
                StartMainScript()
            else
                Status.Text = "❌ " .. tostring(msg)
                Status.TextColor3 = Color3.fromRGB(255, 60, 60)
                VerifyBtn.Text = "VERIFY"
            end
        end)
    end)

    -- GET KEY LOGIC
    GetKeyBtn.MouseButton1Click:Connect(function()
        Status.Text = "กำลังดึงลิงก์..."
        Status.TextColor3 = Color3.fromRGB(150, 150, 200)
        task.spawn(function()
            local success, link = getKeyLink()
            if success then
                fSetClipboard(link)
                Status.Text = "✅ Copy ลิงก์แล้ว! วางในบราวเซอร์"
                Status.TextColor3 = Color3.fromRGB(50, 170, 255)
            else
                Status.Text = "❌ ดึงลิงก์ไม่ได้"
                Status.TextColor3 = Color3.fromRGB(255, 60, 60)
            end
        end)
    end)

    -- AUTO LOGIN จากไฟล์ที่บันทึกไว้
    if isfile and isfile(Config.KeyFileName) then
        local saved = readfile(Config.KeyFileName)
        if saved and saved ~= "" then
            Status.Text = "🔄 พบ key ที่บันทึกไว้ กำลังตรวจสอบ..."
            Status.TextColor3 = Color3.fromRGB(150, 150, 200)
            task.spawn(function()
                local success, msg = verifyKey(saved)
                if success then
                    Status.Text = "✅ Auto-login สำเร็จ!"
                    Status.TextColor3 = Color3.fromRGB(50, 220, 100)
                    task.wait(0.5)
                    ScreenGui:Destroy()
                    StartMainScript()
                else
                    Status.Text = "Key หมดอายุ กรอกใหม่ได้เลย"
                    Status.TextColor3 = Color3.fromRGB(255, 150, 50)
                end
            end)
        end
    end
end

CreateGUI()
