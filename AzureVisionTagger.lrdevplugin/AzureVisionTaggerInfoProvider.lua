local LrView = import 'LrView'

local simpleJsonAcknowledgement = 'Simple JSON encoding and decoding in pure Lua.\n\nCopyright 2010-2014 Jeffrey Friedl\nhttp://regex.info/blog/\n\nLatest version: http://regex.info/blog/lua/json\n\nThis code is released under a Creative Commons CC-BY "Attribution" License:\nhttp://creativecommons.org/licenses/by/3.0/deed.en_US'

-----------------------------------------
local AzureVisionTaggerInfoProvider = {}

function AzureVisionTaggerInfoProvider.sectionsForTopOfDialog(viewFactory, propertyTable)
   local prefs = import 'LrPrefs'.prefsForPlugin(_PLUGIN.id)
   local bind = LrView.bind
   local share = LrView.share

   return {
      {
         title = LOC '$$$/AzureVisionTagger/Settings/AuthHeader=Authentication Settings',

         viewFactory:row {
            spacing = viewFactory:label_spacing(),

            viewFactory:static_text {
               tooltip = "Copy from your Azure Account",
               title = LOC '$$$/AzureVisionTagger/Settings/Heading=You need to create an account on portal.azure.com and create a cognitive services vision API Key',
               alignment = 'right',
               -- width = share 'title_width',
            },
         },

         viewFactory:row {
            spacing = viewFactory:label_spacing(),

            viewFactory:static_text {
               tooltip = "Copy from your Azure Account",
               title = LOC '$$$/AzureVisionTagger/Settings/visionKey=KEY:',
               alignment = 'right',
               -- width = share 'title_width',
            },

            viewFactory:edit_field {
               tooltip = "Copy from your Azure Account",
               fill_horizonal = 1,
               width_in_chars = 35,
               alignment = 'left',
               value = bind { key = 'visionKey', object = prefs },
            },
         },

         viewFactory:row {
            spacing = viewFactory:label_spacing(),

            viewFactory:static_text {
               tooltip = "Copy from your Azure Account",
               title = LOC '$$$/AzureVisionTagger/Settings/visionBaseURL=Vision Base URL:',
               alignment = 'right',
               -- width = share 'title_width',
            },

            --[[
            viewFactory:edit_field {
               tooltip = "Copy from your Azure Account",
               fill_horizonal = 1,
               width_in_chars = 35,
               alignment = 'left',
               value = bind { key = 'visionBaseURL', object = prefs },
            },
            ]]--

            viewFactory:popup_menu {
               items = {
                  { value = 'https://westus.api.cognitive.microsoft.com/', title = 'West US - westus.api.cognitive.microsoft.com' },
                  { value = 'https://westus2.api.cognitive.microsoft.com/' , title = 'West US 2 - westus2.api.cognitive.microsoft.com' },
                  { value = 'https://eastus.api.cognitive.microsoft.com/' , title = 'East US - eastus.api.cognitive.microsoft.com' },
                  { value = 'https://eastus2.api.cognitive.microsoft.com/' , title = 'East US 2 - eastus2.api.cognitive.microsoft.com' },
                  { value = 'https://westcentralus.api.cognitive.microsoft.com/' , title = 'West Central US - westcentralus.api.cognitive.microsoft.com' },
                  { value = 'https://southcentralus.api.cognitive.microsoft.com/' , title = 'South Central US - southcentralus.api.cognitive.microsoft.com' },
                  { value = 'https://westeurope.api.cognitive.microsoft.com/' , title = 'West Europe - westeurope.api.cognitive.microsoft.com' },
                  { value = 'https://northeurope.api.cognitive.microsoft.com/' , title = 'North Europe - northeurope.api.cognitive.microsoft.com' },
                  { value = 'https://southeastasia.api.cognitive.microsoft.com/' , title = 'Southeast Asia - southeastasia.api.cognitive.microsoft.com' },
                  { value = 'https://eastasia.api.cognitive.microsoft.com/' , title = 'East Asia - eastasia.api.cognitive.microsoft.com' },
                  { value = 'https://australiaeast.api.cognitive.microsoft.com/' , title = 'Australia East - australiaeast.api.cognitive.microsoft.com' },
                  { value = 'https://brazilsouth.api.cognitive.microsoft.com/' , title = 'Brazil South - brazilsouth.api.cognitive.microsoft.com' },
                  { value = 'https://canadacentral.api.cognitive.microsoft.com/' , title = 'Canada Central - canadacentral.api.cognitive.microsoft.com' },
                  { value = 'https://centralindia.api.cognitive.microsoft.com/' , title = 'Central India - centralindia.api.cognitive.microsoft.com' },
                  { value = 'https://uksouth.api.cognitive.microsoft.com/' , title = 'UK South - uksouth.api.cognitive.microsoft.com' },
                  { value = 'https://japaneast.api.cognitive.microsoft.com/' , title = 'Japan East - japaneast.api.cognitive.microsoft.com' },
              },
              value = bind { key = 'visionBaseURL', object = prefs },
            },
         },

        
      },

      {
         title = LOC '$$$/AzureVisionTagger/Settings/tagging=Tagging Dialog',

         viewFactory:row {
            spacing = viewFactory:control_spacing(),

            viewFactory:static_text {
               title = LOC '$$$/AzureVisionTagger/Settings/thumbnailSize=Thumbnail size (in tagging dialog)',
               alignment = 'left',
               width = share 'title_width',
            },

            viewFactory:slider {
               min = 250,
               max = 500,
               integral = true,
               alignment = 'left',
               tooltip = 'Allowable range 250 to 500 pixels.',
               value = bind { key = 'thumbnailSize', object = prefs },
            },

            viewFactory:edit_field {
               fill_horizonal = 1,
               width_in_chars = 3,
               min = 250,
               max = 500,
               increment = 1,
               precision = 0,
               alignment = 'left',
               tooltip = 'Allowable range 250 to 500 pixels. “Short side” dimension for thumbnail images shown in the tagging window',
               value = bind { key = 'thumbnailSize', object = prefs },
            },
         },
         viewFactory:row {
            viewFactory:spacer { width = share 'title_width', height = 1 },

            viewFactory:static_text {
               title = LOC '$$$/AzureVisionTagger/Settings/ThumbnailSizeDesc=Size of tagging window thumbnail images (“short side”)',
               alignment = 'right',
            },
         },
         viewFactory:spacer { width = 1, height = 4 },
         viewFactory:row {
            spacing = viewFactory:control_spacing(),
            viewFactory:static_text {
               title = 'Tagging window width',
               tooltip = 'Width (px) of the tagging window (range 500–3800px)',
            },
            viewFactory:edit_field {
               value = bind { key = 'taggingWindowWidth', object = prefs },
               tooltip = 'Width (px) of the tagging window (range 500–3800px)',
               min = 500,
               max = 3800,
               width_in_chars = 4,
               increment = 1,
               precision = 0,
            },
            spacing = viewFactory:control_spacing(),
            viewFactory:static_text {
               title = 'Tagging window height',
               tooltip = 'Height (px) of the tagging window (range 400-2100px)',
            },
            viewFactory:edit_field {
               value = bind { key = 'taggingWindowHeight', object = prefs },
               tooltip = 'Height (px) of the tagging window (range 400–2100px)',
               min = 400,
               max = 2100,
               width_in_chars = 4,
               increment = 1,
               precision = 0,
           }
         },
         viewFactory:spacer { width = 1, height = 4 },
         viewFactory:row {
            spacing = viewFactory:control_spacing(),
            viewFactory:static_text {
               title = 'Image preview window width',
               tooltip = 'Width (px) of the image preview window (range 500–3800px)',
            },
            viewFactory:edit_field {
               value = bind { key = 'imagePreviewWindowWidth', object = prefs },
               tooltip = 'Width (px) of the image preview window (range 500–3800px)',
               min = 500,
               max = 3800,
               width_in_chars = 4,
               increment = 1,
               precision = 0,
            },
            spacing = viewFactory:control_spacing(),
            viewFactory:static_text {
               title = 'Image preview window height',
               tooltip = 'Height (px) of the image preview window (range 400–2100px)',
            },
            viewFactory:edit_field {
               value = bind { key = 'imagePreviewWindowHeight', object = prefs },
               tooltip = 'Height (px) of the image preview window (range 400–2100px)',
               min = 400,
               max = 2100,
               width_in_chars = 4,
               increment = 1,
               precision = 0,
            }
         },
         viewFactory:spacer { width = 1, height = 4 },
         viewFactory:row {
            spacing = viewFactory:control_spacing(),

            viewFactory:checkbox {
               title = LOC '$$$/AzureVisionTagger/Settings/boldExistingKeywords=Show existing keywords in bold',
               tooltip = "Selecting this option will display in bold print any keywords which are already found in your keyword list",
               value = bind { key = 'boldExistingKeywords', object = prefs },
            },
         },
         viewFactory:row {
            spacing = viewFactory:control_spacing(),

            viewFactory:checkbox {
               title = LOC '$$$/AzureVisionTagger/Settings/autoSelectExistingKeywords=Automatically Select Existing Keywords',
               tooltip = "Selecting this option will auto-select keyword checkboxes which would *not* create a new term in your keyword list.",
               value = bind { key = 'autoSelectExistingKeywords', object = prefs },
            },
         },
         -- Probability threshold (only used if autoSelectExistingKeywords is turned on.)
         viewFactory:row {
            -- spacing = viewFactory:control_spacing(),
            spacing = viewFactory:label_spacing(),

            viewFactory:static_text {
               title = LOC '$$$/AzureVisionTagger/Settings/autoSelectProbabilityThreshold=Confidence threshold for auto-selection:',
               alignment = 'left',
               width = share 'title_width',
            },

            viewFactory:slider {
               min = 1,
               max = 99,
               integral = true,
               alignment = 'left',
               value = bind { key = 'autoSelectProbabilityThreshold', object = prefs },
            },

            viewFactory:edit_field {
               fill_horizonal = 1,
               width_in_chars = 2,
               min = 1,
               max = 99,
               increment = 1,
               precision = 0,
               alignment = 'left',
               tooltip = 'Setting for what level of Azure-rated confidence is required for a keyword to be auto-selected.\n\nIgnored unless the "Auto-Select existing keywords" setting is selected.',
               value = bind { key = 'autoSelectProbabilityThreshold', object = prefs },
            },

            spacing = viewFactory:control_spacing(),

            viewFactory:checkbox {
               title = LOC '$$$/AzureVisionTagger/Settings/alsoSelectNewKeywords=Also automatically select new keywords',
               tooltip = "Selecting this option will also autoselect keywords which are not already in your keyword list",
               value = bind { key = 'alsoSelectNewKeywords', object = prefs },
            }
         },

         viewFactory:row {
            spacing = viewFactory:control_spacing(),

            viewFactory:checkbox {
               title = LOC '$$$/AzureVisionTagger/Settings/showProbability=Show Confidence',
               tooltip = "Selecting this will display Azure's level of confidence that a keyword is accurate.",
               value = bind { key = 'showProbability', object = prefs },
            },
         },

         viewFactory:row {
            spacing = viewFactory:label_spacing(),

            viewFactory:static_text {
               title = LOC '$$$/AzureVisionTagger/Settings/ignore_keyword_branches=Ignore keywords branches:',
               tooltip = 'Comma-separated list of keyword terms to ignore (including chilren and descendants).',
               alignment = 'left',
               width = share 'title_width',
            },

            viewFactory:edit_field {
               tooltip = 'Comma-separated list of keyword terms to ignore (including chilren and descendants).',
               width_in_chars = 35,
               height_in_lines = 4,
               enabled = true,
               alignment = 'left',
               value = bind { key = 'ignore_keyword_branches', object = prefs },
            },
         },
      },

      {
         title = LOC '$$$/AzureVisionTagger/Settings/imageHeader=Image Settings',

         viewFactory:row {
            spacing = viewFactory:control_spacing(),

            viewFactory:static_text {
               title = LOC '$$$/AzureVisionTagger/Settings/imageSize=Image size (sent to Azure)',
               alignment = 'left',
               width = share 'title_width',
            },

            viewFactory:slider {
               min = 400,
               max = 2000,
               integral = true,
               alignment = 'left',
               tooltip = 'Allowable range 400 to 2000 pixels. Higher values use more bandwidth, but may deliver more accurate results.',
               value = bind { key = 'imageSize', object = prefs },
            },

            viewFactory:edit_field {
               fill_horizonal = 1,
               width_in_chars = 4,
               min = 400,
               max = 2000,
               increment = 1,
               precision = 0,
               alignment = 'left',
               tooltip = 'Allowable range 400 to 2000 pixels. Higher values use more bandwidth, but may deliver more accurate results.',
               value = bind { key = 'imageSize', object = prefs },
            },
         },

         viewFactory:row {
            viewFactory:spacer { width = share 'title_width', height = 1 },

            viewFactory:static_text {
               title = LOC '$$$/AzureVisionTagger/Settings/ImageSizeDesc=Size of image sent to the Azure server',
               alignment = 'right',
            },
         },
         viewFactory:spacer { width = 1, height = 4 },

         --[[-------------------------------------------
         viewFactory:row {
            spacing = viewFactory:label_spacing(),

            viewFactory:static_text {
               title = LOC '$$$/AzureVisionTagger/Settings/keywordLanguage=Keyword language:',
               alignment = 'left',
               width = share 'title_width',
            },

            viewFactory:popup_menu {
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
               value = bind { key = 'keywordLanguage', object = prefs },
            },
         }, 
         ]]-------------------------------------------
      }
   }
end


function AzureVisionTaggerInfoProvider.sectionsForBottomOfDialog(viewFactory, propertyTable)
   local KwUtilsAttribution = require 'KwUtils'.Attribution
   local LutilsAttribution = require 'LUTILS'.Attribution
   return {
      {
         title = LOC '$$$/AzureVisionTagger/Settings/acknowledgements=Acknowledgements',
         viewFactory:static_text {
            title = LOC '$$$/AzureVisionTagger/Settings/simpleJSON=Simple JSON',
            font = '<system/bold>',
         },
         viewFactory:edit_field {
            width_in_chars = 80,
            height_in_lines = 9,
            enabled = false,
            value = simpleJsonAcknowledgement
         },
         viewFactory:static_text {
            title = LOC '$$$/AzureVisionTagger/Settings/KwUtils=KwUtils: Keyword Utility Functions for Lightroom',
            font = '<system/bold>',
         },
         viewFactory:edit_field {
            width_in_chars = 80,
            height_in_lines = 5,
            enabled = false,
            value = KwUtilsAttribution
         },
         viewFactory:static_text {
            title = LOC '$$$/AzureVisionTagger/Settings/Lutils=LUTILS: Lua Utility Functions for Lightroom',
            font = '<system/bold>',
         },
         viewFactory:edit_field {
            width_in_chars = 80,
            height_in_lines = 5,
            enabled = false,
            value = LutilsAttribution
         }
      }
   }
end


return AzureVisionTaggerInfoProvider
