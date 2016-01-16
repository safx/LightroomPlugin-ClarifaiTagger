local LrApplication = import 'LrApplication'
local LrBinding = import "LrBinding"
local LrColor = import 'LrColor'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrFunctionContext = import "LrFunctionContext"
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrPrefs = import 'LrPrefs'
local LrTasks = import 'LrTasks'
local LrView = import "LrView"
local ClarifaiAPI = require 'ClarifaiAPI'

local logger = LrLogger('ClarifaiAPI')
logger:enable('print')

-----------------------------------------

local function makeLabel(i, j)
   return 'check_' .. tostring(i) .. '_' .. tostring(j);
end

local function makeCheckbox(i, j, keyword, prob)
   local f = LrView.osFactory();

   return f:checkbox {
      title = string.format('%s (%2.1f)', keyword, prob * 100),
      value = LrView.bind(makeLabel(i, j)),
   }
end

local function hasKeyword(photo, keyword)
   local keywords = photo:getRawMetadata('keywords');
   for _, k in ipairs(keywords) do
      if k:getName() == keyword then
         return true
      end
   end

   return false
end

local function contains(keyword, keywords)
   for _, k in ipairs(keywords) do
      if k == keyword then
         return true
      end
   end

   return false
end

local function getOtherKeywords(photo, keywords)
   local ret = {}

   local photoKeywords = photo:getRawMetadata('keywords');
   for _, k in ipairs(photoKeywords) do
      if not contains(k:getName(), keywords) then
         ret[#ret + 1] = k:getName()
      end
   end

   return ret
end

local function makeWindow(catalog, photos, json)
   local results = json['results']
   for _, result  in ipairs(results) do
      local cs = result['result']['tag']['classes'];
   end

   LrFunctionContext.callWithContext('dialogExample', function(context)
       local f = LrView.osFactory();
       local bind = LrView.bind

       local properties = LrBinding.makePropertyTable(context);

       local columns = {}
       for i, photo in ipairs(photos) do
          local keywords = json['results'][i]['result']['tag']['classes']
          local probs    = json['results'][i]['result']['tag']['probs']

          for j = 1, #keywords do
             properties[makeLabel(i, j)] = hasKeyword(photo, keywords[j]);
          end

          local tbl = {
             spacing = f:label_spacing(8),
             bind_to_object = properties,
             f:catalog_photo {
                width = thumbnailViewSize,
                photo = photo,
             },
          }

          for k = 1, 20 do
             tbl[#tbl + 1] = makeCheckbox(i, k, keywords[k], probs[k])
          end


          local otherKeywords = getOtherKeywords(photo, keywords);
          if #otherKeywords > 0 then
             tbl[#tbl + 1] = f:spacer {
                height = 4
             };
             for _, o in ipairs(otherKeywords) do
                tbl[#tbl + 1] = f:static_text {
                   title = '     ' .. o,
                   text_color = LrColor(0.3, 0.3, 0.3),
                }
             end
          end

          columns[i] = f:column(tbl);
       end

       local contents = f:scrolled_view {
          width = 880,
          height = 680,
          background_color = LrColor(0.9, 0.9, 0.9),
          f:row(columns)
       }

       local result = LrDialogs.presentModalDialog({
           title = LOC '$$$/ClarifaiTagger/TaggerWindow/Title=Clarifai Tagger',
           contents = contents,
           actionVerb = 'Save',
           --resizable = true,
           --save_frame = true,
       })

       if result == 'ok' then
          local newKeywords = {};
          catalog:withWriteAccessDo('writePhotosKeywords', function(context)
                for i, photo in ipairs(photos) do
                   local keywords = json['results'][i]['result']['tag']['classes']
                   for j = 1, #keywords do
                      local k = keywords[j];
                      local v = properties[makeLabel(i, j)];
                      if v ~= hasKeyword(photo, k) then
                         local keyword = catalog:createKeyword(k, {}, false, nil, true);
                         if keyword == false then -- This keyword was created in the current withWriteAccessDo block, so we can't get by using `returnExisting`.
                            keyword = newKeywords[k];
                         else
                            newKeywords[k] = keyword;
                         end

                         if v then
                            photo:addKeyword(keyword);
                         else
                            photo:removeKeyword(keyword);
                         end
                      end
                   end
                end
          end )
       end
   end )
end

local function requestJpegThumbnails(target_photos, processed_photos, generated_thumbnails, callback)
   local count = #target_photos
   if count == 0 then
      callback(processed_photos, generated_thumbnails);
      return
   end

   local photo = target_photos[count]
   table.remove(target_photos, count);

   local f = function(jpg, err)
      if err == nil then
         processed_photos[#processed_photos + 1] = photo;
         generated_thumbnails[#generated_thumbnails + 1] = jpg;
         requestJpegThumbnails(target_photos, processed_photos, generated_thumbnails, callback);
      end
   end

   local prefs = LrPrefs.prefsForPlugin();
   local imageSize = tonumber(prefs.imageSize) or 400;
   photo:requestJpegThumbnail(imageSize, imageSize, f);
end

function reverseArray(array)
    local reversed = {}
    for idx, val in ipairs(array) do
        reversed[#array - idx + 1] = val
    end
    return reversed
end

local thumbnailDir = LrPathUtils.getStandardFilePath('temp');

LrTasks.startAsyncTask(function()
      local catalog = LrApplication.activeCatalog();
      local photos = reverseArray(catalog:getTargetPhotos());

      local limitSize = 128 -- currently Clarifai's max_batch_size
      if #photos > limitSize then
         local message = LOC '$$$/ClarifaiTagger/TaggerWindow/ExceedsBatchSizeMessage=Selected photos execeeds the limit (%d).';
         local info = LOC '$$$/ClarifaiTagger/TaggerWindow/ExceedsBatchSizeInfo=%d photos are selected currently.';
         LrDialogs.message(string.format(message, limitSize), string.format(info, #photos), 'warning');
         return
      end

      requestJpegThumbnails(photos, {}, {}, function(photos, thumbnails)
          logger:info(' thumbnail created ', #photos, #thumbnails);
          local thumbnailPaths = {}
          for idx, thumbnail in ipairs(thumbnails) do
             local photo = photos[idx];
             local filePath = photo.path -- photo:getRawMetadata('path');
             local fileName = LrPathUtils.leafName(filePath);
             local path = LrPathUtils.child(thumbnailDir, fileName);
             local jpg_path = LrPathUtils.addExtension(path, 'jpg');

             local out = io.open(jpg_path, 'w');
             io.output(out);
             io.write(thumbnail);
             io.close(out);
             thumbnailPaths[#thumbnailPaths + 1] = jpg_path;
          end

          LrTasks.startAsyncTask(function()
                local message = LOC '$$$/ClarifaiTagger/TaggerWindow/ProcessingMessage=Sending thumbnails of the selected photos...';
                LrDialogs.showBezel(message, 2);

                local json = ClarifaiAPI.getTags(photos, thumbnailPaths);
                makeWindow(catalog, photos, json);

                for _, thumbnailPath in ipairs(thumbnailPaths) do
                   LrFileUtils.delete(thumbnailPath);
                end
          end );
      end );
end )
