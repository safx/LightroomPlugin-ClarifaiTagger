--[[----------------------------------------------------------------------------

KwUtils.lua
Utility functions for Lightroom Keywords

--------------------------------------------------------------------------------

    Copyright 2016 Lowell "LoweMo / LoMo" Montgomery
    https://lowemo.photo
    Latest version: https://lowemo.photo/lightroom-keyword-utils

    This file is used in a few Lightroom plugins.

    This code is released under a Creative Commons CC-BY "Attribution" License:
    http://creativecommons.org/licenses/by/3.0/deed.en_US

    This bundle may be used for any purpose, provided that the copyright notice
    and web-page links, above, as well as the 'AUTHOR_NOTE' and 'Attribution'
    strings, below are maintained. Enjoy.
------------------------------------------------------------------------------]]

local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)
local LUTILS = require 'LUTILS'

local KwUtils = {}

KwUtils.VERSION = 20161101.01 -- version history at end of file
KwUtils.AUTHOR_NOTE = "KwUtils.lua is a set of Lightroom keyword utility functions, © 2016 by Lowell Montgomery (https://lowemo.photo/lightroom-keyword-utils) version: " .. KwUtils.VERSION

-- The following provides an 80 character-width attribution text that can be inserted for display
-- in a plugin derived using these helper functions.
KwUtils.Attribution = "This plugin uses KwUtils, Lightroom keyword utilities, © 2016 by Lowell Montgomery\n (https://lowemo.photo/lightroom-keyword-utils) version: " .. KwUtils.VERSION .. "\n\nThis code is released under a Creative Commons CC-BY “Attribution” License:\n http://creativecommons.org/licenses/by/3.0/deed.en_US"

function KwUtils.addKeywordWithParents(photo, keyword)
    photo:addKeyword(keyword)
    parent = keyword:getParent() 
    if parent ~= nil then
        KwUtils.addKeywordWithParents(photo, parent)
    end
end

-- Add or remove a keyword based on the "state" of the associated checkbox.
-- Presumed is that we call this when the state differs from what is already on this image,
-- i.e. that they keyword is being changed for the photo (added or removed)
function KwUtils.addOrRemoveKeyword(photo, keyword, state)
    if state then
        KwUtils.addKeywordWithParents(photo, keyword)
    else
      -- We cannot assume parents should be removed if already there.
        photo:removeKeyword(keyword)
    end
end

--Returns array of keywords with a given name
function KwUtils.getAllKeywordsByName(name, keywords, found)
    found = found or {}
    if type(found) == 'LrKeyword' then
        found = {found}
        elseif type(found) ~= 'table' then
            found = {}
    end
    for i, kw in pairs(keywords) do
        -- If we have found the keyword we want, return it:
        if kw:getName() == name and kwInTable(kw, found) == false then
            found[#found + 1] = kw
        -- Otherwise, use recursion to check next level if kw has child keywords:
        else
            local kchildren = kw:getChildren()
            if #kchildren > 0 then
                found = KwUtils.getAllKeywordsByName(name, kchildren, found)
            end
        end
    end
    -- By now, we should have them all
    return found
end

-- Gets string representing a keywords parent names in hierarchical order, e.g.
-- "TOP_LEVEL_CATEGORY | second_level_parent | parent"
function KwUtils.getAncestryString(kw, ancestryString)
    ancestryString = ancestryString or ''
    local parent = kw:getParent()
    if parent ~= nil then
        ancestryString = parent:getName() .. " | " .. ancestryString
        ancestryString = KwUtils.getAncestryString(parent, ancestryString)
    end
    return ancestryString;
end

-- Return a comma-separated string listing all children of a term
function KwUtils.getChildrenString(kw)
    local childNamesTable = KwUtils.getKeywordChildNamesTable(kw)
    if #childNamesTable > 0 then
        return table.concat(childNamesTable, ", ")
    else return ""
    end
end

--General Lightroom API helper functions for keywords
function KwUtils.getKeywordChildNamesTable(parentKey)
    local kchildren = parentKey:getChildren()
    local childNames = {}
    if kchildren and #kchildren > 0 then
       childNames = KwUtils.getKeywordNames(kchildren)
    end
    -- Return the table of child terms (empty if no child terms for passed keyword)
    return childNames;
end

-- Get names of all Keyword objects in a table
function KwUtils.getKeywordNames(keywords)  
    local names = {}
    for i, kw in pairs(keywords) do
        names[#names +1] = kw:getName() 
    end
    return names;
end

-- Get existing keywords for a photo which are not in a given set (table)
function KwUtils.getOtherKeywords(photo, keywords)
    photoKeywordList = photo:getFormattedMetadata('keywordTags')
    local photoKeywords = LUTILS.split(photoKeywordList, ', ')
    local ret = {}

    for _, key in ipairs(photoKeywords) do
        if not LUTILS.inTable(key, keywords) then
            ret[#ret + 1] = key
        end
    end

    return ret
end

-- Check for actual keyword (by keyword ID) associated with a photo
function KwUtils.hasKeywordById(photo, keyword)
    kwid = keyword.localIdentifier
    keywordsForPhoto = photo:getRawMetadata('keywords')
    for _, k in pairs(keywordsForPhoto) do
        if k.localIdentifier == kwid then
            return true
        end
    end
    return false
end

-- Check if photo already has a particular keyword (by name)
function KwUtils.hasKeywordByName(photo, keyword)
    local photoKeywordList = string.lower(photo:getFormattedMetadata('keywordTags'))
    local photoKeywordTable = LUTILS.split(photoKeywordList, ', ')
    return LUTILS.inTable(keyword, photoKeywordTable)
end

-- Return true if a keyword is in a table of keywords. Checks keyword ID.
function KwUtils.kwInTable(kw, tb)
    kwid = kw.localIdentifier
    for _, k in pairs(tb) do
        if k.localIdentifier == kwid then return true end
    end
    return false
end

return KwUtils

-- 20161101.01 Initial release.
--    It includes functions I had found myself writing and re-writing in various plugins.
