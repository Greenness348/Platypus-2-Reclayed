local mx
local xAcceleration
local timer = 0

function OnInitialise()
    mx = self.data.speed
    if self.commandArgs.HasField("acceleration") then xAcceleration = self.commandArgs.GetFieldFloat("acceleration") else xAcceleration = 0.002 end
    if Globals.difficulty > 1 then
        SpawnEntityChild("turretNastySingle", self, { x = 7, y = -1 }, NewJSONObject())
    end
end

function OnTick()
    self.movement = { x = mx, y = 0, z = 0 }
    mx = mx + xAcceleration

    local smokePos = { x = self.worldPosition.x - 55, y = self.worldPosition.y }

    timer = timer - 1
    if timer <= 0 then
        timer = 16

        local smokeArgs = NewJSONObject()

        smokeArgs.AddFieldFloat("mx", 1)
        SpawnEntityWorld("smokeRing2", smokePos, smokeArgs)
    end

    if self.position.x > 800 then self.Deactivate() end

    local damageframe = self.GetDamageFrame(self.hitPoints)
    self.animator.AnimateTo(damageframe)

    local currentFrame = self.GetDamageFrame(self.hitPoints)
    if currentFrame ~= lastDamageFrame then
        lastDamageFrame = currentFrame
        for _, effect in ipairs(self.data.damageEffects or {}) do
            if effect.frame == currentFrame then

                if effect.parachuterChance and effect.parachuterChance > 0 then
                    if math.random() < effect.parachuterChance then
                        local paraArgs = NewJSONObject()
                        SpawnEntityWorld("parachuter", { x = self.worldPosition.x + effect.parachuterX, y = self.worldPosition.y + effect.parachuterY }, paraArgs)
                    end
                end

                for _, shard in ipairs(effect.shards or {}) do
                    local shardArgs = NewJSONObject()
                    shardArgs.AddFieldInt("mx", shard.mx)
                    shardArgs.AddFieldInt("my", shard.my)
                    shardArgs.AddFieldInt("frame", shard.frame)
                    shardArgs.AddFieldInt("type", shard.type)

                    SpawnEntityWorld(shard.entity, { x = self.worldPosition.x + shard.x, y = self.worldPosition.y + shard.y }, shardArgs)
                end
            end
        end
    end
end

function OnKill()
    self.SpawnShipShards(16, -6, 0, -15, 5, 0, 0, 0, 0, 0, 0)
    self.SpawnShipDebris(8, -6, 6, -20, 0, 0, 0, 0, 10, 0, 5)
end

function CanFire()
    return self.position.x >= 120
end

function HasCollision()
    return true
end

function ShouldKillPlayerOnTouch()
    return self.position.x >= 29
end
