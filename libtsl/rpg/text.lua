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

-- An experimental library for displaying rpg-like text boxes.
-- Can adjust text pages, color, scroll speed on the fly while
-- processing text using embedded directives.

-- Hooks:
--    lib.draw() - Needs to be called in your draw function to draw the textbox and text
--    lib.update(dt) - Needs to be called in our update function for text scrolling to work
--    lib.init() - Needs to be called once and only once before above functions are called. Optional but recommended.

-- Usage:
--    lib.displayText(t, callback) - Displays text on the screen
--    lib.advanceText() - Advanced to next text page if there is one available. 

-- Dependencies:
--    utf8 string library capable of dealing with strings that have characters greater than 1 byte in length

-- Todo: 
--    remove dependency on game.scale, and game.font

-- Example commands:
--[[
	LINEGROUP: {@3} {@2} {@}           - Changes number of lines shown per page
	COLOR: {#00FF00} {#0F0} {#red} {#} - Changes color text
	SPEED: {$0.8} {$1.0} {$}           - Speed *multiplier* (higher values means slower)
	STYLE: {%ID} {%LARGE} {%}          - Unimplemented
	DIRECTIVE: {!OFF} {!ON} {!}        - Unimplemented
--]]

local lib = {}
local utf8 = require 'libtsl.utf8' -- Dependency, we need it to parse non-ASCII characters properly.

-- Window dimensions are initialized in the init() function
local window = {}
lib.window = window

-- The instructions table and the instructions_limit tell the draw()
-- function what to print and how to do it.
local instructions = {}
local instruction_start = 1
local instruction_limit = 0

local DEFAULT_VISIBLE_LINES = 3
local instruction_visible_lines = DEFAULT_VISIBLE_LINES
local instruction_current_line = 1

local waiting_for_text_advance = false

-- The higher the scroll_delay value the slower text scrolls.
-- Tick is used to keep time, it should be initialized to 0 and never touched.
local DEFAULT_SCROLL_DELAY = 0.015
local message_scroll_delay = DEFAULT_SCROLL_DELAY
local message_scroll_tick = 0

-- These two variables are for the blinker animation
-- notifying user they can advance the text by hitting a key
local blinker_delay = 0.25
local blinker_tick = 0
local blinker_on = false

-- Color definitions, user can modify this if they need.
local color_table = {
	default = {r=255,g=255,b=255},
	white = {r=255,g=255,b=255},
	red = {r=255,g=0,b=0},
	green = {r=0,g=255,b=0},
	blue = {r=0,g=0,b=255}
}
lib.color_table = color_table

-- Functions that will always be executed just before text is
-- delayed and immediately there is no more text to advance to
lib.preDisplayText  = nil
lib.postDisplayText = nil

-- Initializes text window dimensions and text size. If you decide not
-- to call this, ensure that you set all the attributes below yourself.
function lib.init(font)

	lib.isVisible = false
	
	window.left_padding = 16
	window.top_padding = 16
	
	lib.font = font
	lib.char_height = 16
	lib.char_width = 16
	lib.line_padding = 8
	
	window.width = window.left_padding + lib.char_width*32
	window.height = lib.char_height*3 + lib.line_padding*2 + window.top_padding*2
	window.x = love.graphics.getWidth()/2 - window.width/2
	window.y = love.graphics.getHeight()/2 + window.height*2

end

-- Gradually increments the instruction_limit based on message_scroll_delay.
-- Also processes speed based instructions.
function lib.update(dt)

	if not lib.isVisible then return end

	--[[
	if waiting_for_text_advance then
		blinker_tick = blinker_tick + dt
		if blinker_tick > blinker_delay then
			blinker_tick = 0
			if blinker_on then blinker_on = false
			else blinker_on = true end
		end
	end
	--]]
	
	if waiting_for_text_advance then return end
	
	message_scroll_tick = message_scroll_tick + dt
	
	if instruction_limit ~= #instructions and message_scroll_tick > message_scroll_delay then
	
		instruction_limit = instruction_limit + 1

		message_scroll_tick = 0
		
		if type(instructions[instruction_limit]) == 'number' then -- Speed chang
			message_scroll_delay = instructions[instruction_limit]
			message_scroll_tick = 0
		
			print("Scroll speed: " .. message_scroll_delay)
		
		elseif type(instructions[instruction_limit]) == 'table' then -- Visible line change
		
			if instructions[instruction_limit].line then
				
				instruction_visible_lines = instructions[instruction_limit].line
				instruction_limit = instruction_limit + 1
				instruction_start = instruction_limit + 1
				
			end
		
		-- Keep track of newlines so we know when to move the instruction_start.
		-- (This gives the impression of pagification)
		elseif instructions[instruction_limit] == '!n' then 
			instruction_current_line = instruction_current_line + 1
			
			if instruction_current_line > instruction_visible_lines then
				waiting_for_text_advance = true
			end
			
		end
		
		-- If we've gone over the limit of visible lines move instruction_start
		-- to produce a new page
		if instruction_current_line > instruction_visible_lines then
			instruction_current_line = 1
			-- instruction_start = instruction_limit + 1 -- Don't do this here, wait for advanceText() call
		end

	elseif instruction_limit == #instructions  then
		waiting_for_text_advance = true
	end

	
end

-- Draws text based on the instructions from the table 'instructions'
function lib.draw()

	if not lib.isVisible then return end
	
	love.graphics.setFont(lib.font)
	love.graphics.setColor(180,180,180)
	love.graphics.rectangle('line', window.x, window.y, window.width, window.height)
	love.graphics.setColor(20,20,20)
	love.graphics.rectangle('fill', window.x, window.y, window.width, window.height)
	
	love.graphics.setColor(255,255,255)
	local txt_y = window.y + window.top_padding
	local txt_x = window.x + window.left_padding
	
	for i=instruction_start, instruction_limit do
	
		local instruction = instructions[i]
	
		if type(instruction) == 'table' then -- COLOR
		
			if not instruction.line then
				love.graphics.setColor(instruction.r,instruction.g,instruction.b)
			end
		
		elseif type(instruction) == 'number' then
			-- do nothing, this instruction is taken care in update() because it is time based

		elseif instruction == '!n' then -- NEWLINE
			txt_y = txt_y + lib.char_height + lib.line_padding -- move position one line down
			txt_x = window.x + window.left_padding -- move position all the way to the left
			
		else -- SINGLE CHARACTER
			love.graphics.print(instruction,txt_x,txt_y)
			txt_x = txt_x + lib.char_width -- move position right one character
		end
	
	end

	--[[
	if blinker_on then
		love.graphics.setColor(255,255,255)
		love.graphics.rectangle('fill', window.x + window.width - 10, window.y + window.height - 10, 8, 8)
	end
	--]]
	
end

-- Displays the specified table of strings
-- in a textbox. If a callback function is provided
-- it will be called after there no more text to
-- display.
function lib.displayText(t, callback)

	lib.isVisible = false
	instructions = lib._convertToInstructions(t)
	instruction_start = 1
	instruction_limit = 0
	instruction_current_line = 1
	message_scroll_delay = DEFAULT_SCROLL_DELAY
	lib.isVisible = true
	lib._callback = callback
	
	if lib.preDisplayText then
		lib.preDisplayText()
	end
	
	-- if callback then callback() end
	
end

-- The text system can wait for a notification before
-- advancing to the next page of text. Call this function
-- to advance to the next page.
function lib.advanceText()

	if waiting_for_text_advance then
		waiting_for_text_advance = false
		
		if instruction_limit == #instructions then
			lib.isVisible = false
			
			if lib.postDisplayText then
				lib.postDisplayText()
			end
			
			if lib._callback then
				lib._callback()
			end
			
		else
			instruction_start = instruction_limit + 1
		end
	end
	
end

-- Expects a table of strings.
-- Returns a table of instructions (used internally).
function lib._convertToInstructions(t)

	local new_instructions = {}
	
	for k = 1, #t do
	
		local str = t[k]
		local chararray = utf8.chararray2(str)
		
		local i = 1
		while i <= #chararray do
		
			if chararray[i] == '{' then -- Special instruction
				
				local j = i + 1
				
				-- Where does the special instruction end?
				while j <= #chararray do
					if chararray[j] == '}' then
						break
					end
					j = j + 1
				end
				
				-- Does this special instruction carry a value?
				local value = ''
				if i+2 <= j-1 then
					value = utf8.sub2(str,i+2,j-1)
				end
				
				-- Insert instruction into instructions table as appropriate.
				if chararray[i+1] == '!' then -- Special
					table.insert(new_instructions,value)
					
				elseif chararray[i+1] == '@' then -- Pagification
				
					local t = {}
				
					if value ~= '' then
						t.line = tonumber(value)
					else
						t.line = DEFAULT_VISIBLE_LINES
					end
					
					table.insert(new_instructions,t)
					
				elseif chararray[i+1] == '#' then -- Color
					
					if value:match('[%a%d]+') and string.len(value) == 6 then
					
						local t = {}
						t.r = tonumber(string.sub(value,1,2),16)
						t.g = tonumber(string.sub(value,3,4),16)
						t.b = tonumber(string.sub(value,5,6),16)
					
						table.insert(new_instructions,t)
					
					elseif color_table[value] then
						table.insert(new_instructions,color_table[value])
					else
						table.insert(new_instructions,color_table.default)
					end
					
				elseif chararray[i+1] == '$' then -- Scroll speed

					if value:match('%d+[%.%d+]?') then -- Terrible scrubbing
						table.insert(new_instructions,message_scroll_delay*tonumber(value))
					else
						table.insert(new_instructions,DEFAULT_SCROLL_DELAY)
					end
					
					-- print("Scroll speed: " .. message_scroll_delay)
					
				elseif chararray[i+1] == '%' then -- Text style 
					table.insert(new_instructions,value)
				end
				
				i = j + 1
			
			else -- Single character
				table.insert(new_instructions,chararray[i])
				i = i + 1
			end

		
		end
		
		if t[k + 1] then -- Implicitly add newline
			table.insert(new_instructions,'!n')
		end
		
	end

	return new_instructions

end


return lib