--[[
	Copyright (c) 2012, 2015 Kevin Sacro

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

-- A wrapper for the Advanced Tiled Loader by Kadoba.
-- Provides features outside the scope of ATL.

local lib = require('libtsl.observable').new()
local atl = nil

lib.maps = {}           -- All defined maps are stored here
lib.currentMap = nil    -- The "current" map is the one that is drawn
lib.drawAfter = {}      -- Values are expected to be functions

lib._fadeState = nil
lib._fadeAlpha = 0
lib._callback = nil
lib._fadeSpeed = 1000

function lib.initialize(lib)
    atl = lib
end

-- Expecting the filename complete with .tmx extension.
function lib.define(id, mapname) --filename)

	lib.maps[id] = atl.load(mapname .. '.tmx')
	lib.maps[id].useSpriteBatch = false 
	lib.maps[id].drawObjects = false
	
	
	if lib.maps[id].layers['events'] then
		lib.maps[id].layers['events'].visible = false
	end
	
	if lib.maps[id].layers['Player'] then
		lib.maps[id].layers['Player'].visible = false
	end
	
	lib.maps[id]._id = id
	
end

function lib.setCurrentMap(id)
	
	if lib.maps[id] then
		local old_id = nil
		if lib.currentMap then old_id = lib.currentMap._id end
		
		lib.notifyObservers('mapunload', old_id)
		lib.currentMap = lib.maps[id]
		lib.notifyObservers('mapload', lib.currentMap._id)
		
		-- lib.notifyObservers('mapchange','id', old_id)
	end
	
end

function lib.fadeOut(callback) -- Optional argument
	lib._fadeState = 'fadeout'
	lib._fadeAlpha = 0
	lib._callback  = callback -- It's ok if nil
end

function lib.fadeIn(callback) -- Optional argument
	lib._fadeState = 'fadein'
	lib._fadeAlpha = 255
	lib._callback  = callback -- It's ok if nil
end

-- Used for fadein/fadeouts
function lib.update(dt)

	if lib._fadeState then
		if lib._fadeState == 'fadeout' then
			lib._fadeAlpha = lib._fadeAlpha + lib._fadeSpeed * dt
			
			if lib._fadeAlpha > 255 then
				lib._fadeAlpha = 255
				lib._fadeState = 'allblack' -- Ensures that the black overlay stays drawn
				if lib._callback then lib._callback() end -- Notify caller that fadeout is complete
			end
			
		elseif lib._fadeState == 'fadein' then
			lib._fadeAlpha = lib._fadeAlpha - lib._fadeSpeed * dt
			
			if lib._fadeAlpha < 0 then
				lib._fadeAlpha = 0
				lib._fadeState = nil
				if lib._callback then lib._callback() end -- Notify caller that fadein is complete
			end
			
		end
	end

end

function lib.draw(x,y)

	if not lib.currentMap then return end

    x = x or 0
    y = y or 0

	x = math.floor(x)
	y = math.floor(y)
	
	love.graphics.push()
			
		love.graphics.setColor(255,255,255,255)
		love.graphics.translate(x, y)
		lib.currentMap:autoDrawRange(x, y, 1, 0) 		
			
		lib.currentMap:_updateTileRange()
		for i = 1, #lib.currentMap.layerOrder do
			local layer = lib.currentMap.layerOrder[i]
				
			--if layer.name == 'Player' then
			if lib.drawAfter[layer.name] then
				lib.drawAfter[layer.name]()
			end		
			
			if layer.visible and layer.draw then
				layer.draw(layer)
			end
		end
			
	love.graphics.pop()

	if lib._fadeState then
		love.graphics.setColor(0,0,0,lib._fadeAlpha)
		love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
	end

	
end


return lib