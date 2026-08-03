-- =========================
-- GLITCHES TEST BUTTONS
-- =========================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local speedEnabled = false
local spinEnabled = false
local thighEnabled = false

local speedBoost = 50
local humanoid

local function setupCharacter(character)
    humanoid = character:WaitForChild("Humanoid", 5)
end

if player.Character then
    task.spawn(setupCharacter, player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- SPEED
AddBigButton("GlitchesSpeed", "Speed: OFF", function()
    speedEnabled = not speedEnabled

    if humanoid then
        if speedEnabled then
            humanoid.WalkSpeed = 16 + speedBoost
        else
            humanoid.WalkSpeed = 16
        end
    end

    local button = BBSystem.Buttons["GlitchesSpeed"]
    if button then
        button.Text =
            speedEnabled and "Speed: ON" or "Speed: OFF"
    end
end)

-- SPIN
AddBigButton("GlitchesSpin", "Spin: OFF", function()
    spinEnabled = not spinEnabled

    local button = BBSystem.Buttons["GlitchesSpin"]
    if button then
        button.Text =
            spinEnabled and "Spin: ON" or "Spin: OFF"
    end
end)

-- AUTO THIGH
AddBigButton("GlitchesThigh", "Auto Thigh: OFF", function()
    thighEnabled = not thighEnabled

    local button = BBSystem.Buttons["GlitchesThigh"]
    if button then
        button.Text =
            thighEnabled and "Auto Thigh: ON"
            or "Auto Thigh: OFF"
    end
end)

-- SPEED BOOST
AddBigButton("GlitchesBoost", "Speed Boost: 50", function()
    speedBoost = speedBoost + 50

    if speedBoost > 500 then
        speedBoost = 50
    end

    if speedEnabled and humanoid then
        humanoid.WalkSpeed = 16 + speedBoost
    end

    local button = BBSystem.Buttons["GlitchesBoost"]
    if button then
        button.Text = "Speed Boost: " .. speedBoost
    end
end)