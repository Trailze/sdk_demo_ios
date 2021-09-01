# Trailze iOS SDK Demo App
A barebones demo app to get started with the Trailze SDK on iOS 

## Installation instructions
- Make sure you have your Mapbox and Trailze access keys.

- Clone this repo.

- Run `pod install` and open the xcworkspace file

- [Download Trailze.xcframework and TrailzeResourceBundle.bundle](https://trailze-ios-sdk.s3.amazonaws.com/Trailze-iOS-SDK-latest.zip)

- Add the framework and bundle to your project:
![alt text](https://docs.trailze.com/doc-1.png "Logo Title Text 1")
1. Drag and drop the framework and the resource bundle to your base application.
2. Link the framework and the bundle in “Frameworks, Libraries, and Embedded Content”
3. Choose “Do Not Embed” for Trailze.xcframework
4. Choose “Embed & Sign” for TrailzeResourceBundle.bundle

- Replace the placeholder strings with your Mapbox and Trailze access keys in `info.plist`
```swift
<key>TRLAccessToken</key>
<string>ENTER_TRAILZE_ACCESS_TOKEN_HERE</string>
<key>MGLMapboxAccessToken</key>
<string>ENTER_MAPBOX_ACCESS_TOKEN_HERE</string>
```

- Note: the turn-by-turn navigation does not work in the simulator, only on a device.

## And... we're done.

Please check out the [iOS Integration](https://docs.trailze.com/#integration-ios) section in the documentation to see the host of different features you can configure.
