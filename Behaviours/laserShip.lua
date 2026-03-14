local mx = -3
local my = 1
local myMax = 2
local yAcceleration
local timer = 600
local trailTimer = 0
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY

function OnInitialise()
    self.defaultOnHitByBulletBehaviour = true
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldInt("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldInt("smokeTrailPosY", 0)
    yAcceleration = myMax / 50
    
    self.fruitSet = self.commandArgs.GetFieldInt("fruit_set", 5)
end

function OnTick()
    if math.abs(my) >= myMax then yAcceleration = -yAcceleration end
    my = my + yAcceleration

    self.movement = { x = mx, y = my, z = 0 }

    if timer > 0 then
        timer = timer - 1
        if mx < 0.24 then mx = mx + 0.02 end
    else
        if mx >= -3 then mx = mx - 0.01 end
    end

    if smokeTrailEntity ~= "" and mx > 0 then
        trailTimer = trailTimer - 1
        if trailTimer <= 0 then
            trailTimer = 30
            local smokeArgs = NewJSONObject()
            smokeArgs.AddFieldFloat("mx", 1)
            SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
        end
    end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)

    if self.position.x < -200 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return timer <= 500
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
