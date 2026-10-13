# Kotoba Time — iOS starter project

Kotoba Time is a native SwiftUI + WidgetKit starter for Japanese vocabulary learning.

## Important build note
This environment cannot run Xcode or sign iOS applications, so it cannot produce a verified, installable `.ipa` directly. Open this project on a Mac with Xcode, create an iOS App project named `KotobaTime`, add the files below, add a Widget Extension named `KotobaTimeWidget`, configure the shared App Group, then build/archive and export the IPA.

## Features included in this starter
- SwiftUI vocabulary list and search
- JLPT N5–N1 filter
- Japanese term, kana, romaji, Indonesian meaning, example sentence
- Favorite toggle and simple learned status
- Local JSON seed vocabulary
- WidgetKit timeline widget with configurable 30-minute / 1-hour / daily interval setting scaffold
- Shared App Group storage scaffold
- Offline-first design

## Xcode setup
1. In Xcode, create an iOS App project named `KotobaTime`, Interface: SwiftUI, Language: Swift.
2. Add `KotobaTimeApp.swift`, `ContentView.swift`, `Vocabulary.swift`, and `VocabularyStore.swift` to the app target.
3. Add `kotoba_seed.json` to the app target and ensure it is included in Copy Bundle Resources.
4. Add a Widget Extension named `KotobaTimeWidget`.
5. Add `KotobaTimeWidget.swift` to the widget extension target. If you keep `Vocabulary.swift` shared, make sure it is included in both targets.
6. In Signing & Capabilities, add the same App Group to both targets, for example `group.com.yourname.KotobaTime`. Update `VocabularyStore.appGroupID` and widget code to match exactly.
7. Set deployment target to iOS 17 or newer for this starter.
8. Build and run on a simulator or connected iPhone.

## Widget timing limitation
WidgetKit is system-scheduled. The app can request a timeline entry every 30 minutes, but iOS does not guarantee that a widget refreshes exactly on schedule. Do not use a continuously running background timer.

## Exporting an IPA
On a Mac, choose Product > Archive, then Distribute App and follow the signing/distribution flow appropriate to your intended installation method. An IPA must be signed appropriately; a raw IPA is not universally installable.

## Vocabulary data
The included JSON is starter/sample content only, not a complete JLPT N5–N1 dictionary. Validate vocabulary level classifications before educational/public release. Add more entries by following the JSON schema in `kotoba_seed.json`.
