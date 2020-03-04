-- Provide initial default values for plugin preferences.

local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)

local defaultPrefValues = {
   -- CLARIFAI CONFIGURATION
   clientId = 'Copy from application on Clarifai.com',
   clientSecret = 'Copy from application on Clarifai.com',
   modelName = 'Name of the model',
   imageSize = 600, -- Default for size of image sent to Clarifai
   keywordLanguage = '', -- Default is language used for creating your Clarifai application

   -- TAGGING WINDOW SETTINGS
   thumbnailSize = 300, -- Thumbnails shown above columns of keyword checkboxes
   -- Show tags that already are in the Lightroom catalog keyword list in bold
   boldExistingKeywords = true,
    -- Automatically select keywords that already exist in the Lr Catalog keyword list
   autoSelectExistingKeywords = true,
    -- Only auto-select keyword suggestions if the probability is above this value
   autoSelectProbabilityThreshold = 85,
    -- Display the Clarifai-assessed probability for each keyword
   showProbability = false,
   -- Dimensions of the tagging window (default is low and matches former hard-coded setting, but can be set very high)
   taggingWindowHeight = 680, -- pixels high
   taggingWindowWidth = 880, -- pixels wide

   -- Dimensions of the tagging window (default is low to avoid being larger than available screen space)
   imagePreviewWindowHeight = 800,
   imagePreviewWindowWidth = 1250,

    -- For hierarchical keyword lists, ignore branches in your keyword tree which include
    -- terms which Clarifai will never return. e.g. branches with species names, custom process tags, etc.
    -- Skipping branches with many such terms can greatly boost performance since this plugin
    -- scans all keywords in your Lightroom catalog to match terms returned by Clarifai with
    -- existing keywords in your system.
   ignore_keyword_branches = '',
}

for k,v in pairs(defaultPrefValues) do
   if prefs[k] == nil then prefs[k] = v end
end
