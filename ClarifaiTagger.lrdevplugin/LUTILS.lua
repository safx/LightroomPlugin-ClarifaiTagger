--[[----------------------------------------------------------------------------

LUTILS.lua
Utility functions for common Lua tasks. This is a bundle intended to provide
utility functions. Since it's for use in Lightroom plugins, it uses Lua 5.1.x
This bundle may grow over time, but is intended to remain limited in scope to
avoid including this file from causing undue bloat. 

--------------------------------------------------------------------------------

    Copyright 2016 Lowell ("LoweMo" / "LoMo") Montgomery
    https://lowemo.photo
    Latest version: https://lowemo.photo/lightroom-lua-utils

    This file is used in a few Lightroom plugins.

    This code is released under a Creative Commons CC-BY "Attribution" License:
    http://creativecommons.org/licenses/by/3.0/deed.en_US

    This bundle may be used for any purpose, provided that the copyright notice
    and web-page links, above, as well as the 'AUTHOR_NOTE' string, below are
    maintained. Enjoy.
------------------------------------------------------------------------------]]

local LUTILS = {}

LUTILS.VERSION = 20161101.01 -- version history at end of file
LUTILS.AUTHOR_NOTE = "LUTILS.lua--Lua utility functions by Lowell Montgomery (https://lowemo.photo/lightroom-lua-utils) version: " .. LUTILS.VERSION

-- The following provides an 80 character-width attribution text that can be inserted for display
-- in a plugin derived using these helper functions.
LUTILS.Attribution = "This plugin uses LUTILS, Lua utilities, © 2016 by Lowell Montgomery\n (https://lowemo.photo/lightroom-lua-utils) version: " .. LUTILS.VERSION .. "\n\nThis code is released under a Creative Commons CC-BY “Attribution” License:\n http://creativecommons.org/licenses/by/3.0/deed.en_US"

-- Check simple table for a given value's presence
function LUTILS.inTable (val, t)
    if type(t) ~= "table" then
        return false
    else
        for i, tval in pairs(t) do
            if val == tval then return true end
        end
    end
    return false;
end

-- Given a string and delimiter (e.g. ', '), break the string into parts and return as table
-- This works like PHP's explode() function.
function LUTILS.split(s, delim)
   if (delim == '') then return false end
   local pos = 0
   local t = {}
   -- For each delimiter found, add to return table
   for st, sp in function() return string.find(s, delim, pos, true) end do
      -- Get chars to next delimiter and insert in return table
      t[#t + 1] = string.sub(s, pos, st - 1)
      -- Move past the delimiter
      pos = sp + 1
   end
   -- Get chars after last delimiter and insert in return table
   t[#t + 1] = string.sub(s, pos)

   return t;
end

-- Merge two tables (like PHP array_merge())
function LUTILS.tableMerge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            LUTILS.tableMerge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1;
end

-- Basic trim functionality to remove whitespace from either end of a string
function LUTILS.trim(s)
   if s == nil then return nil end
   return string.gsub(s, '^%s*(.-)%s*$', '%1');
end

return LUTILS;
