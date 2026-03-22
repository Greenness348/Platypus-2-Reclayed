local mx = 0
local my = 0
local angle
local target = nil
local cooldownTimer
local homingTimer
local behind
local firstShotDelay
local firePattern
local fireSFX
local isSpawned = false
local iFrames = 40

function OnInitialise()
    cooldownTimer = self.commandArgs.GetFieldFloat("homingCooldown", 50)
    homingTimer = self.commandArgs.GetFieldFloat("homingTime", 150)
    
    behind = self.commandArgs.GetFieldBool("isBehind", false)
    if behind == false then angle = 180 else angle = 0 end

    firstShotDelay = NewDiffDictInt(40, 40, 40, 20, 20).Get()
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser")
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    -- Ticks before it starts homing
    if cooldownTimer > 0 then cooldownTimer = cooldownTimer - 1
    else
        -- Acquire or validate target
        if target == nil then target = GetRandomActivePlayer() elseif target ~= nil and not target.isActive then target = nil end
        
        -- Ticks before it stops homing
        if homingTimer > 0 then
            homingTimer = homingTimer - 1

            -- Homing behaviour
            if target ~= nil then
                local sourcePos = self.worldPosition
                local targetPos = target.worldPosition
                local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
                angle = MoveTowardsAngle(angle, targetAngle, 4)
            end
        end

        -- Despawn outside bounds
        if self.position.x > 800 or self.position.x < -200 or self.position.y > 200 or self.position.y < -800 then self.Deactivate() end
    end

    -- Movement calculation
    local angleRad = math.rad(angle)
    mx = math.cos(angleRad) * 5
    my = math.sin(angleRad) * 5
    self.movement = { x = mx, y = my, z = 0 }

    -- Animation update
    local positiveAngle = (angle % 360 - 5.625) % 360;
    local animatorFrame = math.floor((positiveAngle / (360.0 / self.animator.totalFrames) + self.animator.totalFrames/2) % self.animator.totalFrames);
    self.animator.GoTo(animatorFrame);

    -- Fire pattern
    if CanFire() then
        if firstShotDelay > 0 then firstShotDelay = firstShotDelay - 1 end
        firePattern.Tick()

        -- Fire behaviour
        if firePattern.CanFire() and firstShotDelay == 0 then
            firePattern.MarkFired()
            target = nil
                
            local mxb = math.cos(angleRad) * 8
            local myb = math.sin(angleRad) * 8
            local fireArgs = NewJSONObject()
            fireArgs.AddFieldFloat("mx", mxb)
            fireArgs.AddFieldFloat("my", myb)

            SpawnEntityWorld("enemyshot_laser", { x = self.worldPosition.x + ( math.cos(angleRad) * 40 ), y = self.worldPosition.y + ( math.sin(angleRad) * 40 )}, fireArgs)
            PlaySound(fireSFX)
        end
    end

    -- Ticks before it can kill players on touch
    if isSpawned == false then
        if self.position.x > 0 and self.position.x < 600 and self.position.y > -600 and self.position.y < 0 then isSpawned = true end
    else
        if iFrames > 0 then iFrames = iFrames - 1 end
    end
end

function CanFire()
    return Globals.difficulty > 0 and homingTimer > 0 and cooldownTimer <= 0
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return iFrames <= 35 or mx < 0
end

function ShouldKillPlayerOnTouch()
    return iFrames <= 0
end
