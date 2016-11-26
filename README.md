# LightroomPlugin-ClarifaiTagger

![](Images/ClarifaiTagger1.png)

This Lightroom plugin helps you to add keywords to your photos, powered by the [Clarifai](http://www.clarifai.com/), visual recognition service.

* works with JPEG and Raw files
* works on Windows and Mac OS X (not yet tested on Windows)

## Create a Developer Account on Clarifai.com

To use ClarifaiTagger, you must first create a developer account on [Clarifai](http://www.clarifai.com/) and create an application.

1. Go to  [Clarifai](http://www.clarifai.com/) and create a developer accout.

1. Click "Create an application" from Applications → Create a new Application.

    ![](Images/ClarifaiApp1.png)

1. Once you create your application, the Client ID and Client Secret are provided.

    ![](Images/ClarifaiApp2.png)

## Installation & Setup

To install ClarifaiTagger, follow these steps:

1. Clone or download this project.

1. Open "Lightroom Plug-in Manager" from Lightroom menu → File → Plug-in Manager...

1. Click "Add" and select the `ClarifaiTagger.lrdevplugin`.

    ![](Images/PluginManager1.png)

    Or, simply put the `ClarifaiTagger.lrdevplugin` in its standard location as follows:

    * Mac OS X (current user only): `~/Library/Application Support/Adobe/Lightroom/Modules`
    * Mac OS X (for all users): `/Library/Application Support/Adobe/Lightroom/Modules`
    * Windows: `C:\Users\username\AppData\Roaming\Adobe\Lightroom\Modules`

1. Fill the `Client ID` and `Client Secret` fields with the values provided by clarifai.com for the application you've created.

    ![](Images/PluginManager2.png)

## How to use

1. Select the photos for which you want to add keywords. You may select up to 128 photos (the maximum supported by Clarifai).
1. Choose `Request keyword suggestions from Clarifai` from Lightroom’s `Library → Plugin-Extras` menu.

    ![](Images/ClarifaiTagger_Menu.png)

1. After a few seconds, the Clarifai Tagger window should pop up with the keywords suggested by Clarifai for each selected image.

    ![](Images/ClarifaiTagger1.png)

1. Check keywords you want to add.
1. Click "Save" to apply changes, or "Cancel" otherwise.

## Preferences

![](Images/PluginManager2.png)

### Tagging

* **Show Existing Keywords as Bold**: uses bold face for keywords which are already in the catalog's keyword list
* **Automatically Select Existing Keywords**: automatically selects the checkboxes for keywords which are already in the catalog's keyword list
* **Show Probability**: Display each keyword's rated probability
        ![](Images/ClarifaiTagger2.png)

### Image Settings

* **Image Size**: sets the size of thumbnail images sent to Clarifai
* **Keyword Language**: determines the language of keywords received from Clarifai. By default, it's the language you configured as default for your application (on clarifai.com), however you can change this setting in the plugin preferences to receive keywords in some other language, if you desire.
