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
local catalogKeywordNames = {}
local catalogKeywords = {}
local catalogKeywordPaths = {}

local logger = LrLogger('ClarifaiAPI')
logger:enable('print')

-----------------------------------------

local function makeLabel(i, j)
   return 'check_' .. tostring(i) .. '_' .. tostring(j);
end

local function makeCheckbox(i, j, keyword, prob, boldKeywords, showProbability)
   local f = LrView.osFactory();
   -- Tooltip should show the hierarchical level of a keyword
   local tt = ''
   if catalogKeywordPaths[keyword] and catalogKeywordPaths[keyword] == '' then
       tt = '(In the keyword root level)'
   elseif catalogKeywordPaths[keyword] ~= nil then
       tt = '(In ' .. catalogKeywordPaths[keyword] .. ')'
   end

   local checkbox = {
      title = keyword,
      tooltip = tt,
      value = LrView.bind(makeLabel(i, j)),
   }

   if boldKeywords then
      checkbox.font = '<system/bold>';
   end

   if not showProbability then
      return f:checkbox(checkbox)
   end

   return f:row {
      f:checkbox(checkbox),
      f:static_text {
         title = string.format('(%2.1f)', prob * 100),
         text_color = LrColor(0.5, 0.5, 0.5),
      }
   }
end

-- Check simple table for a given value's presence
local function inTable (val, t)
   if type(t) ~= "table" then
      return false
   else
      for _, tval in pairs(t) do
         if val == tval then return true end
      end
   end
   return false
end

--General Lightroom API helper functions for keywords
function getKeywordByName(keyname, keywordSet)
   for i, kw in pairs(keywordSet) do
     -- If we have found the keyword we want, return it:
      if string.lower(kw:getName()) == string.lower(keyname) then
         return kw
        -- Otherwise, use recursion to check next level if kw has child keywords:
      else
         local kids = kw:getChildren()
         if kids and #kids > 0 then
            nextkw = getKeywordByName(lookfor, kids)
            if nextkw ~= nil then
               return nextkw
            end
         end
      end
   end
    -- If we have not returned the sought keyword, it's not there:
   return nil
end

-- Given a set of keywords (normally starting with a top level of a hierarchy),
-- get all keywords in the set with any child/descendant keywords) and populate
-- our three top-level variables with data we can quickly use.
function findAllKeywords(keywords, kpath)
   kpath = kpath or ''
   for _, kw in pairs(keywords) do
      name = string.lower(kw:getName())
      catalogKeywordNames[#catalogKeywordNames + 1] = name
      catalogKeywords[name] = kw
      catalogKeywordPaths[name] = kpath
      kids = kw:getChildren()
      if kids and #kids > 0 then
         local new_kpath = kpath .. '/' .. name
         findAllKeywords(kids, new_kpath)
      end
   end
end

-- Check if photo already has a particular keyword (by name)
local function hasKeyword(photo, keyword)
   local photoKeywordList = string.lower(photo:getFormattedMetadata('keywordTags'))
   local photoKeywordTable = split(photoKeywordList, ', ')
   return inTable(keyword, photoKeywordTable)
end

-- Given a string and delimiter (e.g. ', '), break the string into parts and return as table
-- This works like PHP's explode() function.
function split(s, delim)
   if (delim == '') then return false end
   local pos = 0
   local t = {}
   -- For each delimiter found, add to return table
   for st, sp in function() return string.find(s, delim, pos, true) end do
      -- Get chars to next delimiter and insert in return table
      t[#t + 1] = string.sub(s, pos, st - 1)
      -- Move past the delimiter
      pos = sp + 1
   end
   -- Get chars after last delimiter and insert in return table
   t[#t + 1] = string.sub(s, pos)
   
   return t
end

-- Get existing keywords for the photo which were not part of the Clarifai response
local function getOtherKeywords(photo, keywords)
    photoKeywordList = string.lower(photo:getFormattedMetadata('keywordTags'))
    local photoKeywords = split(photoKeywordList, ', ')
    local ret = {}
    
    for _, k in ipairs(photoKeywords) do
        if not inTable(k, keywords) then
            ret[#ret + 1] = k
        end
    end
    return ret
end


local function makeWindow(catalog, photos, json)
   local results = json['results']
   for _, result  in ipairs(results) do
      local cs = result['result']['tag']['classes']
   end

   local prefs = LrPrefs.prefsForPlugin();
   local boldExistingKeywords = prefs.boldExistingKeywords
   local autoCheckForExistingKeywords = prefs.autoCheckForExistingKeywords
   local showProbability = prefs.showProbability

   LrFunctionContext.callWithContext('dialogExample', function(context)
      local f = LrView.osFactory()
      local bind = LrView.bind

      local properties = LrBinding.makePropertyTable(context);

      local columns = {}
      for i, photo in ipairs(photos) do
         local keywords = json['results'][i]['result']['tag']['classes']
         local probs    = json['results'][i]['result']['tag']['probs']

         local tbl = {
            spacing = f:label_spacing(8),
            bind_to_object = properties,
            f:catalog_photo {
               width = thumbnailViewSize,
               photo = photo,
            },
         }

         for j = 1, #keywords do
            -- Make sure we are selecting checkboxes for keywords already on a photo:
            local checkKeyword = hasKeyword(photo, keywords[j])
            local boldKeyword = false;

            if boldExistingKeywords or autoCheckForExistingKeywords then
               local c = catalogKeywords[keywords[j]] and true or false

                    if boldExistingKeywords then
                    boldKeyword = c
                end
                if autoCheckForExistingKeywords then
                    checkKeyword = c
                end
            end

             properties[makeLabel(i, j)] = checkKeyword;
             tbl[#tbl + 1] = makeCheckbox(i, j, keywords[j], probs[j], boldKeyword, showProbability)
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
                         local keyword = catalogKeywords[k] 
                         if keyword == nil then
                             keyword = catalog:createKeyword(k, {}, false, nil, true)
                         end
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
                
                --While the request is being processed is a good time to parse the keyword catalog:
                local topLevelKeys = catalog:getKeywords()
                -- Populate the catalogKeywordNames and catalogKeywords tables
                findAllKeywords(topLevelKeys)
                makeWindow(catalog, photos, json);

                for _, thumbnailPath in ipairs(thumbnailPaths) do
                   LrFileUtils.delete(thumbnailPath);
                end
          end );
      end );
end )
