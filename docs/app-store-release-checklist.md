# IdeaRadar App Store Release Checklist

## Repository

- [x] Version set to `1.0.0+1`
- [x] Bundle ID set to `com.bancusoft.idearadar`
- [x] Display name set to `IdeaRadar`
- [x] First release targets iPhone
- [x] Non-exempt encryption declaration set to false
- [ ] Replace the default Flutter app icon
- [ ] Run `dart format --output=none --set-exit-if-changed lib test`
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Run a release-mode smoke test on a physical iPhone

## App Store Connect

- [ ] Confirm Apple Developer agreements are active
- [ ] Create the IdeaRadar app record
- [ ] Use bundle ID `com.bancusoft.idearadar`
- [ ] Copy the metadata from `docs/app-store-metadata.md`
- [ ] Complete age rating
- [ ] Select **Data Not Collected** in App Privacy
- [ ] Add privacy and support URLs
- [ ] Select price: Free
- [ ] Select countries or regions
- [ ] Upload required iPhone screenshots

## Build and upload

```sh
git pull origin main
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build ipa --release
```

Upload `build/ios/ipa/idearadar.ipa` with Apple's Transporter app. Wait for processing, select the build in App Store Connect, complete any export-compliance prompt, and run one internal TestFlight smoke test.

## Final submission

- [ ] Confirm the uploaded build opens and saves an idea
- [ ] Confirm edit, search, notes, archive, and restore
- [ ] Confirm no placeholder text or default Flutter branding remains
- [ ] Add App Review contact information and review notes
- [ ] Select the release option
- [ ] Submit for App Review
