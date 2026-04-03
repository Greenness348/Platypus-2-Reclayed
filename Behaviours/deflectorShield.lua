local timer = 150
local shieldTimer
local shieldUpSprite
local shieldUpAnimator
local shieldSet = false
local bulletCount
local bulletEntity
local deflectRadius
local cooldownSet
local cooldownTick = 0
local minSpeed
local maxSpeed
local shardCount
local shardEntity
local activateSFX
local disableSFX
local fireSFX

function OnInitialise()
    shieldUpSprite = self.customBehaviourData.GetFieldString("shieldUpSprite", "")
    bulletEntity = self.customBehaviourData.GetFieldString("bulletEntity", "")
    shardEntity = self.customBehaviourData.GetFieldString("shardEntity", "")
    activateSFX = self.customBehaviourData.GetFieldString("activateSFX", "")
    disableSFX = self.customBehaviourData.GetFieldString("disableSFX", "")
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    deflectRadius = self.customBehaviourData.GetFieldFloat("deflectRadius", 0)
    shardCount = self.customBehaviourData.GetFieldInt("shardCount", 0)

    shieldUpAnimator = self.SpawnAttachedSpriteAnimator("empty", 1)
    self.animator.Initialise("empty")
    self.animator.ApplyLayerMaterial(self.layer)

    self.hitPoints = self.data.maxHitPoints + 1000
    shieldTimer = NewDiffDictInt(250, 220, 180, 150, 120).Get()
    cooldownSet = NewDiffDictInt(10, 10, 5, 5, 2).Get()
    bulletCount = NewDiffDictInt(2, 3, 3, 4, 4).Get()
    minSpeed = NewDiffDictFloat(2, 3, 4, 5, 6).Get()
    maxSpeed = NewDiffDictFloat(4, 6, 8, 10, 12).Get()
end

function OnTick()
    if shieldSet == false then
        if timer > 0 then timer = timer - 1
        else
            self.animator.Initialise(self.data.spriteName)
            self.animator.ApplyLayerMaterial(self.layer)
            shieldUpAnimator.Initialise("empty")
            shieldUpAnimator.ApplyLayerMaterial(self.layer)
            shieldSet = true
        end
        
        if timer == 28 then
            if activateSFX ~= "" then PlaySound(activateSFX) end
            if shieldUpAnimator ~= "" then shieldUpAnimator.Initialise(shieldUpSprite) end
            shieldUpAnimator.ApplyLayerMaterial(self.layer)
        end
    end
    
    if timer <= 25 then shieldUpAnimator.AnimateToNextFrame(false) end
    self.animator.LoopAnimation()
    
    if cooldownTick > 0 then cooldownTick = cooldownTick - 1 end

    if self.hitPoints <= 1000 then
        if disableSFX ~= "" then PlaySound(disableSFX) end
        self.hitPoints = self.data.maxHitPoints + 1000
        self.animator.Initialise("empty")
        self.animator.ApplyLayerMaterial(self.layer)
        timer = shieldTimer
        shieldSet = false
        for i = 0, shardCount - 1 do
            local ox = math.random(-deflectRadius, deflectRadius)
            local oy = math.random(-deflectRadius, deflectRadius)
            if shardEntity ~= "" then SpawnEntityWorld(shardEntity, { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy }) end
        end            
    end
end

function OnHitByBullet()
    if shieldSet == true then
        if cooldownTick <= 0 then
            cooldownTick = cooldownSet
            if fireSFX ~= "" then PlaySound(fireSFX) end
            for i = 0, bulletCount - 1 do
                local angleDeg = math.random(0, 360)
                local angleRad = math.rad(angleDeg)

                local dx = math.cos(angleRad) * deflectRadius
                local dy = math.sin(angleRad) * deflectRadius
                local mxb = math.cos(angleRad) * math.random(minSpeed, maxSpeed)
                local myb = math.sin(angleRad) * math.random(minSpeed, maxSpeed)

                local fireArgs = NewJSONObject()
                fireArgs.AddFieldFloat("mx", mxb)
                fireArgs.AddFieldFloat("my", myb)

                if bulletEntity ~= "" then SpawnEntityWorld(bulletEntity, { x = self.worldPosition.x + dx, y = self.worldPosition.y + dy }, fireArgs) end
            end
        end
    end
end

function OnKill()
    if shieldSet == true or timer <= 30 then
        if disableSFX ~= "" then PlaySound(disableSFX) end
        for i = 0, shardCount - 1 do
            local ox = math.random(-deflectRadius, deflectRadius)
            local oy = math.random(-deflectRadius, deflectRadius)
            if shardEntity ~= "" then SpawnEntityWorld(shardEntity, { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy }) end
        end      
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
