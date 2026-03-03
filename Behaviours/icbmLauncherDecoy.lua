local my = 0
local mx = 0
function OnInitialise()
    self.ChangeLayers(5)
    mx = -Globals.ScrollingSpeed(5)
end

function OnTick()
    self.movement = { x = mx, y = my, z = 0 }
    if self.position.x < -600 then
        self.Deactivate()
    end
end


function HasCollision()
    return false
end

function ShouldKillPlayerOnTouch()
    return false
end

