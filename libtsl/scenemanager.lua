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

-- Mediator for game scenes. Allows scenes to 
-- communicate and transition with each other.
-- Supports fade in and outs.

local manager = {}

-- Scenes are simply tables that can define
-- one of the six functions: init, load
-- unload, draw, update(dt), keypressed(key,unicode)
local scenes = {}
local currentScene

local sceneFader    = require 'libtsl.scenefader'
local sceneFaderId = '_fader'

-- Adds a scene to this manager with the specified id
function manager.addScene(scene, id)

    if scene.initialize then
		scene.initialize(manager)
	end

	scenes[id] = scene
end

-- Gets the scene with the specified id
function manager.getScene(id)
	if id then
		return scenes[id]
	end
end

function manager.getCurrentScene()
	return currentScene
end

-- Promotes the scene with the specified id to current status
function manager.setCurrentScene(id, notify)

	if notify == nil then notify = true end

	if scenes[id] then	

		-- Notify current scene it is being demoted from current status
		if currentScene and currentScene.unload and notify then
			currentScene.unload()
		end
	
		currentScene = scenes[id]
		
		-- Notify new scene it is being promoted to current status
		if currentScene.load and notify then
			currentScene.load()
		end
		
	end
end

-- Identical to setCurrentScene() except it gradually fades out the
-- current scene and fades in the next scene.
-- transitionAction executes when the screen is black
function manager.transitionTo(nextSceneID, transitionAction, finishAction, fadeoutTime, fadeinTime)
	sceneFader.setTarget(nextSceneID, transitionAction, finishAction, fadeoutTime, fadeinTime)
	manager.setCurrentScene(sceneFaderId)
end

-- Requests that the current scene update itself. dt
-- is the number of seconds passed since last update.
function manager.update(dt)
	if currentScene and currentScene.update then
		currentScene.update(dt)
	end
end

-- Requests that the current scene render itself
function manager.draw()
	if currentScene and currentScene.draw then
		currentScene.draw()
	end
end

-- Notifies the current scene that a key has been pressed.
function manager.keypressed(key,unicode)
	if currentScene and currentScene.keypressed then
		currentScene.keypressed(key,unicode)
	end
end

function manager.keyreleased(key)
	if currentScene and currentScene.keyreleased then
		currentScene.keyreleased(key)
	end
end

manager.addScene(sceneFader,sceneFaderId)

return manager