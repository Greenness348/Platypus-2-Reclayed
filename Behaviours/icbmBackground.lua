local mx
local my = 0
local timer = 3
local spawnXmin
local spawnXmax
local spawnYmin
local spawnYmax
local spawnY
local spawnX
local speedX
local speedY
local isLaunched = false

function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5)

    if self.commandArgs.HasField("spawnRange") then
        local s = self.commandArgs.GetFieldFloatArray("spawnRange")
        spawnXmin = s[1] or 0
        spawnXmax = s[2] or 0
        spawnYmin = s[3] or 0
        spawnYmax = s[4] or 0
    else
        spawnXmin = -200
        spawnXmax = -200
        spawnYmin = -250
        spawnYmax =  200
    end
    if self.commandArgs.HasField("speed") then
        local p = self.commandArgs.GetFieldFloatArray("speed")
        speedX = p[1] or 0
        speedY = p[2] or 0
    else
        speedX =  3
        speedY = -2
    end

    spawnY = math.random( spawnYmin, spawnYmax )
    spawnX = math.random( spawnXmin, spawnXmax )
end

function OnTick()
    if self.worldPosition.x < 500 then
        my = my + 0.1
        timer = timer - 1
        if isLaunched == false then
            PlaySound("s_icbm_warning")
            isLaunched = true
        end
        if timer <= 0 then
            timer = 3
            local smokeArgs = NewJSONObject()
            smokeArgs.AddFieldFloat("mx", -mx)
            SpawnEntityWorld("rocketTrail", { x = self.worldPosition.x, y = self.worldPosition.y - 60 }, smokeArgs)
        end
    end

    if my > 3 then my = 3 end

    if self.worldPosition.y > 200 then
        local missileArgs = NewJSONObject()
        missileArgs.AddFieldFloatArray("speed", { speedX, speedY })
        SpawnEntityWorld("icbmLaunched", { x = spawnX, y = spawnY }, missileArgs)
        self.Deactivate()
    end
    self.movement = { x = mx, y = my, z = 0 }
end

function HasCollision()
    return false
end
