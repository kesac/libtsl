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

local DEFAULT_FADEOUT_TIME = 0.35 -- Amount of time in seconds spent fading out
local DEFAULT_FADEIN_TIME = 0.35  -- Amount of time in seconds spent fading in

local fader = {}
local fadeStart
local fadeAlpha
local state
local sceneManager

function fader.initialize(manager)
	-- Can be adjusted by caller
    sceneManager = manager
end

-- Make sure to set the target screen before
-- letting sceneManager.display show this screen
-- _nextID: id of the screen to fade-transition into
-- transitionAction: (optional) function to execute when screen is fully black
-- transitionAction: (optional) function to execute when transition is complete
-- fadeoutTime: (optional) amount of time to spend fading out
-- fadeinTime: (optional) amount of time to spend fading in
function fader.setTarget(_nextID, transitionAction, finishAction, fadeoutTime, fadeinTime)
	
	fader._previousScreen = sceneManager.getCurrentScene()
    
    if fadeoutTime then
    	fader._fadeoutTime = fadeoutTime
    else
        fader._fadeoutTime = DEFAULT_FADEOUT_TIME
    end

    if fadeinTime then
    	fader._fadeinTime = fadeinTime
    else
        fader._fadeinTime = DEFAULT_FADEIN_TIME
    end

    fader._transitionAction = transitionAction
    fader._finishAction = finishAction
	fader._nextScreen = sceneManager.getScene(_nextID)
	fader._nextID = _nextID
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
	
	if diff <= fader._fadeoutTime then
		fadeAlpha = 255 * (diff/fader._fadeoutTime)
		
		if fader._previousScreen.update then
			fader._previousScreen.update(dt)
		end
	
	elseif diff > fader._fadeoutTime and state == 'fadeout' then 
		state = 'fadein'

		-- Call unload() and load() ourselves when both scenes are not visible.
		-- We will prevent calls to these functions from happening a second time later below.
		--if fader._previousScreen.unload then
        -- this would've been called already when the scenefader became current
			--fader._previousScreen.unload()
		-- end
		
		if fader._nextScreen.load then
			fader._nextScreen.load()
		end
        
        if fader._transitionAction then
            fader._transitionAction()
        end
		
	elseif diff > fader._fadeoutTime and diff <= fader._fadeoutTime+fader._fadeinTime then
		fadeAlpha = 255 - (255 * (diff-fader._fadeoutTime)/(fader._fadeinTime))
		
		if fader._nextScreen.update then
			fader._nextScreen.update(dt)
		end
		
	else
		state = 'stop'
		
		if fader._finishAction then
			fader._finishAction()
		end
		
		-- second argument prevents load() and unload() on previous and new screen from being called a second time
		sceneManager.setCurrentScene(fader._nextID, false) 
	end
	--]]

end

-- Draws the fade rectangle
function fader.draw()

	if state == 'fadeout' then
		fader._previousScreen.draw()
	elseif state == 'fadein' then
		fader._nextScreen.draw()
	end

	love.graphics.setColor(0,0,0,fadeAlpha)
	love.graphics.rectangle('fill',0,0,love.graphics.getWidth(),love.graphics.getHeight())
	
end

return fader