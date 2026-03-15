local mx = 0
local my = 0
local angle
local target = nil
local cooldownTimer
local homingTimer
local behind

-- Speed settings
local baseSpeed = 3
local boostSpeed = 5
local currentSpeed
local acceleration = 0.05

function OnInitialise()
    cooldownTimer = self.commandArgs.GetFieldFloat("homingCooldown", 50)
    homingTimer = self.commandArgs.GetFieldFloat("homingTime", 150)

    behind = self.commandArgs.GetFieldBool("isBehind", false)

    currentSpeed = baseSpeed

    if behind == false then
        angle = 180
    else
        angle = 0
    end
end

function OnTick()

    if cooldownTimer > 0 then
        cooldownTimer = cooldownTimer - 1
    else
        -- Acquire or validate target
        if target == nil then
            target = GetRandomActivePlayer()
        elseif target ~= nil and not target.isActive then
            target = nil
        end

        -- Homing behaviour
        if homingTimer > 0 then
            homingTimer = homingTimer - 1

            if target ~= nil then
                local sourcePos = self.worldPosition
                local targetPos = target.worldPosition

                local targetAngle = math.deg(
                    math.atan2(
                        targetPos.y - sourcePos.y,
                        targetPos.x - sourcePos.x
                    )
                )

                angle = MoveTowardsAngle(angle, targetAngle, 4)
            end
        end

        -- Gradual acceleration
        if currentSpeed < boostSpeed then
            currentSpeed = currentSpeed + acceleration
        end
    end

    -- Movement calculation
    local angleRad = math.rad(angle)

    mx = math.cos(angleRad) * currentSpeed
    my = math.sin(angleRad) * currentSpeed

    self.movement = { x = mx, y = my, z = 0 }

    -- Animation update
    local positiveAngle = (angle % 360 - 5.625) % 360
    local animatorFrame = math.floor(
        (positiveAngle / (360.0 / self.animator.totalFrames) +
        self.animator.totalFrames / 2) % self.animator.totalFrames
    )
    self.animator.GoTo(animatorFrame)

    -- Despawn outside bounds
    if cooldownTimer <= 0 then
        if self.position.x > 800 or self.position.x < -200 then
            self.Deactivate()
        end
        if self.position.y > 200 or self.position.y < -800 then
            self.Deactivate()
        end
    end
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return self.position.x > -100 or cooldownTimer <= 0
end

function ShouldKillPlayerOnTouch()
    return true
end
