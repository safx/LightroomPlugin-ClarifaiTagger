-- Provide initial default values for plugin preferences.

local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)

local defaultPrefValues = {
    clientId = 'Copy from application on Clarifai.com',
    clientSecret = 'Copy from application on Clarifai.com',
    imageSize = 400,
    keywordLanguage = '',
    boldExistingKeywords = true,
    autoSelectExistingKeywords = true,
    showProbability = false,
    autoSelectProbabilityThreshold = 85,
    ignore_keyword_branches = '',
}

for k,v in pairs(defaultPrefValues) do
  if prefs[k] == nil then prefs[k] = v end
end
