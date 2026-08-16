-- [[ PREMIUM MONOCHROME ENGINE v15.0 - ULTIMATE EXPANSION ]]
-- discord.gg/cVbT942MMJ

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local UI = Instance.new("ScreenGui")
UI.Name = "MonochromeEngine"
UI.ResetOnSpawn = false
UI.ZIndexBehavior = Enum.ZIndexBehavior.Global
UI.DisplayOrder = 2147483647
UI.Parent = CoreGui

-- Eski kalıntıları temizle
if CoreGui:FindFirstChild("MonochromeEngine") and CoreGui.MonochromeEngine ~= UI then CoreGui.MonochromeEngine:Destroy() end
if _G.MonoCircle then _G.MonoCircle:Remove() end
if _G.ESPCache then 
    for _, cache in pairs(_G.ESPCache) do
        if cache.Box then cache.Box:Remove() end
        if cache.Lines then for _, line in pairs(cache.Lines) do line:Remove() end end
        if cache.Tracer then cache.Tracer:Remove() end
        if cache.NameTxt then cache.NameTxt:Remove() end
    end
end
if _G.CounterText then _G.CounterText:Remove() end

local Config = {
    Enabled = false,
    -- AIMBOT
    TargetMode = "Players",
    FriendCheck = false,    
    TeamCheck = false,      
    TargetPart = "Head",
    Smoothness = 0.12,
    WallCheck = false,
    FOVCheck = false,
    FOVRadius = 130,
    MenuKey = Enum.KeyCode.T, -- Default'u T yaptık
    LockKey = Enum.UserInputType.MouseButton2,
    
    -- TRIGGERBOT (YENİ)
    TriggerBot = false,
    TriggerMode = "Single", -- Single, Hold
    
    -- ESP
    EspTargetMode = "Players",
    ShowTeam = false,
    ShowFriends = false,
    ChamsESP = false,
    BoxESP = false,
    SkeletonESP = false,
    TracerESP = false,
    NameESP = false,
    CounterESP = false,
    
    -- MISC / PLAYER (YENİ)
    WalkSpeedToggle = false,
    WalkSpeedValue = 25,
    InfJump = false,
    ThirdPerson = false
}

local Camera = Workspace.CurrentCamera
local Holding = false
local MenuOpen = true
local ListeningForMenuKey = false
local IsHoldingClick = false
local UI_FONT = Enum.Font.GothamBold
local TWEEN_INFO = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- STATÜ AYARI
local UserRole = "NORMAL MEMBER"
local RoleColor = Color3.fromRGB(150, 150, 155)

if LocalPlayer.Name == "wra10s" then
    UserRole = "ENGINE CO-OWNER / ADMIN"
    RoleColor = Color3.fromRGB(255, 60, 60)
end

-- FOV Çemberi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1.5
FOVCircle.NumSides = 100
FOVCircle.Filled = false
FOVCircle.Transparency = 0.6
_G.MonoCircle = FOVCircle

-- GUI SAYAÇ KUTUSU (ZIndex Fix uygulandı)
local CounterFrame = Instance.new("Frame")
CounterFrame.Size = UDim2.new(0, 220, 0, 32)
CounterFrame.Position = UDim2.new(0.5, -110, 0, 15)
CounterFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
CounterFrame.BorderSizePixel = 0
CounterFrame.ZIndex = 200
CounterFrame.Visible = false
CounterFrame.Parent = UI

Instance.new("UICorner", CounterFrame).CornerRadius = UDim.new(0, 6)
local CntStroke = Instance.new("UIStroke", CounterFrame)
CntStroke.Color = Color3.fromRGB(40, 40, 46)
CntStroke.Thickness = 1.2

local CounterLabel = Instance.new("TextLabel")
CounterLabel.Size = UDim2.new(1, 0, 1, 0)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Text = "RENDERED TARGETS : 0"
CounterLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
CounterLabel.Font = UI_FONT
CounterLabel.TextSize = 11
CounterLabel.ZIndex = 205 -- FIX BURADA: Text arkada kalmasın diye Frame'den yüksek
CounterLabel.Parent = CounterFrame

-- ESP CACHE SİSTEMİ
local ESP_Cache = {}
_G.ESPCache = ESP_Cache

local SkeletonConnections = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local function GetESPObj(player)
    if not ESP_Cache[player] then
        local box = Drawing.new("Square"); box.Thickness = 1.5; box.Color = Color3.fromRGB(255, 255, 255); box.Filled = false
        local tracer = Drawing.new("Line"); tracer.Thickness = 1.5; tracer.Color = Color3.fromRGB(255, 255, 255)
        local nameTxt = Drawing.new("Text"); nameTxt.Size = 14; nameTxt.Center = true; nameTxt.Outline = true; nameTxt.Color = Color3.fromRGB(255, 255, 255)
        local lines = {}
        for i = 1, #SkeletonConnections do
            local line = Drawing.new("Line"); line.Thickness = 1.5; line.Color = Color3.fromRGB(200, 200, 205); table.insert(lines, line)
        end
        ESP_Cache[player] = {Box = box, Lines = lines, Tracer = tracer, NameTxt = nameTxt, Highlight = nil}
    end
    return ESP_Cache[player]
end

local function ClearESPObj(player)
    if ESP_Cache[player] then
        ESP_Cache[player].Box:Remove(); ESP_Cache[player].Tracer:Remove(); ESP_Cache[player].NameTxt:Remove()
        for _, line in ipairs(ESP_Cache[player].Lines) do line:Remove() end
        if ESP_Cache[player].Highlight then ESP_Cache[player].Highlight:Destroy() end
        ESP_Cache[player] = nil
    end
end
Players.PlayerRemoving:Connect(ClearESPObj)

-- ANA ULTRA PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 680, 0, 520)
MainFrame.Position = UDim2.new(0.5, -340, 0.4, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.ZIndex = 100
MainFrame.Parent = UI

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new("UIStroke", MainFrame); MainStroke.Color = Color3.fromRGB(40, 40, 46); MainStroke.Thickness = 1.8

local TopBar = Instance.new("Frame"); TopBar.Size = UDim2.new(1, 0, 0, 44); TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 15); TopBar.ZIndex = 105; TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 16)
local TopBarLineFix = Instance.new("Frame"); TopBarLineFix.Size = UDim2.new(1, 0, 0, 14); TopBarLineFix.Position = UDim2.new(0, 0, 1, -14); TopBarLineFix.BackgroundColor3 = Color3.fromRGB(12, 12, 15); TopBarLineFix.BorderSizePixel = 0; TopBarLineFix.ZIndex = 106; TopBarLineFix.Parent = TopBar
local TopLine = Instance.new("Frame"); TopLine.Size = UDim2.new(1, 0, 0, 1); TopLine.Position = UDim2.new(0, 0, 1, 0); TopLine.BackgroundColor3 = Color3.fromRGB(24, 24, 28); TopLine.BorderSizePixel = 0; TopLine.ZIndex = 107; TopLine.Parent = TopBar

local TitleLabel = Instance.new("TextLabel"); TitleLabel.Size = UDim2.new(1, -20, 1, 0); TitleLabel.Position = UDim2.new(0, 22, 0, 0); TitleLabel.BackgroundTransparency = 1; TitleLabel.Text = "WRATHS MONOCHROME // CORE ENGINE v15.0"; TitleLabel.TextColor3 = Color3.fromRGB(250, 250, 255); TitleLabel.Font = UI_FONT; TitleLabel.TextSize = 12; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left; TitleLabel.ZIndex = 110; TitleLabel.Parent = TopBar

-- SÜRÜKLEME
local Dragging, DragInput, DragStart, StartPosition
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        Dragging = true; DragStart = input.Position; StartPosition = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == DragInput and Dragging then
        local Delta = input.Position - DragStart
        MainFrame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end
end)

local LeftPanel = Instance.new("Frame"); LeftPanel.Size = UDim2.new(0, 200, 1, -64); LeftPanel.Position = UDim2.new(0, 12, 0, 52); LeftPanel.BackgroundColor3 = Color3.fromRGB(11, 11, 13); LeftPanel.BorderSizePixel = 0; LeftPanel.ZIndex = 120; LeftPanel.Parent = MainFrame
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 12); Instance.new("UIStroke", LeftPanel).Color = Color3.fromRGB(22, 22, 26)

local AvatarImage = Instance.new("ImageLabel"); AvatarImage.Size = UDim2.new(0, 40, 0, 40); AvatarImage.Position = UDim2.new(0, 12, 0, 12); AvatarImage.BackgroundColor3 = Color3.fromRGB(18, 18, 22); AvatarImage.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=150&height=150&format=png"; AvatarImage.ZIndex = 130; AvatarImage.Parent = LeftPanel
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", AvatarImage).Color = Color3.fromRGB(38, 38, 44)

local UsernameLabel = Instance.new("TextLabel"); UsernameLabel.Size = UDim2.new(1, -65, 0, 16); UsernameLabel.Position = UDim2.new(0, 60, 0, 14); UsernameLabel.BackgroundTransparency = 1; UsernameLabel.Text = LocalPlayer.Name:upper(); UsernameLabel.TextColor3 = Color3.fromRGB(255, 255, 255); UsernameLabel.Font = UI_FONT; UsernameLabel.TextSize = 11; UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left; UsernameLabel.ZIndex = 130; UsernameLabel.Parent = LeftPanel

local UserStatus = Instance.new("TextLabel"); UserStatus.Size = UDim2.new(1, -65, 0, 12); UserStatus.Position = UDim2.new(0, 60, 0, 28); UserStatus.BackgroundTransparency = 1; UserStatus.Text = UserRole; UserStatus.TextColor3 = RoleColor; UserStatus.Font = Enum.Font.SourceSansBold; UserStatus.TextSize = 10; UserStatus.TextXAlignment = Enum.TextXAlignment.Left; UserStatus.ZIndex = 130; UserStatus.Parent = LeftPanel

local RightContainer = Instance.new("Frame"); RightContainer.Size = UDim2.new(1, -236, 1, -64); RightContainer.Position = UDim2.new(0, 224, 0, 52); RightContainer.BackgroundColor3 = Color3.fromRGB(11, 11, 13); RightContainer.BorderSizePixel = 0; RightContainer.ZIndex = 120; RightContainer.Parent = MainFrame
Instance.new("UICorner", RightContainer).CornerRadius = UDim.new(0, 12); Instance.new("UIStroke", RightContainer).Color = Color3.fromRGB(22, 22, 26)

local function CreatePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20); page.Position = UDim2.new(0, 10, 0, 10); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
    page.ScrollBarThickness = 2; page.ScrollBarImageColor3 = Color3.fromRGB(38, 38, 42); page.CanvasSize = UDim2.new(0, 0, 0, 600)
    page.Visible = false; page.ZIndex = 150; page.Parent = RightContainer
    return page
end

local AimbotPage = CreatePage(); AimbotPage.Visible = true
local CombatPage = CreatePage()
local PlayersPage = CreatePage()
local EspPage = CreatePage()
local MiscPage = CreatePage()

local function CreateTabButton(text, yOffset)
    local Btn = Instance.new("TextButton"); Btn.Size = UDim2.new(1, -24, 0, 36); Btn.Position = UDim2.new(0, 12, 0, yOffset); Btn.BackgroundColor3 = Color3.fromRGB(15, 15, 18); Btn.Text = "      " .. text; Btn.TextColor3 = Color3.fromRGB(130, 130, 135); Btn.Font = UI_FONT; Btn.TextSize = 10; Btn.TextXAlignment = Enum.TextXAlignment.Left; Btn.ZIndex = 135; Btn.Parent = LeftPanel
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8); local Stroke = Instance.new("UIStroke", Btn); Stroke.Color = Color3.fromRGB(24, 24, 28)
    local Indicator = Instance.new("Frame"); Indicator.Size = UDim2.new(0, 4, 0, 16); Indicator.Position = UDim2.new(0, 8, 0.5, -8); Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Indicator.BorderSizePixel = 0; Indicator.Visible = false; Indicator.ZIndex = 140; Indicator.Parent = Btn
    Btn.MouseEnter:Connect(function() if not Indicator.Visible then TweenService:Create(Btn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play(); TweenService:Create(Btn, TWEEN_INFO, {TextColor3 = Color3.fromRGB(200, 200, 205)}):Play() end end)
    Btn.MouseLeave:Connect(function() if not Indicator.Visible then TweenService:Create(Btn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(15, 15, 18)}):Play(); TweenService:Create(Btn, TWEEN_INFO, {TextColor3 = Color3.fromRGB(130, 130, 135)}):Play() end end)
    return Btn, Indicator, Stroke
end

local AimbotTabBtn, AimbotInd, AimbotStrk = CreateTabButton("AIMBOT CORE", 66)
local CombatTabBtn, CombatInd, CombatStrk = CreateTabButton("COMBAT & TRIGGER", 108)
local PlayersTabBtn, PlayersInd, PlayersStrk = CreateTabButton("TARGET FILTERS", 150)
local EspTabBtn, EspInd, EspStrk = CreateTabButton("VISUALS & ESP", 192)
local MiscTabBtn, MiscInd, MiscStrk = CreateTabButton("PLAYER & MISC", 234)

AimbotTabBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 26); AimbotTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255); AimbotInd.Visible = true; AimbotStrk.Color = Color3.fromRGB(45, 45, 52)

local function ResetTabs()
    local tabs = {
        {Btn = AimbotTabBtn, Ind = AimbotInd, Strk = AimbotStrk, Page = AimbotPage},
        {Btn = CombatTabBtn, Ind = CombatInd, Strk = CombatStrk, Page = CombatPage},
        {Btn = PlayersTabBtn, Ind = PlayersInd, Strk = PlayersStrk, Page = PlayersPage},
        {Btn = EspTabBtn, Ind = EspInd, Strk = EspStrk, Page = EspPage},
        {Btn = MiscTabBtn, Ind = MiscInd, Strk = MiscStrk, Page = MiscPage}
    }
    for _, t in ipairs(tabs) do
        t.Page.Visible = false; t.Ind.Visible = false
        TweenService:Create(t.Btn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(15, 15, 18)}):Play()
        TweenService:Create(t.Btn, TWEEN_INFO, {TextColor3 = Color3.fromRGB(130, 130, 135)}):Play()
        TweenService:Create(t.Strk, TWEEN_INFO, {Color = Color3.fromRGB(24, 24, 28)}):Play()
    end
end

local function ActivateTab(btn, ind, strk, page)
    ind.Visible = true
    TweenService:Create(btn, TWEEN_INFO, {BackgroundColor3 = Color3.fromRGB(22, 22, 26)}):Play()
    TweenService:Create(btn, TWEEN_INFO, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
    TweenService:Create(strk, TWEEN_INFO, {Color = Color3.fromRGB(45, 45, 52)}):Play()
    page.Visible = true
end

AimbotTabBtn.MouseButton1Click:Connect(function() ResetTabs(); ActivateTab(AimbotTabBtn, AimbotInd, AimbotStrk, AimbotPage) end)
CombatTabBtn.MouseButton1Click:Connect(function() ResetTabs(); ActivateTab(CombatTabBtn, CombatInd, CombatStrk, CombatPage) end)
PlayersTabBtn.MouseButton1Click:Connect(function() ResetTabs(); ActivateTab(PlayersTabBtn, PlayersInd, PlayersStrk, PlayersPage) end)
EspTabBtn.MouseButton1Click:Connect(function() ResetTabs(); ActivateTab(EspTabBtn, EspInd, EspStrk, EspPage) end)
MiscTabBtn.MouseButton1Click:Connect(function() ResetTabs(); ActivateTab(MiscTabBtn, MiscInd, MiscStrk, MiscPage) end)

local function AddToggle(parentTab, propName, labelText, yOffset)
    local FrameBlock = Instance.new("Frame"); FrameBlock.Size = UDim2.new(1, -10, 0, 44); FrameBlock.Position = UDim2.new(0, 0, 0, yOffset); FrameBlock.BackgroundColor3 = Color3.fromRGB(14, 14, 17); FrameBlock.BorderSizePixel = 0; FrameBlock.ZIndex = 160; FrameBlock.Parent = parentTab
    Instance.new("UICorner", FrameBlock).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", FrameBlock).Color = Color3.fromRGB(24, 24, 28)
    local Text = Instance.new("TextLabel"); Text.Size = UDim2.new(1, -80, 1, 0); Text.Position = UDim2.new(0, 16, 0, 0); Text.BackgroundTransparency = 1; Text.Text = labelText; Text.TextColor3 = Color3.fromRGB(235, 235, 240); Text.Font = Enum.Font.GothamMedium; Text.TextSize = 11; Text.TextXAlignment = Enum.TextXAlignment.Left; Text.ZIndex = 170; Text.Parent = FrameBlock
    local ToggleBtn = Instance.new("TextButton"); ToggleBtn.Size = UDim2.new(0, 58, 0, 26); ToggleBtn.Position = UDim2.new(1, -72, 0.5, -13); ToggleBtn.Font = UI_FONT; ToggleBtn.TextSize = 10; ToggleBtn.ZIndex = 180; ToggleBtn.Parent = FrameBlock
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6); local TglStroke = Instance.new("UIStroke", ToggleBtn)

    local function UpdateVisuals(anim)
        local targetBg = Config[propName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(20, 20, 24)
        local targetText = Config[propName] and Color3.fromRGB(8, 8, 10) or Color3.fromRGB(140, 140, 145)
        local targetStroke = Config[propName] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(36, 36, 42)
        ToggleBtn.Text = Config[propName] and "ON" or "OFF"
        if anim then
            TweenService:Create(ToggleBtn, TWEEN_INFO, {BackgroundColor3 = targetBg}):Play(); TweenService:Create(ToggleBtn, TWEEN_INFO, {TextColor3 = targetText}):Play(); TweenService:Create(TglStroke, TWEEN_INFO, {Color = targetStroke}):Play()
        else
            ToggleBtn.BackgroundColor3 = targetBg; ToggleBtn.TextColor3 = targetText; TglStroke.Color = targetStroke
        end
    end
    ToggleBtn.MouseButton1Click:Connect(function() Config[propName] = not Config[propName]; UpdateVisuals(true) end)
    UpdateVisuals(false)
end

local function AddSelector(parentTab, propName, labelText, options, yOffset)
    local FrameBlock = Instance.new("Frame"); FrameBlock.Size = UDim2.new(1, -10, 0, 44); FrameBlock.Position = UDim2.new(0, 0, 0, yOffset); FrameBlock.BackgroundColor3 = Color3.fromRGB(14, 14, 17); FrameBlock.BorderSizePixel = 0; FrameBlock.ZIndex = 160; FrameBlock.Parent = parentTab
    Instance.new("UICorner", FrameBlock).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", FrameBlock).Color = Color3.fromRGB(24, 24, 28)
    local Text = Instance.new("TextLabel"); Text.Size = UDim2.new(1, -140, 1, 0); Text.Position = UDim2.new(0, 16, 0, 0); Text.BackgroundTransparency = 1; Text.Text = labelText; Text.TextColor3 = Color3.fromRGB(235, 235, 240); Text.Font = Enum.Font.GothamMedium; Text.TextSize = 11; Text.TextXAlignment = Enum.TextXAlignment.Left; Text.ZIndex = 170; Text.Parent = FrameBlock
    local SelectBtn = Instance.new("TextButton"); SelectBtn.Size = UDim2.new(0, 120, 0, 26); SelectBtn.Position = UDim2.new(1, -134, 0.5, -13); SelectBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24); SelectBtn.Text = tostring(Config[propName]):upper(); SelectBtn.TextColor3 = Color3.fromRGB(225, 225, 230); SelectBtn.Font = UI_FONT; SelectBtn.TextSize = 9; SelectBtn.ZIndex = 180; SelectBtn.Parent = FrameBlock
    Instance.new("UICorner", SelectBtn).CornerRadius = UDim.new(0, 6); local SelStroke = Instance.new("UIStroke", SelectBtn); SelStroke.Color = Color3.fromRGB(36, 36, 42)

    local currentIndex = 1
    for i, v in ipairs(options) do if v == Config[propName] then currentIndex = i break end end
    SelectBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        Config[propName] = options[currentIndex]
        SelectBtn.Text = tostring(Config[propName]):upper(); SelectBtn.TextSize = 7
        TweenService:Create(SelectBtn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 9}):Play()
    end)
end

-- 1. Aimbot Page
AddToggle(AimbotPage, "Enabled", "Aimbot Master Core", 0)
AddToggle(AimbotPage, "WallCheck", "Wall Structural Check", 50)
AddToggle(AimbotPage, "FOVCheck", "Restrict Target With FOV", 100)
AddSelector(AimbotPage, "TargetPart", "Aim Locking Bone", {"Head", "HumanoidRootPart"}, 150)
AddSelector(AimbotPage, "Smoothness", "Locking Speed", {0.05, 0.10, 0.15, 0.25, 0.50, 1}, 200)
AddSelector(AimbotPage, "FOVRadius", "Radius Circle", {80, 130, 180, 250, 350}, 250)

-- MENU BIND
local BindBlock = Instance.new("Frame"); BindBlock.Size = UDim2.new(1, -10, 0, 44); BindBlock.Position = UDim2.new(0, 0, 0, 300); BindBlock.BackgroundColor3 = Color3.fromRGB(14, 14, 17); BindBlock.ZIndex = 160; BindBlock.Parent = AimbotPage
Instance.new("UICorner", BindBlock).CornerRadius = UDim.new(0, 8); Instance.new("UIStroke", BindBlock).Color = Color3.fromRGB(24, 24, 28)
local BindText = Instance.new("TextLabel"); BindText.Size = UDim2.new(1, -140, 1, 0); BindText.Position = UDim2.new(0, 16, 0, 0); BindText.BackgroundTransparency = 1; BindText.Text = "Menu Intercept Keybind"; BindText.TextColor3 = Color3.fromRGB(235, 235, 240); BindText.Font = Enum.Font.GothamMedium; BindText.TextSize = 11; BindText.TextXAlignment = Enum.TextXAlignment.Left; BindText.ZIndex = 170; BindText.Parent = BindBlock
local BindBtn = Instance.new("TextButton"); BindBtn.Size = UDim2.new(0, 120, 0, 26); BindBtn.Position = UDim2.new(1, -134, 0.5, -13); BindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24); BindBtn.Text = "[" .. Config.MenuKey.Name:upper() .. "]"; BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255); BindBtn.Font = UI_FONT; BindBtn.TextSize = 9; BindBtn.ZIndex = 180; BindBtn.Parent = BindBlock
Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6); Instance.new("UIStroke", BindBtn).Color = Color3.fromRGB(36, 36, 42)
BindBtn.MouseButton1Click:Connect(function() if not ListeningForMenuKey then ListeningForMenuKey = true; BindBtn.Text = "[...]" end end)

-- 2. Combat & Trigger Page (YENİ)
AddToggle(CombatPage, "TriggerBot", "Enable TriggerBot (Silent Aim)", 0)
AddSelector(CombatPage, "TriggerMode", "Trigger Fire Mode", {"Single", "Hold"}, 50)

-- 3. Players Page
AddSelector(PlayersPage, "TargetMode", "Aimbot Target Mode", {"NPC", "Players", "Both"}, 0)
AddToggle(PlayersPage, "FriendCheck", "Aimbot Ignore Friends", 50)
AddToggle(PlayersPage, "TeamCheck", "Aimbot Ignore Team", 100)

-- 4. ESP Page
AddSelector(EspPage, "EspTargetMode", "ESP Radar Mode", {"NPC", "Players", "Both"}, 0)
AddToggle(EspPage, "ShowTeam", "Show Team on ESP", 50)
AddToggle(EspPage, "ShowFriends", "Show Friends on ESP", 100)
AddToggle(EspPage, "NameESP", "Target Identity (Name)", 150)
AddToggle(EspPage, "ChamsESP", "Chams Highlight Outline", 200)
AddToggle(EspPage, "BoxESP", "2D Bounding Box ESP", 250)
AddToggle(EspPage, "TracerESP", "RootPart Tracers", 300)
AddToggle(EspPage, "SkeletonESP", "Skeleton Tracer ESP", 350)
AddToggle(EspPage, "CounterESP", "Rendered Target Counter", 400)

-- 5. Misc & Player Page (YENİ)
AddToggle(MiscPage, "WalkSpeedToggle", "Override WalkSpeed", 0)
AddSelector(MiscPage, "WalkSpeedValue", "WalkSpeed Multiplier", {16, 25, 35, 50, 75, 100, 150}, 50)
AddToggle(MiscPage, "InfJump", "Infinite Jump (Air Hop)", 100)
AddToggle(MiscPage, "ThirdPerson", "Force Third Person View", 150)


local function ToggleMenu()
    MenuOpen = not MenuOpen
    UI.Enabled = MenuOpen
    if not MenuOpen then
        FOVCircle.Visible = false
        Holding = false
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if ListeningForMenuKey and input.UserInputType == Enum.UserInputType.Keyboard then
        Config.MenuKey = input.KeyCode; BindBtn.Text = "[" .. input.KeyCode.Name:upper() .. "]"; ListeningForMenuKey = false; return
    end
    if input.KeyCode == Config.MenuKey then ToggleMenu(); return end
    
    -- Infinite Jump Logic
    if input.KeyCode == Enum.KeyCode.Space and Config.InfJump and not processed then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    
    if processed then return end
    if input.UserInputType == Config.LockKey then Holding = true end
end)

UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Config.LockKey then Holding = false end end)

-- TARGET MATH
local function IsVisible(targetPart)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new(); raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, targetPart.Parent}; raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    return Workspace:Raycast(origin, direction, raycastParams) == nil
end

local function ValidateTarget(model, mode, ignoreFriends, ignoreTeam)
    local targetPlayer = Players:GetPlayerFromCharacter(model)
    if mode == "NPC" and targetPlayer then return false end
    if mode == "Players" and not targetPlayer then return false end
    if model == LocalPlayer.Character then return false end
    if targetPlayer then
        if ignoreFriends and LocalPlayer:IsFriendsWith(targetPlayer.UserId) then return false end
        if ignoreTeam and targetPlayer.Team == LocalPlayer.Team then return false end
    end
    return true
end

local function GetClosestTarget()
    local closest, shortestDistance = nil, math.huge
    local currentTargets = {}
    if Config.TargetMode == "Players" or Config.TargetMode == "Both" then for _, p in ipairs(Players:GetPlayers()) do if p.Character then table.insert(currentTargets, p.Character) end end end
    if Config.TargetMode == "NPC" or Config.TargetMode == "Both" then for _, v in ipairs(Workspace:GetChildren()) do if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(v) then table.insert(currentTargets, v) end end end

    for _, obj in ipairs(currentTargets) do
        local humanoid = obj:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 and ValidateTarget(obj, Config.TargetMode, Config.FriendCheck, Config.TeamCheck) then
            local hitBox = obj:FindFirstChild(Config.TargetPart)
            if hitBox then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hitBox.Position)
                if onScreen then
                    local mouseDistance = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if (not Config.FOVCheck or mouseDistance <= Config.FOVRadius) and mouseDistance < shortestDistance and IsVisible(hitBox) then
                        shortestDistance = mouseDistance; closest = hitBox
                    end
                end
            end
        end
    end
    return closest
end

local function UpdateESP()
    local renderedCount = 0
    if not MenuOpen then
        for _, player in ipairs(Players:GetPlayers()) do
            if ESP_Cache[player] then
                local esp = ESP_Cache[player]
                esp.Box.Visible = false; esp.Tracer.Visible = false; esp.NameTxt.Visible = false
                for _, line in ipairs(esp.Lines) do line.Visible = false end
                if esp.Highlight then esp.Highlight.Enabled = false end
            end
        end
        CounterFrame.Visible = false
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local esp = GetESPObj(player)
            local character = player.Character
            local isValid = character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and ValidateTarget(character, Config.EspTargetMode, not Config.ShowFriends, not Config.ShowTeam)

            if isValid then
                renderedCount = renderedCount + 1
                local hrp = character.HumanoidRootPart
                local head = character:FindFirstChild("Head")
                local hrpPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

                if Config.ChamsESP then
                    if not esp.Highlight then
                        local h = Instance.new("Highlight"); h.Name = "MonoChams"; h.FillColor = Color3.fromRGB(200, 200, 255); h.OutlineColor = Color3.fromRGB(255, 255, 255); h.FillTransparency = 0.5; h.OutlineTransparency = 0; h.Parent = character
                        esp.Highlight = h
                    else esp.Highlight.Parent = character; esp.Highlight.Enabled = true end
                else if esp.Highlight then esp.Highlight:Destroy(); esp.Highlight = nil end end

                if onScreen then
                    if Config.BoxESP and head then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 2
                        esp.Box.Size = Vector2.new(width, height); esp.Box.Position = Vector2.new(hrpPos.X - width / 2, headPos.Y); esp.Box.Visible = true
                    else esp.Box.Visible = false end

                    if Config.TracerESP then
                        esp.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y); esp.Tracer.To = Vector2.new(hrpPos.X, hrpPos.Y); esp.Tracer.Visible = true
                    else esp.Tracer.Visible = false end

                    if Config.NameESP and head then
                        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
                        esp.NameTxt.Text = player.Name; esp.NameTxt.Position = Vector2.new(headPos.X, headPos.Y - 20); esp.NameTxt.Visible = true
                    else esp.NameTxt.Visible = false end

                    if Config.SkeletonESP then
                        for i, connection in ipairs(SkeletonConnections) do
                            local p1, p2 = character:FindFirstChild(connection[1]), character:FindFirstChild(connection[2])
                            if p1 and p2 then
                                local pos1, s1 = Camera:WorldToViewportPoint(p1.Position); local pos2, s2 = Camera:WorldToViewportPoint(p2.Position)
                                if s1 and s2 then esp.Lines[i].From = Vector2.new(pos1.X, pos1.Y); esp.Lines[i].To = Vector2.new(pos2.X, pos2.Y); esp.Lines[i].Visible = true
                                else esp.Lines[i].Visible = false end
                            else esp.Lines[i].Visible = false end
                        end
                    else for _, line in ipairs(esp.Lines) do line.Visible = false end end
                else
                    esp.Box.Visible = false; esp.Tracer.Visible = false; esp.NameTxt.Visible = false
                    for _, line in ipairs(esp.Lines) do line.Visible = false end
                end
            else
                esp.Box.Visible = false; esp.Tracer.Visible = false; esp.NameTxt.Visible = false
                for _, line in ipairs(esp.Lines) do line.Visible = false end
                if esp.Highlight then esp.Highlight:Destroy(); esp.Highlight = nil end
            end
        end
    end
    
    if Config.CounterESP then
        CounterLabel.Text = "RENDERED TARGETS : " .. tostring(renderedCount)
        CounterFrame.Visible = true
    else
        CounterFrame.Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    UpdateESP()
    
    -- MISC UPDATE LOGIC
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Config.WalkSpeedToggle then LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeedValue end
    end
    
    if Config.ThirdPerson then LocalPlayer.CameraMaxZoomDistance = 50; LocalPlayer.CameraMinZoomDistance = 10 
    else LocalPlayer.CameraMinZoomDistance = 0.5 end

    -- FOV CIRCLE UPDATE
    if Config.FOVCheck and Config.Enabled and MenuOpen then
        FOVCircle.Visible = true; FOVCircle.Position = UserInputService:GetMouseLocation(); FOVCircle.Radius = Config.FOVRadius
    else FOVCircle.Visible = false end

    -- AIMBOT & TRIGGERBOT LOGIC
    if Config.Enabled and Holding and MenuOpen then
        local target = GetClosestTarget()
        if target then
            local lookAtCFrame = CFrame.lookAt(Camera.CFrame.Position, target.Position)
            Camera.CFrame = Config.Smoothness < 1 and Camera.CFrame:Lerp(lookAtCFrame, Config.Smoothness) or lookAtCFrame
            
            -- TriggerBot Logic (Exploit-Specific Click functions required like mouse1press)
            if Config.TriggerBot then
                if Config.TriggerMode == "Single" and typeof(mouse1click) == "function" then
                    mouse1click()
                elseif Config.TriggerMode == "Hold" and typeof(mouse1press) == "function" and not IsHoldingClick then
                    mouse1press()
                    IsHoldingClick = true
                end
            end
        else
            -- Release Trigger if target lost
            if IsHoldingClick and typeof(mouse1release) == "function" then
                mouse1release()
                IsHoldingClick = false
            end
        end
    else
        -- Release Trigger if not holding aim key
        if IsHoldingClick and typeof(mouse1release) == "function" then
            mouse1release()
            IsHoldingClick = false
        end
    end
end)