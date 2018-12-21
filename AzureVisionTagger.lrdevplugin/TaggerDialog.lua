local LrApplication = import 'LrApplication'
local LrBinding = import "LrBinding"
local LrColor = import 'LrColor'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrFunctionContext = import "LrFunctionContext"
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)
local LrTasks = import 'LrTasks'
local LrView = import "LrView"
local AzureVisionApi = require 'AzureVisionAPI'
local KwUtils = require 'KwUtils'
local LUTILS = require 'LUTILS'

local logger = LrLogger('AzureVisionAPI')
logger:enable('logfile')

-----------------------------------------
-- Returns a checkbox label used in the dialog. i, j, and k are normally all integers
local function getCheckboxLabel(i, j, k)
   return 'check_' .. tostring(i) .. '_' .. tostring(j) .. '_' .. tostring(k)
end

local function makeCheckbox(i, j, k, tagName, prob, boldKeywords, showProbability)
   local f = LrView.osFactory()
   -- Tooltip should show the hierarchical level of a keyword
   local tt = ''
   local lowerkey = string.lower(tagName)
   if KwUtils.catKwPaths[lowerkey] ~= nil and KwUtils.catKwPaths[lowerkey][k] == '' then
       tt = '(In the keyword root level)'
   elseif KwUtils.catKwPaths[lowerkey] ~= nil then
       tt = '(In ' .. KwUtils.catKwPaths[lowerkey][k] .. ')'
   else -- KwUtils.catKwPaths[lowerkey] == nil
      tt = "New keyword by the name “”" .. tagName .. "” will be created by selecting this tag."
   end

   local checkbox = {
      title = tagName,
      tooltip = tt,
      value = LrView.bind(getCheckboxLabel(i, j, k)),
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

-- Builds the tagger Dialog window
local function makeWindow(catalog, photos, json)
   local results = json['results']
  --  for _, result  in ipairs(results) do
  --     local cs = result['result']['tag']['classes']
  --  end

   local boldExistingKeywords = prefs.boldExistingKeywords
   local autoSelectExistingKeywords = prefs.autoSelectExistingKeywords
   local showProbability = prefs.showProbability

   LrFunctionContext.callWithContext('showDialog', function(context)
      local f = LrView.osFactory()
      local bind = LrView.bind

      local properties = LrBinding.makePropertyTable(context)

      local columns = {}
      for i, photo in ipairs(photos) do
         --  local keywords = json['results'][i]['result']['tag']['classes']
         --  local probs    = json['results'][i]['result']['tag']['probs']
         logger:info(' avTags ', i);
         local keywords = {} -- The tag as received from azure
         local probs    = {} -- The confidence of the tag
         local captions = {}

         local avTags = json[i]['tags']
         for i, tag in ipairs(avTags) do
            logger:info(' tag: ', tag['name'])
            table.insert(keywords, tag['name'])
            table.insert(probs, tag['confidence'])
         end

         local avCaption  = json[i]['description']['captions']
         for l, caption in ipairs(avCaption) do
            table.insert( captions, caption['text'] )
         end

         local tbl = {
            spacing = f:label_spacing(8),
            bind_to_object = properties,
            f:catalog_photo {
               width = prefs.thumbnailSize,
               photo = photo,
            }
         }

         tbl[#tbl +1] = f:static_text {
            title = table.concat(captions, ', '),
            text_color = LrColor(0.3, 0.3, 0.3),
         }

         local previewWidth = prefs.imagePreviewWindowWidth;
         local previewHeight = prefs.imagePreviewWindowHeight;
         local previewButtonTt = "Open larger preview (in " .. previewWidth .. " x " .. previewHeight .. "px window)";
         tbl[#tbl + 1] = f:row {
            f:push_button {
               title = 'View Full Size Image',
               tooltip = previewButtonTt,
               action = function (clickedview)
                  LrDialogs.presentModalDialog({
                     title = 'Review Image',
                     contents = f:catalog_photo {
                        photo = photo,
                        width = previewWidth,
                        height = previewHeight,
                        tooltip = "Press “Enter” key to close if the “Close Window” button is off-screen",
                     },
                     cancelVerb = '< exclude >',
                     actionVerb = 'Close Window',
                  });
               end
            }
         }

         for j = 1, #keywords do
            local lowerkey = string.lower(keywords[j])
            local numKeysByName = KwUtils.catKws[lowerkey] ~= nil and #KwUtils.catKws[lowerkey] or false

            -- Make sure we are selecting checkboxes for keywords already on a photo:
            local selectKeyword = KwUtils.hasKeywordByName(photo, keywords[j])

            local boldKeyword = false;
            local kwExists = (KwUtils.keywordExists(keywords[j]) ~= false) and true or false

            if boldExistingKeywords or autoSelectExistingKeywords then
               -- Does the keyword list include the keyword
               if boldExistingKeywords then
                  boldKeyword = kwExists
               end
               -- Probability from Azure actually expressed as fraction of one.
               local prob = tonumber(probs[j]) * 100
               if autoSelectExistingKeywords and tonumber(prob) >= tonumber(prefs.autoSelectProbabilityThreshold) then
                  if prefs.alsoSelectNewKeywords then 
                     selectKeyword = true
                  else
                     selectKeyword = kwExists
                  end
               end
            end
            if numKeysByName ~= false then
               for k=1, numKeysByName do
                  local keyword = KwUtils.catKws[lowerkey][k]
                  properties[getCheckboxLabel(i, j, k)] = selectKeyword
                  tbl[#tbl + 1] = makeCheckbox(i, j, k, keywords[j], probs[j], boldKeyword, showProbability)
               end
            else
               local k = 0
               -- It is a new keyword so will not be selected automatically
               properties[getCheckboxLabel(i, j, k)] = selectKeyword --false
               tbl[#tbl + 1] = makeCheckbox(i, j, k, keywords[j], probs[j], boldKeyword, showProbability)
            end
         end

         local otherKeywords = KwUtils.getOtherKeywords(photo, keywords)
         if #otherKeywords > 0 then
            tbl[#tbl + 1] = f:spacer {
               height = 4
            }
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
         width = prefs.taggingWindowWidth,
         height = prefs.taggingWindowHeight,
         background_color = LrColor(0.9, 0.9, 0.9),
         f:row(columns)
      }

      local result = LrDialogs.presentModalDialog({
         title = LOC '$$$/AzureVisionTagger/TaggerWindow/Title=AzureVision Tagger',
         contents = contents,
         actionVerb = 'Save',
      })

      if result == 'ok' then
         local newKeywords = {}
         catalog:withWriteAccessDo('writePhotosKeywords', function(context)
               for i, photo in ipairs(photos) do
                  -- local keywords = json['results'][i]['result']['tag']['classes']

                  
                  -- Description: Captions
                  local captions = json[i]['description']['captions']
                  for i, caption in ipairs(captions) do
                     --local _cap = photo:setPropertyForPlugin(_PLUGIN.id, 'azureVisionCaption', caption)
                     photo:setPropertyForPlugin(_PLUGIN, 'azureVisionCaption', caption['text'])
                  end

                  -- Description: Tags
                  local tags = {}
                  local avTags = json[i]['description']['tags']
                  for m, tag in ipairs(avTags) do
                     table.insert( tags, tag )
                  end
                  photo:setPropertyForPlugin(_PLUGIN, 'azureVisionTags', table.concat(tags, ', '))

                  -- Colors
                  local colors = {}
                  local avColors = json[i]['color']['dominantColors']
                  for n, color in ipairs(avColors) do
                     table.insert( colors, color )
                  end
                  photo:setPropertyForPlugin(_PLUGIN, 'azureVisionColors', table.concat(colors, ', '))
                  
                  -- Azure Vision API Request Metadata
                  photo:setPropertyForPlugin(_PLUGIN, 'azureVisionRequestID', json[i]['requestId'])
                  photo:setPropertyForPlugin(_PLUGIN, 'azureVisionRequestTS', string.format('%s', os.date('%Y-%m-%d %H:%M:%S')))


                  local keywords = {}
                  -- local probs    = {}
                  local avTags = json[i]['tags']
                  for i, tag in ipairs(avTags) do
                     logger:info(' avTags: ', tag['name'])
                     table.insert(keywords, tag['name'])
                    --  table.insert(probs, concept['value'])
                  end

                  for j = 1, #keywords do
                     local kwName = keywords[j]
                     local kwLower = string.lower(kwName)
                     local keywordsByName = KwUtils.catKws[kwLower]
                     local numKeysByName = keywordsByName ~= nil and #keywordsByName or 0

                     -- First deal with the issue of adding a keyword that was not in the Lightroom library before:
                     if numKeysByName == 0 then
                        local checkboxState = properties[getCheckboxLabel(i, j, 0)]
                        if checkboxState ~= false then
                          -- catalog:createKeyword( keywordName, synonyms, includeOnExport, parent, returnExisting )
                           local keyword = catalog:createKeyword(kwName, {}, true, nil, true)
                           if keyword == false then
                              -- Keyword created in current withWriteAccessDo block, so is inaccessible via `returnExisting`.
                              keyword = newKeywords[kwName]
                           else
                              newKeywords[kwName] = keyword
                           end
                           photo:addKeyword(keyword)

                        end

                      -- Not a new term, but only one checkbox exists for the term:
                     else
                        for k=1, numKeysByName do
                           local checkboxState = properties[getCheckboxLabel(i, j, k)]
                           local keyword = KwUtils.catKws[kwLower][k]
                           if numKeysByName == 1 and checkboxState ~= KwUtils.hasKeywordByName(photo, kwName) then
                              KwUtils.addOrRemoveKeyword(photo, keyword, checkboxState)

                           elseif numKeysByName > 1 then
                              -- We need to use more accurate (less performant) means to verify the actual keyword
                              -- is (or is not) already associated with the photo.
                              if checkboxState ~= KwUtils.hasKeywordById(photo, keyword) then
                                 KwUtils.addOrRemoveKeyword(photo, keyword, checkboxState)
                              end
                           end
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
      callback(processed_photos, generated_thumbnails)
      return
   end

   local photo = target_photos[count]
   table.remove(target_photos, count)

   local f = function(jpg, err)
      if err == nil then
         processed_photos[#processed_photos + 1] = photo
         generated_thumbnails[#generated_thumbnails + 1] = jpg
         requestJpegThumbnails(target_photos, processed_photos, generated_thumbnails, callback)
      end
   end

   local imageSize = tonumber(prefs.imageSize) or 400
   photo:requestJpegThumbnail(imageSize, imageSize, f)
end

function reverseArray(array)
    local reversed = {}
    for idx, val in ipairs(array) do
        reversed[#array - idx + 1] = val
    end
    return reversed
end

local thumbnailDir = LrPathUtils.getStandardFilePath('temp')

LrTasks.startAsyncTask(function()
   local catalog = LrApplication.activeCatalog()
   local photos = reverseArray(catalog:getTargetPhotos())

   local limitSize = 128 -- currently Clarifai's max_batch_size
   if #photos > limitSize then
      local message = LOC '$$$/AzureVisionTagger/TaggerWindow/ExceedsBatchSizeMessage=Selected photos execeeds the limit (%d).'
      local info = LOC '$$$/AzureVisionTagger/TaggerWindow/ExceedsBatchSizeInfo=%d photos are selected currently.'
      LrDialogs.message(string.format(message, limitSize), string.format(info, #photos), 'warning')
      return
   end

   requestJpegThumbnails(photos, {}, {}, function(photos, thumbnails)
       logger:info(' thumbnail created ', #photos, #thumbnails)
       local thumbnailPaths = {}
       for idx, thumbnail in ipairs(thumbnails) do
          local photo = photos[idx]
          local filePath = photo.path -- photo:getRawMetadata('path');
          local fileName = LrPathUtils.leafName(filePath)
          local path = LrPathUtils.child(thumbnailDir, fileName)
          local jpg_path = LrPathUtils.addExtension(path, 'jpg')
          logger:info(' jpg_path ', jpg_path)
          local out = io.open(jpg_path, 'wb')
          io.output(out)
          io.write(thumbnail)
          io.close(out)
          thumbnailPaths[#thumbnailPaths + 1] = jpg_path
       end

       LrTasks.startAsyncTask(function()
             local message = LOC '$$$/AzureVisionTagger/TaggerWindow/ProcessingMessage=Sending thumbnails of the selected photos...'
             LrDialogs.showBezel(message, 2)

             local json = AzureVisionApi.getTags(photos, thumbnailPaths)

             -- Populate the KwUtils.catKws and KwUtils.catKwPaths tables
             local allKeys = KwUtils.getAllKeywords(catalog)
             makeWindow(catalog, photos, json)

             for _, thumbnailPath in ipairs(thumbnailPaths) do
                LrFileUtils.delete(thumbnailPath)
             end
       end )
   end )
end)
