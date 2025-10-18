-- Anti-múltipla execução (DEVE SER A PRIMEIRA LINHA DO ARQUIVO)
local alreadyLoaded
if getgenv then
    alreadyLoaded = getgenv()._YORIICHIMENU_LOADED
    if not alreadyLoaded then getgenv()._YORIICHIMENU_LOADED = true end
else
    alreadyLoaded = _G._YORIICHIMENU_LOADED
    if not alreadyLoaded then _G._YORIICHIMENU_LOADED = true end
end
if alreadyLoaded then return end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    while not LocalPlayer do
        RunService.Heartbeat:Wait()
        LocalPlayer = Players.LocalPlayer
    end
end
local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")

if getgenv then
    getgenv()._YORIICHIMENU_HITBOX_STATUS = getgenv()._YORIICHIMENU_HITBOX_STATUS or { ["1_2_5"] = false, ["Boss3"] = false }
else
    _G._YORIICHIMENU_HITBOX_STATUS = _G._YORIICHIMENU_HITBOX_STATUS or { ["1_2_5"] = false, ["Boss3"] = false }
end
local sharedHitboxStatus = (getgenv and getgenv()._YORIICHIMENU_HITBOX_STATUS) or _G._YORIICHIMENU_HITBOX_STATUS

local sg = Instance.new("ScreenGui")
sg.Name = "YoriichiMenuUI"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.Parent = playerGui

local HitboxEvent = Instance.new("BindableEvent")
HitboxEvent.Name = "_Yoriichi_HitboxEvent"
HitboxEvent.Parent = sg

local function Notify(msg)
    pcall(function() print("[Yoriichi Menu]: " .. msg) end)
end

local function newUICornerGui(parent, radius)
    radius = radius or UDim.new(0,16)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius
    c.Parent = parent
    return c
end
local function newUIStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(0,0,0)
    s.Thickness = thickness or 2
    s.Parent = parent
    return s
end
local function styleButton(btn, colorBase, colorHover, colorDown, textBase, textHover)
    btn.BackgroundColor3 = colorBase
    btn.TextColor3 = textBase
    btn.AutoButtonColor = false
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = colorHover
        btn.TextColor3 = textHover
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = colorBase
        btn.TextColor3 = textBase
    end)
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = colorDown
    end)
    btn.MouseButton1Up:Connect(function()
        if btn.IsMouseOver and btn:IsMouseOver() then
            btn.BackgroundColor3 = colorHover
        else
            btn.BackgroundColor3 = colorBase
        end
    end)
end
local function makeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input == dragInput) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local mainWidth, mainHeight = 480, 300
local main = Instance.new("Frame")
main.Name = "MainWindow"
main.Size = UDim2.fromOffset(mainWidth, mainHeight)
main.Position = UDim2.new(0.5, -mainWidth/2, 0.45, -mainHeight/2)
main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.Active = true
main.Parent = sg

local mainBg = Instance.new("Frame", main)
mainBg.Size = UDim2.fromScale(1, 1)
mainBg.BackgroundColor3 = Color3.fromRGB(67, 9, 17)
mainBg.BorderSizePixel = 0
newUICornerGui(mainBg, UDim.new(0, 18))
newUIStroke(mainBg, Color3.fromRGB(30,10,12), 2)

local title = Instance.new("TextLabel", mainBg)
title.Text = "Yoriichi Menu"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.TextXAlignment = Enum.TextXAlignment.Center
spawn(function()
    local t = 0
    while title and title.Parent do
        title.TextColor3 = Color3.fromHSV((t % 1), 0.8, 1)
        t = t + 0.01
        RunService.Heartbeat:Wait()
    end
end)

local tabBar = Instance.new("Frame", mainBg)
tabBar.Name = "TabBar"
tabBar.Size = UDim2.new(1, -20, 0, 28)
tabBar.Position = UDim2.new(0, 10, 0, 45)
tabBar.BackgroundTransparency = 1
tabBar.BorderSizePixel = 0

local tabNames = {"Universal", "Lootblox"}
local tabButtons = {}
local selectedTab = 1
local function createPage(name)
    local frame = Instance.new("Frame", mainBg)
    frame.Name = name.."Page"
    frame.Size = UDim2.new(1, -20, 1, -110)
    frame.Position = UDim2.new(0, 10, 0, 73)
    frame.BackgroundColor3 = Color3.fromRGB(97, 11, 33)
    newUICornerGui(frame, UDim.new(0, 16))
    frame.Visible = false
    frame.Active = true
    return frame
end

local universalPage = createPage("Universal")
local lootbloxPage = createPage("Lootblox")
universalPage.Visible = true

local function selectTab(idx)
    selectedTab = idx
    for i, btn in ipairs(tabButtons) do
        if i == idx then
            btn.BackgroundColor3 = Color3.fromRGB(180,34,59)
            btn.TextColor3 = Color3.fromRGB(255,255,255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(97,11,33)
            btn.TextColor3 = Color3.fromRGB(220,220,220)
        end
    end
    universalPage.Visible = (idx == 1)
    lootbloxPage.Visible = (idx == 2)
end

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabBar)
    btn.Name = name.."TabBtn"
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 20
    btn.Size = UDim2.new(0.48, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.5 + 0.01, 0, 0, 0)
    btn.BorderSizePixel = 0
    btn.ZIndex = 11
    btn.Active = true
    newUICornerGui(btn, UDim.new(1,0))
    styleButton(btn, Color3.fromRGB(97,11,33), Color3.fromRGB(180,34,59), Color3.fromRGB(150,17,40), Color3.fromRGB(220,220,220), Color3.fromRGB(255,255,255))
    btn.MouseButton1Click:Connect(function() selectTab(i) end)
    tabButtons[i] = btn
end

makeDraggable(main)
makeDraggable(mainBg)

local cleanupConnections = {}
local function cleanupAll()
    if getgenv then getgenv()._YORIICHIMENU_LOADED = nil else _G._YORIICHIMENU_LOADED = nil end
    for _, c in ipairs(cleanupConnections) do
        pcall(function() c:Disconnect() end)
    end
    cleanupConnections = {}
    if _G._YoriichiHitboxManager and type(_G._YoriichiHitboxManager.Destroy) == "function" then
        pcall(function() _G._YoriichiHitboxManager.Destroy() end)
        _G._YoriichiHitboxManager = nil
    end
end

local closeBtn = Instance.new("TextButton", mainBg)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 24
closeBtn.Size = UDim2.new(0,38,0,30)
closeBtn.Position = UDim2.new(1, -46, 0, 8)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 100
closeBtn.Active = true
newUICornerGui(closeBtn, UDim.new(1, 0))
newUIStroke(closeBtn, Color3.fromRGB(97,11,33), 1)
styleButton(closeBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

local minBtn = Instance.new("TextButton", mainBg)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 24
minBtn.Size = UDim2.new(0,38,0,30)
minBtn.Position = UDim2.new(1, -90, 0, 8)
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 100
minBtn.Active = true
newUICornerGui(minBtn, UDim.new(1, 0))
newUIStroke(minBtn, Color3.fromRGB(67, 9, 17), 1)
styleButton(minBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

closeBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if sg and sg.Parent then sg:Destroy() end
        cleanupAll()
    end)
end)

minBtn.MouseButton1Click:Connect(function()
    if sg:FindFirstChild("MiniWindow") then
        sg:FindFirstChild("MiniWindow"):Destroy()
        main.Visible = true
        main.Position = UDim2.new(0.5, -mainWidth/2, 0.45, -mainHeight/2)
        return
    end
    main.Visible = false
    local mini = Instance.new("Frame", sg)
    mini.Name = "MiniWindow"
    mini.Size = UDim2.new(0,48,0,48)
    mini.Position = UDim2.new(0, 40, 0.7, 0)
    mini.BackgroundColor3 = Color3.fromRGB(180, 34, 59)
    mini.BorderSizePixel = 0
    newUICornerGui(mini, UDim.new(0, 14))
    newUIStroke(mini, Color3.fromRGB(67, 9, 17), 2)
    local miniImage = Instance.new("ImageButton", mini)
    miniImage.Size = UDim2.new(1,0,1,0)
    miniImage.BackgroundTransparency = 1
    miniImage.Image = "rbxassetid://72447234301333"
    miniImage.AutoButtonColor = true
    newUICornerGui(miniImage, UDim.new(1,0))
    miniImage.MouseButton1Up:Connect(function() if mini and mini.Parent then mini:Destroy() end main.Visible = true end)
end)

local runBtn = Instance.new("TextButton", universalPage)
runBtn.Name = "RunFastBtn"
runBtn.Text = "Correr Rápido"
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 18
runBtn.Size = UDim2.new(0.8, 0, 0, 36)
runBtn.Position = UDim2.new(0.1, 0, 0, 16)
styleButton(runBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
newUICornerGui(runBtn, UDim.new(0, 7))
newUIStroke(runBtn, Color3.fromRGB(67, 9, 17), 2)

local jumpBtn = Instance.new("TextButton", universalPage)
jumpBtn.Name = "JumpHighBtn"
jumpBtn.Text = "Pular Alto"
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 18
jumpBtn.Size = UDim2.new(0.8, 0, 0, 36)
jumpBtn.Position = UDim2.new(0.1, 0, 0, 64)
styleButton(jumpBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
newUICornerGui(jumpBtn, UDim.new(0, 7))
newUIStroke(jumpBtn, Color3.fromRGB(67, 9, 17), 2)

local fastActive = false
local jumpActive = false
local origValues = {}

local function applyMovementToHumanoid(humanoid)
    if not humanoid then return end
    local char = humanoid.Parent
    if not char then return end
    local id = tostring(char)
    origValues[id] = origValues[id] or {WalkSpeed = humanoid.WalkSpeed, JumpPower = humanoid.JumpPower}
    humanoid.WalkSpeed = fastActive and 65 or (origValues[id].WalkSpeed or 16)
    humanoid.JumpPower = jumpActive and 170 or (origValues[id].JumpPower or 50)
end

runBtn.MouseButton1Click:Connect(function()
    fastActive = not fastActive
    runBtn.Text = fastActive and "Correr Rápido (ON)" or "Correr Rápido"
    Notify(fastActive and "Velocidade aumentada!" or "Velocidade normal!")
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then applyMovementToHumanoid(hum) end
end)

jumpBtn.MouseButton1Click:Connect(function()
    jumpActive = not jumpActive
    jumpBtn.Text = jumpActive and "Pular Alto (ON)" or "Pular Alto"
    Notify(jumpActive and "Pulo MUITO aumentado!" or "Pulo normalizado!")
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then applyMovementToHumanoid(hum) end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    applyMovementToHumanoid(hum)
end)
if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
    applyMovementToHumanoid(LocalPlayer.Character:FindFirstChildClass("Humanoid"))
end

local HitboxManager = {}
do
    local hitboxStatus = sharedHitboxStatus
    local hitboxSizes = { ["1_2_5"] = Vector3.new(36,36,36), ["Boss3"] = Vector3.new(1000,1000,1000) }
    local defaultSize = Vector3.new(2,2,1)
    local hrpData = setmetatable({}, { __mode = "k" })
    local descendantAddedConn, descendantRemovingConn

    local function ensureOrigSizeTag(hrp)
        local tag = hrp:FindFirstChild("_YoriichiOrigSize")
        if tag and tag:IsA("Vector3Value") then return tag end
        local v = Instance.new("Vector3Value")
        v.Name = "_YoriichiOrigSize"
        v.Value = hrp.Size
        v.Parent = hrp
        return v
    end

    local function createVisual(hrp, key)
        if not hrp or not hrp.Parent then return end
        if hrpData[hrp] then return end
        local tag = ensureOrigSizeTag(hrp)
        local targetSize = hitboxSizes[key] or hrp.Size
        hrp.Size = targetSize
        local part = Instance.new("Part")
        part.Name = "_YoriichiHitboxVisual"
        part.Size = hrp.Size
        part.Transparency = 0.5
        part.Color = Color3.fromRGB(0,255,0)
        part.Anchored = false
        part.CanCollide = false
        part.Massless = true
        part.Parent = hrp
        part.CFrame = hrp.CFrame
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = hrp
        weld.Part1 = part
        weld.Parent = hrp
        local sizeConn = hrp:GetPropertyChangedSignal("Size"):Connect(function()
            if part and part.Parent then
                part.Size = hrp.Size
            end
        end)
        hrpData[hrp] = { key = key, origTag = tag, visual = part, sizeConn = sizeConn }
    end

    local function removeVisual(hrp)
        local data = hrpData[hrp]
        if not data then return end
        if data.origTag and data.origTag:IsA("Vector3Value") then
            hrp.Size = data.origTag.Value or defaultSize
            pcall(function() data.origTag:Destroy() end)
        else
            hrp.Size = defaultSize
        end
        if data.sizeConn then pcall(function() data.sizeConn:Disconnect() end) end
        if data.visual and data.visual.Parent then pcall(function() data.visual:Destroy() end) end
        hrpData[hrp] = nil
    end

    local function applyToggleForKey(key, enabled)
        hitboxStatus[key] = enabled
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj and obj.Name == key and obj:FindFirstChild("HumanoidRootPart") then
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                if enabled then
                    createVisual(hrp, key)
                else
                    removeVisual(hrp)
                end
            end
        end
        pcall(function() HitboxEvent:Fire(key, enabled) end)
    end

    descendantAddedConn = Workspace.DescendantAdded:Connect(function(desc)
        if not desc then return end
        if desc.Name == "HumanoidRootPart" and desc.Parent and hitboxStatus[desc.Parent.Name] then
            createVisual(desc, desc.Parent.Name)
            return
        end
        if desc:IsA("Model") and hitboxStatus[desc.Name] and desc:FindFirstChild("HumanoidRootPart") then
            createVisual(desc:FindFirstChild("HumanoidRootPart"), desc.Name)
            return
        end
    end)

    descendantRemovingConn = Workspace.DescendantRemoving:Connect(function(desc)
        if not desc then return end
        if desc.Name == "HumanoidRootPart" then
            removeVisual(desc)
        end
    end)

    HitboxManager.Toggle = function(key, enabled)
        applyToggleForKey(key, enabled)
    end

    HitboxManager.GetStatus = function()
        local s = {}
        for k, v in pairs(hitboxStatus) do s[k] = v end
        return s
    end

    HitboxManager.Destroy = function()
        if descendantAddedConn then pcall(function() descendantAddedConn:Disconnect() end) end
        if descendantRemovingConn then pcall(function() descendantRemovingConn:Disconnect() end) end
        for hrp, _ in pairs(hrpData) do
            pcall(function() removeVisual(hrp) end)
        end
        hrpData = {}
    end

    _G._YoriichiHitboxManager = HitboxManager
end

local overlay
local function createOverlay()
    if overlay and overlay.Parent then return overlay end
    overlay = Instance.new("TextButton", sg)
    overlay.Name = "Yoriichi_DropdownOverlay"
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.ZIndex = 80
    overlay.AutoButtonColor = false
    overlay.Text = ""
    overlay.Visible = false
    return overlay
end
createOverlay()

local openDropdown = nil
local function closeOpenDropdown()
    if openDropdown then
        if openDropdown.frame and openDropdown.frame.Parent then
            openDropdown.frame.Visible = false
        end
        if openDropdown.toggleBtn and openDropdown.toggleBtn.Parent then
            openDropdown.toggleBtn.Text = openDropdown.title .. " ▼"
        end
        if overlay and overlay.Parent then overlay.Visible = false end
        openDropdown = nil
    end
end

local function createMultiDropdown(parent, title, options, yPos)
    local container = {}
    container.title = title

    local btn = Instance.new("TextButton", parent)
    btn.Text = title .. " ▼"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 18
    btn.Size = UDim2.new(0.8, 0, 0, 36)
    btn.Position = UDim2.new(0.1, 0, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(180,34,59)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    newUICornerGui(btn, UDim.new(0, 7))
    newUIStroke(btn, Color3.fromRGB(67, 9, 17), 2)
    styleButton(btn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

    local frame = Instance.new("Frame", parent)
    frame.Visible = false
    frame.BackgroundColor3 = Color3.fromRGB(97, 11, 33)
    frame.Size = UDim2.new(0.8, 0, 0, math.min(#options * 44, 200))
    frame.Position = UDim2.new(0.1, 0, 0, yPos + 40)
    frame.BorderSizePixel = 0
    newUICornerGui(frame, UDim.new(0, 7))
    newUIStroke(frame, Color3.fromRGB(67, 9, 17), 2)
    frame.ClipsDescendants = true
    frame.ZIndex = 100

    local scroll = Instance.new("ScrollingFrame", frame)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.CanvasSize = UDim2.new(0, 0, 0, #options * 44)
    scroll.ScrollBarThickness = 6
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local listLayout = Instance.new("UIListLayout", scroll)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)

    local itemRefs = {}
    local clickDebounce = {}

    local function refreshIndicator(key, indicator)
        local status = (HitboxManager and HitboxManager.GetStatus and HitboxManager.GetStatus()[key]) or sharedHitboxStatus[key]
        if indicator and indicator.Parent then
            indicator.BackgroundColor3 = status and Color3.new(0,1,0) or Color3.fromRGB(60,60,60)
        end
    end

    for i, opt in ipairs(options) do
        local item = Instance.new("Frame", scroll)
        item.LayoutOrder = i
        item.Size = UDim2.new(1, -8, 0, 40)
        item.BackgroundTransparency = 1

        local btnItem = Instance.new("TextButton", item)
        btnItem.Size = UDim2.new(1, -8, 1, 0)
        btnItem.Position = UDim2.new(0, 4, 0, 0)
        btnItem.BackgroundColor3 = Color3.fromRGB(180,34,59)
        btnItem.Text = ""
        btnItem.Font = Enum.Font.Gotham
        btnItem.TextSize = 17
        btnItem.BorderSizePixel = 0
        newUICornerGui(btnItem, UDim.new(1,0))
        styleButton(btnItem, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

        local indicator = Instance.new("Frame", btnItem)
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(0, 10, 0.5, -8)
        indicator.BorderSizePixel = 0
        newUICornerGui(indicator, UDim.new(1,0))
        indicator.BackgroundColor3 = Color3.fromRGB(60,60,60)

        local lbl = Instance.new("TextLabel", btnItem)
        lbl.Size = UDim2.new(1, -44, 1, 0)
        lbl.Position = UDim2.new(0, 36, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = opt.label or opt.key
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 16
        lbl.TextColor3 = Color3.fromRGB(255,255,255)
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        btnItem.MouseButton1Click:Connect(function()
            if clickDebounce[opt.key] then return end
            clickDebounce[opt.key] = true
            delay(0.08, function() clickDebounce[opt.key] = nil end)
            local current = (HitboxManager and HitboxManager.GetStatus and HitboxManager.GetStatus()[opt.key]) or sharedHitboxStatus[opt.key]
            if HitboxManager and HitboxManager.Toggle then
                HitboxManager.Toggle(opt.key, not current)
            else
                sharedHitboxStatus[opt.key] = not current
                pcall(function() HitboxEvent:Fire(opt.key, not current) end)
            end
        end)

        itemRefs[opt.key] = { indicator = indicator, label = lbl }
        refreshIndicator(opt.key, indicator)
    end

    local hitEventConn = HitboxEvent.Event:Connect(function(key, enabled)
        if itemRefs[key] and itemRefs[key].indicator then
            itemRefs[key].indicator.BackgroundColor3 = enabled and Color3.new(0,1,0) or Color3.fromRGB(60,60,60)
        end
    end)
    table.insert(cleanupConnections, hitEventConn)

    btn.MouseButton1Click:Connect(function()
        if openDropdown and openDropdown ~= container then
            closeOpenDropdown()
        end
        frame.Visible = not frame.Visible
        btn.Text = title .. (frame.Visible and " ▲" or " ▼")
        if frame.Visible then
            openDropdown = { rootFrame = frame, toggleBtn = btn, title = title }
            local o = createOverlay()
            if o then
                o.Visible = true
                o.ZIndex = 90
                if o:IsDescendantOf(sg) then
                    local conn = o.MouseButton1Click:Connect(function()
                        closeOpenDropdown()
                        if conn then pcall(function() conn:Disconnect() end) end
                    end)
                    table.insert(cleanupConnections, conn)
                end
            end
        else
            if overlay then overlay.Visible = false end
            openDropdown = nil
        end
    end)

    container.toggleBtn = btn
    container.frame = frame
    container.rootFrame = parent

    return container
end

createMultiDropdown(lootbloxPage, "Expandir Hitbox", {
    {key="1_2_5", label="Aranha"},
    {key="Boss3", label="Boss Aranha"}
}, 18)

main.Visible = false
wait(0.10)
main.Visible = true
main.Position = UDim2.new(0.5, -mainWidth/2, 0.45, -mainHeight/2)
selectTab(1)
Notify("Script adaptado para Delta/mobile carregado — pronto para uso.")
