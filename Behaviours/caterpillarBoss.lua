
local posX
local posY

local mx
local my
local myMax
local yAcceleration

local totalSegments
local spawnTimer = 400



local argstype1 = NewJSONObject()
argstype1.AddFieldInt('x', 0)
argstype1.AddFieldInt('y', 0)
argstype1.AddFieldInt('speedX', 0)
argstype1.AddFieldInt('speedY', 0)
argstype1.AddFieldInt('maxSpeedY', 0)
argstype1.AddFieldInt('segments', -2)

local argstype2 = NewJSONObject()
argstype2.AddFieldInt('x', 0)
argstype2.AddFieldInt('y', 0)
argstype2.AddFieldInt('speedX', 0)
argstype2.AddFieldInt('speedY', 0)
argstype2.AddFieldInt('maxSpeedY', 0)
argstype2.AddFieldInt('segments', -2)




local allowedToShoot
local firePattern

local fireSFX

local shootMinX = 60
local shootMaxX = 620






function OnInitialise()

    if self.commandArgs.HasField("x") then posX = self.commandArgs.GetFieldFloat("x") else posX = 0 end
    if self.commandArgs.HasField("y") then posY = self.commandArgs.GetFieldFloat("y") else posY = 0 end


    if self.commandArgs.HasField("speedX") then mx = self.commandArgs.GetFieldFloat("speedX") else mx = self.data.speed end

    if self.commandArgs.HasField("speedY") then my = self.commandArgs.GetFieldFloat("speedY") else my = self.data.speed end
    if self.commandArgs.HasField("maxSpeedY") then myMax = self.commandArgs.GetFieldFloat("maxSpeedY") else myMax = self.data.speed * 1.25 end

    if self.commandArgs.HasField("segments") then totalSegments = self.commandArgs.GetFieldFloat("segments") else totalSegments = 0 end

    if self.commandArgs.HasField("fireSFX") then fireSFX = self.commandArgs.GetFieldString("fireSFX") else fireSFX = "s_laser2" end


    


    allowedToShoot = math.random(0, 100) < Globals.firingChanceSaucer.Get()
    firePattern = NewFirePatternFromEntityData(self.data)

    yAcceleration = myMax / 25
end



function OnTick()

    self.position.x = 2000

    -- y movement
    if math.abs(my) >= myMax then
        yAcceleration = -yAcceleration
    end
    my = my + yAcceleration

    -- movement
    self.movement = { x = mx, y = my, z = 0 }

    -- animation
    dmgFrame = self.GetDamageFrame(self.hitPoints)   
    self.animator.AnimateTo(dmgFrame);


    argstype2.SetFieldInt('x', posX)
    argstype2.SetFieldInt('y', posY)
    argstype2.SetFieldInt('speedX', mx)
    argstype2.SetFieldInt('speedY', my)
    argstype2.SetFieldInt('maxSpeedY', myMax)



    if spawnTimer > 0 then
        spawnTimer = spawnTimer - 1
    else
        totalSegments = totalSegments - 1
        spawnTimer = 400
    end
        


    --spawn other segments
    if totalSegments > 0 then

        if spawnTimer == 0 then
           SpawnEntityChild("caterpillarBossBody", self, { x = 200, y = 0 }, NewJSONObject())
           -- SpawnEntityLocal("caterpillarBossBody", { x = posX, y = posY }, argstype2)
        end

    else

        if totalSegments == 0 and spawnTimer == 0 then
            SpawnEntityLocal("caterpillarBossHead", { x = posX + 200, y = posY }, argstype2)
        end

    end


    --Player.SetWeaponTimer(totalSegments)


    -- disappear if offscreen
    if self.position.x < -2600 then -- OG -260
        self.Deactivate()
    end

    return true
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function CanFire()
    return true
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
