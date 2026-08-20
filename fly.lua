-- 手机飞行菜单（带UI按钮）
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

-- ========== 配置 ==========
local flying = false
local currentSpeed = 1
local flySpeeds = {39, 50, 100, 500, 2000}
local flySpeed = flySpeeds[currentSpeed]

local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000

-- ========== 创建UI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyMenu"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- 主按钮（圆形，红色，半透明）
local mainBtn = Instance.new("ImageButton")
mainBtn.Size = UDim2.new(0, 60, 0, 60)
mainBtn.Position = UDim2.new(0.85, -30, 0.15, 0)
mainBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
mainBtn.BackgroundTransparency = 0.2
mainBtn.BorderSizePixel = 0
mainBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = mainBtn

local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, 0, 1, 0)
btnText.BackgroundTransparency = 1
btnText.Text = "飞"
btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
btnText.TextSize = 24
btnText.Font = Enum.Font.GothamBold
btnText.Parent = mainBtn

-- ========== 菜单面板 ==========
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 220, 0, 280)
menu.Position = UDim2.new(0.5, -110, 0.5, -140)
menu.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
menu.BackgroundTransparency = 0.05
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menu

-- 标题
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "飞行控制"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = menu

-- 飞行开关按钮
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.8, 0, 0, 45)
toggleBtn.Position = UDim2.new(0.1, 0, 0, 50)
toggleBtn.Text = "飞行: 关闭"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.BorderSizePixel = 0
toggleBtn.Parent = menu

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleBtn

-- 速度显示
local speedText = Instance.new("TextLabel")
speedText.Size = UDim2.new(0.8, 0, 0, 30)
speedText.Position = UDim2.new(0.1, 0, 0, 105)
speedText.BackgroundTransparency = 1
speedText.Text = "速度: 1档 (39)"
speedText.TextColor3 = Color3.fromRGB(200, 200, 200)
speedText.TextSize = 16
speedText.Font = Enum.Font.Gotham
speedText.Parent = menu

-- 速度档位按钮（5个横向排列）
local speedContainer = Instance.new("Frame")
speedContainer.Size = UDim2.new(0.9, 0, 0, 40)
speedContainer.Position = UDim2.new(0.05, 0, 0, 140)
speedContainer.BackgroundTransparency = 1
speedContainer.Parent = menu

local speedBtns = {}
for i = 1, 5 do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.18, 0, 1, 0)
    btn.Position = UDim2.new((i-1)*0.2, 0, 0, 0)
    btn.Text = i .. "档"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    btn.BorderSizePixel = 0
    btn.TextSize = 12
    btn.Parent = speedContainer
    
    local btnCorner2 = Instance.new("UICorner")
    btnCorner2.CornerRadius = UDim.new(0, 4)
    btnCorner2.Parent = btn
    
    speedBtns[i] = btn
    
    btn.MouseButton1Click:Connect(function()
        currentSpeed = i
        flySpeed = flySpeeds[currentSpeed]
        speedText.Text = "速度: " .. currentSpeed .. "档 (" .. flySpeed .. ")"
        
        for j, b in pairs(speedBtns) do
            if j == currentSpeed then
                b.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
            else
                b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            end
        end
        
        if flying then
            print("[飞行] 速度切换至 " .. flySpeed)
        end
    end)
end
speedBtns[1].BackgroundColor3 = Color3.fromRGB(255, 100, 0)

-- 关闭菜单按钮（×）
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = menu

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeBtn

-- ========== 功能逻辑 ==========
-- 开关菜单
local menuOpen = false
mainBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menu.Visible = menuOpen
end)

-- 关闭按钮
closeBtn.MouseButton1Click:Connect(function()
    menu.Visible = false
    menuOpen = false
end)

-- 飞行开关
toggleBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        humanoid.PlatformStand = true
        bodyVelocity.Parent = rootPart
        toggleBtn.Text = "飞行: 开启"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        humanoid.PlatformStand = false
        bodyVelocity.Parent = nil
        toggleBtn.Text = "飞行: 关闭"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    end
end)

-- 拖动主按钮
local dragging = false
local dragStart, btnStart

mainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        btnStart = mainBtn.Position
    end
end)

mainBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        mainBtn.Position = UDim2.new(btnStart.X.Scale, btnStart.X.Offset + delta.X, btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
    end
end)

-- ========== 移动控制 ==========
local function getMoveDirection()
    local camera = workspace.CurrentCamera
    local moveDir = Vector3.new(0, 0, 0)
    
    local camForward = camera.CFrame.LookVector
    local camRight = camera.CFrame.RightVector
    camForward = Vector3.new(camForward.X, 0, camForward.Z).Unit
    camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
    
    local stick = humanoid.MoveDirection
    if stick.Magnitude > 0.1 then
        moveDir = camForward * stick.Z + camRight * stick.X
    end
    
    local lookY = camera.CFrame.LookVector.Y
    if math.abs(lookY) > 0.15 then
        moveDir = moveDir + Vector3.new(0, -lookY, 0)
    end
    
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * flySpeed
    end
    return moveDir
end

rs.RenderStepped:Connect(function()
    if flying then
        bodyVelocity.Velocity = getMoveDirection()
    end
end)

print("✅ 飞行菜单加载完成！点击屏幕上的红色【飞】按钮")
