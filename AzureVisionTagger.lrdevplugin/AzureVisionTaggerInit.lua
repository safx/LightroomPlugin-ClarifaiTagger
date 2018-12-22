-- Provide initial default values for plugin preferences.

local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)

local defaultPrefValues = {
   -- Azure CONFIGURATION
   visionKey = 'Copy from portal.azure.com',
   visionBaseURL = 'https://westeurope.api.cognitive.microsoft.com/',
   imageSize = 600, -- Default for size of image sent to Azure
   --keywordLanguage = '', 

   -- TAGGING WINDOW SETTINGS
   thumbnailSize = 300, -- Thumbnails shown above columns of keyword checkboxes
   -- Show tags that already are in the Lightroom catalog keyword list in bold
   boldExistingKeywords = true,
    -- Automatically select keywords that already exist in the Lr Catalog keyword list
   autoSelectExistingKeywords = true,
    -- Only auto-select keyword suggestions if the probability is above this value
   autoSelectProbabilityThreshold = 85,
    -- Display the Azure-assessed confidence for each keyword
   showProbability = false,
   -- also autoselect new keywords above the probability threshold
   alsoSelectNewKeywords = false,
   -- Dimensions of the tagging window (default is low and matches former hard-coded setting, but can be set very high)
   taggingWindowHeight = 680, -- pixels high
   taggingWindowWidth = 880, -- pixels wide

   -- Dimensions of the tagging window (default is low to avoid being larger than available screen space)
   imagePreviewWindowHeight = 800,
   imagePreviewWindowWidth = 1250,

    -- For hierarchical keyword lists, ignore branches in your keyword tree which include
    -- terms which Azure will never return. e.g. branches with species names, custom process tags, etc.
    -- Skipping branches with many such terms can greatly boost performance since this plugin
    -- scans all keywords in your Lightroom catalog to match terms returned by Azure with
    -- existing keywords in your system.
   ignore_keyword_branches = '',
}

for k,v in pairs(defaultPrefValues) do
   if prefs[k] == nil then prefs[k] = v end
end
