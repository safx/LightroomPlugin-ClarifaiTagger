local LrPrefs = import 'LrPrefs'
local LrView = import 'LrView'
local ClarifaiAPI = require 'ClarifaiAPI'

-----------------------------------------

local function trim(s)
   if s == nil then return nil end
   return string.gsub(s, '^%s*(.-)%s*$', '%1')
end

local function getOrDefault(value, default)
   if value == nil then
      return default
   end
   return value
end

local function sectionsForTopOfDialog(viewFactory, properties)
   local f = viewFactory;

   local f = LrView.osFactory();
   local bind = LrView.bind
   local share = LrView.share

   local prefs = LrPrefs.prefsForPlugin();
   properties.clientId = prefs.clientId;
   properties.clientSecret = prefs.clientSecret;
   properties.accessToken = prefs.accessToken;
   properties.imageSize = getOrDefault(tonumber(prefs.imageSize), 400);
   properties.keywordLanguage = getOrDefault(prefs.keywordLanguage, '');
   properties.boldExistingKeywords = getOrDefault(prefs.boldExistingKeywords, true);
   properties.autoCheckForExistingKeywords = getOrDefault(prefs.autoCheckForExistingKeywords, true);
   properties.showProbability = getOrDefault(prefs.showProbability, false);

   return {
      {
         title = LOC '$$$/ClarifaiTagger/Preferences/AuthHeader=Authentication Settings',
         bind_to_object = properties,

         f:row {
            spacing = f:label_spacing(),

            f:static_text {
               title = LOC '$$$/ClarifaiTagger/Preferences/ClientId=Client ID:',
               alignment = 'right',
               width = share 'title_width',
            },

            f:edit_field {
               fill_horizonal = 1,
               width_in_chars = 35,
               value = bind 'clientId',
            },
         },

         f:row {
            spacing = f:label_spacing(),

            f:static_text {
               title = LOC '$$$/ClarifaiTagger/Preferences/ClientSecret=Client Secret:',
               alignment = 'right',
               width = share 'title_width',
            },

            f:edit_field {
               fill_horizonal = 1,
               width_in_chars = 35,
               value = bind 'clientSecret',
            },
         },

         f:row {
            spacing = f:label_spacing(),

            f:static_text {
               title = LOC '$$$/ClarifaiTagger/Preferences/AccessToken=Access Token:',
               alignment = 'right',
               width = share 'title_width',
            },

            f:edit_field {
               fill_horizonal = 1,
               width_in_chars = 35,
               enabled = false,
               value = bind 'accessToken',
            },
         },

         f:separator { fill_horizontal = 1 },
      },

      {
         title = LOC '$$$/ClarifaiTagger/Preferences/Tagging=Tagging',
         bind_to_object = properties,

         f:row {
            spacing = f:control_spacing(),

            f:checkbox {
               title = LOC '$$$/ClarifaiTagger/Preferences/BoldExistingKeywords=Show Existing Keywords as Bold',
               value = bind 'boldExistingKeywords'
            },
         },
         f:row {
            spacing = f:control_spacing(),

            f:checkbox {
               title = LOC '$$$/ClarifaiTagger/Preferences/AutoCheckForExistingKeywords=Auto Check for Existing Keywords',
               value = bind 'autoCheckForExistingKeywords'
            },
         },
         f:row {
            spacing = f:control_spacing(),

            f:checkbox {
               title = LOC '$$$/ClarifaiTagger/Preferences/showProbability=Show Probability',
               value = bind 'showProbability'
            },
         },
      },

      {
         title = LOC '$$$/ClarifaiTagger/Preferences/ImageHeader=Image Settings',
         bind_to_object = properties,

         f:row {
            spacing = f:control_spacing(),

            f:static_text {
               title = LOC '$$$/ClarifaiTagger/Preferences/ImageSize=Image Size:',
               alignment = 'right',
               width = share 'title_width',
            },

            f:slider {
               min = 224,
               max = 1024,
               integral = true,
               value = bind 'imageSize',
            },

            f:edit_field {
               fill_horizonal = 1,
               width_in_chars = 4,
               min = 224,
               max = 1024,
               increment = 1,
               precision = 0,
               value = bind 'imageSize',
            },
         },

         f:row {
            f:spacer { width = share 'title_width', height = 1 },

            f:static_text {
               title = LOC '$$$/ClarifaiTagger/Preferences/ThumbnailSizeDesc=size of Image send to Clarifai server (224-1024)',
               alignment = 'right',
            },
         },
         f:spacer { width = 1, height = 4 },

         f:row {
            spacing = f:label_spacing(),

            f:static_text {
               title = LOC '$$$/ClarifaiTagger/Preferences/KeywordLanguage=Keyword Language:',
               alignment = 'right',
               width = share 'title_width',
            },

            f:popup_menu {
               items = {
                  { value = ''      , title = 'Default (depends on the server setting)' },
                  { value = 'ar'    , title = 'Arabic (ar)'                  },
                  { value = 'bn'    , title = 'Bengali (bn)'                 },
                  { value = 'da'    , title = 'Danish (da)'                  },
                  { value = 'de'    , title = 'German (de)'                  },
                  { value = 'en'    , title = 'English (en)'                 },
                  { value = 'es'    , title = 'Spanish (es)'                 },
                  { value = 'fi'    , title = 'Finnish (fi)'                 },
                  { value = 'fr'    , title = 'French (fr)'                  },
                  { value = 'hi'    , title = 'Hindi (hi)'                   },
                  { value = 'hu'    , title = 'Hungarian (hu)'               },
                  { value = 'it'    , title = 'Italian (it)'                 },
                  { value = 'ja'    , title = 'Japanese (ja)'                },
                  { value = 'ko'    , title = 'Korean (ko)'                  },
                  { value = 'nl'    , title = 'Dutch (nl)'                   },
                  { value = 'no'    , title = 'Norwegian (no)'               },
                  { value = 'pa'    , title = 'Punjabi (pa)'                 },
                  { value = 'pl'    , title = 'Polish (pl)'                  },
                  { value = 'pt'    , title = 'Portuguese (pt)'              },
                  { value = 'ru'    , title = 'Russian (ru)'                 },
                  { value = 'sv'    , title = 'Swedish (sv)'                 },
                  { value = 'tr'    , title = 'Turkish (tr)'                 },
                  { value = 'zh-TW' , title = 'Chinese Traditional (zh-TW)'  },
                  { value = 'zh'    , title = 'Chinese Simplified (zh)'      },
               },
               value = bind 'keywordLanguage',
            },
         },
      }
   }
end

local function sectionsForBottomOfDialog(viewFactory, properties)
   local f = viewFactory;
   return {
      {
         title = LOC '$$$/ClarifaiTagger/Preferences/Acknowledgements=Acknowledgements',

         f:static_text {
            title = LOC '$$$/ClarifaiTagger/Preferences/SimpleJSON=Simple JSON',
         },
         f:edit_field {
            width_in_chars = 80,
            height_in_lines = 9,
            enabled = false,
            value = 'Simple JSON encoding and decoding in pure Lua.\n\nCopyright 2010-2014 Jeffrey Friedl\nhttp://regex.info/blog/\n\nLatest version: http://regex.info/blog/lua/json\n\nThis code is released under a Creative Commons CC-BY "Attribution" License:\nhttp://creativecommons.org/licenses/by/3.0/deed.en_US\n'
         }
      }
   }
end

local function endDialog(properties)
   local prefs = LrPrefs.prefsForPlugin();

   prefs.clientId = trim(properties.clientId);
   prefs.clientSecret = trim(properties.clientSecret);
   prefs.accessToken = trim(properties.accessToken);
   prefs.imageSize = tonumber(properties.imageSize);
   prefs.keywordLanguage = trim(properties.keywordLanguage);
   prefs.boldExistingKeywords = properties.boldExistingKeywords;
   prefs.autoCheckForExistingKeywords = properties.autoCheckForExistingKeywords;
   prefs.showProbability = properties.showProbability;
end


return {
   sectionsForTopOfDialog = sectionsForTopOfDialog,
   sectionsForBottomOfDialog = sectionsForBottomOfDialog,
   endDialog = endDialog,
}
