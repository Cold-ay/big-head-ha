# Credit Card Record

Offline iOS app for Hong Kong credit card spending, repayment cycle tracking, simple due reminders, encrypted backup export/import, and a next-payment widget.

## Requirements

- Xcode 16 or newer
- iOS 17 simulator or device
- A configured Apple development team is required for device/archive signing when App Groups are enabled.

## Build

```bash
xcodebuild build -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test

```bash
xcodebuild test -scheme CreditCardRecord -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Local Notes

If Command Line Tools are selected instead of full Xcode, prefix commands with:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
```
