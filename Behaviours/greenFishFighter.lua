local mx
local my = 0
local angle
local target = nil
local cooldownTimer
local homingTimer
local firstShotDelay
local firePattern
local fireSFX

function OnInitialise()
    cooldownTimer = self.commandArgs.GetFieldFloat("homingCooldown", 50)
    homingTimer = self.commandArgs.GetFieldFloat("homingTime", 150)
    
    behind = self.commandArgs.GetFieldBool("isBehind", false)
    if behind == false then mx = -5; angle = 180 else mx = 5; angle = 0 end

    firstShotDelay = NewDiffDictInt(80, 40, 20, 20, 20).Get()
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "s_laser")
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }

    local positiveAngle = (angle % 360 - 5.625) % 360;
    local animatorFrame = math.floor((positiveAngle / (360.0 / self.animator.totalFrames) + self.animator.totalFrames/2) % self.animator.totalFrames);
    self.animator.GoTo(animatorFrame);
    local angleRad = math.rad(angle)

    if cooldownTimer > 0 then cooldownTimer = cooldownTimer - 1
    else
        if target == nil then target = GetRandomActivePlayer() elseif target ~= nil and not target.isActive then target = nil end
        if target ~= nil and homingTimer > 0 then homingTimer = homingTimer - 1 end
        if homingTimer > 0 then
            if target ~= nil then
                local sourcePos = self.worldPosition
                local targetPos = target.position
                local targetAngle = math.deg(math.atan2(targetPos.y + 50 - sourcePos.y, targetPos.x - sourcePos.x))
                angle = MoveTowardsAngle(angle, targetAngle, 4)
                mx = math.cos(angleRad) * 5
                my = math.sin(angleRad) * 5
            end
        end
    end

    if CanFire() then
        if GetActivePlayerCount() > 0 then
            if firstShotDelay > 0 then firstShotDelay = firstShotDelay - 1 end
            firePattern.Tick()

            if firePattern.CanFire() and firstShotDelay == 0 then
                firePattern.MarkFired()
                
                local dx = math.cos(angleRad) * 40
                local dy = math.sin(angleRad) * 40
                local mxb = math.cos(angleRad) * 8
                local myb = math.sin(angleRad) * 8

                local fireArgs = NewJSONObject()
                fireArgs.AddFieldFloat("mx", mxb)
                fireArgs.AddFieldFloat("my", myb)

                SpawnEntityWorld("enemyshot_laser", { x = self.worldPosition.x + ( math.cos(angleRad) * 40 ), y = self.worldPosition.y + ( math.sin(angleRad) * 40 )}, fireArgs)
                PlaySound(fireSFX)
            end
        end
    end

    if cooldownTimer <= 0 then
        if self.position.x > 800 or self.position.x < -200 then self.Deactivate() end
        if self.position.y > 200 or self.position.y < -800 then self.Deactivate() end
    end
end

function CanFire()
    return homingTimer > 0 and cooldownTimer <= 0
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return self.position.x > -100
end

function ShouldKillPlayerOnTouch()
    return true
end
