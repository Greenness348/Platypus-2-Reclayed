local mx = 0
local my = -5
local dx = 0
local dy = 0
local vx = 0
local vy = 0
local target = nil
local length
local t = math.random(0, 10)
local sprite = 0
local spriteInvert = false
local timer = 0
local targetTimer = math.random(50, 200)
local leaveTimer = 600
local isSpawned = false
local iFrames = 40

function OnTick()
    if timer > 0 then timer = timer - 1 else timer = 3 end

    length = math.sqrt(vx * vx + vy * vy)
    if target == nil then target = GetRandomActivePlayer() elseif target ~= nil and not target.isActive then target = nil end
    if target ~= nil then
        vx = target.worldPosition.x - self.worldPosition.x
        vy = target.worldPosition.y - self.worldPosition.y
    else
        vx = -300 - self.worldPosition.x
        vy = -300 - self.worldPosition.y
    end
        dx = vx / length
        dy = vy / length
    
    if timer == 0 then
        if      dy <= -0.6                   then       self.animator.Initialise("Sprites/Enemies/bug-1")
        elseif  dy <= -0.4 and dy > -0.6     then       self.animator.Initialise("Sprites/Enemies/bug-2")
        elseif  dy <= -0.2 and dy > -0.4     then       self.animator.Initialise("Sprites/Enemies/bug-3")
        elseif  dy <=    0 and dy > -0.2     then       self.animator.Initialise("Sprites/Enemies/bug-4")
        elseif  dy >     0                   then       self.animator.Initialise("Sprites/Enemies/bug-5")
        end
    end

    if targetTimer > 0 then targetTimer = targetTimer - 1 else targetTimer = math.random(50, 200); target = nil end

    if leaveTimer > 0 then
        leaveTimer = leaveTimer - 1
        mx = mx + ( dx * 0.15 )

        if timer <= 0 then
            if spriteInvert == false then sprite = sprite + 1 else sprite = sprite - 1 end
            if dx > 0 then
                if sprite <= 0 then spriteInvert = false elseif sprite >= 5 then spriteInvert = true end
            else
                if sprite >= 18 then spriteInvert = true elseif sprite <= 13 then spriteInvert = false end
            end
        end
    else
        mx = mx - 0.15
        if timer <= 0 then
            if spriteInvert == false then sprite = sprite + 1 else sprite = sprite - 1 end
            if sprite >= 18 then spriteInvert = true elseif sprite <= 13 then spriteInvert = false end
        end
    end
        my = my + ( dy * 0.15 )
    if mx < -5 then mx = -5 elseif mx > 5 then mx = 5 end
    if my < -5 then my = -5 elseif my > 5 then my = 5 end
    t = t + 0.05

    self.animator.GoTo(sprite)

    self.movement = { x = mx + ( math.cos(t) * 0.5 ), y = my + ( math.cos(t) * 1 ), z = 0 }

    if isSpawned == false then
        if self.position.x > 0 and self.position.x < 600 and self.position.y > -600 and self.position.y < 0 then isSpawned = true end
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
