local oktofire = false
local initialDelay
local shieldTimer = 30
local shieldTimeSet
local shieldUpSprite
local shieldUpAnimator
local shieldSet = false
local flashSprite
local flashAnimator
local bulletCount
local bulletEntity
local deflectRadius
local deflectAngle = 0
local dispersionAngle
local deflectDispersion
local cooldownTimeSet
local cooldownTimer = 0
local minSpeed
local maxSpeed
local shardCount
local shardEntity
local activateSFX
local disableSFX
local fireSFX

function OnInitialise()
    shieldUpSprite = self.customBehaviourData.GetFieldString("shieldUpSprite", "")
    flashSprite = self.customBehaviourData.GetFieldString("flashSprite", "")
    bulletEntity = self.customBehaviourData.GetFieldString("bulletEntity", "")
    shardEntity = self.customBehaviourData.GetFieldString("shardEntity", "")
    activateSFX = self.customBehaviourData.GetFieldString("activateSFX", "")
    disableSFX = self.customBehaviourData.GetFieldString("disableSFX", "")
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    deflectRadius = self.customBehaviourData.GetFieldFloat("deflectRadius", 0)
    dispersionAngle = self.customBehaviourData.GetFieldFloat("deflectDispersion", 45)
    initialDelay = self.customBehaviourData.GetFieldInt("initialDelay", 0)
    shardCount = self.customBehaviourData.GetFieldInt("shardCount", 0)

    shieldUpAnimator = self.SpawnAttachedSpriteAnimator("empty", 1)
    if flashSprite ~= "" then
        flashAnimator = self.SpawnAttachedSpriteAnimator(flashSprite, 2)
        flashAnimator.GoTo(0)
    end
    self.animator.Initialise("empty")
    self.animator.ApplyLayerMaterial(self.layer)

    if self.customBehaviourData.HasField("shieldUpTimer") then
        local a = self.customBehaviourData.GetFieldIntArray("shieldUpTimer")
        shieldTimeSet = NewDiffDictInt(a[1], a[2], a[3], a[4], a[5]).Get()
    else shieldTimeSet = NewDiffDictInt(250, 220, 180, 150, 120).Get() end
    if self.customBehaviourData.HasField("deflectCooldown") then
        local a = self.customBehaviourData.GetFieldIntArray("deflectCooldown")
        cooldownTimeSet = NewDiffDictInt(a[1], a[2], a[3], a[4], a[5]).Get()
    else cooldownTimeSet = NewDiffDictInt(10, 10, 5, 5, 2).Get() end
    if self.customBehaviourData.HasField("bulletCount") then
        local a = self.customBehaviourData.GetFieldIntArray("bulletCount")
        bulletCount = NewDiffDictInt(a[1], a[2], a[3], a[4], a[5]).Get()
    else bulletCount = NewDiffDictInt(1, 1, 1, 1, 1).Get() end
    if self.customBehaviourData.HasField("minSpeed") then
        local a = self.customBehaviourData.GetFieldFloatArray("minSpeed")
        minSpeed = NewDiffDictFloat(a[1], a[2], a[3], a[4], a[5]).Get()
    else minSpeed = NewDiffDictFloat(2, 3, 4, 5, 6).Get() end
    if self.customBehaviourData.HasField("maxSpeed") then
        local a = self.customBehaviourData.GetFieldFloatArray("maxSpeed")
        maxSpeed = NewDiffDictFloat(a[1], a[2], a[3], a[4], a[5]).Get()
    else maxSpeed = NewDiffDictFloat(4, 6, 8, 10, 12).Get() end
end

function OnTick()
    if initialDelay > 0 then initialDelay = initialDelay - 1 end
    if CanFire() then oktofire = true end
    if not shieldSet then
        if flashSprite ~= "" then flashAnimator.GoTo(0) end
        if oktofire and shieldTimer > 0 then shieldTimer = shieldTimer - 1 end
        if shieldTimer == 0 then
            self.animator.Initialise(self.data.spriteName)
            self.animator.ApplyLayerMaterial(self.layer)
            shieldUpAnimator.Initialise("empty")
            shieldUpAnimator.ApplyLayerMaterial(self.layer)
            shieldSet = true
        end
        if shieldTimer == 28 then
            if activateSFX ~= "" then PlaySound(activateSFX) end
            if shieldUpSprite ~= "" then shieldUpAnimator.Initialise(shieldUpSprite) end
            shieldUpAnimator.ApplyLayerMaterial(self.layer)
        end
    end

    if flashSprite ~= "" then flashAnimator.AnimateToFirstIndex() end
    if shieldTimer <= 25 then shieldUpAnimator.AnimateToNextFrame(false) end
    self.animator.LoopAnimation()

    if cooldownTimer > 0 then cooldownTimer = cooldownTimer - 1 end

    if self.hitPoints <= 0 then
        if disableSFX ~= "" then PlaySound(disableSFX) end
        self.hitPoints = self.data.maxHitPoints
        self.animator.Initialise("empty")
        self.animator.ApplyLayerMaterial(self.layer)
        shieldTimer = shieldTimeSet
        shieldSet = false
        for _ = 1, shardCount do
            local ox = math.random(-deflectRadius, deflectRadius)
            local oy = math.random(-deflectRadius, deflectRadius)
            if shardEntity ~= "" then SpawnEntityWorld(shardEntity, { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy }) end
        end
    end
end

function OnHitByBullet(playerBullet)
    if shieldSet then
        if cooldownTimer == 0 then
            cooldownTimer = cooldownTimeSet
            if flashSprite ~= "" then flashAnimator.GoTo(flashAnimator.totalFrames - 1) end
            if fireSFX ~= "" then PlaySound(fireSFX) end
            if playerBullet.data.behaviourName ~= "PlayerLightningBehaviour" then
                if playerBullet ~= nil then
                    local sourcePos = self.worldPosition
                    local targetPos = playerBullet.worldPosition
                    local targetAngle = math.deg(math.atan2(targetPos.y - sourcePos.y, targetPos.x - sourcePos.x))
                    deflectAngle = MoveTowardsAngle(deflectAngle, targetAngle, 360)
                end
            else deflectAngle = RandRangeF(90, 270) end
            deflectDispersion = RandRangeF(-dispersionAngle, dispersionAngle)
            for i = 0, bulletCount - 1 do
                local t = (bulletCount > 1) and (i / (bulletCount - 1)) or 0.5
                local shotAngle = (deflectAngle - 1 / 2 + t) + deflectDispersion
                local dx = math.cos(math.rad(shotAngle - deflectDispersion)) * deflectRadius
                local dy = math.sin(math.rad(shotAngle - deflectDispersion)) * deflectRadius

                local fireArgs = NewJSONObject()
                fireArgs.AddFieldFloat("mx", math.cos(math.rad(shotAngle)) * RandRangeF(minSpeed, maxSpeed))
                fireArgs.AddFieldFloat("my", math.sin(math.rad(shotAngle)) * RandRangeF(minSpeed, maxSpeed))
                if bulletEntity ~= "" then SpawnEntityWorld(bulletEntity, { x = self.worldPosition.x + dx, y = self.worldPosition.y + dy }, fireArgs) end
            end
        end
    end
end

function OnKill()
    if shieldSet or shieldTimer <= 28 then
        if disableSFX ~= "" then PlaySound(disableSFX) end
        for _ = 1, shardCount do
            local ox = math.random(-deflectRadius, deflectRadius)
            local oy = math.random(-deflectRadius, deflectRadius)
            if shardEntity ~= "" then SpawnEntityWorld(shardEntity, { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy }) end
        end
    end
end

function IsKilledManually()
    return true
end

function CanFire()
    return self.parent.CanFire() and initialDelay == 0
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
