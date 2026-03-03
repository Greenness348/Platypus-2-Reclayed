local mx = 2
local my = 1
local myMax = 2
local yAcceleration

local timer = 250
local trailTimer = 0

function OnInitialise()
    if Globals.difficulty > 1 then
        SpawnEntityChild("turretNastySingle", self, { x = 7, y = -1 }, NewJSONObject())
    end
    yAcceleration = myMax / 50
end

function OnTick()
    if math.abs(my) >= myMax then
        yAcceleration = -yAcceleration
    end
    my = my + yAcceleration

    self.movement = { x = mx, y = my, z = 0 }

    timer = timer - 1
    if timer >= 0 then
        mx = mx + 0.005
    elseif timer < 0 then
        if mx >= -3 then
            mx = mx - 0.05
        end
    end

    local smokePos = { x = self.worldPosition.x - 55, y = self.worldPosition.y }

    if mx >= 0 then
        trailTimer = trailTimer - 1
        if trailTimer <= 0 then
            trailTimer = 16

            local args = NewJSONObject()
            local smokeTrail = 1

            args.AddFieldFloat("mx", smokeTrail)
            SpawnEntityWorld("smokeRing2", smokePos, args)
        end
    end

    if self.position.x < -200 and mx <= 0 then self.Deactivate() end

    local damageframe = self.GetDamageFrame(self.hitPoints)
    self.animator.AnimateTo(damageframe)
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 60
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= 29 or mx <= 0
end
