local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrStringUtils = import 'LrStringUtils'
local LrFileUtils = import 'LrFileUtils'
local JSON = require 'JSON'
local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)

local logger = LrLogger('ClarifaiAPI')
logger:enable('print')


local baseURL = 'https://api.clarifai.com/v2/models/'
local defaultModelID = 'aaa03c23b3724a16a56b629203edc62c' -- general v1.5
--------------------------------

ClarifaiAPI = {}

function ClarifaiAPI.getTags_impl(photos, thumbnailPaths)
    local headers = {
       { field = 'Authorization', value = 'Key ' .. prefs.clientId },
      --  { field = 'Authorization', value = 'Key e2a415c0928445c3864ac960713e9dee' },
       { field = 'Content-Type', value = 'application/json' },
      --  { field = 'Accept-Language', value = prefs.keywordLanguage },
    };
    
    local modelID = prefs.modelID
    if (modelID == "") then
      modelId = defaultModelID
    end
    
    local redictionURL = baseURL .. modelID .. "/outputs"
    
    local payload_prefix = '{"inputs": ['
    local payload_middle =  ''
    local payload_postfix = ']}'
    for idx, photo in ipairs(photos) do
      --payload_middle = '{"data":{"image":{"url": "https://samples.clarifai.com/metro-north.jpg"}}}';
      payload_middle = payload_middle .. '{"data":{"image":{"base64": "' .. LrStringUtils.encodeBase64(LrFileUtils.readFile(thumbnailPaths[idx])) .. '"}}},';
    end
    payload_middle = payload_middle:sub(1, -2)
    local payload = payload_prefix .. payload_middle .. payload_postfix;
    logger:info(' get tags START');
    local body, reshdrs = LrHttp.post(redictionURL, payload, headers, "POST", 50, string.len(payload))
    -- logger:info(' get tags body: ', body);

   local json = JSON:decode(body);
   return json, reshdrs.status;
end

function ClarifaiAPI.getTags(photos, thumbnailPaths)
  --  if prefs.accessToken == nil then
  --     ClarifaiAPI.getToken();
  --  end

   local json, status = ClarifaiAPI.getTags_impl(photos, thumbnailPaths);
  --  if status == 401 then
  --     ClarifaiAPI.getToken();
  --     json, status = ClarifaiAPI.getTags_impl(photos, thumbnailPaths);
  --  end

   return json
end


return ClarifaiAPI
