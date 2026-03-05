local mx
local decoy
local missiles
local offset = 0
local spawnXmin
local spawnXmax
local spawnYmin
local spawnYmax
local speedX
local speedY

function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5)

    if self.commandArgs.HasField("decoy") then decoy = self.commandArgs.GetFieldBool("decoy") else decoy = false end
    
    if decoy == false then
        if self.commandArgs.HasField("missiles") then missiles = self.commandArgs.GetFieldInt("missiles") else missiles = 1 end
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

        for i = 0, missiles - 1 do
            local missileArgs = NewJSONObject()
            missileArgs.AddFieldFloatArray("spawnRange", { spawnXmin, spawnXmax, spawnYmin, spawnYmax })
            missileArgs.AddFieldFloatArray("speed", { speedX, speedY })
            SpawnEntityWorld("icbmBackground", { x = self.worldPosition.x + offset, y = self.worldPosition.y }, missileArgs)

            local launcherArgs = NewJSONObject()
            launcherArgs.AddFieldBool("decoy", true)
            SpawnEntityWorld("icbmLauncher", { x = self.worldPosition.x + offset, y = self.worldPosition.y }, launcherArgs)
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

