local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- =========================
-- ESTADOS
-- =========================

local speedEnabled = false
local spinEnabled = false
local thighEnabled = false
local trackerEnabled = false

local speedBoost = 350
local humanoid
local baseWalkSpeed = 16

-- =========================
-- SPEED
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

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local leg =
        character:FindFirstChild("LeftUpperLeg")
        or character:FindFirstChild("Left Leg")

    if not leg then return end

    local old = character:FindFirstChild("AutoThighPart")
    if old then
        old:Destroy()
    end

    local part = Instance.new("Part")
    part.Name = "AutoThighPart"
    part.Size = Vector3.new(0.5, 0.5, 2)
    part.Transparency = 1
    part.CanCollide = true
    part.Massless = true
    part.CFrame = leg.CFrame
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

local function saveProperties(character)
    originalProperties = {}

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") then
            originalProperties[obj] =
                obj.CustomPhysicalProperties
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
    if trackerPart then
        trackerPart:Destroy()
        trackerPart = nil
    end

    restoreProperties()
end

local function enableTracker(character)
    if not trackerEnabled then
        return
    end

    removeTracker()

    local root =
        character:FindFirstChild("HumanoidRootPart")

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

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart")
            and obj ~= trackerPart
            and not obj:FindFirstAncestorOfClass("Tool") then

            local old = obj.CustomPhysicalProperties

            if old then
                obj.CustomPhysicalProperties =
                    PhysicalProperties.new(
                        0.1,
                        old.Friction,
                        old.Elasticity,
                        old.FrictionWeight,
                        old.ElasticityWeight
                    )
            else
                obj.CustomPhysicalProperties =
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
-- RESPAWN
-- =========================

local function setupCharacter(character)
    local hum = character:WaitForChild("Humanoid", 5)

    if hum then
        setupHumanoid(hum)
    end

    task.wait(0.5)

    if thighEnabled then
        createThigh(character)
    end

    if trackerEnabled then
        enableTracker(character)
    end
end

if player.Character then
    task.spawn(setupCharacter, player.Character)
end

player.CharacterAdded:Connect(function(character)
    task.spawn(setupCharacter, character)
end)

-- =========================
-- BIG BUTTON: SPEED
-- =========================

AddBigButton(
    "GlitchesSpeed",
    "Speed ON / OFF",
    function()

        speedEnabled = not speedEnabled

        if speedEnabled then
            if humanoid then
                humanoid.WalkSpeed =
                    baseWalkSpeed + speedBoost
            end

            print("Speed: ON")
        else
            if humanoid then
                humanoid.WalkSpeed =
                    baseWalkSpeed
            end

            print("Speed: OFF")
        end
    end
)

-- =========================
-- BIG BUTTON: SPEED BOOST
-- =========================

AddBigButton(
    "GlitchesSpeedBoost",
    "Speed Boost: 350",
    function()

        speedBoost = 350

        if speedEnabled and humanoid then
            humanoid.WalkSpeed =
                baseWalkSpeed + speedBoost
        end

        print("Speed Boost:", speedBoost)
    end
)

-- =========================
-- BIG BUTTON: SPIN
-- =========================

AddBigButton(
    "GlitchesSpin",
    "Spin ON / OFF",
    function()

        spinEnabled = not spinEnabled

        print(
            "Spin:",
            spinEnabled and "ON" or "OFF"
        )
    end
)

-- =========================
-- BIG BUTTON: AUTO THIGH
-- =========================

AddBigButton(
    "GlitchesThigh",
    "Auto Thigh ON / OFF",
    function()

        thighEnabled = not thighEnabled

        if thighEnabled then

            if player.Character then
                createThigh(player.Character)
            end

            print("Auto Thigh: ON")

        else

            if player.Character then
                local part =
                    player.Character:FindFirstChild(
                        "AutoThighPart"
                    )

                if part then
                    part:Destroy()
                end
            end

            print("Auto Thigh: OFF")
        end
    end
)

-- =========================
-- BIG BUTTON: TRACKER
-- =========================

AddBigButton(
    "GlitchesTracker",
    "Tracker Physics ON / OFF",
    function()

        trackerEnabled = not trackerEnabled

        if trackerEnabled then

            if player.Character then
                enableTracker(player.Character)
            end

            print("Tracker Physics: ON")

        else

            removeTracker()

            print("Tracker Physics: OFF")
        end
    end
)