local timer
local sprite

function OnInitialise()
    timer = 2
    sprite = 0
end

function OnTick()
    timer = timer - 1
    
    if timer <= 0 then
        timer = 2
        sprite = sprite + 1
    end

    self.animator.AnimateTo(sprite);

    if sprite == 16 then
        self.Deactivate()
    end
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return true
end

