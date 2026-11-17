# App Flow Redesign

Updated: 2026-11-18. Native SwiftUI, offline storage, existing records retained.

## Navigation

| Destination | Responsibility | Scope |
| --- | --- | --- |
| Overview (first screen) | Add a first/additional card, monthly total, six-month trend, category mix and transaction history | All records, including history retained after a card is removed |
| Quick | Choose a card, amount, currency/rate, merchant, transaction date and category; save | One transaction on one active card |
| Cards | Swipe between cards, inspect monthly spending, category mix and transaction history; remove a card | Selected card and selected month only |
| Repayment | Swipe between credit cards, inspect recorded/estimated statement dates and spending, mark paid | Selected active credit card only |
| Settings (navigation-bar sheet) | Defaults, privacy, language, appearance, recurring records and local record counts | App preferences and recurring rules |

The separate Trends tab is removed. Its actual consumption chart now lives in Overview. Overall totals are not repeated as a separate destination with a competing repayment strategy.

## Categories

- Eleven categories use one shared identifier/icon/color mapping: dining, transport, grocery, shopping, bills, entertainment, travel, online, health, education, other.
- A three-column, four-row grid keeps all category choices together. No horizontal category scroller or nested scrolling panel.
- Category selection stays inline in Quick because an extra page would add a step to each transaction. The grid is about 360 points tall; the page can scroll vertically on smaller screens.
- The same icon mapping appears in transaction history, spending breakdowns and default-category selection. Unknown legacy categories retain their label and receive the Other icon.
- Settings and recurring records reuse the same full grid. Selected state has a border and checkmark, not color alone.

## Card Selection

- One shared carousel is used by Quick, Cards, Repayment, default-card selection and recurring-card selection.
- Horizontal swiping, page dots and a checkbox-style single-selection sheet update the same selected card ID.
- Each face shows recorded HKD-equivalent spending for the displayed month. Billing currency stays separately visible.
- Shared card artwork now uses twenty bundled issuer images, preserving landscape/portrait proportions, with a fine border and soft shadow. Card name, currency, last four digits and spending sit below the artwork. Other cards use a brushed fallback. See [artwork sources and rights](README_CARD_FACES.md).
- Card-specific details filter by UUID, not display name. Removed/inactive default cards fall back to an available active card in Quick.
- A first-card action appears on Overview; the add action remains in the navigation bar after cards exist. Card creation is a sheet, not permanently embedded below card statistics.
- EasyCard is TWD stored value: manually record spending, no credit statement or repayment. No live balance reading or wallet integration is implied.

## Settings

- Removed appearance preview tiles.
- Added default card, default category, persistent hide-amounts preference and local record counts.
- Language and appearance remain available. Recurring rules have their own settings detail screen rather than filling the main settings page.
- The settings sheet explicitly follows the saved appearance preference, so changing Dark, Light or System updates the currently open sheet as well as the underlying interface. The add-card sheet follows the same preference.
- Default changes update an empty Quick draft, not a draft already containing an amount or merchant. Saving resets category to the current default.
- Privacy masks displayed amounts and hides numeric trend charts. Editing fields remain usable.
- UI tests use a separate preferences suite and in-memory records, keeping production preferences and data separate.
- Settings includes an Open Shortcuts command. Wallet-triggered recording requires a user-created personal automation; the app does not show a misleading connected/enabled switch because it cannot verify the automation's configuration.

## Shortcuts Input

Record Spending now receives an explicit local card entity, amount, merchant, ISO currency, category and optional date, exchange rate and stable reference. It writes through the app's shared main context, with explicit saves and no networking or CloudKit. The shared configuration retains the previous default store URL. HKD is never inferred for an unknown currency; foreign spending without an explicit positive rate fails without creating a transaction. Optional import metadata preserves existing manual-record defaults.

Card entities use UUIDs and exclude inactive cards. Removed mappings never fall back to another card. Optional references prevent retries from adding another record on that card; absent references do not trigger approximate time/merchant deduplication. Shortcuts records appear in the normal consumption lists and calculations with a source label, not a bank-verification badge. [Setup, Apple API restrictions and device-test requirements](README.md#wallet-automation).

## Visual Direction

Restrained mint surfaces, coral accents, multicolor category symbols, rounded typography and generous tap targets. Unframed information sections, compact navigation, clear totals and distinct bank card faces. Existing dark/light color support is retained.

## Unchanged Limits

No bank transfer, live FX, direct Apple Wallet feed or automatic cloud backup. User-configured Shortcuts can supply new purchase events but cannot guarantee complete coverage. HKD is the reporting currency; real statement amounts and deadlines remain authoritative. Backup UI, notification scheduling and live widget data are separate outstanding integrations described in the main README.

## Verification

Verified on an isolated iPhone 17 Pro simulator running iOS 26.5: 82 tests passed, zero failures, zero runtime warnings. Coverage includes all eleven category tiles, first-screen card creation, single-card filtering, swipe/checklist synchronization in Quick, EasyCard exclusion from repayments, default-category updates, privacy and transaction-history preservation after card removal. Added coverage verifies twenty bundled images decode offline, landscape/portrait/fallback previews do not block card selection, and Dark/Light/System changes update settings without dismissing the sheet. Twelve Shortcuts tests verify persistent writes, exact decimal conversion, required foreign FX, invalid-input rejection, removed-card handling, reference deduplication/conflicts, intent parameter mapping, entity identity, analytics inclusion and the unchanged default store URL. Branding checks verify BigHeadHa's display name, compiled AppIcon metadata, asset catalog and native Home Screen registration; screenshot pixel checks confirm the new artwork renders. Generated metadata confirms the discoverable action, registered card query, required input fields and background operation. Real-device Wallet events and old-store migration validation remain outside this run.

The appearance regression was reproduced before the fix: the preference reported Light while the open settings sheet still reported a dark color scheme. The corrected test passes; captured backgrounds also change from RGB (18, 23, 23) to (247, 251, 250). See [current card and appearance screenshots](README_CARD_FACES.md#ui-evidence).

Local QA screenshots remain under `artifacts/redesign/` and `artifacts/card-art/`. They are excluded from the public source; the generated BigHeadHa branding assets are included under `docs/branding/` and the Xcode asset catalog.
