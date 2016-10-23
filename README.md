# On The Map
On The Map is the third major application of the Udacity iOS Developer Nanodegree. This app enables Udacity students to share their
current location alongside an interesting link. The main focus of developing this app lays on Networking in iOS.

## Description
On The Map is an app that lets Udacity students share their current location with an interesting link which can be anything
from an interesting article they've read to their LinkedIn profile. In the beginning the user can login with either Udacity
credentials or via Facebook. 

The user can then watch all the previously posted student locations either in a map view or a table view and tap on a student
to be directed to the associated link.

From the map or the table view it's also possible for the student to add a new location or update an existing one by tapping on
the pin symbol in the navigation bar.

## About Facebook login
In order to use Facebook login you have to follow these steps:
- Download the [Facebook SDK](https://developers.facebook.com/docs/ios/getting-started/)
- Unzip it and put the files `Bolts.framework`, `FBSDKCoreKit.framework` and `FBSDKLoginKit.framework` into ~/Documents/FacebookSDK (if you put it in a different directory the project's Framework Search Path has to be set accordingly)
- Drag the files `Bolts.framework`, `FBSDKCoreKit.framework` and `FBSDKLoginKit.framework` in the Frameworks folder or to *Linked Frameworks and Libraries* in the general Target settings, check **Create groups for any added folders** and uncheck **Copy items into destination group's folder**. 

## Screenshots
### Login Screen
![Login Screen](https://github.com/helmrich/On-The-Map/blob/master/otm-login-screen.png "Login Screen")

### Map View
![Map View](https://github.com/helmrich/On-The-Map/blob/master/otm-map-view.png "Map View")

### Table View
![Table View](https://github.com/helmrich/On-The-Map/blob/master/otm-table-view.png "Table View")

### Posting a Location - Finding a location
![Posting a Location - Find location](https://github.com/helmrich/On-The-Map/blob/master/otm-information-posting-1.png "Posting a Location - Find location")

### Adding a Link to the Location
![Adding a Link to the Location](https://github.com/helmrich/On-The-Map/blob/master/otm-information-posting-2.png "Adding a link to the location")


