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

-- This is a wrapper for the Simple Tiled Implementation library

local lib = {}
local sti = nil
lib._maps = {}
lib._mode = nil

lib.currentMap = nil
lib.tileWidth = 48

lib.physics = {}
lib.physics.enabled = true;

--lib._eventsCache = {}


-- Provide a reference to the STI library here
function lib.initialize(lib)
    sti = lib
end

function lib.define(id, filepath)
    lib._maps[id] = sti.new(filepath)
        
    if love.filesystem.exists(filepath .. '-script.lua') then
		lib._maps[id].script = require(filepath .. '-script')
	end
    
    local map = lib._maps[id]
    for i = #map.layers, 1, -1 do -- we iterate backwards as the list may grow while iterating
        local layer = map.layers[i]
        
        -- DEBUG: print(i .. ' ' .. layer.type .. ': ' .. layer.name)

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
        lib.currentMap = lib._maps[id]
        lib._eventsCache = {}
        
        if lib.physics.enabled then

            if not lib.physics.world then
                lib.physics.world = love.physics.newWorld(0,0)
            end

            if lib.physics.collision then
                lib.physics.collision.body:destroy()
            end

            lib.physics.collision = lib.currentMap:initWorldCollision(lib.physics.world)
        
        end
        
    end
end

function lib.update(dt)
    lib.currentMap:update(dt)
end

function lib.draw()
    lib.currentMap:draw()       
end

--[[
function lib._getCachedTileEvents(tileX, tileY)
    return lib._eventsCache[tileX .. ',' .. tileY]
end

function lib._cacheTileEvents(events, tileX, tileY)
    local cache = {}
    cache.value = events
    local key = tileX .. ',' .. tileY
    lib._eventsCache[key] = cache
end
--]]

function lib.getTileEvents(tileX, tileY)

    local events = nil

    if lib.currentMap and lib.currentMap.layers['Events'] then

        tileX = tonumber(tileX)
        tileY = tonumber(tileY)

        --[[
        local cached = lib._getCachedTileEvents(tileX, tileY)

        -- If we've checked this tile for events before then we've cached the events already
        if cached then 
            if cached.value then -- must be in a nested if-statement to prevent the else block from running
                events = cached.value
            end
            wasCached = true;
        else -- Else check if there is a match        
        --]]
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
                end
            end
         --[[
            if events then
                lib._cacheTileEvents(events, tileX, tileY)
            else
                lib._cacheTileEvents(nil, tileX, tileY)
            end
        end
        --]]
    end
    
    return events
end

return lib