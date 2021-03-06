Kollections
-----------
This project is no longer maintained.  Open-sourcing it for historical purposes only.  It was supposed to be a somewhat contrived token-based media game(?) where users could curate their own collections of photos and videos for other users to view.  Other users could then attempt to add their own entries to the user's "kollection" if the user requested entries.  If a user selected a submitted entry, points/tokens would be awarded to the submitter.  The premise of the app was definitely forced, with lots of unanswered questions as to why someone would even want to use it, but it was more a way for me to get further practice with the Parse cloud code module than anything, if I recall.

**********

Below are the notes I'd left to myself from the private README:
__________________________________________________________________
DEVELOPER NOTES
------------------------------------------------------------------
- Creating a kollection creates an entry in the Activity table as "created" with just a kollection pointer added; toUser and fromUser are both filled in as the current user
- Photo objects have no relation to anything other than the user pointer which points to the photo's creator
- Subject objects only have pointers to the kollection which they are a part of
- To link Photo objects with Subject objects, when a Photo object is created/uploaded, and Activity of "submitted" is also created; this Activity object contains a pointer to the kollection, subject and photo objects it pertains to
- If a kollection or subject object is deleted, the "submitted" activities are modified and the kollection and subject pointers are cleared; the photo object pointers remain and the photo objects are untouched; this will allow users to resubmit the same photo elsewhere without redundant uploads

__________________________________________________________________
TO DO 
------------------------------------------------------------------
- Add KKCache/KKUtility methods for kollection objects
- Add pertinant constants for kollection object tracking
- Allow for a user created using Parse to link themselves with FB and/or Twitter via Settings page: https://www.parse.com/docs/ios_guide#fbusers-link/iOS
- Add ability to post to Facebook: https://www.parse.com/docs/ios_guide#fbusers-signup/iOS
- Add icon to FB URL scheme in Target --> Info "icon@2x.png"
- Add app store ID to FB app settings page once added to iTunes for direct linking to it in app store
- Attributed strings in SignUpViewController linking to UIWebView of TOS and Privacy policy on www.startakollection.com
- Redo Log in button in another color? Top two corners are pixelated
- Make the collectionview side-scrolling toolbar size dynamically based on length of string titles, instead of constant width for each item
- update the UI for adding comments below a photo
- when creating a kollection, successfully share to FB if toggle turned on
- create FB objects for sharing a new kollection

__________________________________________________________________
TO DO CLOUD CODE
------------------------------------------------------------------
- Cloud code added to prevent the same Display Name from being signed up with as other users
- Look into the real-time Crowdflower photo moderation module included in Parse now

__________________________________________________________________
COMPLETED
------------------------------------------------------------------

__________________________________________________________________
VIEWS NEEDING TIPS/HINTS
------------------------------------------------------------------
- KKKollectionSubjectsTableViewController to explain swipe left and right to go into/out of editing mode for deleting and reordering subjects 

__________________________________________________________________
FUTURE
------------------------------------------------------------------
- Add Viddy support with 15-second video clips
- Add Twitter login integration; add icon to Twitter app page
- Add filters and photo manipulation to KKEditPhotoViewController
- Add ability to make Kollections location-based and only accept submissions from within a certain radius of
  a certain map coordinate
- Fix photo submissions so a photo will drag immediately on touch instead of requiring a 2nd touch to drag
- Fix ability to touch and drag photo tray open in relation to creating drop targets correctly for photo submission (dragging itself works fine, just not drop target frames)
- Add ability to have different koin values per subject instead of kollection-wide
- Ability to display where photos in a kollection were taken all on a map (if geopoint available)
- Ability to upload entire kollection to Facebook at once
- Ability to import photos from Facebook and Instagram
  
__________________________________________________________________  
3RD PARTIES USED
------------------------------------------------------------------
- Nimbus
- BlockAlerts and ActionSheets by Gustavo Ambrozio
- SlimeRefresh
- UIImage+Categories
- MBProgressHUD
- TTTTimeIntervalFormatter
- iOS Image Editor - https://github.com/heitorfr/ios-image-editor
- DLCImagePickerController - https://github.com/gobackspaces/DLCImagePickerController#readme
- GPUImage - https://github.com/BradLarson/GPUImage
- ELCImagePickerController - https://github.com/elc/ELCImagePickerController

