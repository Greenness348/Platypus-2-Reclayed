local mx
local xAcceleration
local timer = 0

function OnInitialise()
    mx = self.data.speed
    xAcceleration = self.commandArgs.GetFieldFloat("acceleration", 0.002)
    if Globals.difficulty > 1 then
        SpawnEntityChild("turretNastySingle", self, { x = 7, y = -1 }, NewJSONObject())
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }
    mx = mx + xAcceleration

    local smokePos = { x = self.worldPosition.x - 55, y = self.worldPosition.y }

    timer = timer - 1
    if timer <= 0 then
        timer = 16

        local smokeArgs = NewJSONObject()

        smokeArgs.AddFieldFloat("mx", 1)
        SpawnEntityWorld("smokeRing2", smokePos, smokeArgs)
    end

    if self.position.x > 800 then self.Deactivate() end

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 120
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= 29
end
