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

-- A timer for executing tasks at a specified point
-- in the future. It doesn't do anything fancy like
-- recurring tasks.

local timer = {}
timer.tasks = {}


function timer.update(dt)

	local t = love.timer.getTime()
	for i = #timer.tasks, 1, -1 do
		
		local task = timer.tasks[i]
		
		if t - task.start >= task.time then
			task.execute()
			table.remove(timer.tasks, i)
		end
		
	end

end

-- 'func' is the anonymous function to execute, it
-- shouldn't have any paramters.
-- 'seconds' is the number of seconds until the function
-- should be executed.
function timer.execute(func,seconds)
	
	local task = {}
	
	task.execute = func
	task.time = seconds
	task.start = love.timer.getTime()
	
	table.insert(timer.tasks, task)

end


return timer