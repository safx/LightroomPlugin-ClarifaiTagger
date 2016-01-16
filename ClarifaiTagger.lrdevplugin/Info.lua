return {
   LrSdkVersion = 5.0,
   LrSdkMinimumVersion = 5.0,

   LrToolkitIdentifier = 'com.blogspot.safxdev.tagger.clarifai',
   LrPluginName = LOC "$$$/ClarifaiTagger/PluginName=ClarifaiTagger",

   LrLibraryMenuItems = {
      {
         title = LOC "$$$/ClarifaiTagger/OpenClarifaiTagger=Open with Selected Photos",
         file = "TaggerDialog.lua",
         enabledWhen = "photosSelected",
      },
   },

   LrPluginInfoProvider = 'PluginInfoProvider.lua',

   VERSION = { major=1, minor=0, revision=0, build=1, },
}
