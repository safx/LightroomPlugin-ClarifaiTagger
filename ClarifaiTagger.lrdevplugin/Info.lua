local menuItems = {
     title = LOC "$$$/ClarifaiTagger/OpenClarifaiTagger=Request keyword suggestions from Clarifai",
     file = "TaggerDialog.lua",
     enabledWhen = "photosSelected"
}

return {
   LrSdkVersion = 5.0,
   LrSdkMinimumVersion = 5.0,

   LrToolkitIdentifier = "com.blogspot.safxdev.tagger.clarifai",
   LrPluginInfoUrl = "https://github.com/safx/LightroomPlugin-ClarifaiTagger",
   
   LrPluginName = "ClarifaiTagger",
   -- Put in both "File" and "Library" plugin menus
   LrExportMenuItems = menuItems,
   LrLibraryMenuItems = menuItems,
   LrPluginInfoProvider = 'ClarifaiTaggerInfoProvider.lua',
   LrInitPlugin = 'ClarifaiTaggerInit.lua',

   VERSION = {display='1.1.0', major=1, minor=1, revision=0, build=20161011},
}
