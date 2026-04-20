local mx = 0
local my = 0
local speed
local target1
local target2
local dx1 = 0
local dy1 = 0
local dx2 = 0
local dy2 = 0
local length1
local length2
local lengthT
local direction = 180
local degrees = 1
local turnAngle = 1
local snakeSet = false
local leaveTimer = 7200
local isSpawned = false

local segmentCount
local entityID = {}
local segmentEntity = {}
local moveHistory = {}
local animHistory = {}
local destroyedSprite = "Sprites/Enemies/serpent destroyed"

local angle = 0
local target = nil
local turretData
local firePattern
local fireSFX
local firstShotDelay
local extraShotDelay = 7
local isDisabled = false

function OnInitialise()
    self.fruitSet = 4
    speed = math.abs(self.data.speed)

    turretData = NewTurretDataFromEntityData(self.data)
    firePattern = NewFirePatternFromEntityData(self.data)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    firstShotDelay = self.commandArgs.GetFieldInt("firstShotDelay", 100)

    segmentCount = self.commandArgs.GetFieldInt("segments", 4) - 1
    for i = 1, segmentCount do
        local index = i
        local snakeArgs = NewJSONObject()
        snakeArgs.AddFieldInt("firstShotDelay", firstShotDelay)
        snakeArgs.AddFieldInt("extraShotDelay", extraShotDelay)
        entityID[index] = SpawnEntityLocal("snakeEyesSegment", self.position, snakeArgs)
        segmentEntity[index] = GetEntity(entityID[index])
        moveHistory[index] = {}
        animHistory[index] = {}
        extraShotDelay = extraShotDelay + 7
    end
end

function Fire()
    for _, bulletParams in ipairs(turretData.CalculateBulletParams(self.worldPosition, angle)) do
        SpawnEntityWorld(bulletParams.bulletEntity, bulletParams.spawnPosition, bulletParams.args)
    end
    if fireSFX ~= "" then PlaySound(fireSFX) end
end

function OnTick()
    if mx > -self.data.speed and snakeSet == false then mx = mx - 0.07
    else
        if snakeSet == false then snakeSet = true end
        if leaveTimer > 0 then
            target1 = GetPlayer(0)
            if target1.isActive then
                dx1 = target1.worldPosition.x - self.worldPosition.x
                dy1 = target1.worldPosition.y - self.worldPosition.y
                length1 = math.sqrt(dx1 * dx1 + dy1 * dy1)
                dx1 = dx1 / length1
                dy1 = dy1 / length1
            else length1 = 1000 end
            target2 = GetPlayer(1)
            if target2.isActive then
                dx2 = target2.worldPosition.x - self.worldPosition.x
                dy2 = target2.worldPosition.y - self.worldPosition.y
                length2 = math.sqrt(dx2 * dx2 + dy2 * dy2)
                dx2 = dx2 / length2
                dy2 = dy2 / length2
            else length2 = 1000 end
            if target1.isActive or target2.isActive then
                if length1 > length2 then
                    lengthT = length2
                    local sourcePos = self.worldPosition
                    local targetPos = target2.worldPosition
                    local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
                    direction = MoveTowardsAngle(direction, targetAngle, turnAngle)
                else
                    lengthT = length1
                    local sourcePos = self.worldPosition
                    local targetPos = target1.worldPosition
                    local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
                    direction = MoveTowardsAngle(direction, targetAngle, turnAngle)
                end
                if lengthT < 200 then degrees = degrees + 0.005 else degrees = degrees - 0.005 end
                if degrees < 1 then degrees = 1 elseif degrees > 3 then degrees = 3 end
                turnAngle = degrees
            else
                local sourcePos = self.worldPosition
                local targetPos = { x = 400, y = -300 }
                local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
                direction = MoveTowardsAngle(direction, targetAngle, turnAngle)
            end
            mx = math.cos(math.rad(direction)) * speed
            my = math.sin(math.rad(direction)) * speed
        end
    end
    self.movement = { x = mx, y = my, z = 0 }

    firePattern.Tick()
    if firstShotDelay > 0 then firstShotDelay = firstShotDelay - 1 end
    if target == nil then target = GetRandomActivePlayer() elseif target ~= nil and not target.isActive then target = nil end
    if target ~= nil then
        local sourceAimPos = self.worldPosition
        local targetAimPos = target.worldPosition
        local targetAimAngle = math.deg(math.atan2(targetAimPos.y - sourceAimPos.y, targetAimPos.x - sourceAimPos.x))
        angle = MoveTowardsAngle(angle, targetAimAngle, 360)
        if firePattern.CanFire() and CanFire() then
            firePattern.MarkFired()
            target = nil
            Fire()
        end
    end

    if self.hitPoints <= (self.data.maxHitPoints / 2) then
        if isDisabled == false then
            self.animator.Initialise(destroyedSprite)
            SpawnEntityWorld("explosionMedium", self.worldPosition)
            isDisabled = true
        end
    end

    local spriteAngle = (direction % 360) % 360
    local spriteIndex = math.floor((spriteAngle / (360.0 / self.animator.totalFrames) + self.animator.totalFrames / 2) % self.animator.totalFrames)
    self.animator.GoTo(spriteIndex)

    local baseDelay = 30
    for i = 1, segmentCount do
        local historyM = moveHistory[i]
        local historyD = animHistory[i]
        table.insert(historyM, self.movement)
        table.insert(historyD, direction)
        local maxDelay = baseDelay * i

        if #historyM > maxDelay then table.remove(historyM, 1) end
        if #historyD > maxDelay then table.remove(historyD, 1) end

        local historyM = moveHistory[i]
        local historyD = animHistory[i]
        local delayedM = historyM[1]
        local delayedD = historyD[1]

        if segmentEntity[i].hitPoints > 10000 then self.hitPoints = self.data.maxHitPoints else
            if segmentEntity[i].hitPoints > 1000 then
                segmentEntity[i].animator.Initialise(destroyedSprite)
                SpawnEntityWorld("explosionMedium", segmentEntity[i].worldPosition)
            end
        end
        segmentEntity[i].movement = delayedM
        local segmentAngle = (delayedD % 360) % 360
        local segmentIndex = math.floor((segmentAngle / (360.0 / segmentEntity[i].animator.totalFrames) + segmentEntity[i].animator.totalFrames / 2) % segmentEntity[i].animator.totalFrames)
        segmentEntity[i].animator.GoTo(segmentIndex)
    end

    if isSpawned == false then
        if self.position.x < 750 and self.position.x > -150 and self.position.y < 150 and self.position.y > -750 then isSpawned = true end
    else
        if leaveTimer > 0 then leaveTimer = leaveTimer - 1
        else
            if self.position.x < -1000 or self.position.x > 1600 or self.position.y < -1600 or self.position.y > 1000 then
                self.Deactivate()
                for i = 1, segmentCount do
                    segmentEntity[i].Deactivate()
                end
            end
        end
    end
end

function OnHitByPlayer()
    for i = 1, segmentCount do
        if segmentEntity[i].hitPoints > 10000 then self.hitPoints = self.data.maxHitPoints end
    end
end

function OnKill()
    for i = 1, segmentCount do
        segmentEntity[i].Kill()
    end
end

function CanFire()
    return firstShotDelay == 0 and isDisabled == false
end

function HasCollision()
    return isSpawned
end

function ShouldKillPlayerOnTouch()
    return true
end
