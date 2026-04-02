local timer = 150
local shieldTimer
local sprite = 0
local spriteTimer
local activationSprite
local shieldUp
local shieldSet = false
local bullets
local bulletEntity
local deflectRadius
local cooldownSet
local cooldownTick = 0
local minSpeed
local maxSpeed
local shards = 60
local activateSFX
local disableSFX
local deflectSFX

function OnInitialise()
    activationSprite = self.customBehaviourData.GetFieldString("activationSprite", "")
    bulletEntity = self.customBehaviourData.GetFieldString("bulletEntity", "")
    activateSFX = self.customBehaviourData.GetFieldString("activateSFX", "")
    disableSFX = self.customBehaviourData.GetFieldString("disableSFX", "")
    deflectSFX = self.customBehaviourData.GetFieldString("deflectSFX", "")
    deflectRadius = self.customBehaviourData.GetFieldFloat("deflectRadius", 0)

    shieldUp = self.SpawnAttachedSpriteAnimator(activationSprite, 1)
    self.animator.Initialise(self.data.spriteName)
    self.animator.Initialise("empty")
    shieldUp.Initialise("empty")

    self.hitPoints = self.data.maxHitPoints + 1000
    spriteTimer = timer - 28

    shieldTimer = NewDiffDictInt(250, 220, 180, 150, 120).Get()
    cooldownSet = NewDiffDictInt(10, 10, 5, 5, 2).Get()
    bullets = NewDiffDictInt(2, 3, 3, 4, 4).Get()
    minSpeed = NewDiffDictFloat(2, 3, 4, 5, 6).Get()
    maxSpeed = NewDiffDictFloat(4, 6, 8, 10, 12).Get()
end

function OnTick()
    if shieldSet == false then
        if timer > 0 then timer = timer - 1
        else
            self.animator.Initialise(self.data.spriteName)
            shieldUp.Initialise("empty")
            shieldSet = true
        end
        
        if timer == 30 then
            if activateSFX ~= "" then PlaySound(activateSFX) end
            shieldUp.Initialise(activationSprite)
        end
        
        if spriteTimer > 0 then spriteTimer = spriteTimer - 1
        elseif spriteTimer <= 0 and sprite < 9 then
            sprite = sprite + 1
            spriteTimer = 2
        end
    end
    
    shieldUp.AnimateTo(sprite, false)
    self.animator.AnimateToNextFrame(true)
    
    if cooldownTick > 0 then cooldownTick = cooldownTick - 1 end

    if self.hitPoints <= 1000 then
        if disableSFX ~= "" then PlaySound(disableSFX) end
        self.hitPoints = self.data.maxHitPoints + 1000
        self.animator.Initialise("empty")
        timer = shieldTimer
        spriteTimer = shieldTimer - 28
        sprite = 0
        shieldSet = false
        for i = 0, shards - 1 do
            local ox = math.random(-deflectRadius, deflectRadius)
            local oy = math.random(-deflectRadius, deflectRadius)
            SpawnEntityWorld("deflectorShieldShard", { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy })
        end            
    end
end

function OnHitByBullet()
    if shieldSet == true then
        if cooldownTick <= 0 then
            cooldownTick = cooldownSet
            if deflectSFX ~= "" then PlaySound(deflectSFX) end
            for i = 0, bullets - 1 do
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
        for i = 0, shards - 1 do
            local ox = math.random(-deflectRadius, deflectRadius)
            local oy = math.random(-deflectRadius, deflectRadius)
            SpawnEntityWorld("deflectorShieldShard", { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy })
        end      
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
