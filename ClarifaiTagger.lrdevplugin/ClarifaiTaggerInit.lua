-- Provide initial default values for plugin preferences.

local LrPrefs = import 'LrPrefs'

local defaultPrefValues = {
    clientId = 'Copy from application on Clarifai.com',
    clientSecret = 'Copy from application on Clarifai.com',
    imageSize = 400,
    keywordLanguage = '',
    boldExistingKeywords = true,
    autoSelectExistingKeywords = true,
    showProbability = false,
    autoSelectProbabilityThreshold = 85,
    ignoreKeywordTreeBranches = '',
}

local prefs = LrPrefs.prefsForPlugin(_PLUGIN.id)
for k,v in pairs(defaultPrefValues) do
  if prefs[k] == nil then prefs[k] = v end
end
