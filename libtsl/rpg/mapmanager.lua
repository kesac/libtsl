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

-- This is a mapmanager that uses the Simple Tiled Implementation library internally

local lib = require('libtsl.observable').new()
local sti = require('sti')

lib._maps = {}
lib._mode = nil
lib.currentMap = nil
lib.currentMapID = nil
lib.tileWidth = love.physics.getMeter()
lib.physics = {}
lib.physics.world = love.physics.newWorld(0,0)

function lib.define(id, filepath)
    
    local map = sti.new(filepath)
    lib._maps[id] = map
    map.entities = require('libtsl.rpg.entitymanager').new(lib.physics.world)
    
    if love.filesystem.exists(filepath .. '-script.lua') then
		map.script = require(filepath .. '-script')
        
        if map.script.setup then
            map.script.setup(lib, map.entities)
        end

	end

    -- we iterate backwards as the list may grow while iterating
    for i = #map.layers, 1, -1 do 
        local layer = map.layers[i]
        
        if layer.type ~= 'tilelayer' then
            layer.visible = false
        end

        if layer.name == 'Player' then
            layer.visible = false
        
            local spriteLayer = map:addCustomLayer('Player',i)
            function spriteLayer:draw() 
                if lib.drawSprites then
                    lib.drawSprites()
                end
            end
            
        end
    end -- for
    
end

function lib.setCurrentMap(id)
    if lib._maps[id] then
        
        if lib.currentMap then
            if lib.currentMap.script and lib.currentMap.script.unload then
                lib.currentMap.script:unload()
            end

            lib.currentMap.entities:removePhysicsBodies()       
        end
        
        lib.currentMap = lib._maps[id]
        lib.currentMapID = id
        lib._eventsCache = {}
        
        if lib.currentMap.script and lib.currentMap.script.load then
            lib.currentMap.script:load()
        end

        lib.currentMap.entities:restorePhysicsBodies()
    
        if lib.physics.mapCollision then
            lib.physics.mapCollision.body:destroy()
        end

        lib.physics.mapCollision = lib.currentMap:initWorldCollision(lib.physics.world)

    end
end

function lib.update(dt)
    lib.currentMap:update(dt)
    lib.currentMap.entities:update(dt)
end

function lib.draw()
    lib.currentMap:draw()       
    lib.currentMap.entities:draw()
end


function lib.getEventAtTile(tileX, tileY, eventTrigger)

    local events = nil

    if lib.currentMap and lib.currentMap.layers['Events'] then

        tileX = tonumber(tileX)
        tileY = tonumber(tileY)

        local layer = lib.currentMap.layers['Events']

        for i = 1, #layer.objects do
            local object = layer.objects[i]

            local objectX1 = math.floor(object.rectangle[1].x/lib.tileWidth)
            local objectY1 = math.floor(object.rectangle[1].y/lib.tileWidth)
            local objectX2 = math.floor(object.rectangle[3].x/lib.tileWidth)
            local objectY2 = math.floor(object.rectangle[3].y/lib.tileWidth)
   
            if (tileX >= objectX1 and tileX <= objectX2)
            and (tileY >= objectY1 and tileY <= objectY2) then
                events = object.properties
                break
            end
        end
    end

    if events then
        for trigger, action in pairs(events) do
            if string.lower(trigger) == eventTrigger then
                return {trigger = trigger, action = action}
            end
        end
    end
    
    return nil
end

return lib