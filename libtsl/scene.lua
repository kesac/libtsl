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

-- This is an example empty scene to show what functions scenes
-- can define. You do not need to define all of these functions
-- At the bare minimum draw() should be defined.

local scene = {}

function scene.initialize(manager)
    -- called when this scene is added to a scenemanager
    -- passes the manager as the only argument
end

function scene.load()
    -- called when the scene becomes the current scene
end

function scene.unload()
    -- called when the scene is replaced by another scene
end

function scene.update(dt)
	-- called when the scene needs to update itself
end

function scene.draw()
	-- called when the scene needs to draw itself
end

function scene.keypressed(key,unicode)
	-- called when the scene needs to handle a keypressed event
end

function scene.keyreleased(key,unicode)
	-- called when the scene needs to handle a key released event
end

return scene