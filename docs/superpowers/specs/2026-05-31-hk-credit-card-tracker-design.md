# Hong Kong Credit Card Tracker Design

## Summary

Build a native offline iOS app for recording Hong Kong credit card spending, predicting statement-cycle repayments, showing consumption charts, and reminding users before card payments are due. The app stores data on-device, supports user-controlled encrypted backup export/import, and avoids a backend or account system.

Apple Wallet or FinanceKit transaction import is a future optional adapter, not an MVP dependency. Current Hong Kong support and entitlement access are not reliable enough for the core product.

## Goals

- Let users record card spending quickly at or near point of purchase.
- Track multiple Hong Kong credit cards with visual card images.
- Predict repayment amounts by statement cycle and due date.
- Notify users before each card payment is due.
- Show category, card, and monthly spending charts in HKD.
- Support non-HKD travel and online spending through assist-currency fields.
- Keep all records private and offline.
- Let users export/import encrypted backups manually through Files or iCloud Drive.
- Add a Home Screen widget for the next payment due countdown.

## Non-Goals For MVP

- Server sync or account login.
- Automatic bank scraping.
- Mandatory Apple Wallet transaction import.
- Automatic public-holiday/bank-term rule updates.
- Actionable notification buttons such as snooze or mark paid.
- Card rewards optimization beyond later smart hints.
- Android or web support.

## Platform

- Native iOS app.
- Minimum target: iOS 17.
- UI: SwiftUI.
- Persistence: SwiftData.
- Notifications: local notifications.
- Quick capture: App Intents and Shortcuts.
- Widget: WidgetKit.
- Optional app lock: Face ID / passcode via LocalAuthentication.

## Navigation

The MVP uses a tab-based app with Quick Add as the primary first screen.

- **Quick Add**: swipeable credit-card image carousel, amount input, merchant, category, optional assist currency and rate, save.
- **Repayment**: current and upcoming card cycles, due dates, amount due, countdowns.
- **Charts**: monthly spending, category breakdown, card breakdown, currency drill-down.
- **Cards**: credit card setup, card image, statement rule, due-date prediction rule, reminder timing.
- **Settings**: backup export/import, privacy, widget privacy mode, categories.

## Quick Add Flow

1. User opens app and lands on Quick Add.
2. User swipes to select a credit card image.
3. User enters amount.
4. User selects or types merchant.
5. User selects category.
6. User optionally enters original currency, original amount, and exchange rate.
7. App stores both original values and normalized HKD value.
8. App assigns the transaction to the card's active statement cycle.

Fast capture entry points:

- App Intent: "Record Spending".
- Action Button via Shortcut.
- Back Tap via Shortcut.
- Lock Screen widget opening Quick Add.
- Later Siri phrase support.

## Card Image Carousel

The first Quick Add selector is a swipeable carousel of user cards. Each card may show:

- Bank/card name.
- Last 4 digits.
- User-selected or uploaded card image.
- Current cycle amount.
- Due-date badge when relevant.

Later smart card hints can show short reward/context messages such as "Dining card", "Online spending", or "Travel card". These hints are informational and should not block fast entry.

## Currency Model

HKD is the main currency. Repayments, charts, budgets, and widget totals use HKD.

Each transaction can optionally include assist-currency fields:

- Original amount.
- Original currency code.
- Exchange rate to HKD.
- Converted HKD amount.
- Rate note or source label.

The user can record travel or online spending in foreign currency while the app calculates repayment and analytics in HKD.

## Repayment Model

Each credit card has a first user-entered statement date and due date. The app predicts future cycles from this pattern.

Supported prediction styles:

- Statement date repeats monthly on a fixed day.
- Due date repeats monthly on a fixed day.
- Due date is an offset from statement date, such as statement date plus 25 days.

Each predicted cycle is editable. If a bank changes a due date because of weekend, public holiday, or terms, the user can adjust the actual date. The app should not silently hardcode bank rules in the MVP.

Repayment amount is the sum of all transactions assigned to that card's statement cycle, normalized to HKD.

## Notifications

MVP uses simple local reminders only.

Reminder types:

- Upcoming due date reminder.
- Optional pre-due reminders such as 7 days, 3 days, and 1 day before due.
- Optional statement closing reminder.

Tapping a reminder opens the relevant card repayment detail screen. Notification buttons for snooze or mark paid are out of MVP scope.

## Widget

Add a WidgetKit extension for a Home Screen "Next Payment Due" countdown.

Widget sizes:

- Small: nearest card due, days left, optionally amount.
- Medium: next 2-3 upcoming card payments.
- Large: later enhancement with due list and month spend summary.

Widget data comes from a read-only snapshot written by the main app into shared app group storage. The widget must work offline.

Privacy mode:

- When enabled, the widget hides amounts and shows only card name/countdown.
- Tapping the widget opens the Repayment tab or relevant card detail.

## Data Model

Core entities:

- `CreditCard`: bank, name, last4, card image file reference, active flag, statement prediction rule, due prediction rule, reminder settings.
- `StatementCycle`: card reference, start date, end date, statement date, due date, predicted/manual flag, optional paid flag.
- `Transaction`: date, merchant, category, card reference or manual source, HKD amount, optional original currency amount, optional original currency code, optional exchange rate, note.
- `Category`: name, icon, color, optional monthly budget.
- `BackupPackage`: schema version, encrypted payload, export timestamp, record counts.
- `WidgetSnapshot`: generated display strings and next-due data for WidgetKit.

Card images are stored as files in the app sandbox and referenced by identifier from SwiftData. Backup export includes these image files in the encrypted payload.

## Backup And Restore

The app has no live cloud sync. Backup is user-controlled.

Export:

1. User chooses Export Backup.
2. App serializes SwiftData records, settings, categories, and card images.
3. App encrypts the package using CryptoKit AES-GCM with a user-entered backup password and a random salt for key derivation.
4. User saves the backup file through the iOS share sheet or Files, including iCloud Drive if desired.

Import:

1. User chooses Import Backup.
2. App validates file type, version, and encryption.
3. App previews record counts and restore impact.
4. User confirms restore.
5. App restores records and regenerates widget snapshots.

## Privacy

- All primary data stays on device.
- No backend telemetry by default.
- Face ID / passcode app lock protects app launch.
- Private widget mode hides amounts.
- Backup files are encrypted before export.

## Testing Plan

Unit tests:

- Statement cycle prediction.
- Due-date prediction.
- Transaction-to-cycle assignment.
- Currency conversion.
- Repayment total calculation.
- Backup serialization version checks.
- Backup encryption/decryption round trip.

UI tests:

- Quick Add creates transaction.
- Assist currency transaction saves HKD conversion.
- Card setup predicts next cycle.
- Backup import preview appears before restore.

Widget tests:

- Nearest due payment appears correctly.
- Privacy mode hides amounts.
- Empty state appears when no cards exist.

Notification tests:

- Local reminders schedule at configured offsets.
- Reminder tap opens repayment detail.

## Risks And Mitigations

- **Apple Wallet import unavailable in Hong Kong**: keep Wallet/FinanceKit import out of MVP and design adapters later.
- **Bank repayment terms vary**: require user-entered first statement/due dates and editable predicted cycles.
- **Incorrect exchange rates**: store manual rate and original values so users can audit entries.
- **Widget privacy exposure**: include private widget mode from MVP.
- **Backup restore data loss**: show preview and confirmation before restore.

## MVP Defaults

- Starter categories: dining, transport, grocery, shopping, bills, entertainment, travel, online, health, education, other.
- Paid status is included as an optional manual field in repayment detail, but not exposed through notification actions.
- Default reminder offsets: 7 days, 3 days, and 1 day before due date.
