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

-- Rudimentary library for table to string and
-- table to file operations. Only converts tables
-- that have non-numeric keys defined. Only correctly
-- converts the following value types: boolean, number,
-- string, and table.

local lib = {}

-- Converts a table to a string, then writes
-- the string to the specified filename. Do not
-- include parent directories, just give the filename.
-- It will be placed in %appdata%/LOVE/<identity>.
function lib.tableToLuaFile(t,filename)
	love.filesystem.write(filename, 'return ' .. lib.tableToString(t))
end

-- Converts a table to a string.
function lib.tableToString(t)
	return lib._table_to_string(t)
end

-- Internal use only. Converts a table to a string.
-- If there are nested tables, this function will
-- call itself recursively.
function lib._table_to_string(t)

	local str = "{"

	for i,v in pairs(t) do
	
		local t = type(v)
	
		if t == "number" then
			str = str .. i .. "=" .. tostring(v) .. ","
		elseif t == "string" then
			str = str .. i .. "=" .. "'" .. v .. "'" .. ","
		elseif t == "table" then
			str = str .. i .. "=" ..  lib._to_string(v) .. ","
		elseif t == "boolean" then
			str = str .. i .. "=" .. tostring(v) .. ","
		else
			str = str .. i .. "='" .. t .. "',"
		end
	end

	str = str .. "}"
	
	return str
	
end

return lib