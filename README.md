# Vodic kroz Valjevo

Android & iOS application "Vodič kroz Valjevo"

## Description

We have developed a unique tour guide application that caters to the needs of blind people. The app comes equipped with cutting-edge accessibility features that ensure a seamless experience for visually challenged users. One of the most impressive features of the app is its text-to-speech functionality, which makes it incredibly easy for users to access the information they need. The app supports multiple languages which makes it the perfect travel companion for people from different parts of the world.

<ul>Supported languages:
<li>Serbian (Latin script)</li>
<li>Serbian (Cyrilic script)</li>
<li>English</li>
<li>German</li>
</ul>

## Back4App data

The guide reads its content and photos from Back4App. Guide data is cached only
in memory for five minutes and can be reused during a temporary connection
loss; the refresh button fetches it again. Photos that have not yet been
loaded still require a connection. The old SQLite data is no longer used. The
app logo and screen backgrounds remain bundled, while guide photos load from
HTTPS URLs on demand.

When no network interface is available, failed or pending online content shows
an offline message with settings and retry controls. Cached guide data remains
available, and failed reads and photos retry when the device reports a
connection has returned. A connected Wi-Fi network does not guarantee internet
access, so a failed request in that case shows a separate request-failure
message. Android can
open wireless settings; on iOS, use Settings or Control Center to enable Wi-Fi
or mobile data. An unsent bug report remains in the form and is not submitted
automatically.

1. Create a Back4App application and add only its public client settings to a
   local `.env` file in the project root:

   ```dotenv
   KEY_APPLICATION_ID=your-application-id
   KEY_CLIENT_KEY=your-client-key
   KEY_PARSE_SERVER_URL=https://parseapi.back4app.com/
   ```

   The whole `.env` file, including comments, is bundled into the app and can
   be extracted from the APK or IPA. **Never put a master key or any other
   secret in `.env`.** The app rejects unexpected or invalid entries at
   startup, but that check cannot remove anything already included in a build.
   The file is ignored by Git.
2. From the project root, install dependencies with `flutter pub get`.
3. The app does not need `MASTER_KEY`. Keep it outside `.env` and the app
   bundle, for example in the ignored `.env.admin` file or a secret manager.
   Rotate it in Back4App if it was included in a previously published build.
4. In Back4App, allow public **Find** and **Get** access to the six guide
   classes and keep public writes disabled. The separate `BugReport` class
   needs its own permissions for submitting reports. Manage guide content
   through the Back4App dashboard; the app only reads it.
5. Run the app:

   ```powershell
   flutter run
   ```

The Back4App class and field names are case-sensitive:

| Class | Required content fields |
| --- | --- |
| `Sights` | `title_*`, `description_*`, `sight_image_path`, `sight_image_path2`, `sight_image_path3`, `latitude`, `longitude` |
| `Sports` | `title_*`, `description_*`, `sport_image_path`, `sport_image_path2`, `sport_image_path3`, `latitude`, `longitude` |
| `Parks` | `title_*`, `description_*`, `park_image_path`, `park_image_path2`, `park_image_path3`, `latitude`, `longitude` |
| `Hotels` | `title_*`, `hotel_image_path`, `hotel_image_path2`, `latitude`, `longitude`, `website`, numeric `noStars` |
| `Restaurants` | `title_*`, `restaurant_image_path`, `restaurant_image_path2`, `restaurant_images_resource`, `latitude`, `longitude` |
| `AboutCity` | `legend_title_*`, `legend_description_*`, `history_*`, `about_city_image_path` |

For each `*`, provide `en`, `de`, `sr`, `sr_Cyrl`, and `sr_Latn` fields.
Guide image fields are strings containing HTTPS URLs, not Parse File objects.
`AboutCity` has one record per legend; its
`history_*` and image values should be kept consistent across those records.
The app uses each Parse `objectId` for detail navigation; `sourceId` is not
required for new records.

The interface supports phones and tablets in portrait and landscape, including
large system text. To run the responsive, cache, and regression tests:

```powershell
flutter test
```

## Accessibility

The app targets WCAG 2.2 AA and Android/iOS accessibility guidance. It offers
labeled controls, an accessible list alternative for hotel and restaurant maps,
buttons for map and photo navigation, zoom and panning, explicit speech
start/stop controls for descriptions and individual city facts, and support for
reduced motion. City fact values and units are spoken in the selected language.
Text-to-speech can work without a network connection when an appropriate device
voice is installed.

The automated tests cover touch-target sizes, semantic labels, text contrast,
keyboard actions, and responsive layouts up to 300% text scaling. Before each
release, manually check on Android and iOS:

- Use TalkBack and VoiceOver to verify reading order, control names, loading
  and error announcements, language selection, fact pronunciation, and the
  read/stop actions.
- Navigate with an external keyboard and switch control, checking visible
  focus, forms, dialogs, maps, and galleries without dragging or pinching.
- Check portrait and landscape with large system text and magnification; verify
  that content reflows and controls remain visible and reachable.
- Check reduced-motion settings and contrast, including text on photos and
  focused, selected, and disabled controls.
- Test network loss, photo retry, and speech without internet when a suitable
  offline device voice is installed. Include users of assistive technology.

Automated checks alone do not establish or certify WCAG conformance.

## Android 16 KB page sizes

The Android build packages native libraries uncompressed. Keep Android Gradle
Plugin 8.5.1 or later and NDK r28 or later when updating the build; the
Flutter engine and any native dependencies must also support 16 KB pages.

Before publishing a new release, build the app bundle with the release signing
configuration and verify that it requests 16 KB alignment:

```powershell
flutter build appbundle --release
java -jar C:\path\to\bundletool-all.jar dump config --bundle=build\app\outputs\bundle\release\app-release.aab
```

The bundle configuration must contain `PAGE_ALIGNMENT_16K`. Also check the
`LOAD` and `GNU_RELRO` segments of every packaged native library, verify
generated APK ZIP alignment with `zipalign -c -P 16 4 <path-to-apk>`, and
test the app on a 16 KB device or emulator (`adb shell getconf PAGE_SIZE` must
print `16384`). See the
[Android 16 KB page size guide](https://developer.android.com/guide/practices/page-sizes)
for the complete verification steps. Previously uploaded bundles are not
changed; rebuild and upload a new bundle with an incremented version code.
