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

-- Script for creating animations based on a sprite sheet.

local lib = {}

-- uses lua-based indexing
function lib.create(img,cols,rows,framespeed,startframe,endframe)

	local anima = {}
	anima.image = img
	anima.rows = rows or 1
	anima.cols = cols or 1
	anima.framespeed = framespeed or 1.0
	anima.startframe = startframe or 1
	anima.endframe = endframe or rows*cols
	
	-- We need frame dimensions in order to create quads
	anima.framewidth  = anima.image:getWidth()  / anima.cols
	anima.frameheight = anima.image:getHeight() / anima.rows 

	-- These variables are used to keep track of ongoing animations
	anima.currentframe = 1
	anima.tick = 0
	anima.active = false
	anima.isLooping = false
	
	anima.x = 0 -- Pixel coordinates
	anima.y = 0
	
	-- Quads are placed in order here
	anima.quads = {}
	
	-- Switches to 0 based indexing briefly for easier to read calculations
	for i = anima.startframe-1, anima.endframe-1 do
	
		local quad_row = math.floor(i / anima.cols)
		local quad_col = i % anima.cols
		
		local quad = love.graphics.newQuad(
			quad_col * anima.framewidth,  -- Quad X coordinate in pixels
			quad_row * anima.frameheight, -- Quad Y coordinate in pixels
			anima.framewidth,             -- Pixels
			anima.frameheight,
			anima.image:getWidth(),
			anima.image:getHeight()
		)

		table.insert(anima.quads, quad)
		
	end
	
	anima.play = lib._play
	anima.loop = lib._loop
	anima.stop = lib._stop
	anima.draw = lib._draw
	anima.update = lib._update
	anima.clone = lib._clone
	
	return anima

end

function lib._play(animation, x, y)
	animation.tick = 0
	animation.currentframe = 1
	animation.x = x or 0
	animation.y = y or 0
	animation.loop = false
	animation.active = true
    return animation
end

function lib._loop(animation, x, y)
	--if not animation.active then
    animation.tick = 0
    animation.currentframe = 1
    animation.x = x or 0
    animation.y = y or 0
    animation.isLooping = true
    animation.active = true
    return animation
	--end
end

function lib._stop(animation)
	animation.active = false
    return animation
end

function lib._draw(animation)
	if animation.active then	
		love.graphics.setColor(255,255,255,255)
        love.graphics.draw(
			animation.image,
			animation.quads[animation.currentframe],
			animation.x,
			animation.y
		)
	end
end

function lib._update(animation,dt)
	
	if animation.active then
		animation.tick = animation.tick + dt
		
		if animation.tick > animation.framespeed then
			animation.tick = 0
			animation.currentframe = animation.currentframe + 1
			
			--if animation.currentframe > animation.endframe then -- Incorrect		
			if animation.currentframe > #animation.quads then			
				if not animation.isLooping then
					animation.active = false
				end
				
				animation.currentframe = 1
			end
			
		end
	end
	
end


return lib