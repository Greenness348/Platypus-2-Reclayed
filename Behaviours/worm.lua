local timer = 0

function OnTick()
    self.movement = { x = -4, y = 0, z = 0 }
    if timer > 0 then timer = timer - 1 else self.animator.AnimateToNextFrame(true); timer = 2 end
    if self.position.x < -200 then self.Deactivate() end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
