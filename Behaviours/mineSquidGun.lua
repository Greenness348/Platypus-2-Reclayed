local direction = 90
local spreadAngle = 120

local sprite
local mineSprite
local minePeek = -60

local bullets = 1
local speed = 6

local firePattern
local fireSFX

local timer = 150
local firstLaunch = 20

function OnInitialise()
    sprite = self.data.spriteName
    mineSprite = self.SpawnAttachedSpriteAnimator(sprite, -100, false)
    mineSprite.position = { x = 0, y = -60 }
    self.animator.Initialise("empty")

    if self.commandArgs.HasField("fireSFX") then fireSFX = self.commandArgs.GetFieldString("fireSFX") else fireSFX = "s_enemyfire_minesquid" end
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    mineSprite.position = { x = 0, y = minePeek }

    if timer >= 0 then
        timer = timer - 1
    end

    if CanFire() == true then
        firePattern.Tick()
        if firstLaunch > 0 then
            firstLaunch = firstLaunch - 1
        end

        if firePattern.GetTicksTillFire() <= 20 or firstLaunch <= 20 and firstLaunch > 0 then
            minePeek = minePeek + 3
        end

        if firePattern.CanFire() and firstLaunch <= 0 then
            firePattern.MarkFired()
            PlaySound(fireSFX)
            minePeek = -60
            mineSprite.position = { x = 0, y = -60 }
            
            for i = 0, bullets - 1 do
                local t = (bullets > 1) and (i / (bullets - 1)) or 0.5
                local angleDeg = direction - spreadAngle / 2 + t * spreadAngle
                local angleRad = math.rad(angleDeg)
                local mxb = math.cos(angleRad) * speed - 3
                local myb = math.sin(angleRad) * speed

                local args = NewJSONObject()
                args.AddFieldFloat("mx", mxb * 0.93)
                args.AddFieldFloat("my", myb)

                SpawnEntityWorld("enemyshot_bomb", self.worldPosition, args)
            end
        end
    end
end

function CanFire()
    return timer <= 0
end
