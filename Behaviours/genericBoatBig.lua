local mx
local wakeSprite
local wakePosX
local wakePosY
local wakeRender

function OnInitialise()
    mx = self.commandArgs.GetFieldFloat("speed", 0.3)
    self.fruit_set = self.commandArgs.GetFieldInt("fruit_set", 6)

    wakeSprite = self.customBehaviourData.GetFieldString("wakeSprite", "")
    wakePosX = self.customBehaviourData.GetFieldInt("wakePosX", 0)
    wakePosY = self.customBehaviourData.GetFieldInt("wakePosY", 0)
    
    if wakeSprite ~= "" then
        wakeRender = self.SpawnAttachedSpriteAnimator(wakeSprite, 1)
        wakeRender.position = { x = wakePosX, y = wakePosY }
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }

    local lastFrame = self.animator.currentFrame
    self.animator.GoTo(self.GetDamageFrame(self.data.maxHitPoints, self.hitPoints, self.animator.totalFrames))
    self.HandleDamageEffects(self.animator.currentFrame, lastFrame)
    wakeRender.AnimateToNextFrame(true)
    
    if self.position.x < -300 or self.position.x > 950 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(32, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(32, -12, 8, -20, 0, 0, 0, 0, 10, 0, 5)

    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x - 20, y = self.worldPosition.y })
    SpawnEntityWorld("explosionBig", { x = self.worldPosition.x + 80, y = self.worldPosition.y })
end

function CanFire()
    return self.position.x >= 154.5 and mx > 0 or self.position.x <= 770.5 and mx < 0
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x > -50 or mx <= 0
end
