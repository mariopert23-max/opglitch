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
local trackerEnabled = false

-- =========================
-- SPEED + SPIN
-- =========================

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
                    root.CFrame =
                        root.CFrame *
                        CFrame.Angles(0, math.rad(360), 0)
                end
            end

        elseif state == Enum.HumanoidStateType.Landed then

            if speedEnabled then
                hum.WalkSpeed = baseWalkSpeed
            end
        end
    end)
end

-- =========================
-- AUTO THIGH
-- =========================

local function createThigh(character)
    if not thighEnabled then
        return
    end

    local root = character:WaitForChild("HumanoidRootPart")
    task.wait(0.5)

    local leftLeg =
        character:FindFirstChild("LeftUpperLeg")
        or character:FindFirstChild("Left Leg")

    if not leftLeg then
        return
    end

    local old = character:FindFirstChild("AutoThighPart")

    if old then
        old:Destroy()
    end

    local offset =
        root.CFrame:Inverse() * leftLeg.CFrame

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
end

-- =========================
-- TRACKER PHYSICS
-- =========================

local originalProperties = {}
local trackerPart
local trackerConnections = {}
local trackerCharacter

local function saveProperties(character)
    originalProperties = {}

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            originalProperties[object] =
                object.CustomPhysicalProperties
        end
    end
end

local function restoreProperties()
    for part, properties in pairs(originalProperties) do
        if part and part.Parent then
            part.CustomPhysicalProperties = properties
        end
    end

    originalProperties = {}
end

local function removeTracker()
    for _, connection in ipairs(trackerConnections) do
        connection:Disconnect()
    end

    trackerConnections = {}

    if trackerPart then
        trackerPart:Destroy()
        trackerPart = nil
    end

    restoreProperties()
end

local function enableTracker(character)
    if not character or not trackerEnabled then
        return
    end

    removeTracker()

    trackerCharacter = character

    local root =
        character:WaitForChild("HumanoidRootPart", 5)

    if not root then
        return
    end

    saveProperties(character)

    trackerPart = Instance.new("Part")
    trackerPart.Name = "TrackerPart"
    trackerPart.Size = Vector3.new(2, 2, 2)
    trackerPart.Transparency = 1
    trackerPart.CanCollide = false
    trackerPart.Anchored = false
    trackerPart.Massless = true
    trackerPart.Parent = character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = trackerPart
    weld.Part1 = root
    weld.Parent = trackerPart

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart")
            and object ~= trackerPart
            and object:FindFirstAncestorOfClass("Tool") == nil then

            local oldProperties =
                object.CustomPhysicalProperties

            if oldProperties then
                object.CustomPhysicalProperties =
                    PhysicalProperties.new(
                        0.1,
                        oldProperties.Friction,
                        oldProperties.Elasticity,
                        oldProperties.FrictionWeight,
                        oldProperties.ElasticityWeight
                    )
            else
                object.CustomPhysicalProperties =
                    PhysicalProperties.new(
                        0.1,
                        0.7,
                        0,
                        1,
                        1
                    )
            end
        end
    end
end

-- =========================
-- CHARACTER SETUP
-- =========================

local function setupCharacter(character)

    setupHumanoid(
        character:WaitForChild("Humanoid")
    )

    if thighEnabled then
        task.spawn(createThigh, character)
    end

    if trackerEnabled then
        task.spawn(enableTracker, character)
    end
end

if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(function(character)

    task.wait(1)

    setupCharacter(character)

end)

-- =========================
-- BUTTON: SPEED
-- =========================

BindableButtons.AddBButton(
    "Speed",
    "Speed",
    function()

        speedEnabled = true

        if humanoid then
            humanoid.WalkSpeed =
                baseWalkSpeed + speedBoost
        end

        shared.Notify("Speed ON", 2)

    end,

    function()

        speedEnabled = false

        if humanoid then
            humanoid.WalkSpeed =
                baseWalkSpeed
        end

        shared.Notify("Speed OFF", 2)

    end
)

-- =========================
-- SPEED BOOST SLIDER
-- =========================

section:AddSlider(
    "Speed Boost",
    0,
    99999,
    350,
    function(value)

        speedBoost = value

        if speedEnabled and humanoid then
            humanoid.WalkSpeed =
                baseWalkSpeed + speedBoost
        end

    end
)

-- =========================
-- BUTTON: SPIN
-- =========================

BindableButtons.AddBButton(
    "Spin",
    "Spin on Jump",
    function()

        spinEnabled = true
        shared.Notify("Spin ON", 2)

    end,

    function()

        spinEnabled = false
        shared.Notify("Spin OFF", 2)

    end
)

-- =========================
-- BUTTON: AUTO THIGH
-- =========================

BindableButtons.AddBButton(
    "AutoThigh",
    "Auto Thigh",
    function()

        thighEnabled = true

        if player.Character then
            task.spawn(
                createThigh,
                player.Character
            )
        end

        shared.Notify("Auto Thigh ON", 2)

    end,

    function()

        thighEnabled = false

        if player.Character then

            local part =
                player.Character:FindFirstChild(
                    "AutoThighPart"
                )

            if part then
                part:Destroy()
            end
        end

        shared.Notify("Auto Thigh OFF", 2)

    end
)

-- =========================
-- BUTTON: TRACKER PHYSICS
-- =========================

BindableButtons.AddBButton(
    "TrackerPhysics",
    "Tracker Physics",
    function()

        trackerEnabled = true

        if player.Character then
            task.spawn(
                enableTracker,
                player.Character
            )
        end

        shared.Notify("Tracker Physics ON", 2)

    end,

    function()

        trackerEnabled = false

        removeTracker()

        shared.Notify(
            "Tracker Physics OFF",
            2
        )

    end
)