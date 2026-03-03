local mx
local my = 0
local dx = dx or 0
local dy = dy or 0
local vx1 = 0
local vy1 = 0
local vx2 = 0
local vy2 = 0

local speed = 4.5

local timer
local homingTimer

local direction

local bullets = 1
local allowedToShoot
local firePattern
local fireSFX

function OnInitialise()
    if self.commandArgs.HasField("homingCooldown") then timer = self.commandArgs.GetFieldFloat("homingCooldown") else timer = 50 end
    if self.commandArgs.HasField("homingTime") then homingTimer = self.commandArgs.GetFieldFloat("homingTime") else homingTimer = 150 end
    
    if self.commandArgs.HasField("isBehind") then behind = self.commandArgs.GetFieldBool("isBehind") else behind = false end
    if behind == false then mx = -5 else mx = 5 end

    if Globals.fishFire == true then allowedToShoot = true else allowedToShoot = false end
    if self.commandArgs.HasField("fireSFX") then fireSFX = self.commandArgs.GetFieldString("fireSFX") else fireSFX = "s_laser" end
    firePattern = NewFirePatternFromEntityData(self.data)
end

function OnTick()
    local pos1 = GetPlayer(0).GetWorldPosition()
    local pos2 = GetPlayer(1).GetWorldPosition()

    local length1 = math.sqrt(vx1 * vx1 + vy1 * vy1)
    local length2 = math.sqrt(vx2 * vx2 + vy2 * vy2)
    
    self.movement = { x = mx, y = my, z = 0 }

    local angle = math.atan2(my, mx)
    angle = (math.pi / 2) - angle
    direction = (math.floor((angle / (2 * math.pi)) * 64 - 47.5) % 64)

    if timer > 0 then
        timer = timer - 1
        self.animator.GoTo(direction)
    else
        self.animator.AnimateTo(direction, true)
        if GetActivePlayerCount() > 0 and homingTimer > 0 then
            homingTimer = homingTimer - 1
        end
        if homingTimer > 0 then
            if GetActivePlayerCount() > 0 then
                if length1 > length2 and GetActivePlayerCount() == 2 then
                    dx = vx2 / length2
                    dy = vy2 / length2
                else
                    dx = vx1 / length1
                    dy = vy1 / length1
                end
                mx = dx * speed
                my = dy * speed
            end
        end
    end

    if homingTimer <= 0 then
        vx1 = 0 - self.worldPosition.x
        vy1 = pos1.y - self.worldPosition.y
        vx2 = 0 - self.worldPosition.x
        vy2 = pos2.y - self.worldPosition.y
    else
        vx1 = pos1.x - self.worldPosition.x
        vy1 = pos1.y - self.worldPosition.y
        vx2 = pos2.x - self.worldPosition.x
        vy2 = pos2.y - self.worldPosition.y
    end

    if CanFire() then
        if GetActivePlayerCount() > 0 then
            firePattern.Tick()

            if firePattern.CanFire() then
                firePattern.MarkFired()
                for i = 0, bullets - 1 do
                    local mxb = dx * 8
                    local myb = dy * 8

                    local firePos = { x = self.worldPosition.x + ( dx * 40 ), y = self.worldPosition.y + ( dy * 40 )}

                    local args = NewJSONObject()
                    args.AddFieldFloat("mx", mxb)
                    args.AddFieldFloat("my", myb)

                    SpawnEntityWorld("enemyshot_laser", firePos, args)
                    PlaySound(fireSFX)
                end
            end
        end
    end

    if timer <= 0 then
        if self.position.x < -200 then self.Deactivate() end
        if self.position.x > 800 then self.Deactivate() end
        if self.position.y < -800 then self.Deactivate() end
        if self.position.y > 200 then self.Deactivate() end
    end
end

function CanFire()
    return allowedToShoot and homingTimer > 0 and timer <= -20
end

function OnKill()
    self.SpawnShipShards(10, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return self.position.x > -100 or timer <= 0
end

function ShouldKillPlayerOnTouch()
    return true
end
