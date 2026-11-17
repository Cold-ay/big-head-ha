# BigHeadHa

<img src="CreditCardRecord/Assets.xcassets/AppIcon.appiconset/AppIcon.png" width="96" height="96" alt="BigHeadHa app icon">

Offline iOS spending tracker with Hong Kong and selected Taiwan card presets, statement-cycle estimates, HKD reporting, manual foreign-currency exchange rates, and monthly recurring spending records.

Card research: [Hong Kong](README_CARDS_BY_ISSUER.md), [Taiwan](README_TAIWAN_CARDS.md). Taiwan includes 15 credit-card presets across 9 banks plus EasyCard as stored value. Debit and stored-value cards are excluded from credit repayments. The app does not connect to banks, move money, or fetch FX rates. Repayment amounts are recorded HKD-equivalent spending, not a bank-issued statement balance.

Navigation: Overview, Quick, Cards, Repayment. Settings opens from the navigation bar. [App flow and UI decisions](README_APP_FLOW.md).

## Wallet Automation

Direct import of arbitrary Wallet payment cards, their artwork and historical transactions is not available to this Hong Kong/Taiwan app. [FinanceKit](https://developer.apple.com/financekit/) currently lists eligible U.S. and U.K. accounts and requires an approved managed entitlement. [PassKit](https://developer.apple.com/documentation/passkit/pkpasslibrary/passes()) only returns passes the app is entitled to access; enabling Wallet capability does not grant access to other issuers' cards. The app does not use a payment checkout sheet as a card-import workaround.

Implemented alternative: the **Record Spending** App Intent saves supplied purchase data directly to the same local SwiftData store used by the app, without opening Quick Add. [Apple's Transaction trigger](https://support.apple.com/en-ie/guide/shortcuts/apd65c67538a/ios) can run a personal automation when a selected Wallet card is tapped. It is not an all-transactions bank feed.

### One-Time Setup on iPhone

1. Install and launch the app. Add the matching card inside this app using a preset or manual entry. Card art remains the bundled art, not a copy from Wallet.
2. Open Shortcuts from Settings or the iPhone Shortcuts app. Create a Wallet/Transaction personal automation and select **one Wallet card**. Use an unrestricted merchant/category trigger if offered so purchases are not accidentally filtered out.
3. Configure automatic running as supported by your iOS version, such as Run Immediately or disabling Ask Before Running. [Apple's automation guide](https://support.apple.com/en-hk/guide/shortcuts/apd602971e63/ios) describes these controls. Required action permissions and device unlock/data-protection rules still apply.
4. Add this app's **Record Spending** action directly to that automation. Select the matching **App Card**. Do not choose Any Card in the Wallet trigger while mapping to a single fixed App Card; create one automation per card instead.
5. Map **Amount** and **Merchant** to the corresponding properties of Shortcut Input where your iOS version/card supplies them. Set **Currency Code** to the actual purchase currency, for example HKD. Use a currency input property if available; do not assume a foreign purchase uses the card's billing currency. Currency is required and has no implicit HKD default.
6. Set **Category** (default Other). Optionally provide **Transaction Date** and a stable **Transaction Reference** if available. Without a supplied date, the receipt time is used, not a bank posting date. A reference must remain identical when retrying the same event; a new random UUID on every run will not deduplicate retries.
7. For a foreign-currency purchase, provide **HKD per 1 Currency Unit**. The app never fetches FX or guesses a rate. Missing/invalid amount, merchant, currency or required FX causes an error and saves nothing. Failed imports are not queued; add those purchases using Quick Add.
8. Run a small real payment on your iPhone and compare the card, amount, merchant and currency in the app with Wallet/bank records. The simulator cannot validate a real Apple Pay trigger or issuer-supplied properties.

Imported records show a Shortcuts source label and participate in the existing charts and repayment estimates. The source denotes the entry channel, not Apple/bank verification. Removed/inactive card mappings fail instead of selecting a different card. Stable references are deduplicated per app card; conflicting references report an error. Without a stable reference, identical-looking purchases are kept to avoid silently dropping legitimate spending.

This does not import past transactions, create a personal automation without user action, read Wallet images, confirm settlement, or guarantee capture of Apple Watch, web/in-app Apple Pay, refunds, transport/stored-value events or every issuer event. Test your actual device/card combination. Do not rely on it as the sole record of a bank balance or repayment amount.

Verification: 82 unit/UI tests passed on an isolated iPhone 17 Pro simulator (iOS 26.5), including 12 import-specific tests and compiled-icon/native Home Screen branding checks. Generated [intent registration metadata](artifacts/wallet-automation/intent-registration.json) confirms the action and card query are discoverable and `openAppWhenRun` is false. [Settings screenshot](artifacts/wallet-automation/settings.png). Actual Wallet-trigger delivery, issuer fields, locked-device behavior and pre-existing-store migration still require device testing.

The repository also contains encrypted-backup and widget helpers. These helpers do not by themselves constitute a finished backup/restore or scheduled-reminder workflow; those integrations need separate end-to-end verification.

## Xcode Branding

Open `CreditCardRecord.xcodeproj` and choose the shared **BigHeadHa** scheme. The app's Home Screen name and widget brand are BigHeadHa. The original target/module name, bundle IDs and App Group remain unchanged to protect existing storage and signing compatibility; the original CreditCardRecord scheme remains available for older scripts.

The 1024 x 1024 RGB, opaque sRGB app icon is wired through `Assets.xcassets/AppIcon.appiconset` in Debug and Release. The [original generated master](docs/branding/BigHeadHaIcon-Master.png) and [generation prompt/provenance](docs/branding/icon-prompt.txt) are included. The mark was created using the built-in image generator; only production resizing was applied afterward.

[Installed Home Screen verification](docs/branding/home-screen.png) shows the native icon and BigHeadHa label on an isolated simulator. The adjacent generic CreditCardRecord icon is the Xcode UI-test runner, not the shipping app.

An unsigned Release build for a physical iOS device also compiles successfully. The project currently emits an interface-orientation warning for iPad multitasking; configure supported orientations before distribution. This build is not a signed archive or App Store submission.

## Current Limitations

- Bank statements remain authoritative. Predicted dates do not implement each bank's holiday rules; recorded spending excludes unrecorded interest, fees and adjustments.
- TWD is supported as an original transaction currency with manual conversion. Reporting and recorded repayment totals remain HKD equivalents, not native TWD bank balances.
- Reminder scheduling and the export/import user interface are not connected yet. The widget still uses placeholder content rather than live shared repayment data.
- Quick Add is manual. Shortcuts can supply new purchase data after user configuration, but direct Wallet retrieval and historical import are not implemented. Live Wallet triggers still need physical-device verification.
- Recurring entries catch up when the app opens/becomes active and do not move money.
- Simulator tests do not replace physical-device signing, old-store migration checks or a full release audit.

## Requirements

- Xcode 16 or newer
- iOS 17 simulator or device
- A configured Apple development team is required for device/archive signing when App Groups are enabled.

## Build

Issuer card artwork is excluded from the public source until redistribution rights are confirmed. To reproduce the full local card-art build and tests, first download the original issuer assets (Node.js 18+ and curl). This is a development step only; the installed app makes no card-art network requests. Cards without downloaded art use the built-in fallback.

```bash
node scripts/fetch-card-art.mjs
xcodebuild build -scheme BigHeadHa -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Test

```bash
xcodebuild test -scheme BigHeadHa -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Local Notes

If Command Line Tools are selected instead of full Xcode, prefix commands with:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```
