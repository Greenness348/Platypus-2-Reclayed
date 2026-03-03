local mx = 1.5
local timer
local trailTimer = 0

function OnInitialise()
    if self.commandArgs.HasField("thrusterTime") then timer = self.commandArgs.GetFieldFloat("thrusterTime") else timer = 200 end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }

    if timer > 0 then
        timer = timer - 1
        if mx <= 3 then mx = mx + 0.02 else mx = mx + 0.005 end
    else
        if mx >= -3 then mx = mx - 0.1 end
    end

    if timer > 0 then
        if trailTimer > 0 then
            trailTimer = trailTimer - 1
        else
            trailTimer = 3

            local args = NewJSONObject()
            local smokeTrail = 2

            args.AddFieldFloat("mx", smokeTrail)
            SpawnEntityWorld("rocketTrail", { x = self.worldPosition.x - 35, y = self.worldPosition.y + 4 }, args)
        end
    end

    if self.position.x <= -200 and mx < 0 then self.Deactivate() end
    if self.position.x >= 1000 and mx > 0 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(24, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= -50
end
