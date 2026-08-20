-- 手机专用飞行脚本（无键盘依赖）
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local flying = false
local flySpeed = 80
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 100000

-- 获取移动方向（纯手机摇杆 + 视角）
local function getMoveDirection()
    local camera = workspace.CurrentCamera
    local moveDir = Vector3.new(0, 0, 0)
    
    -- 相机方向（投影到水平面，用于前后左右）
    local camForward = camera.CFrame.LookVector
    local camRight = camera.CFrame.RightVector
    camForward = Vector3.new(camForward.X, 0, camForward.Z).Unit
    camRight = Vector3.new(camRight.X, 0, camRight.Z).Unit
    
    -- 手机摇杆输入（MoveDirection 自动适配触屏摇杆）
    local stick = humanoid.MoveDirection
    if stick.Magnitude > 0.1 then
        -- stick.Z: 正=前（摇杆上推），负=后（摇杆下拉）
        -- stick.X: 正=右，负=左
        moveDir = camForward * stick.Z + camRight * stick.X
    end
    
    -- 上下飞行：根据手机视角俯仰（看天就上，看地就下）
    local lookY = camera.CFrame.LookVector.Y
    if math.abs(lookY) > 0.15 then
        moveDir = moveDir + Vector3.new(0, -lookY, 0)
    end
    
    -- 归一化并乘以速度
    if moveDir.Magnitude > 0 then
        moveDir = moveDir.Unit * flySpeed
    end
    return moveDir
end

-- 切换飞行
local function toggleFly()
    flying = not flying
    if flying then
        humanoid.PlatformStand = true
        bodyVelocity.Parent = rootPart
        print("✈️ 飞行已开启 | 速度: " .. flySpeed)
    else
        humanoid.PlatformStand = false
        bodyVelocity.Parent = nil
        print("✈️ 飞行已关闭")
    end
end

-- 手机触屏双击检测（双击屏幕切换飞行）
local lastTap = 0
local uis = game:GetService("UserInputService")

uis.TouchEnabled:Connect(function()
    uis.TouchTap:Connect(function()
        local now = tick()
        if now - lastTap < 0.4 then  -- 0.4秒内双击
            toggleFly()
            lastTap = 0
        else
            lastTap = now
        end
    end)
end)

-- 备用：如果游戏不支持TouchTap，用屏幕触摸次数检测
if not uis.TouchTap then
    local tapCount = 0
    local tapTimer = 0
    uis.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.Touch then
            local now = tick()
            if now - tapTimer < 0.4 then
                tapCount = tapCount + 1
                if tapCount >= 2 then
                    toggleFly()
                    tapCount = 0
                end
            else
                tapCount = 1
            end
            tapTimer = now
        end
    end)
end

-- 飞行主循环
game:GetService("RunService").RenderStepped:Connect(function()
    if flying then
        bodyVelocity.Velocity = getMoveDirection()
    end
end)

print("✅ 手机飞行脚本加载完成！双击屏幕切换飞行")