local mx = 3
local my = -3
local dx = dx or 0
local dy = dy or 0
local vx1 = 0
local vy1 = 0
local vx2 = 0
local vy2 = 0
local t = math.random(0, 4)

local sprite = 0
local spriteSet = false

local timer = 0
local leaveTimer = math.random(400, 600)
local iFrames = 40

function OnTick()
    if timer > 0 then timer = timer - 1 else timer = 4 end

    local pos1 = GetPlayer(0).GetWorldPosition()
    vx1 = pos1.x - self.worldPosition.x
    vy1 = pos1.y - self.worldPosition.y
    local pos2 = GetPlayer(1).GetWorldPosition()
    vx2 = pos2.x - self.worldPosition.x
    vy2 = pos2.y - self.worldPosition.y
    local length1 = math.sqrt(vx1 * vx1 + vy1 * vy1)
    local length2 = math.sqrt(vx2 * vx2 + vy2 * vy2)

    if length1 > length2 and GetActivePlayerCount() == 2 then
        dx = vx2 / length2
        dy = vy2 / length2
    else
        dx = vx1 / length1
        dy = vy1 / length1
    end
    
    if timer == 0 then
        if dy < 0 then
            if spriteSet == false then 
                self.animator.Initialise("Sprites/Enemies/bug downward")
                spriteSet = true
            end
        else 
            if spriteSet == true then
                self.animator.Initialise("Sprites/Enemies/bug upward")
                spriteSet = false
            end
        end
    end

    if leaveTimer > 0 then
        leaveTimer = leaveTimer - 1
        mx = mx + ( dx * 0.15 )

        if timer <= 0 then
            if dx > 0 then
                if sprite > 0 then sprite = sprite - 1 else sprite = sprite + 1 end
            else
                if sprite < 6 then sprite = sprite + 1 else sprite = sprite - 1 end
            end
        end
    else
        mx = mx - 0.15
        if timer <= 0 then
            if sprite < 6 then sprite = sprite + 1 else sprite = sprite - 1 end
        end
    end
        my = my + ( dy * 0.15 )
    if mx < -5 then mx = -5 elseif mx > 5 then mx = 5 end
    if my < -5 then my = -5 elseif my > 5 then my = 5 end
    t = t + 0.05

    self.animator.GoTo(sprite)

    self.movement = { x = mx + ( math.cos(t) * 0.5 ), y = my + ( math.cos(t) * 0.5 ), z = 0 }

    if isSpawned == false then
        if self.position.x > 0 and self.position.x < 600 then isSpawned = true end
        if self.position.y > -600 and self.position.y < 0 then isSpawned = true end
    else
        if iFrames > 0 then iFrames = iFrames - 1 end
    end

    if self.position.x < -200 and leaveTimer <= 0 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return iFrames <= 0
end

