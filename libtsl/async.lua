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

---- Provides support for running asynchronous sequences of functions.

local lib = {}

--- Runs the specified sequence of functions to one after another. 
--- Each function (except for the last one in the chain) must take a
--- single callback function as an argument and run that callback function
--- when finished its own work.
function lib.run(...)

	local chain = {}
	chain.functions = {...}
	chain.currentIndex = 1
	chain.runNext = lib._nextEvent
    chain:runNext()

end

function lib._nextEvent(chain)
	if chain.currentIndex <= #chain.functions then
		chain.functions[chain.currentIndex](function() chain:runNext() end)
		chain.currentIndex = chain.currentIndex + 1
	end
end

return lib