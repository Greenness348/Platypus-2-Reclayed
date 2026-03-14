local timer = 8
local sprite = 0
local chargeSFX
local fireSFX

function OnInitialise()
    self.defaultOnHitByBulletBehaviour = false
    chargeSFX = self.customBehaviourData.GetFieldString("chargeSFX", "")
    fireSFX = self.customBehaviourData.GetFieldString("fireSFX", "")
    if chargeSFX ~= "" then PlaySound(chargeSFX) end
end

function OnTick()
    if timer > 0 then timer = timer - 1
    else
        if sprite < 4 then
            timer = 8
            sprite = sprite + 1
        else
            timer = 4
            sprite = sprite + 1
        end
        if sprite == 5 then
            if fireSFX ~= "" then PlaySound(fireSFX) end
        end
    end

    self.animator.GoTo(sprite);

    if sprite == 10 then
        self.Deactivate()
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end
