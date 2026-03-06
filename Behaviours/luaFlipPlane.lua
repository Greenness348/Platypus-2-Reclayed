local mx = 6.5
local mxTotal
local knockback = 0
local knockbackCap = 0
local timer = 82
local flipTimer = 133
local flipSprite = 0
local spawnTurrets = false
local turretEntity1
local turretPosX1
local turretPosY1
local turretEntity2
local turretPosX2
local turretPosY2
local allowDamageFrames = false

function OnInitialise()
    if self.customBehaviourData.HasField("topTurretEntity") then turretEntity1 = self.customBehaviourData.GetFieldString("topTurretEntity") else turretEntity1 = "turretFlipPlane1" end
    if self.customBehaviourData.HasField("topTurretX") then turretPosX1 = self.customBehaviourData.GetFieldInt("topTurretX") else turretPosX1 = -22 end
    if self.customBehaviourData.HasField("topTurretY") then turretPosY1 = self.customBehaviourData.GetFieldInt("topTurretY") else turretPosY1 =  67 end
    if self.customBehaviourData.HasField("bottomTurretEntity") then turretEntity2 = self.customBehaviourData.GetFieldString("bottomTurretEntity") else turretEntity2 = "turretFlipPlane2" end
    if self.customBehaviourData.HasField("bottomTurretX") then turretPosX2 = self.customBehaviourData.GetFieldInt("bottomTurretX") else turretPosX2 = -22 end
    if self.customBehaviourData.HasField("bottomTurretY") then turretPosY2 = self.customBehaviourData.GetFieldInt("bottomTurretY") else turretPosY2 = -74 end
    
    if self.commandArgs.HasField("fruit_set") then self.fruitSet = self.commandArgs.GetFieldInt("fruit_set") else self.fruitSet = 5 end
end

function OnTick()
    mxTotal = mx + knockback

    if knockback > 0 then
        knockback = knockback - 0.065
    else
        knockback = 0
    end

    knockbackCap = mx + 1.3

    self.movement = { x = mxTotal, y = 0, z = 0 }

    if timer > 0 then
        timer = timer - 1
    end

    if timer <= 0 and mx > -1.3 then
        mx = mx - 0.065
    end

    if flipSprite < 11 then
        flipTimer = flipTimer - 1
    end

    if flipSprite == 1 or flipSprite == 3 or flipSprite == 5 or flipSprite == 7 then
        flipSprite = flipSprite + 1
        flipTimer = 2
    elseif flipTimer <= 0 and flipSprite < 11 then
        flipSprite = flipSprite + 1
    end

    local damageframe = self.GetDamageFrame(self.hitPoints / 3.25)   

    if allowDamageFrames == false then
        self.animator.AnimateTo(flipSprite)
    else
        self.animator.AnimateTo(damageframe);
    end

    if spawnTurrets == false and flipSprite == 11 then
        SpawnEntityChild(turretEntity1, self, { x = turretPosX1, y = turretPosY1 })
        SpawnEntityChild(turretEntity2, self, { x = turretPosX2, y = turretPosY2 })
        allowDamageFrames = true
        spawnTurrets = true
    end

    if self.position.x < -200 and mx < 0 then self.Deactivate() end
end

function OnHitByBullet()
    if mx <= 0.845 and self.position.x <= 770 then
        knockback = 2.145 - knockbackCap
    end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 60
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= 260 or mx < 0
end
