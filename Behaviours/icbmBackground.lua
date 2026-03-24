local mx
local my = 0
local direction
local trailTimer = 3
local launchTime
local spawnXmin
local spawnXmax
local spawnYmin
local spawnYmax
local spawnY
local spawnX
local isFirst
local isLaunched = false

function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5) * Globals.backgroundSpeedMultiplier

    direction = self.commandArgs.GetFieldInt("direction")
    isFirst = self.commandArgs.GetFieldBool("isFirst")
    launchTime = self.commandArgs.GetFieldInt("launchTime")
    if self.commandArgs.HasField("spawnRange") then
        local s = self.commandArgs.GetFieldIntArray("spawnRange")
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
    spawnY = math.random( spawnYmin, spawnYmax )
    spawnX = math.random( spawnXmin, spawnXmax )
end

function OnTick()
    if self.worldPosition.x < 600 then
        if launchTime > 0 then launchTime = launchTime - 1
        else
            my = my + 0.1
            if isLaunched == false then
                if isFirst == true then PlaySound("s_icbm_siren") end
                PlaySound("s_icbm_launch")
                isLaunched = true
            end
            if trailTimer > 0 then trailTimer = trailTimer - 1
            else
                trailTimer = 3
                local smokeArgs = NewJSONObject()
                smokeArgs.AddFieldFloat("mx", -mx)
                SpawnEntityWorld("rocketTrail2", { x = self.worldPosition.x, y = self.worldPosition.y - 85 }, smokeArgs)
            end
        end
    end

    if my > 3 then my = 3 end

    if self.worldPosition.y > 200 then
        local missileArgs = NewJSONObject()
        missileArgs.AddFieldInt("direction", direction)
        SpawnEntityWorld("icbmLaunched", { x = spawnX, y = spawnY }, missileArgs)
        self.Deactivate()
    end
    self.movement = { x = mx, y = my, z = 0 }
end

function HasCollision()
    return false
end
