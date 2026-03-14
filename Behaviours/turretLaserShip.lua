local firePattern
local entity
local originOffX
local originOffY

function OnInitialise()
    firePattern = NewFirePatternFromEntityData(self.data)
    entity = self.customBehaviourData.GetFieldString("bulletEntity", "")
    originOffX = self.customBehaviourData.GetFieldInt("bulletOriginOffX", 0)
    originOffY = self.customBehaviourData.GetFieldInt("bulletOriginOffY", 0)
end

function OnTick()
    if entity ~= "" and CanFire() == true then
        firePattern.Tick()
        if firePattern.CanFire() then
            firePattern.MarkFired()
            SpawnEntityChild(entity, self, { x = self.position.x + ( originOffX - 480 ), y = self.position.y + ( originOffY + 0.5 )})
        end
    end
end

function CanFire()
    return self.parent.CanFire()
end
