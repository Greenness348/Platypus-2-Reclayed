local mx = 2.2
local timer = 0
local trailTimer = 0
local smokeTrailEntity
local smokeTrailPosX
local smokeTrailPosY
local planeSprite = 0
local bombSprite
local bombEntity
local bombProp
local bombPosX
local bombPosY
local bombPeekX
local bombPeekY
local firstDrop
local dropTimer = 0
local firePattern
local fireSFX
local allowedToDrop = false
local allowDamageFrames = false

function OnInitialise()
    smokeTrailEntity = self.customBehaviourData.GetFieldString("smokeTrailEntity", "")
    smokeTrailPosX = self.customBehaviourData.GetFieldInt("smokeTrailPosX", 0)
    smokeTrailPosY = self.customBehaviourData.GetFieldInt("smokeTrailPosY", 0)
    bombSprite = self.customBehaviourData.GetFieldString("bombSprite", "")
    bombEntity = self.customBehaviourData.GetFieldString("bombEntity", "")
    bombPosX = self.customBehaviourData.GetFieldInt("bombPosX", 0)
    bombPosY = self.customBehaviourData.GetFieldInt("bombPosY", 0)
    bombPeekX = bombPosX
    bombPeekY = bombPosY
    bombProp = self.SpawnAttachedSpriteAnimator(bombSprite, -1)
    bombProp.position = { x = bombPosX, y = bombPosY }
    bombProp.Initialise("empty")
    firstDrop = self.customBehaviourData.GetFieldInt("firstDropDelay", 0)
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    firePattern = NewFirePatternFromEntityData(self.data)
    self.fruitSet = self.commandArgs.GetFieldInt("fruit_set", 5)
end

function OnTick()
    bombProp.position = { x = bombPeekX, y = bombPeekY }

    if ShouldKillPlayerOnTouch() == true then
        if timer > 0 then timer = timer - 1 end
        if timer <= 0 and planeSprite < 4 then
            timer = 10
            planeSprite = planeSprite + 1
        end
        if planeSprite == 4 then
            allowDamageFrames = true
        end
    end

    if mx > 0.8 then mx = mx - 0.01 end
    self.movement = { x = mx, y = 0, z = 0 }

    if smokeTrailEntity ~= "" then
        trailTimer = trailTimer - 1
        if trailTimer <= 0 then
            trailTimer = 16
            local smokeArgs = NewJSONObject()
            smokeArgs.AddFieldFloat("mx", 1)
            SpawnEntityWorld(smokeTrailEntity, { x = self.worldPosition.x + smokeTrailPosX, y = self.worldPosition.y + smokeTrailPosY }, smokeArgs)
        end
    end

    if bombSprite ~= "" and CanFire() == true then
        firePattern.Tick()
        if firstDrop > 0 then firstDrop = firstDrop - 1 end
        if firePattern.CanFire() and firstDrop <= 0 and dropTimer <= 0 then
            firePattern.MarkFired()
            dropTimer = 32
        end
    end

    if bombSprite ~= "" and allowDamageFrames == true then
        if allowedToDrop == false and dropTimer == 30 then
            bombProp.Initialise(bombSprite, 0)
            allowedToDrop = true
        end
        if dropTimer > 0 then dropTimer = dropTimer - 1 end
        if dropTimer == 31 then PlaySound(fireSFX) end
        if dropTimer <= 31 and dropTimer > 1 then
            bombPeekX = bombPeekX - 0.8
            bombPeekY = bombPeekY - 3
        elseif dropTimer == 1 then
            bombPeekX = bombPosX
            bombPeekY = bombPosY
            bombProp.position = { x = bombPosX, y = bombPosY }
            local bombArgs = NewJSONObject()
            bombArgs.AddFieldFloat("my", -3)
            if bombEntity ~= "" then SpawnEntityWorld(bombEntity, { x = self.worldPosition.x + ( -24 + bombPosX ), y = self.worldPosition.y + ( -90 + bombPosY ) }, bombArgs) end
        end
    end

    local lastFrame = self.animator.currentFrame
    if allowDamageFrames == false then self.animator.GoTo(planeSprite)
    else
        self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, (self.hitPoints / 1.8005), self.animator.totalFrames))
        self.HandleDamageEffects(self.animator.currentFrame, lastFrame)
    end

    if self.position.x > 840 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return allowDamageFrames and self.position.x <= 720
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= -40
end

