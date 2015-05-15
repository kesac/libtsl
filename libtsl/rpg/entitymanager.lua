--[[
	Copyright (c) 2015 Kevin Sacro

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
	NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
	DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
	OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
	USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

local lib = {}

function lib.new(physicsWorld)  
    local manager = {}
    manager.entities = {}
    manager.physicsWorld = physicsWorld

    manager.add = lib.add
    manager.addNPC = lib.addNPC
    
    manager.getEntityAtTile = lib.getEntityAtTile
        
    manager.restorePhysicsBodies = lib.restorePhysicsBodies
    manager.removePhysicsBodies = lib.removePhysicsBodies
    manager.clear = lib.clear
    manager.update = lib.update
    manager.draw = lib.draw

    return manager
end

function lib:add(entity, initializeBody)
    entity:setPhysicsWorld(self.physicsWorld)
    table.insert(self.entities,entity)
    
    if initializeBody then
        entity:initializeBody()
    end
end

function lib:addNPC(id, imagePath, x, y)
    local entity = require('libtsl.rpg.entity').new(id)
    entity.x = x or 0
    entity.y = y or 0

    entity:setSprite(imagePath)
    entity:setPhysicsWorld(self.physicsWorld)
    entity.updateMovement = require('libtsl.rpg.entitymovement').randomWalk

    table.insert(self.entities,entity)

    return entity
end

function lib:getEntityAtTile(tileX, tileY)

    for i = 1, #self.entities do
        if tileX == self.entities[i].tileX and tileY == self.entities[i].tileY then
            return self.entities[i]
        end
    end
    
    return nil
    
end

function lib:removePhysicsBodies()
    for i = #self.entities, 1, -1 do
        self.entities[i]:destroyBody()
    end
end

function lib:restorePhysicsBodies()
    for i = 1, #self.entities do
        self.entities[i]:initializeBody()
    end
end

function lib:clear()
    for i = #self.entities, 1, -1 do
        self.entities[i]:destroyBody()
        table.remove(self.entities, i)
    end
end

function lib:update(dt)

    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]
        if entity.update then
            entity:update(dt)
        
            if entity.duration and entity.duration <= 0 then
                entity:destroyBody()
                table.remove(self.entities, i)
            end
        end
    end

end

function lib:draw()
    for _,entity in pairs(self.entities) do
        if entity.draw then
            entity:draw()
        end
    end
end




return lib