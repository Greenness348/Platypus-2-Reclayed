local my
local mx
local speed
local direction
local angle
local sprite
local trailTimer = 3
local dx1 = 0
local dy1 = 0
local dx2 = 0
local dy2 = 0
local player1
local player2
local length1
local length2

function OnInitialise()
    direction = self.commandArgs.GetFieldInt("direction")
    angle = (direction % 360 + 101.25) % 360
    sprite = math.floor((angle / (360.0 / self.animator.totalFrames) + self.animator.totalFrames/2) % self.animator.totalFrames)
    self.animator.GoTo(sprite)

    speed = NewDiffDictInt(3, 4, 5, 6, 7).Get()
    mx = math.cos(math.rad(direction)) * speed
    my = math.sin(math.rad(direction)) * speed
    self.movement = { x = mx, y = my, z = 0 }
end

function OnTick()
    local r = 80
    local ox = 0
    local oy = 0
    if sprite == 0 then         ox =  0;        oy = -r
    elseif sprite == 1 then     ox =  r*0.38;   oy = -r*0.92
    elseif sprite == 2 then     ox =  r*0.71;   oy = -r*0.71
    elseif sprite == 3 then     ox =  r*0.92;   oy = -r*0.38
    elseif sprite == 4 then     ox =  r;        oy =  0
    elseif sprite == 5 then     ox =  r*0.92;   oy =  r*0.38
    elseif sprite == 6 then     ox =  r*0.71;   oy =  r*0.71
    elseif sprite == 7 then     ox =  r*0.38;   oy =  r*0.92
    elseif sprite == 8 then     ox =  0;        oy =  r
    elseif sprite == 9 then     ox = -r*0.38;   oy =  r*0.92
    elseif sprite == 10 then    ox = -r*0.71;   oy =  r*0.71
    elseif sprite == 11 then    ox = -r*0.92;   oy =  r*0.38
    elseif sprite == 12 then    ox = -r;        oy =  0
    elseif sprite == 13 then    ox = -r*0.92;   oy = -r*0.38
    elseif sprite == 14 then    ox = -r*0.71;   oy = -r*0.71
    elseif sprite == 15 then    ox = -r*0.38;   oy = -r*0.92
    end

    if trailTimer > 0 then trailTimer = trailTimer - 1
    else
        trailTimer = 3
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 0)
        SpawnEntityWorld("icbmTrail", { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy}, smokeArgs)
    end
    if self.position.x < -300 and mx < 0 then self.Deactivate() end
    if self.position.x >  900 and mx > 0 then self.Deactivate() end
    if self.position.y >  300 and my > 0 then self.Deactivate() end
    if self.worldPosition.y < -450 then
        SpawnEntityWorld("explosionHuge", { x = self.worldPosition.x, y = self.worldPosition.y + 150 })
        self.Deactivate()
    end
        
    player1 = GetPlayer(0)
    if player1.isActive then
        dx1 = player1.worldPosition.x - (self.worldPosition.x + (math.cos(math.rad(direction)) * 200))
        dy1 = player1.worldPosition.y - (self.worldPosition.y + (math.sin(math.rad(direction)) * 200))
        length1 = math.sqrt(dx1 * dx1 + dy1 * dy1)
        dx1 = dx1 / length1
        dy1 = dy1 / length1
        if length1 < 150 then player1.TriggerWarning() end
    end
    player2 = GetPlayer(1)
    if player2.isActive then
        dx2 = player2.worldPosition.x - (self.worldPosition.x + (math.cos(math.rad(direction)) * 200))
        dy2 = player2.worldPosition.y - (self.worldPosition.y + (math.sin(math.rad(direction)) * 200))
        length2 = math.sqrt(dx2 * dx2 + dy2 * dy2)
        dx2 = dx2 / length2
        dy2 = dy2 / length2
        if length2 < 150 then player2.TriggerWarning() end
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
