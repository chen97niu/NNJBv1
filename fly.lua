-- 手机飞行脚本（宋体「本」字 + 彩色流光）
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local flying = false
local speed = 80
local bodyVel = Instance.new("BodyVelocity")
bodyVel.MaxForce = Vector3.new(1, 1, 1) * 100000

-- ========== 删除旧的UI ==========
if game:GetService("CoreGui"):FindFirstChild("FlyUI") then
    game:GetService("CoreGui"):FindFirstChild("FlyUI"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyUI"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

-- ========== 主按钮（宋体「本」字 + 彩色流光边框） ==========
local mainBtn = Instance.new("ImageButton")
mainBtn.Size = UDim2.new(0, 70, 0, 70)
mainBtn.Position = UDim2.new(0.85, -35, 0.15, 0)
mainBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainBtn.BackgroundTransparency = 0
mainBtn.BorderSizePixel = 0
mainBtn.Parent = screenGui

-- 圆角
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = mainBtn

-- 彩色流光边框（UIStroke）
local border = Instance.new("UIStroke")
border.Thickness = 3
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
border.Parent = mainBtn

-- 流光颜色动画
local colors = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 165, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 255, 255),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(255, 0, 255)
}
local colorIndex = 1
task.spawn(function()
    while screenGui and screenGui.Parent do
        colorIndex = colorIndex % #colors + 1
        border.Color = colors[colorIndex]
        task.wait(0.12)
    end
end)

-- 按钮文字（宋体「本」）
local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, 0, 1, 0)
btnText.BackgroundTransparency = 1
btnText.Text = "本"
btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
btnText.TextSize = 32
btnText.Font = Enum.Font.SourceSans  -- Roblox没有宋体，用SourceSans替代
btnText.TextScaled = true
btnText.Parent = mainBtn

-- ========== 菜单面板 ==========
local menu = Instance.new("Frame")
menu.Size = UDim2.new(0, 200, 0, 150)
menu.Position = UDim2.new(0.5, -100, 0.4, 0)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
menu.BackgroundTransparency = 0
menu.BorderSizePixel = 0
menu.Visible = false
menu.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menu

-- 菜单标题
local menuTitle = Instance.new("TextLabel")
menuTitle.Size = UDim2.new(1, 0, 0, 35)
menuTitle.BackgroundTransparency = 1
menuTitle.Text = "飞行控制"
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.TextSize = 18
menuTitle.Font = Enum.Font.GothamBold
menuTitle.Parent = menu

-- 飞行开关按钮（菜单里的功能）
local flyToggle = Instance.new("TextButton")
flyToggle.Size = UDim2.new(0.8, 0, 0, 45)
flyToggle.Position = UDim2.new(0.1, 0, 0, 45)
flyToggle.Text = "🛑 飞行: 关闭"
flyToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
flyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
flyToggle.BorderSizePixel = 0
flyToggle.Parent = menu

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = flyToggle

-- 关闭菜单按钮
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 95)
closeBtn.BorderSizePixel = 0
closeBtn.Parent = menu

local closeCorner2 = Instance.new("UICorner")
closeCorner2.CornerRadius = UDim.new(1, 0)
closeCorner2.Parent = closeBtn

-- ========== 功能逻辑 ==========
local menuOpen = false

-- 点击主按钮开关菜单
mainBtn.MouseButton1Click:Connect(function()
    menuOpen = not menuOpen
    menu.Visible = menuOpen
end)

-- 关闭菜单
closeBtn.MouseButton1Click:Connect(function()
    menu.Visible = false
    menuOpen = false
end)

-- 飞行开关
flyToggle.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        hum.PlatformStand = true
        bodyVel.Parent = root
        flyToggle.Text = "✅ 飞行: 开启"
        flyToggle.BackgroundColor3 = Color3.fromRGB(0, 160, 0)
        print("✈️ 飞行开启")
    else
        hum.PlatformStand = false
        bodyVel.Parent = nil
        flyToggle.Text = "🛑 飞行: 关闭"
        flyToggle.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
        print("✈️ 飞行关闭")
    end
end)

-- 拖动主按钮
local dragging = false
local dragStart, btnStart

mainBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        btnStart = mainBtn.Position
    end
end)

mainBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainBtn.Position = UDim2.new(btnStart.X.Scale, btnStart.X.Offset + delta.X, btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
    end
end)

-- ========== 飞行控制 ==========
local function getDir()
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.new(0, 0, 0) end
    
    local dir = Vector3.new(0, 0, 0)
    local charForward = root.CFrame.LookVector
    local charRight = root.CFrame.RightVector
    charForward = Vector3.new(charForward.X, 0, charForward.Z).Unit
    charRight = Vector3.new(charRight.X, 0, charRight.Z).Unit
    
    local stick = hum.MoveDirection
    if stick.Magnitude > 0.1 then
        dir = charForward * stick.Z + charRight * stick.X
    end
    
    local lookY = cam.CFrame.LookVector.Y
    if lookY > 0.4 then
        dir = dir + Vector3.new(0, 1, 0)
    elseif lookY < -0.4 then
        dir = dir + Vector3.new(0, -1, 0)
    end
    
    if dir.Magnitude > 0 then
        dir = dir.Unit * speed
    end
    return dir
end

rs.RenderStepped:Connect(function()
    if flying then
        bodyVel.Velocity = getDir()
    end
end)

print("✅ 飞行加载完成！点击「本」按钮打开菜单")