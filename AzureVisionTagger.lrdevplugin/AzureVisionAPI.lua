local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrStringUtils = import 'LrStringUtils'
local LrFileUtils = import 'LrFileUtils'
local LrErrors = import 'LrErrors'
local JSON = require 'JSON'
local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)

local logger = LrLogger('AzureVisionAPI')
logger:enable('logfile')


local tagAPIURL   = prefs.visionBaseURL .. 'vision/v2.0/analyze'

--------------------------------

AzureVisionAPI = {}

function AzureVisionAPI.getTags_impl(photos, thumbnailPaths)
    logger:info('AzureVisionAPI.getTags_impl')
    local jsonResults = {}
    local resStatus = 200
    local visualFeatures = 'Categories,Tags,Description,Color&Details=Celebrities,Landmarks'
    tagAPIURL = tagAPIURL .. '?Visualfeatures=' .. visualFeatures
    logger:info('Visualfeatures: ' ..  visualFeatures)
    logger:info('URL: ' .. tagAPIURL)
    local headers = {
       { field = 'Ocp-Apim-Subscription-Key', value = prefs.visionKey },
    --   { field = 'visualFeatures', value = visualFeatures },
       { field = 'Content-Type', value = 'application/octet-stream' }
    };

    logger:info(photos)
    for idx, photo in ipairs(photos) do
      logger:info('reading file: ' .. thumbnailPaths[idx])
      local payload = LrFileUtils.readFile(thumbnailPaths[idx]) 
      logger:info(' get tags START');
      local body, reshdrs = LrHttp.post(tagAPIURL, payload, headers, "POST", 50, string.len(payload))
      
      logger:info('status = ' .. reshdrs.status)

      if not (reshdrs.status == 200) then
        logger:error("Error: " .. body)
        resStatus = reshdrs.status
        LrErrors.throwUserError('Vision API ERROR: ' .. body)
        return {}, resStatus
      end
      
      jsonResults[idx] = JSON:decode(body)
      logger:info('body: ' .. body)
    end

   return jsonResults, resStatus
end

function AzureVisionAPI.getTags(photos, thumbnailPaths)
  logger:info('AzureVisionAPI.getTags') 
   local json, status = AzureVisionAPI.getTags_impl(photos, thumbnailPaths);
   return json
end


return AzureVisionAPI
