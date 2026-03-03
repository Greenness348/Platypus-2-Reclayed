local my = -2
local mx = 3
local timer = 3
local speedX
local speedY
local offsetX
local offsetY
local iframes = 40
local set = false

function OnInitialise()
    if self.commandArgs.HasField("speed") then
        local p = self.commandArgs.GetFieldFloatArray("speed")
        speedX = p[1] or 0
        speedY = p[2] or 0
    else
        speedX =  3
        speedY = -2
    end
    mx = speedX
    my = speedY
end

function OnTick()
    timer = timer - 1

    local angle = math.atan2(-mx, my)
    local sprite = (math.floor((angle / (2 * math.pi)) * 16 + 0.5) % 16)
    self.animator.GoTo(sprite)

    local r = 70
    local ox = 0
    local oy = 0
    if sprite == 0 then
        ox = 0      oy = -r
    elseif sprite == 1 then
        ox =  r*0.38  oy = -r*0.92
    elseif sprite == 2 then
        ox =  r*0.71  oy = -r*0.71
    elseif sprite == 3 then
        ox =  r*0.92  oy = -r*0.38
    elseif sprite == 4 then
        ox =  r      oy = 0
    elseif sprite == 5 then
        ox =  r*0.92  oy =  r*0.38
    elseif sprite == 6 then
        ox =  r*0.71  oy =  r*0.71
    elseif sprite == 7 then
        ox =  r*0.38  oy =  r*0.92
    elseif sprite == 8 then
        ox =  0      oy =  r
    elseif sprite == 9 then
        ox = -r*0.38  oy =  r*0.92
    elseif sprite == 10 then
        ox = -r*0.71  oy =  r*0.71
    elseif sprite == 11 then
        ox = -r*0.92  oy =  r*0.38
    elseif sprite == 12 then
        ox = -r      oy = 0
    elseif sprite == 13 then
        ox = -r*0.92  oy = -r*0.38
    elseif sprite == 14 then
        ox = -r*0.71  oy = -r*0.71
    elseif sprite == 15 then
        ox = -r*0.38  oy = -r*0.92
    end

    if timer <= 0 then
        timer = 3
        SpawnEntityWorld("rocketTrail", { x = self.worldPosition.x + ox, y = (self.worldPosition.y + oy)}, NewJSONObject())
    end
    if self.worldPosition.y < -520 then
        self.Kill()
    end
    if self.position.x < -600 then self.Deactivate() end
    if self.position.x > 1600 then self.Deactivate() end
    if self.position.y > 400 then self.Deactivate() end
    self.movement = { x = mx, y = my, z = 0 }

    iframes = iframes - 1
    if iframes <= 0 then
        set = true
    end
end


function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return set
end

