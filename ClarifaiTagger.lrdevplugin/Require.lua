--[[----------------------------------------------------------------------------
12345678901234567890123456789012345678901234567890123456789012345678901234567890

Require

Copyright 2010, John R. Ellis -- You may use this script for any purpose, as
long as you include this notice in any versions derived in whole or part from
this file.


This module replaces the standard "require" with one that provides the ability
to reload all files and to define a search path for loading .lua files from
shared directories.  For an introductory overview, see the accompanying
"Debugging Toolkit.htm".

Overview of the public interface; for details, see the particular function:

value require (string filename, [, reload])
    Loads a file if it hasn't already been loaded. 
    
namespace path (...)
    Sets the search path for source directories.
    
namespace loadDirectory (string dir)  
    Sets the base directory from where files are loaded.
    
namespace reload (boolean or nil force) 
    Specifies whether subsequent 'require's reload files.

string or nil findFile (filename)
    Searches for a file in the current search path of source directories.
    
table newGlobals ()    
    Returns all global names defined since the initial require.
------------------------------------------------------------------------------]]

local Require = {}

local LrFileUtils = import 'LrFileUtils'
local LrFunctionContext = import 'LrFunctionContext'
local LrPathUtils = import 'LrPathUtils'
local LrTasks = import 'LrTasks'

local Debug
    --[[ To break load dependencies and allow Debug.lua to be located in 
    another directory than the plugin, Debug.lua is loaded the first
    time require() is called. ]]
    
local originalRequire
    --[[ The original values of "require". ]]
    
local level = 0
    --[[ The level of nesting of currently executing require's.  Level = 1
    means the outermost require. ]]

local filenameLoaded = {}
    --[[ Table mapping filename => true, indicating the file has been loaded
    by loadFile/debugRequire. ]]
    
local filenameResult = {}
    --[[ Table mapping filename => value of loading the file. ]]
    
local originalG 
    --[[ Shallow copy of _G at the start of loading the top-level file. ]]

local nameIsNewGlobal = {}
    --[[ Table mapping a name to true if it has been defined in _G by the 
    top-level require or a nested require. ]]

local filenameNewGlobals = {}
    --[[ Table mapping filename to a table containing all the globals defined by
    loading that file. The table of globals maps a global name to its value
    at the time of loading. ]]

local loadDir
    --[[ The directory from which loadFile and debugRequire will load files.
    If nil, then defaults to _PLUGIN.path ]]
    
local pathDirs = {"."}
    --[[ List of directories that will be searched for the file.  The first
    directory is always ".".  All directories are relative to the _PLUGIN.path.
    ]]

    -- Forward references
local safeLoadfile

--[[----------------------------------------------------------------------------
public value
require (string filename, [, reload])

This version of require is similar to the standard one, but it allows control
over whether files are reloaded and it tracks which files define which new
globals.  If "reload" is true, then the file is loaded regardless if it
had already been loaded.
------------------------------------------------------------------------------]]

function Require.require (filename, reload) 
return LrFunctionContext.callWithContext ("", function (context)
    if type (filename) ~= "string" then 
        error ("arg #1 to 'require' not a string", 2)
        end
    if LrPathUtils.extension (filename) == "" then 
        filename = filename .. ".lua"
        end

    if filename == "Require.lua" then return Require end

    if not Debug and filename ~= "Debug.lua" then 
        pcall (function () Debug = Require.require ("Debug") end)
        end
    
    if filename == "Debug.lua" and Debug then return Debug end

    if not reload and filenameLoaded [filename] then
        return filenameResult [filename]
        end
    
    if not originalG then
        originalG = table.shallowcopy (_G)
        setmetatable (originalG, nil)
        end

    level = level + 1
    context:addCleanupHandler (function () level = level - 1 end)

    local function raiseError (msg)
        error (string.format ("'require' can't open script '%s': %s", 
            filename, msg), 2)
        end

    local filePath = Require.findFile (filename) 
    if not filePath then raiseError ("can't find the file") end
    local chunk, e = safeLoadfile (filePath)
    if not chunk then error (e, 0) end
    if level == 1 and Debug and Debug.enabled then 
        chunk = Debug.showErrors (chunk) 
        end
    local success, value = LrTasks.pcall (chunk)

    if success then 
        filenameLoaded [filename] = true
        filenameResult [filename] = value
        end
    
    local newGlobals = {}
    local foundNewGlobal = false
    for k, v in pairs (_G) do 
        if originalG [k] == nil and not nameIsNewGlobal [k] then
            nameIsNewGlobal [k] = true
            newGlobals [k] = v            
            foundNewGlobal = true 
            end
        end    
    if foundNewGlobal then filenameNewGlobals [filename] = newGlobals end
    
    if not success then 
        error (value, 0)
    else
        return value
        end
    end) end
    

--[[----------------------------------------------------------------------------
void chunk, err
safeLoadfile (string path)

Provides the equivalent of loadfile (path), except that it allows "path" to
contain non-ASCII characters (unlike the LR 3/4 SDK).  Returns the compiled
chunk, or nil and an error message. 
------------------------------------------------------------------------------]]

function safeLoadfile (path)
    local success, contents = LrTasks.pcall (LrFileUtils.readFile, path)
    if not success then return nil, contents end
    local sourcePath = LrPathUtils.makeRelative (path, loadDir or _PLUGIN.path)
    if sourcePath:sub (1, 2) == ".\\" then sourcePath = sourcePath:sub (3) end
    return loadstring (contents, sourcePath)
    end        

--[[----------------------------------------------------------------------------
public namespace
path (...)

Sets a search path of directories to search for required files. "." is always
implicitly included at the front of the path.  Each argument should be a string
containing a directory path, and each path can be absolute or relative to the
directory set by loadDirectory() (which defaults to _PLUGIN.path).  Returns the
Require module.
------------------------------------------------------------------------------]]

function Require.path (...)
    pathDirs = {"."}
    for i = 1, select ("#", ...) do 
        local dir = select (i, ...)
        table.insert (pathDirs, dir)
        end
    return Require
    end


--[[----------------------------------------------------------------------------
public namespace
loadDirectory (string dir)

Sets the directory from which files will be loaded (defaults to _PLUGIN.path).
A value of nil (the default) causes files to be loaded from the plugin
directory. Returns the Require module.
------------------------------------------------------------------------------]]

function Require.loadDirectory (dir)
    loadDir = dir
    return Require
    end


--[[----------------------------------------------------------------------------
public string or nil
findFile (filename)

If "filename" is an absolute path, it is returned.  If it is relative,
the path directories are searched for the first one containing it.  Returns
the fully qualified path name if it is found, nil otherwise.
------------------------------------------------------------------------------]]

function Require.findFile (filename)
    if not LrPathUtils.isRelative (filename) then return filename end
    for i, pathDir in ipairs (pathDirs) do
        if LrPathUtils.isRelative (pathDir) then
            pathDir = LrPathUtils.child (loadDir or _PLUGIN.path, pathDir)
            end
        local filePath = LrPathUtils.child (pathDir, filename)
        if LrFileUtils.exists (filePath) then return filePath end
        end
    return nil
    end


--[[----------------------------------------------------------------------------
public namespace
reload (boolean or nil force)

If "force" is true, or if "force" is nil and the plugin directory's name ends in
".lrdevplugin", then all information about previously loaded modules is
immediately discarded, forcing them to be reloaded by subsequent 'require's.

A useful idiom is to do the following at the top of the root script:

    require 'Require'.reload()

When debugging (e.g. when running from a ".lrdevplugin" directory), this will
force all subsequent nested scripts to be reloaded; but when run from a
"release" directory (".lrplugin"), a 'require'd script will be loaded at most
once.

Returns the Require module.
------------------------------------------------------------------------------]]

function Require.reload (force)
    if force == true or 
       (force == nil and _PLUGIN.path:sub (-12) == ".lrdevplugin") 
    then
        filenameLoaded = {}
        filenameResult = {}
        nameIsNewGlobal = {}
        filenameNewGlobals = {}
        originalG = nil
        end
    return Require
    end


--[[----------------------------------------------------------------------------
public table
newGlobals ()

Returns a table containing the new globals that were defined by each loaded file
since the beginning or the last call to reload ().  Has the form:

{filename1 => {name1 => value1, name2 => value2 ...},
 filename 2 => {name3 => value 3, name4 => value4 ...}, ...}
 
Clears the table after returning it. 
------------------------------------------------------------------------------]]

function Require.newGlobals ()
    local result = filenameNewGlobals
    filenameNewGlobals = {}
    return result
    end
    

--[[----------------------------------------------------------------------------
------------------------------------------------------------------------------]]

originalRequire = require
require = Require.require

return Require