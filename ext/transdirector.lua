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

local lib = {}

local director     = require 'lib.scenedirector'
local fadescene    = require 'lib.ext.transfader'
local fadescene_id = '_fader'

director.addScene(fadescene,fadescene_id)
fadescene.setSceneDirector(director)

local defaultFadeoutTime = fadescene.fadeoutTime
local defaultFadeinTime = fadescene.fadeinTime

-- Make all scenedirector functions available
for k,v in pairs(director) do
	lib[k] = v
end

function lib.transitionTo(nextSceneID,fadeoutTime,fadeinTime)

	fadescene.fadeoutTime = fadeoutTime or defaultFadeoutTime
	fadescene.fadeinTime = fadeinTime or defaultFadeinTime
	fadescene.setTarget(nextSceneID)
	director.setCurrentScene(fadescene_id)

end

return lib

