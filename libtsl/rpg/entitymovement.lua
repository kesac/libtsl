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

---- Defines movement patterns for entities. (Replace an
---- entity's updateMovement() function with one of the
---- functions defined here.)

local lib = {}

--- Replacing an entity's updateMovement() function
--- with this function causes it to walk in random
--- "bursts" in random dirctions.
function lib:randomWalk(dt, force)
  
    if not self.movedelay then
        self.movedelay = 0
        self.forceduration = 0
        self.applyX = 0
        self.applyY = 0
    end

    if self.forceduration > 0 then
        force.x = self.applyX
        force.y = self.applyY
        self.forceduration = self.forceduration - dt

    elseif self.movedelay > 0 then
        self.movedelay = self.movedelay - dt
    else
        if love.math.random() < 0.50 then

            local direction = love.math.random()
            
            self.applyX = 0
            self.applyY = 0
            
            if  direction < 0.25 then
                self.applyX = -1
            elseif direction < 0.50 then
                self.applyX = 1
            elseif direction < 0.75 then
                self.applyY = -1
            else
                self.applyY = 1
            end
            
            self.forceduration = 0.25
            self.movedelay = 1
        end
    end
end

return lib