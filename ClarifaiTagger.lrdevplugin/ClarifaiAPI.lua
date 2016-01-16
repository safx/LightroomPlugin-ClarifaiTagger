local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'
local JSON = require 'JSON'

local prefs = LrPrefs.prefsForPlugin();

local logger = LrLogger('ClarifaiAPI')
logger:enable('print')


local tagAPIURL   = 'https://api.clarifai.com/v1/tag/'
local tokenAPIURL = 'https://api.clarifai.com/v1/token/'

--------------------------------

ClarifaiAPI = {}

function ClarifaiAPI.getToken()
   local headers = {
      { field = 'Content-Type', value = 'application/x-www-form-urlencoded' },
      { field = 'Accept-Language', value = 'ja-JP' },
   };

   local data = 'grant_type=client_credentials&client_id=' .. prefs.clientId .. '&client_secret=' .. prefs.clientSecret;
   local body, reshdrs = LrHttp.post(tokenAPIURL, data, headers);

   logger:info(' get token', reshdrs.status, body);

   local json = JSON:decode(body);
   prefs.accessToken = json.access_token;
end

function ClarifaiAPI.getTags_impl(photos, thumbnailPaths)
   local mimeChunks = {};

   for idx, photo in ipairs(photos) do
      local thumbnailPath = thumbnailPaths[idx];
      local filePath = photo.path -- photo:getRawMetadata('path');
      local fileName = LrPathUtils.leafName(filePath);
      mimeChunks[ #mimeChunks + 1 ] = { name = 'encoded_data', fileName = fileName, filePath = thumbnailPath, contentType = 'application/octet-stream' };
   end

   local headers = {
      { field = 'Authorization', value = 'Bearer ' .. prefs.accessToken },
      { field = 'Accept-Language', value = prefs.keywordLanguage },
   };

   logger:info(' get tags START');
   local body, reshdrs = LrHttp.postMultipart(tagAPIURL, mimeChunks, headers);
   logger:info(' get tags', reshdrs.status);

   local json = JSON:decode(body);
   return json, reshdrs.status;
end

function ClarifaiAPI.getTags(photos, thumbnailPaths)
   if prefs.accessToken == nil then
      ClarifaiAPI.getToken();
   end

   local json, status = ClarifaiAPI.getTags_impl(photos, thumbnailPaths);
   if status == 401 then
      ClarifaiAPI.getToken();
      json, status = ClarifaiAPI.getTags_impl(photos, thumbnailPaths);
   end

   return json
end


return ClarifaiAPI
