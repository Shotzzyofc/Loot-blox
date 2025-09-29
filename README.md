-- Proteção anti-múltipla execução (sempre PRIMEIRA LINHA)
local alreadyLoaded
if getgenv then
    alreadyLoaded = getgenv()._YORIICHIMENU_LOADED
    if not alreadyLoaded then getgenv()._YORIICHIMENU_LOADED = true end
else
    alreadyLoaded = _G._YORIICHIMENU_LOADED
    if not alreadyLoaded then _G._YORIICHIMENU_LOADED = true end
end
if alreadyLoaded then return end

-- Serviços principais
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- UI sempre no PlayerGui (Delta Mobile)
local sg = Instance.new("ScreenGui")
sg.Name = "YoriichiMenuUI"
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui

local function Notify(msg)
    print("[Yoriichi Menu]: "..msg)
end

-- Utilitários UI
local function newUICorner(parent, radius)
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
local function animateRGB(label)
    spawn(function()
        local t = 0
        while label and label.Parent do
            label.TextColor3 = Color3.fromHSV((t % 1), 0.8, 1)
            t = t + 0.01
            RunService.Heartbeat:Wait()
        end
    end)
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
        if btn:IsMouseOver() then
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

-- Main UI
local mainWidth, mainHeight = 480, 270
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
newUICorner(mainBg, UDim.new(0, 22))
newUIStroke(mainBg, Color3.fromRGB(30,10,12), 2)

local grad = Instance.new("UIGradient", mainBg)
grad.Rotation = 90
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(180, 34, 59)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(97, 11, 33)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(67, 9, 17))
})

local title = Instance.new("TextLabel", mainBg)
title.Text = "Yoriichi Menu"
title.Size = UDim2.new(1, 0, 0, 40)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 32
title.TextXAlignment = Enum.TextXAlignment.Center
animateRGB(title)

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
    frame.Size = UDim2.new(1, -20, 1, -91)
    frame.Position = UDim2.new(0, 10, 0, 73)
    frame.BackgroundColor3 = Color3.fromRGB(97, 11, 33)
    newUICorner(frame, UDim.new(0, 17))
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
    newUICorner(btn, UDim.new(1,0))
    styleButton(btn, Color3.fromRGB(97,11,33), Color3.fromRGB(180,34,59), Color3.fromRGB(150,17,40), Color3.fromRGB(220,220,220), Color3.fromRGB(255,255,255))
    btn.MouseButton1Click:Connect(function() selectTab(i) end)
    tabButtons[i] = btn
end

makeDraggable(main)
makeDraggable(mainBg)

-- Botão FECHAR (X)
local closeBtn = Instance.new("TextButton", mainBg)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 26
closeBtn.Size = UDim2.new(0,38,0,30)
closeBtn.Position = UDim2.new(1, -46, 0, 10)
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 100
closeBtn.Active = true
newUICorner(closeBtn, UDim.new(1, 0))
newUIStroke(closeBtn, Color3.fromRGB(97,11,33), 1)
styleButton(closeBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

closeBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if sg and sg.Parent then sg:Destroy() end
        if getgenv then getgenv()._YORIICHIMENU_LOADED = nil else _G._YORIICHIMENU_LOADED = nil end
        -- Remove partes hitbox se fechar
        for _, part in pairs(workspace:GetDescendants()) do
            if part:IsA("Part") and part.Name == "_YoriichiHitboxVisual" then
                part:Destroy()
            end
        end
    end)
end)

-- Botão MINIMIZAR (-)
local minBtn = Instance.new("TextButton", mainBg)
minBtn.Text = "-"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 26
minBtn.Size = UDim2.new(0,38,0,30)
minBtn.Position = UDim2.new(1, -90, 0, 10)
minBtn.BorderSizePixel = 0
minBtn.ZIndex = 100
minBtn.Active = true
newUICorner(minBtn, UDim.new(1, 0))
newUIStroke(minBtn, Color3.fromRGB(67, 9, 17), 1)
styleButton(minBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

-- Mini ícone
local imageUrl = "rbxassetid://72447234301333"
local miniPos = UDim2.new(0, 40, 0.7, 0)
local miniFrame = nil
local function createMiniWindow()
    if sg:FindFirstChild("MiniWindow") then return sg:FindFirstChild("MiniWindow") end
    miniFrame = Instance.new("Frame", sg)
    miniFrame.Name = "MiniWindow"
    miniFrame.Size = UDim2.new(0,48,0,48)
    miniFrame.Position = miniPos
    miniFrame.BackgroundColor3 = Color3.fromRGB(180, 34, 59)
    miniFrame.BorderSizePixel = 0
    newUICorner(miniFrame, UDim.new(0, 14))
    newUIStroke(miniFrame, Color3.fromRGB(67, 9, 17), 2)
    miniFrame.ZIndex = 999

    local miniImage = Instance.new("ImageButton", miniFrame)
    miniImage.Size = UDim2.new(1,0,1,0)
    miniImage.Position = UDim2.new(0,0,0,0)
    miniImage.BackgroundTransparency = 1
    miniImage.Image = imageUrl
    miniImage.ZIndex = 1000
    miniImage.AutoButtonColor = true
    newUICorner(miniImage, UDim.new(1,0))

    -- Drag mobile/PC
    local dragging, dragStart, startPos, moved
    local function beginDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = miniFrame.Position
        moved = false
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            miniFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
            miniPos = miniFrame.Position
            moved = true
        end
    end
    local function connectDraggable(guiObject)
        guiObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                beginDrag(input)
            end
        end)
        guiObject.InputChanged:Connect(updateDrag)
    end
    connectDraggable(miniFrame)
    connectDraggable(miniImage)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)
    local function tryOpen()
        if moved then return end
        if sg:FindFirstChild("MiniWindow") then sg:FindFirstChild("MiniWindow"):Destroy() end
        main.Visible = true
        main.Position = UDim2.new(0.5, -mainWidth/2, 0.45, -mainHeight/2)
    end
    miniImage.MouseButton1Up:Connect(tryOpen)
    miniImage.TouchTap:Connect(tryOpen)
    return miniFrame
end

minBtn.MouseButton1Click:Connect(function()
    if sg:FindFirstChild("MiniWindow") then
        sg:FindFirstChild("MiniWindow"):Destroy()
        main.Visible = true
        main.Position = UDim2.new(0.5, -mainWidth/2, 0.45, -mainHeight/2)
        return
    end
    main.Visible = false
    local mini = createMiniWindow()
    mini.Position = miniPos
end)

-- Universal funções (Correr/Pular)
local runBtn = Instance.new("TextButton", universalPage)
runBtn.Name = "RunFastBtn"
runBtn.Text = "Correr Rápido"
runBtn.Font = Enum.Font.GothamBold
runBtn.TextSize = 18
runBtn.Size = UDim2.new(0.8, 0, 0, 36)
runBtn.Position = UDim2.new(0.1, 0, 0, 20)
styleButton(runBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255, 80, 80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
runBtn.BorderSizePixel = 0
newUICorner(runBtn, UDim.new(0, 7))
newUIStroke(runBtn, Color3.fromRGB(67, 9, 17), 2)

local jumpBtn = Instance.new("TextButton", universalPage)
jumpBtn.Name = "JumpHighBtn"
jumpBtn.Text = "Pular Alto"
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 18
jumpBtn.Size = UDim2.new(0.8, 0, 0, 36)
jumpBtn.Position = UDim2.new(0.1, 0, 0, 68)
styleButton(jumpBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255, 80, 80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))
jumpBtn.BorderSizePixel = 0
newUICorner(jumpBtn, UDim.new(0, 7))
newUIStroke(jumpBtn, Color3.fromRGB(67, 9, 17), 2)

local fastActive = false
local jumpActive = false
local origWalkSpeed = 16
local origJumpPower = 50

local function setSpeed(enable)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if enable then
            origWalkSpeed = humanoid.WalkSpeed or origWalkSpeed
            humanoid.WalkSpeed = 65
        else
            humanoid.WalkSpeed = origWalkSpeed or 16
        end
    end
end
local function setJump(enable)
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if enable then
            origJumpPower = humanoid.JumpPower or origJumpPower
            humanoid.JumpPower = 170
        else
            humanoid.JumpPower = origJumpPower or 50
        end
    end
end
runBtn.MouseButton1Click:Connect(function()
    fastActive = not fastActive
    setSpeed(fastActive)
    runBtn.Text = fastActive and "Correr Rápido (ON)" or "Correr Rápido"
    Notify(fastActive and "Velocidade aumentada!" or "Velocidade normal!")
end)
jumpBtn.MouseButton1Click:Connect(function()
    jumpActive = not jumpActive
    setJump(jumpActive)
    jumpBtn.Text = jumpActive and "Pular Alto (ON)" or "Pular Alto"
    Notify(jumpActive and "Pulo MUITO aumentado!" or "Pulo normalizado!")
end)
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    setSpeed(fastActive)
    setJump(jumpActive)
end)

-- Lootblox: Dropdown múltiplo e hitbox visual sincronizada
local hitboxStatus = { ["1_2_5"] = false, ["Boss3"] = false }
-- Aranha: 36x maior, Boss: 1000x1000x1000
local hitboxSizes = { ["1_2_5"] = Vector3.new(36, 36, 36), ["Boss3"] = Vector3.new(1000, 1000, 1000) }
local defaultSize = Vector3.new(2, 2, 1)

local function updateHitboxParts()
    -- Remove partes antigas
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("Part") and part.Name == "_YoriichiHitboxVisual" then
            part:Destroy()
        end
    end
    for npc, enabled in pairs(hitboxStatus) do
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == npc and obj:FindFirstChild("HumanoidRootPart") then
                local hrp = obj.HumanoidRootPart
                if enabled then
                    hrp.Size = hitboxSizes[npc]
                    local part = Instance.new("Part")
                    part.Anchored = false
                    part.CanCollide = false
                    part.Massless = true
                    part.Transparency = 0.5
                    part.Color = Color3.new(0,1,0)
                    part.Size = hrp.Size
                    part.Name = "_YoriichiHitboxVisual"
                    part.CFrame = hrp.CFrame
                    part.Parent = hrp
                    local weld = Instance.new("WeldConstraint")
                    weld.Part0 = hrp
                    weld.Part1 = part
                    weld.Parent = hrp
                else
                    hrp.Size = defaultSize
                end
            end
        end
    end
end
spawn(function()
    while true do
        for npc, enabled in pairs(hitboxStatus) do
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == npc and obj:FindFirstChild("HumanoidRootPart") then
                    for _, part in pairs(obj.HumanoidRootPart:GetChildren()) do
                        if part:IsA("Part") and part.Name == "_YoriichiHitboxVisual" then
                            part.Size = obj.HumanoidRootPart.Size
                            part.CFrame = obj.HumanoidRootPart.CFrame
                        end
                    end
                end
            end
        end
        updateHitboxParts()
        wait(0.4)
    end
end)

local function createMultiDropdown(parent, title, options, yPos)
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
    newUICorner(btn, UDim.new(0, 7))
    newUIStroke(btn, Color3.fromRGB(67, 9, 17), 2)
    styleButton(btn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

    local frame = Instance.new("Frame", parent)
    frame.Visible = false
    frame.BackgroundColor3 = Color3.fromRGB(97, 11, 33)
    frame.Size = UDim2.new(0.8, 0, 0, #options * 42)
    frame.Position = UDim2.new(0.1, 0, 0, yPos + 38)
    frame.BorderSizePixel = 0
    newUICorner(frame, UDim.new(0, 7))
    newUIStroke(frame, Color3.fromRGB(67, 9, 17), 2)
    frame.ClipsDescendants = true

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", frame)
        optBtn.Text = opt.label
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 17
        optBtn.Size = UDim2.new(1, 0, 0, 40)
        optBtn.Position = UDim2.new(0, 0, 0, (i-1)*42)
        optBtn.BackgroundColor3 = Color3.fromRGB(180,34,59)
        optBtn.TextColor3 = Color3.fromRGB(255,255,255)
        optBtn.BorderSizePixel = 0
        newUICorner(optBtn, UDim.new(1,0))
        styleButton(optBtn, Color3.fromRGB(180,34,59), Color3.fromRGB(255,80,80), Color3.fromRGB(120,0,0), Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255))

        -- Bolinha verde
        local indicator = Instance.new("Frame", optBtn)
        indicator.Name = "Indicator"
        indicator.Size = UDim2.new(0, 16, 0, 16)
        indicator.Position = UDim2.new(0, 10, 0.5, -8)
        indicator.BackgroundColor3 = hitboxStatus[opt.key] and Color3.new(0,1,0) or Color3.fromRGB(60,60,60)
        indicator.BorderSizePixel = 0
        newUICorner(indicator, UDim.new(1,0))
        local function updateIndicator()
            indicator.BackgroundColor3 = hitboxStatus[opt.key] and Color3.new(0,1,0) or Color3.fromRGB(60,60,60)
        end
        optBtn.MouseButton1Click:Connect(function()
            hitboxStatus[opt.key] = not hitboxStatus[opt.key]
            updateIndicator()
            Notify((hitboxStatus[opt.key] and "Hitbox ativada para " or "Hitbox desativada de ")..opt.label.."!")
        end)
    end
    btn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        btn.Text = title .. (frame.Visible and " ▲" or " ▼")
    end)
end

createMultiDropdown(lootbloxPage, "Expandir Hitbox", {
    {key="1_2_5", label="Aranha"},
    {key="Boss3", label="Boss Aranha"}
}, 20)

main.Visible = false
wait(0.10)
main.Visible = true
main.Position = UDim2.new(0.5, -mainWidth/2, 0.45, -mainHeight/2)
selectTab(1)
Notify("Script carregado corretamente — pronto para uso!")
