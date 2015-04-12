--[[
	Copyright (c) 2012 Kevin Sacro

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

-- Convenience functions for game entity creation and updating

local entity = {}

-- Instantiates a generic entity and returns it
function entity.new(x,y,angle,speed)
	local e = {}

	e.x = x or 0
	e.y = y or 0
	e.angle = angle or 0
	e.speed = speed or 0
	
	return e
end

-- Updates the specified game entity providing they have
-- the keys 'x','y','speed', and 'angle' defined.
function entity.update(entity,dt)
		local cos = math.cos(entity.angle)
		local sin = -math.sin(entity.angle)
		local xSpeed = entity.speed * cos
		local ySpeed = entity.speed * sin
		
		entity.x = entity.x + xSpeed*dt
		entity.y = entity.y + ySpeed*dt
end

function entity.updateAll(t,dt)
	for _,v in pairs(t) do
		entity.update(v)
	end
end

return entity