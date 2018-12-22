local menuItems = {
     title = LOC "$$$/AzureVisionTagger/OpenAzureVisionTagger=Request keyword suggestions from Azure",
     file = "TaggerDialog.lua",
     enabledWhen = "photosSelected"
}

return {
   LrSdkVersion = 5.0,
   LrSdkMinimumVersion = 5.0,

   LrToolkitIdentifier = "com.hanebambel.lightroom.plugin.azurevision",
   LrPluginInfoUrl = "https://github.com/hanebambel/LightroomPlugin-AzureVisionTagger",

   
   LrPluginName = "AzureVisionTagger",
   -- Put in both "File" and "Library" plugin menus
   LrExportMenuItems = menuItems,
   LrLibraryMenuItems = menuItems,
   LrPluginInfoProvider = 'AzureVisionTaggerInfoProvider.lua',
   LrInitPlugin = 'AzureVisionTaggerInit.lua',

   -- Azure specific Metadata extension
   LrMetadataProvider = 'AzureVisionMetadataDefinition.lua',
   LrMetadataTagsetFactory = 'AzureVisionTagset.lua',

   VERSION = {display='1.0.0', major=1, minor=0, revision=0, build=20181218},
}
