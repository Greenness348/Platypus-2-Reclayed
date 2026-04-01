local timer = 150
local shieldTimer
local sprite = 0
local spriteTimer
local shieldUp
local shieldSet = false
local bullets
local cooldownSet
local cooldownTick = 0
local minSpeed
local maxSpeed
local shards = 60

function OnInitialise()
    shieldUp = self.SpawnAttachedSpriteAnimator("Effects/Particles/deflector shield up", 1)
    self.animator.Initialise("Effects/Particles/deflector shield loop")
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
        if timer > 0 then
            timer = timer - 1
        elseif timer <= 0 then
            self.animator.Initialise("Effects/Particles/deflector shield loop")
            shieldUp.Initialise("empty")
            shieldSet = true
        end
        
        if timer == 30 then
            PlaySound("s_enemy_shield_up")
            shieldUp.Initialise("Effects/Particles/deflector shield up")
        end
        
        if spriteTimer > 0 then
            spriteTimer = spriteTimer - 1
        elseif spriteTimer <= 0 and sprite < 9 then
            sprite = sprite + 1
            spriteTimer = 2
        end
    end
    
    shieldUp.AnimateTo(sprite, false)
    self.animator.AnimateToNextFrame(true)
    
    if cooldownTick > 0 then
        cooldownTick = cooldownTick - 1
    end

    if self.hitPoints <= 1000 then
        PlaySound("s_enemy_shield_down")
        self.hitPoints = self.data.maxHitPoints + 1000
        self.animator.Initialise("empty")
        timer = shieldTimer
        spriteTimer = shieldTimer - 28
        sprite = 0
        shieldSet = false
        for i = 0, shards - 1 do
            local ox = math.random(-60, 60)
            local oy = math.random(-60, 60)
            local shardPos = { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy }
            SpawnEntityWorld("deflectorShieldShard", shardPos, NewJSONObject())
        end            
    end
end

function OnHitByBullet()
    if shieldSet == true then
        if cooldownTick <= 0 then
            cooldownTick = cooldownSet
            PlaySound("s_enemyfire_deflector")
            for i = 0, bullets - 1 do
                local angleDeg = math.random(0, 360)
                local angleRad = math.rad(angleDeg)

                local dx = math.cos(angleRad) * 60
                local dy = math.sin(angleRad) * 60
                local mxb = math.cos(angleRad) * math.random(minSpeed, maxSpeed)
                local myb = math.sin(angleRad) * math.random(minSpeed, maxSpeed)

                local firePos = { x = self.worldPosition.x + dx, y = self.worldPosition.y + dy }
            
                local fireArgs = NewJSONObject()
                fireArgs.AddFieldFloat("mx", mxb)
                fireArgs.AddFieldFloat("my", myb)

                SpawnEntityWorld("enemyshot_pelletSmall_red", firePos, fireArgs)
            end
        end
    end
end

function OnKill()
    if shieldSet == true or timer <= 30 then
        PlaySound("s_enemy_shield_down")
        for i = 0, shards - 1 do
            local ox = math.random(-60, 60)
            local oy = math.random(-60, 60)
            local shardPos = { x = self.worldPosition.x + ox, y = self.worldPosition.y + oy }
            SpawnEntityWorld("deflectorShieldShard", shardPos, NewJSONObject())
        end      
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
