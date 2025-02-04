# LifeSpace

## Setup Instructions

### Requirements

1. A mac computer running MacOS Sequoia 15.2 or greater.
2. Xcode 16.2 or later installed.
3. A [Mapbox](https://www.mapbox.com/) account and access token.
4. A [Firebase](http://firebase.google.com) account with Cloud Firestore, Cloud Storage, and `Sign in With Apple` enabled.

### Configuration

1. Clone the repository to your local computer.
2. Follow the directions outlined [here](https://docs.mapbox.com/ios/maps/guides/install/) to get your Mapbox secret *access token*.
3. Create a `.mapbox` file in the root of the project directory that contains the secret access token.
4. Open `LifeSpace.xcodeproj` in the root of the project directory in Xcode.
5. In Xcode, copy the `GoogleService-Info.plist` from your Firebase project into the `Supporting Files` folder, overwriting the sample file. *Do not* commit this file to the repository on GitHub.
6. In the `Resources` folder, add a file called `studyIDs.csv` that contains all valid study IDs, with each separated by a single newline character without any whitespace or additional characters.

Following these steps, you can build and run the application in an iOS simulator or physical device. 

> [!NOTE]
> The authors recommend using a physical device when testing location services.