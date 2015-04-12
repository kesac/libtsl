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

-- This is an intermediate scene for facilitating
-- fade-in/fade-out transitions between a pair of
-- screens. SceneManager uses this for its
-- transitionTo() function.

local fader = {}
local fadeStart
local fadeAlpha
local state
local sceneManager

function fader.initialize(manager)
	-- Can be adjusted by caller
	fader.fadeoutTime = 0.35 -- Amount of time in seconds spent fading out
	fader.fadeinTime = 0.35  -- Amount of time in seconds spent fading in
    sceneManager = manager
end

-- Make sure to set the target screen before
-- letting sceneManager.display show this screen
-- nextID: id of the screen to fade-transition into
-- prevID: (optional) id of screen to fade-transition out of
function fader.setTarget(nextID, prevID)
	if not prevID then
		fader.previousScreen = sceneManager.getCurrentScene()
	else
		fader.previousScreen = sceneManager.getScene(prevID)
	end
	fader.nextScreen = sceneManager.getScene(nextID)
	fader.nextID = nextID
end

-- Resets state to 'fadeout'
function fader.load()
	state = 'fadeout'
	fadeStart = love.timer.getTime()
	fadeAlpha = 0
end

-- Gradually updates the state and alpha of fade rectangle
function fader.update(dt)

	local diff = love.timer.getTime()-fadeStart
	
	if diff <= fader.fadeoutTime then
		fadeAlpha = 255 * (diff/fader.fadeoutTime)
		
		if fader.previousScreen.update then
			fader.previousScreen.update(dt)
		end
	
	elseif diff > fader.fadeoutTime and state == 'fadeout' then 
		state = 'fadein'

		-- Call unload() and load() ourselves when both scenes are not visible.
		-- We will prevent calls to these functions from happening a second time later below.
		if fader.previousScreen.unload then
			fader.previousScreen.unload()
		end
		
		if fader.nextScreen.load then
			fader.nextScreen.load()
		end
		
	elseif diff > fader.fadeoutTime and diff <= fader.fadeoutTime+fader.fadeinTime then
		fadeAlpha = 255 - (255 * (diff-fader.fadeoutTime)/(fader.fadeinTime))
		
		if fader.nextScreen.update then
			fader.nextScreen.update(dt)
		end
		
	else
		state = 'stop'
		
		if fader.postevent then
			fader.postevent()
		end
		
		-- second argument prevents load() and unload() on previous and new screen from being called a second time
		sceneManager.setCurrentScene(fader.nextID, false) 
	end
	--]]

end

-- Draws the fade rectangle
function fader.draw()

	if state == 'fadeout' then
		fader.previousScreen.draw()
	elseif state == 'fadein' then
		fader.nextScreen.draw()
	end

	love.graphics.setColor(0,0,0,fadeAlpha)
	love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
	
end

return fader