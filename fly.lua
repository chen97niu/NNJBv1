-- 手机飞行脚本（按钮开启/关闭）
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

-- ========== 创建UI ==========
-- 先删除旧的
if game:GetService("CoreGui"):FindFirstChild("FlyUI") then
    game:GetService("CoreGui"):FindFirstChild("FlyUI"):Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyUI"
screenGui.Parent = game:GetService("CoreGui")
screenGui.ResetOnSpawn = false

-- 飞行按钮（屏幕右下角，半透明，方便点击）
local flyBtn = Instance.new("ImageButton")
flyBtn.Size = UDim2.new(0, 80, 0, 80)
flyBtn.Position = UDim2.new(0.85, -40, 0.85, -40)
flyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
flyBtn.BackgroundTransparency = 0.2
flyBtn.BorderSizePixel = 2
flyBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
flyBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = flyBtn

local btnText = Instance.new("TextLabel")
btnText.Size = UDim2.new(1, 0, 1, 0)
btnText.BackgroundTransparency = 1
btnText.Text = "飞"
btnText.TextColor3 = Color3.fromRGB(255, 255, 255)
btnText.TextSize = 28
btnText.Font = Enum.Font.GothamBold
btnText.Parent = flyBtn

-- 状态文字（显示在按钮下方）
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 100, 0, 30)
statusText.Position = UDim2.new(0.85, -50, 0.85, 50)
statusText.BackgroundTransparency = 1
statusText.Text = "关闭"
statusText.TextColor3 = Color3.fromRGB(255, 200, 200)
statusText.TextSize = 16
statusText.Font = Enum.Font.Gotham
statusText.TextScaled = true
statusText.Parent = screenGui

-- ========== 按钮功能 ==========
flyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    if flying then
        hum.PlatformStand = true
        bodyVel.Parent = root
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        flyBtn.BackgroundTransparency = 0
        statusText.Text = "飞行中"
        statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
        print("✈️ 飞行开启")
    else
        hum.PlatformStand = false
        bodyVel.Parent = nil
        flyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        flyBtn.BackgroundTransparency = 0.2
        statusText.Text = "关闭"
        statusText.TextColor3 = Color3.fromRGB(255, 200, 200)
        print("✈️ 飞行关闭")
    end
end)

-- 拖动按钮
local dragging = false
local dragStart, btnStart

flyBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        btnStart = flyBtn.Position
    end
end)

flyBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

uis.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        flyBtn.Position = UDim2.new(btnStart.X.Scale, btnStart.X.Offset + delta.X, btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
        -- 状态文字跟着按钮移动
        statusText.Position = UDim2.new(flyBtn.Position.X.Scale, flyBtn.Position.X.Offset - 10, flyBtn.Position.Y.Scale, flyBtn.Position.Y.Offset + 85)
    end
end)

-- ========== 飞行控制 ==========
local function getDir()
    local cam = workspace.CurrentCamera
    if not cam then return Vector3.new(0, 0, 0) end
    
    local dir = Vector3.new(0, 0, 0)
    local forward = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector
    forward = Vector3.new(forward.X, 0, forward.Z).Unit
    right = Vector3.new(right.X, 0, right.Z).Unit
    
    -- 摇杆控制前后左右
    local stick = hum.MoveDirection
    if stick.Magnitude > 0.1 then
        dir = forward * stick.Z + right * stick.X
    end
    
    -- 视角控制上下（看天↑，看地↓）
    local up = cam.CFrame.LookVector.Y
    if up > 0.3 then
        dir = dir + Vector3.new(0, 1, 0)
    elseif up < -0.3 then
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

print("✅ 手机飞行加载完成！点击右下角【飞】按钮")