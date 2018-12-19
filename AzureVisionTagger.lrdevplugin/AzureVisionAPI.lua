local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrStringUtils = import 'LrStringUtils'
local LrFileUtils = import 'LrFileUtils'
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
    local visualFeatures = 'Categories,Tags,Description&Details=Celebrities,Landmarks'
    tagAPIURL = tagAPIURL .. '?Visualfeatures=' .. visualFeatures
    logger:info('Visualfeatures: ' ..  visualFeatures)
    logger:info('URL: ' .. tagAPIURL)
    local headers = {
       { field = 'Ocp-Apim-Subscription-Key', value = prefs.visionKey },
    --   { field = 'visualFeatures', value = visualFeatures },
       { field = 'Content-Type', value = 'application/octet-stream' }
    };

    
    --local payload_prefix = '{"inputs": ['
    --local payload_middle =  ''
    --local payload_postfix = ']}'
    --for idx, photo in ipairs(photos) do
      --payload_middle = '{"data":{"image":{"url": "https://samples.AzureVision.com/metro-north.jpg"}}}';
    --  payload_middle = payload_middle .. '{"data":{"image":{"base64": "' .. LrStringUtils.encodeBase64(LrFileUtils.readFile(thumbnailPaths[idx])) .. '"}}},';
    --end
    --payload_middle = payload_middle:sub(1, -2)
    --local payload = payload_prefix .. payload_middle .. payload_postfix;
    logger:info(photos)
    for idx, photo in ipairs(photos) do
      logger:info('reading file: ' .. thumbnailPaths[idx])
      local payload = LrFileUtils.readFile(thumbnailPaths[idx]) 
      logger:info(' get tags START');
      local body, reshdrs = LrHttp.post(tagAPIURL, payload, headers, "POST", 50, string.len(payload))
      if not reshdrs.status == 200 then
        logger:error("Error: " .. body)
        resStatus = reshdrs.status
      end
      jsonResults[idx] = JSON:decode(body)
      logger:info('body: ' .. body)
    end
    
    -- logger:info(' get tags body: ', body);

   --local json = JSON:decode(body);
   --logger:info(json)
   --return json, reshdrs.status;
   return jsonResults, resStatus
end

function AzureVisionAPI.getTags(photos, thumbnailPaths)
  --  if prefs.accessToken == nil then
  --     AzureVisionAPI.getToken();
  --  end
  logger:info('AzureVisionAPI.getTags') 
   local json, status = AzureVisionAPI.getTags_impl(photos, thumbnailPaths);
  --  if status == 401 then
  --     AzureVisionAPI.getToken();
  --     json, status = AzureVisionAPI.getTags_impl(photos, thumbnailPaths);
  --  end

   return json
end


return AzureVisionAPI
