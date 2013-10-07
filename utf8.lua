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

-- Provides utility functions for UTF-8
-- encoded strings.

local utf8 = {}

-- Trims leading and trailing whitespace
-- from the specified string. Should work with
-- any utf-8 string.
function utf8.trim(str)
	return string.match(str,"^%s*(.*)%s*$") -- Also see http://lua-users.org/wiki/StringTrim
end

-- Splits the specified utf-8 encoded
-- string with characters up to 2 bytes
-- in length using the provided delimiter.
function utf8.split2(str,delimiter)

	local tokens = {}
	local bytes = string.len(str)
	local delimiterByte = string.byte(delimiter,1)
	
	local i = 1
	local start = 1
	
	while i <= bytes do
	
		local byte = string.byte(str,i)

		if byte == delimiterByte then
			table.insert(tokens,string.sub(str,start,i-1))
			start = i+1
		elseif i == bytes then
			table.insert(tokens,string.sub(str,start,i))
			start = i+1
		end
		
		if byte > 127 then
			i = i + 2
		else
			i = i + 1
		end

	end
	
	return tokens
end

-- Returns an array of utf-8 characters
-- where characters are up to 2 bytes
-- in length.
function utf8.chararray2(str)

	local array = {}
	
	local bytes = string.len(str)
	
	local i = 1
	while i <= bytes do
	
		local byte = string.byte(str,i)

		if byte > 127 then
			table.insert(array, string.sub(str,i,i+1))
			i = i + 2
		else
			table.insert(array, string.char(byte))
			i = i + 1
		end

	end
	
	return array

end

-- Determines length for utf-8 encoded
-- strings with characters up to 2 bytes
-- in length.
function utf8.len2(str)

	local bytes = string.len(str)
	local length = 0
	
	local i = 1
	while i <= bytes do
	
		length = length + 1	

		if string.byte(str,i) > 127 then
			i = i + 1
		end
	
		i = i + 1
	
	end
	
	return length

end

-- A substring function for utf-8 encoded
-- strings with characters up to 2 bytes
-- in length.
function utf8.sub2(str,s,l)

	local bytes = string.len(str)

	local i = 1
	while i <= bytes do
		
		local c = string.byte(str,i)
	
		if c > 127 then -- 2 byte character detected
			
			-- the starting index needs to be moved by one
			if i < s then
				s = s + 1
			end
			
			
			i = i + 1 -- no need to check next byte
			l = l + 1 -- the ending index needs to be moved by one
			
		end
		
		i = i + 1
		
		if i > l then
			break
		end
		
	end
	
	return string.sub(str,s,l)

end

return utf8