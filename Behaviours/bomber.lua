local mx = 2.2
local timer = 0
local trailTimer = 0
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
    if self.customBehaviourData.HasField("bombSprite") then bombSprite = self.customBehaviourData.GetFieldString("bombSprite") else bombSprite = "Effects/Bullets/bullet bomb" end
    if self.customBehaviourData.HasField("bombEntity") then bombEntity = self.customBehaviourData.GetFieldString("bombEntity") else bombEntity = "enemyshot_bomb" end
    if self.customBehaviourData.HasField("bombPosX") then bombPosX = self.customBehaviourData.GetFieldInt("bombPosX") else bombPosX = -5 end
    if self.customBehaviourData.HasField("bombPosY") then bombPosY = self.customBehaviourData.GetFieldInt("bombPosY") else bombPosY = -20 end
    bombPeekX = bombPosX
    bombPeekY = bombPosY
    bombProp = self.SpawnAttachedSpriteAnimator(bombSprite, -1)
    bombProp.position = { x = bombPosX, y = bombPosY }
    bombProp.Initialise("empty")
    if self.customBehaviourData.HasField("ticksTillFirstDrop") then firstDrop = self.customBehaviourData.GetFieldInt("ticksTillFirstDrop") else firstDrop = 30 end
    if self.customBehaviourData.HasField("fireSFX") then fireSFX = self.customBehaviourData.GetFieldString("fireSFX") else fireSFX = "s_enemyfire_bomber" end
    firePattern = NewFirePatternFromEntityData(self.data)
    if self.commandArgs.HasField("fruit_set") then self.fruitSet = self.commandArgs.GetFieldInt("fruit_set") else self.fruitSet = 5 end
end

function OnTick()
    local damageframe = self.GetDamageFrame(self.hitPoints / 1.8005)   
    if allowDamageFrames == false then self.animator.GoTo(planeSprite) else self.animator.GoTo(damageframe) end

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

    trailTimer = trailTimer - 1
    if trailTimer <= 0 then
        trailTimer = 16
        local smokeArgs = NewJSONObject()
        smokeArgs.AddFieldFloat("mx", 1)
        SpawnEntityWorld("smokeRing3", { x = self.worldPosition.x - 70, y = self.worldPosition.y + 3 }, smokeArgs)
    end

    if CanFire() == true then
        firePattern.Tick()
        if firstDrop > 0 then firstDrop = firstDrop - 1 end
        if firePattern.CanFire() and firstDrop <= 0 and dropTimer <= 0 then
            firePattern.MarkFired()
            dropTimer = 32
        end
    end

    if allowDamageFrames == true then
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
            SpawnEntityWorld(bombEntity, { x = self.worldPosition.x + ( -24 + bombPosX ), y = self.worldPosition.y + ( -90 + bombPosY ) }, bombArgs)
        end
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
