local mx = 0
local my = 0
local angle
local target = nil
local cooldownTimer
local homingTimer
local behind
local isSpawned = false
local iFrames = 40

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
    
    self.defaultOnHitByBulletBehaviour = true
    self.defaultOnHitByPlayerBehaviour = true
end

function OnTick()
    -- Ticks before it starts homing
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
    
    -- Ticks before it can kill players on touch
    if isSpawned == false then
        if self.position.x > 0 and self.position.x < 600 and self.position.y > -600 and self.position.y < 0 then isSpawned = true end
    else
        if iFrames > 0 then iFrames = iFrames - 1 end
    end
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return iFrames < 40 or mx < 0
end

function ShouldKillPlayerOnTouch()
    return iFrames <= 0
end
