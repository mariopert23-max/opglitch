local shared = odh_shared_plugins
local section = shared.AddSection("Glitches")

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local humanoid
local baseWalkSpeed = 16
local speedBoost = 350

local speedEnabled = false
local spinEnabled = false
local thighEnabled = false

local function setupHumanoid(hum)
    humanoid = hum
    baseWalkSpeed = hum.WalkSpeed

    hum.StateChanged:Connect(function(_, state)
        if state == Enum.HumanoidStateType.Jumping then
            if speedEnabled then
                hum.WalkSpeed = baseWalkSpeed + speedBoost
            end

            if spinEnabled then
                local root = hum.Parent:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(360), 0)
                end
            end

        elseif state == Enum.HumanoidStateType.Landed then
            if speedEnabled then
                hum.WalkSpeed = baseWalkSpeed
            end
        end
    end)
end

local function setupCharacter(character)
    setupHumanoid(character:WaitForChild("Humanoid"))

    if thighEnabled then
        task.spawn(function()
            local root = character:WaitForChild("HumanoidRootPart")
            task.wait(0.5)

            local leftLeg =
                character:FindFirstChild("LeftUpperLeg")
                or character:FindFirstChild("Left Leg")

            if not leftLeg then return end

            local old = character:FindFirstChild("AutoThighPart")
            if old then old:Destroy() end

            local offset = root.CFrame:Inverse() * leftLeg.CFrame

            local part = Instance.new("Part")
            part.Name = "AutoThighPart"
            part.Size = Vector3.new(0.5, 0.5, 2)
            part.CFrame =
                root.CFrame * CFrame.new(-0.9, offset.Y, 0)
            part.CanCollide = true
            part.Massless = true
            part.Transparency = 1
            part.Parent = character

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = part
            weld.Part1 = root
            weld.Parent = part
        end)
    end
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- Speed
BindableButtons.AddBButton(
    "Speed",
    "Speed",
    function()
        speedEnabled = true
    end,
    function()
        speedEnabled = false

        if humanoid then
            humanoid.WalkSpeed = baseWalkSpeed
        end
    end
)

-- Barra de velocidad
section:AddSlider("Speed Boost", 0, 99999, 350, function(value)
    speedBoost = value
end)

-- Giro
BindableButtons.AddBButton(
    "Spin",
    "Spin",
    function()
        spinEnabled = true
    end,
    function()
        spinEnabled = false
    end
)

-- Auto Thigh
BindableButtons.AddBButton(
    "AutoThigh",
    "Auto Thigh",
    function()
        thighEnabled = true

        if player.Character then
            setupCharacter(player.Character)
        end
    end,
    function()
        thighEnabled = false

        if player.Character then
            local part =
                player.Character:FindFirstChild("AutoThighPart")

            if part then
                part:Destroy()
            end
        end
    end
)