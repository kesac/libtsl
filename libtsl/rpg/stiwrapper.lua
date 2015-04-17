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


-- This is a wrapper for both Advanced Tiled Loader and Simple Tiled Implementation
-- which are libraries for loading and drawing Tiled maps.

local lib = {}
local sti = nil

lib._maps = {}
lib._currentMap = nil
lib._mode = nil

-- Provide a reference to the STI library here
function lib.initialize(lib)
    sti = lib
end

function lib.define(id, filepath)
    lib._maps[id] = sti.new(filepath)

    local map = lib._maps[id]
    for i = #map.layers, 1, -1 do -- we iterate backwards as the list may grow while iterating
        local layer = map.layers[i]
        
        -- DEBUG: print(i .. ' ' .. layer.type .. ': ' .. layer.name)

        if layer.type ~= 'tilelayer' then
            layer.visible = false
        elseif layer.name == 'Player' then
        
            layer.collidable = true
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
        lib._currentMap = lib._maps[id]
    end
end

function lib.update(dt)
    lib._currentMap:update(dt)
end

function lib.draw()
    lib._currentMap:draw()       
end

return lib