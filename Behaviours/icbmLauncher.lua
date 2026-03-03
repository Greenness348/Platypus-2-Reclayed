local my = 0
local mx = 0
local hitbox = false
local onPlane = false
local timer = 3
local missiles
local offset = 0
local store1
local spawnXmin
local spawnXmax
local spawnYmin
local spawnYmax
local speedX
local speedY
local decoy = 2
local type

function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5)

    if self.commandArgs.HasField("missiles") then missiles = self.commandArgs.GetFieldInt("missiles") else missiles = 1 end
    if self.commandArgs.HasField("type") then type = self.commandArgs.GetFieldInt("type") else type = 0 end
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
        local args = NewJSONObject()
        args.AddFieldFloatArray("spawnRange", { spawnXmin, spawnXmax, spawnYmin, spawnYmax })
        args.AddFieldFloatArray("speed", { speedX, speedY })
        if type == 1 then
            SpawnEntityWorld("icmmBackground", { x = self.worldPosition.x + offset, y = self.worldPosition.y + 101}, args)
            else
            SpawnEntityWorld("icbmBackground", { x = self.worldPosition.x + offset, y = self.worldPosition.y + 111}, args)
        end
        SpawnEntityWorld("icbmLauncherDecoy", { x = self.worldPosition.x + (offset * 1), y = self.worldPosition.y}, NewJSONObject())
        offset = offset + 70
    end
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    if self.position.x < -1600 then
        self.Deactivate()
    end
end


function HasCollision()
    return hitbox
end

function ShouldKillPlayerOnTouch()
    return true
end

