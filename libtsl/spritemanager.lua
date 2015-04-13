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

local lib = {}

local animations = {}
local animation_instances = {}

function lib.add(id, spriteanimation)
	animations[id] = spriteanimation
end

function lib.get(id)
	return animations[id]
end

function lib.instance(id)

	local animation = animations[id]
	
	if animation then

		local new_instance = lib._clone(animation)
		new_instance.id = id
		return new_instance
	
	else
		print('No animation with id ' .. id .. 'exists.')
	end
	
end

function lib.play(id, x, y)

	local animation = animations[id]
	
	if animation then

		local new_instance = lib._clone(animation)
		new_instance.id = id
		
		table.insert(animation_instances, new_instance)
		new_instance:play(x, y)	
	
		return new_instance
	
	else
		print('No animation with id ' .. id .. 'exists.')
	end

end

function lib.loop(id, x, y)

	local animation = animations[id]
	
	if animation then

		local new_instance = lib._clone(animation)
		new_instance.id = id
		
		table.insert(animation_instances, new_instance)
		new_instance:loop(x, y)	
	
		return new_instance
	
	end

end

function lib.stop(id)

	for i = #animation_instances, 1, -1 do
		
		if animation_instances[i].id == id then
			animation_instances[i]:stop()
			table.remove(animation_instances,i)
		end
		
	end

end

function lib.stopAll()

	for i = #animation_instances, 1, -1 do

		animation_instances[i]:stop()
		table.remove(animation_instances,i)
		
	end
end

function lib.update(dt)

	for i = #animation_instances, 1, -1 do
		
		animation_instances[i]:update(dt)
		
		if not animation_instances[i].active then
			table.remove(animation_instances, i)
		end
		
	end
end

function lib.draw()

	for _, animation in pairs(animation_instances) do
		animation:draw()
	end
	
end

function lib._clone(animation)

	local anima = {}
	
	for k,v in pairs(animation) do
		anima[k] = v
	end
	
	return anima

end

return lib