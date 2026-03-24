local mx
local decoy
local missiles
local offset = 0
local direction
local spawnXmin
local spawnXmax
local spawnYmin
local spawnYmax
local launchTime
local launchTimeMin
local launchTimeMax
local isFirst = true

function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5) * Globals.backgroundSpeedMultiplier

    decoy = self.commandArgs.GetFieldBool("decoy", false)
    
    if decoy == false then
        missiles = self.commandArgs.GetFieldInt("missiles", 1)
        direction = self.commandArgs.GetFieldInt("direction", -30)
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
        if self.commandArgs.HasField("timeRange") then
            local t = self.commandArgs.GetFieldIntArray("timeRange")
            launchTimeMin = t[1] or 0
            launchTimeMax = t[2] or 0
        else
            launchTimeMin = 120
            launchTimeMax = 120
        end
        launchTime = launchTimeMin

        for i = 0, missiles - 1 do
            local missileArgs = NewJSONObject()
            missileArgs.AddFieldIntArray("spawnRange", { spawnXmin, spawnXmax, spawnYmin, spawnYmax })
            missileArgs.AddFieldInt("launchTime", launchTime)
            missileArgs.AddFieldInt("direction", direction)
            missileArgs.AddFieldBool("isFirst", isFirst)
            SpawnEntityWorld("icbmBackground", { x = self.worldPosition.x + offset, y = self.worldPosition.y}, missileArgs)
            launchTime = math.random( launchTimeMin, launchTimeMax )
            isFirst = false

            local launcherArgs = NewJSONObject()
            launcherArgs.AddFieldBool("decoy", true)
            SpawnEntityWorld("icbmLauncher", { x = self.worldPosition.x + offset, y = self.worldPosition.y}, launcherArgs)
            offset = offset + 70
        end
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }
    if decoy == false then
        if self.position.x < -1600 then self.Deactivate() end
    else        
        if self.position.x < -600 then self.Deactivate() end
    end
end

function HasCollision()
    return false
end
