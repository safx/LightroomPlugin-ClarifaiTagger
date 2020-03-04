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
--------------------------------

ClarifaiAPI = {}

function ClarifaiAPI.getTags_impl(photos, thumbnailPaths)
    local headers = {
       { field = 'Authorization', value = 'Key ' .. prefs.clientId },
      --  { field = 'Authorization', value = 'Key e2a415c0928445c3864ac960713e9dee' },
       { field = 'Content-Type', value = 'application/json' },
      --  { field = 'Accept-Language', value = prefs.keywordLanguage },
    };
    
    local modelName = prefs.modelName
    modelId = ClarifaiAPI.modelNameToModelID(modelName)
    
    local redictionURL = baseURL .. modelId .. "/outputs"
    
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

   local json, status = ClarifaiAPI.getTags_impl(photos, thumbnailPaths);

   return json
end

function ClarifaiAPI.modelNameToModelID(name)
  local modelNameToID = {
    ["general"]="aaa03c23b3724a16a56b629203edc62c",
    ["food"]="bd367be194cf45149e75f01d59f77ba7",
    ["color"]="eeed0b6733a644cea07cf4c60f87ebb7",
    ["travel"]="eee28c313d69466f836ab83287a54ed9",
  }
  local modelId = modelNameToID[name]
  if (modelId == nil) then
    modelId = "aaa03c23b3724a16a56b629203edc62c" -- use general as default
  end
  return modelId
end

return ClarifaiAPI
