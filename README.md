# flutter-app

All the actual Flutter app code for [Identiflora](https://identifloraapp.wordpress.com/). Please setup the following to use this app directly off GitHub code. Although, some setup may also require steps outlined in the [identiflora-api](https://github.com/Identiflora/identiflora-api) and [identiflora-database](https://github.com/Identiflora/identiflora-database) as well.

## Google Cloud Setup

[Google Cloud](https://cloud.google.com/) is required to have any form of contact with Google's API, such as for the "Sign in with Google" button. Currently, the only steps required to setup Google Cloud for Identiflora is to make a personalized [Android keystore](https://docs.flutter.dev/deployment/android#create-an-upload-keystore) and client IDs for both the debug and release versions. However, this key must be accessed through build channels, which requires some additional setup.

Note that this is a pretty extensive process and if you do not have about 30 minutes to an hour to do this in one sitting then I would suggest waiting until you do. The app will function perfectly fine as long as you do not plan to use a release version for testing or click the "Sign in with Google" button.

### Pre-Google Cloud Setup (Keystore)
1. Open terminal (or CMD) and navigate to "android" directory within the "flutter-app" local repo location.
2. Open .txt file or any document and create a password for your keystore. This is the same password you will copy into the terminal in the next step. DO NOT CLOSE THIS BUT SAVE THIS SOMEWHERE YOU CAN FIND IT LATER.
3. Run this command and copy over password from step 2 (DO NOT ANSWER ANY OTHER PROMPTS WITHOUT VIEWING STEP 4):
    * Windows:
      ```bash
      keytool -genkey -v -keystore $env:USERPROFILE\release-key.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias androidreleasekey
      ```
    * Linux/Mac:
      ```bash
      keytool -genkey -v -keystore ~/release-key.jks -keyalg RSA \ -keysize 2048 -validity 10000 -alias androidreleasekey
      ```
4. Enter in prompts as follows:
    * What is your first and last name? [Just press enter or skip]
    * What is the name of your organizational unit? [Just press enter or skip]
    * What is the name of your organization? Identiflora
    * What is the name of your City or Locality? Reno
    * What is the name of your State or Province? Nevada
    * What is the two-letter country code for this unit? [Just press enter or skip]
5. Type "y", press enter, and recopy password into prompt.
6. Go to directory referenced by "Storing" output terminal print. 
    * Windows Ex: ```C:\Users\\{current_user}\```
7. Copy this keystore into the "app" folder located within the "android" local repo folder.
8. Make a file directly in **"android" not "android/app"** directory called "key.properties". 
    * Fill out this file using this example:
      ```
      storePassword=<key_password>
      keyPassword=<key_password>
      keyAlias=androidreleasekey
      storeFile=<path_to_key_dir>
      ```
      The path to dir should be something like: ```<path_to_repo_clone>\\android\\app\\release-key.jks```
  
      **IMPORTANT**: If you are using Windows make sure to have the double slash between all directories instead of the normal single.
  9. **VERY IMPORTANT!** Verify that both your keystore file (.jks) and key.properties are ignored by Git. This should be done automatically as Flutter has built in ignores for any .jks and key.properties. No repository should contain these files as that is a breach of security.
<br></br>

### Google Cloud Setup (Client IDs)
1. Log onto [Google Cloud console](https://console.cloud.google.com/) and setup an account, if needed.
2. Click "Select a Project" on the top left and create a new project (top right of pop up window). This can be named whatever you want.
3. Click "Select Project" in notification window, after project is finished being created. 
4. In the search bar at the top, type "oauth" this should come up with an "OAuth Consent Screen" option. Select that.
5. Click "Get Started" on OAuth Overview screen.
6. Enter app name (Identiflora) and your email. Click next.
7. Select "External" as this is very important for actual app communication.
8. Enter your email again. Click next. Agree to terms. Then click create.
9. On the lefthand side select "Clients" then click "Create Client" at the top.
10. Select "Android" and fill out client name. This should include the word "Debug" or "Release" depending which client ID you want to make first. You will have to make two of these.
11. Put "com.example.identiflora" in package name.
12. Now you need to get the SHA-1 fingerprint from your keystores. Personally, I don't like the command Google Cloud provides so I suggest doing the following instead.
    * Verify you are in the "android" subdirectory of the "flutter-app" local repo clone.
    * Use this command: ```./gradlew signingReport```
    * Scroll to the top and look for Variant/Config of "release" or "debug" versions.
    * Copy the SHA1 line into Google Cloud for the correct variant.
13. Click "Verify ownership" even though it currently always fails. Then click "Create" that should now be lit up blue.
14. Repeat steps 9-13 again for the other version (Release or Debug).
15. You should now be able to view both client IDs on the "Clients" page of OAuth. Copy these into the "CLIENT_ID" variable for the correct environment (Debug into development and Release into production). If you are confused what an Environment is, refer to next section of readme.
16. Lastly, you need to contact Dylan for the "SERVER_ID" portion of this setup as it must match the API's ID and, therefore, cannot be generated by anyone else.

<u>Google Cloud Setup for iOS</u> (Client IDs)
1. On the Google Cloud Console, go to your project.
2. Navigate to "APIs & Services" > "Credentials".
3. Click "Create Credentials" > "OAuth client ID".
4. Select "iOS" as the Application type.
5. Enter the app's Bundle ID (e.g., `com.example.identiflora` or match the `PRODUCT_BUNDLE_IDENTIFIER` in Xcode).
6. Click "Create".
7. Copy the generated "Client ID" and its corresponding "iOS URL scheme" / "Reversed Client ID" (e.g. `com.googleusercontent.apps.YOUR_IOS_CLIENT_ID`).
8. Open `ios/Runner/Info.plist` in your project.
9. Locate the `GIDClientID` and `CFBundleURLSchemes` keys inside the `<!-- Google Sign-in Section -->`.
10. Replace the placeholder values (`YOUR_IOS_CLIENT_ID...`) with your actual iOS Client ID and Reversed Client ID respectively.
<br></br>

## Environment(s) Setup

The environment class (in lib/environment.dart) is setup to allow easy swapping between local development and cloud testing. There are just a couple of things to complete locally to set it up. 

1. Create 2 files with the following names: 
    - `.env.production` (for cloud testing)
    - `.env.development` (for local development)
2. IMPORTANT: Double check that both of these files are present in .gitignore. 
3. Use the environment variable names from `.env.example` to populate both files (You will need to replace the value of the variables). 
4. It is setup so that if you build in debug mode, it will use `.env.development`, and if you run in release mode it will use `.env.production`. To run in release mode, use 

    ```bash
   flutter run --release
    ```

***WARNING:*** Make sure to follow the Google Cloud setup steps above BEFORE adding Google variables from ".env.example" to any environment. It will also explain the process of why they are neededed in more detail.

### Usage:

If you need to add a new environment variable for any reason, you must add it to all of the `.env` files, and add a get method for it in the Environment class. 

Once a get method is implemented, environment variables can be accessed using Environment.exampleVariable. 
<br></br>

## Google Maps Setup

Google Maps is used to display plant identification geolocation data of where the plant was identified. To setup Google Maps, get an [API key from Google](https://mapsplatform.google.com/) and add it to your environment file under "MAPS_API_KEY" variable name, as shown in the env.example. Additionally, enter this API key into your Android local.properties file as "maps.api.key" variable name.