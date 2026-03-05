local mx = 0.3
local timer = 0
local trailTimer = 0
local planeSprite = 0
local mineSprite
local minePeekX = -5
local minePeekY = -20
local firstLaunch = 30
local firePattern
local fireSFX
local allowDamageFrames = false

function OnInitialise()
    mineSprite = self.SpawnAttachedSpriteAnimator("Effects/Bullets/bullet bomb", -100, false)
    mineSprite.position = { x = -5, y = -20 }
    mineSprite.Initialise("empty")

    if self.commandArgs.HasField("fireSFX") then fireSFX = self.commandArgs.GetFieldString("fireSFX") else fireSFX = "s_enemyfire_bomber" end
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    local damageframe = self.GetDamageFrame(self.hitPoints / 1.75)   
    if allowDamageFrames == false then self.animator.GoTo(planeSprite) else self.animator.GoTo(damageframe) end

    mineSprite.position = { x = minePeekX, y = minePeekY }

    if ShouldKillPlayerOnTouch() == true then
        if timer > 0 then timer = timer - 1 end
        if timer <= 0 and planeSprite < 4 then
            timer = 10
            planeSprite = planeSprite + 1
        end
        if planeSprite == 4 then
            allowDamageFrames = true
            mineSprite.Initialise("Effects/Bullets/bullet bomb", 0)
        end
    end

    self.movement = { x = mx, y = 0, z = 0 }
    mx = mx + 0.001

    trailTimer = trailTimer - 1
    if trailTimer <= 0 then
        trailTimer = 16
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 1)
        SpawnEntityWorld("smokeRing3", { x = self.worldPosition.x - 70, y = self.worldPosition.y + 3 }, smokeArgs)
    end

    if CanFire() == true then
        firePattern.Tick()
        if firstLaunch > 0 then firstLaunch = firstLaunch - 1 end
        if firePattern.GetTicksTillFire() == 25 or firstLaunch == 25 then PlaySound(fireSFX) end
        if firePattern.GetTicksTillFire() <= 30 or firstLaunch <= 30 and firstLaunch > 0 then
            minePeekX = minePeekX - 1
            minePeekY = minePeekY - 3
        end

        if firePattern.CanFire() and firstLaunch <= 0 then
            firePattern.MarkFired()
            minePeekX = -5
            minePeekY = -20
            mineSprite.position = { x = -5, y = -20 }
            local mineArgs = NewJSONObject()
            mineArgs.AddFieldFloat("my", -3)
            SpawnEntityWorld("enemyshot_bomb", { x = self.worldPosition.x - 35, y = self.worldPosition.y - 108 }, mineArgs)
        end
    end

    if self.position.x > 840 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 15
end

function HasCollision()
    return true
end
function ShouldKillPlayerOnTouch()
    return self.position.x >= -25
end


