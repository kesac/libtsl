--[[
	Copyright (c) 2012-2013 Kevin Sacro

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

-- Handles audio. Able to handle fade-ins
-- and fade-outs.

local lib = {}

lib.enabled = true -- If false, all functions will not do anything (except for add).
                   -- Used to safely distribute no-sound versions of games (where sound
                   -- files are excluded) without breaking existing code. 

lib.audio = {}     -- Container for all audio sources.

-- Adds the file at the specified path as a new
-- audio source.
--
-- path: local path to audio file
-- playback: one of 'static' or 'stream' denoting if the audio file
--    should be loaded completely in memory before playing or streamed
--    on the fly. (Use stream for anything that's not a short sound effect)
--
-- id: the desired id for the audio source
-- volume (optional): A float within [0,1] specifying the desired volume
--    for the audio source. If not specified, volume will be 1. 
function lib.add(path,playback,id,volume)

	if not volume then
		volume = 1
	end

	local wrapper = {}
	wrapper.source = love.audio.newSource(path,playback) 
	wrapper.volume = volume
	wrapper.targetvolume = nil -- can be one of 'min','max', nil
	
	
	lib.audio[id] = wrapper
	
end

-- Returns true if the specified source is
-- playing, else it returns false.
function lib.isPlaying(id)
	if lib.enabled then
		local wrapper = lib.audio[id]
		return not wrapper.source:isStopped()
	else
		return false
	end
end

-- Plays the audio source of the specified id.
function lib.play(id)
	if lib.enabled then
		local wrapper = lib.audio[id]
		wrapper.source:stop()
		wrapper.source:setLooping(false)
		wrapper.source:setVolume(wrapper.volume)
		wrapper.targetvolume = nil
		wrapper.source:play()
	end
end

-- Plays the audio source of the specified id by
-- gradually increasing the volume from 0 to the
-- source's max volume.
function lib.fadeplay(id)
	if lib.enabled then
		local wrapper = lib.audio[id]
		wrapper.source:stop()
		wrapper.source:setLooping(false)
		wrapper.source:setVolume(0)
		wrapper.targetvolume = 'max'
		wrapper.source:play()
	end
end

-- Plays the audio source of the specified id.
-- Automatically restarts the audio source when
-- playback reaches the end of the source.
function lib.loop(id)
	if lib.enabled then
		local wrapper = lib.audio[id]
		wrapper.source:stop()
		wrapper.source:setLooping(true)
		wrapper.source:setVolume(wrapper.volume)
		wrapper.targetvolume = nil
		wrapper.source:play()
	end
end

-- Plays the audio source of the specified id by
-- gradually increasing the volume from 0 to the
-- source's max volume.
-- Automatically restarts the audio source when
-- playback reaches the end of the source.
function lib.fadeloop(id)
	if lib.enabled then
		local wrapper = lib.audio[id]
		wrapper.source:stop()
		wrapper.source:setLooping(true)
		wrapper.source:setVolume(0)
		wrapper.targetvolume = 'max'
		wrapper.source:play()
	end
end

-- Stops playing the audio source of the specified id.
function lib.stop(id)
	if lib.enabled then
		local wrapper = lib.audio[id]
		wrapper.source:stop()
	end
end

-- Gradually reduces the volume of the audio source of
-- the specified id to 0, then stops playing the
-- audio source completely.
function lib.fadestop(id)
	if lib.enabled then
		local wrapper = lib.audio[id]
		wrapper.targetvolume = 'min'
	end
end

-- This needs to be called in a game's main update
-- function for fade functionality to work properly.
function lib.update(dt)
	
	if lib.enabled then
		for _,wrapper in pairs(lib.audio) do
		
			if wrapper.targetvolume then
			
				if wrapper.targetvolume == 'min' then
					
					local newvolume = wrapper.source:getVolume() - dt/2
				
					if newvolume <= 0.01 then
						newvolume = 0
						wrapper.source:stop()
						wrapper.targetvolume = nil
					end
					
					wrapper.source:setVolume(newvolume)
				
				elseif wrapper.targetvolume == 'max' then

					local newvolume = wrapper.source:getVolume() + dt/4
				
					if newvolume > wrapper.volume then
						newvolume = wrapper.volume
						wrapper.targetvolume = nil
					end
					
					wrapper.source:setVolume(newvolume)
				
				end
			
			end
		
		end
	end

end

-- Stops playback of all audio sources.
function lib.stopall()

	if lib.enabled then
		for _, wrapper in pairs(lib.audio) do
			wrapper.source:stop()
		end
	end

end

-- Calls fadestop on all audio sources.
function lib.fadestopall()

	if lib.enabled then
		for id, _ in pairs(lib.audio) do
			local wrapper = lib.audio[id]
			
			-- Only target sources that are still playing
			if not wrapper.source:isStopped() then 
				lib.fadestop(id)
			end
			
		end
	end

end

return lib