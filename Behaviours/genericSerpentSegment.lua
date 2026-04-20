local destroyed = false
local isSpawned = false

local angle = 0
local target = nil
local turretData
local firePattern
local fireSFX
local firstShotDelay
local extraShotDelay

function OnInitialise()
    self.fruitSet = 4
    self.hitPoints = self.data.maxHitPoints + 10000

    turretData = NewTurretDataFromEntityData(self.data)
    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    firstShotDelay = self.commandArgs.GetFieldInt("firstShotDelay")
    extraShotDelay = self.commandArgs.GetFieldInt("extraShotDelay")
    firstShotDelay = firstShotDelay + extraShotDelay
end

function Fire()
    for _, bulletParams in ipairs(turretData.CalculateBulletParams(self.worldPosition, angle)) do
        SpawnEntityWorld(bulletParams.bulletEntity, bulletParams.spawnPosition, bulletParams.args)
    end
    if fireSFX ~= "" then PlaySound(fireSFX) end
end

function OnTick()
    firePattern.Tick()
    if target == nil then target = GetRandomActivePlayer() elseif target ~= nil and not target.isActive then target = nil end
    if target == nil then firstShotDelay = extraShotDelay
    else
        if firstShotDelay > 0 then firstShotDelay = firstShotDelay - 1 end
        local sourcePos = self.worldPosition
        local targetPos = target.worldPosition
        local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
        angle = MoveTowardsAngle(angle, targetAngle, 360)
        if firePattern.CanFire() and CanFire() and firstShotDelay == 0 then
            firePattern.MarkFired()
            target = nil
            Fire()
        end
    end
    
    if destroyed == false then
        if self.hitPoints <= 10000 then destroyed = true end
    else self.hitPoints = 1000 end

    if isSpawned == false then
        if self.position.x < 750 and self.position.x > -150 and self.position.y < 150 and self.position.y > -750 then isSpawned = true end
    end
end

function OnHitByPlayer()
    if destroyed == true then self.hitPoints = 1000 end
end

function CanFire()
    return firstShotDelay == 0 and destroyed == false
end

function HasCollision()
    return isSpawned
end

function ShouldKillPlayerOnTouch()
    return true
end
