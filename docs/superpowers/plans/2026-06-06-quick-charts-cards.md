# Quick Charts Cards Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Improve Quick amount entry, add consumption habit charts, and add a Cards screen with Hong Kong issuer presets.

**Architecture:** Keep this as a narrow MVP slice. Put pure formatting/aggregation logic in Core so it can be tested without launching SwiftUI, and add small SwiftUI views for Charts and Cards. Use static HK issuer presets now; bank-specific artwork and rules can be added later.

**Tech Stack:** SwiftUI, SwiftData, Swift Charts, XCTest.

---

### Task 1: Numeric Quick Amount Input

**Files:**
- Create: `CreditCardRecord/Core/AmountInputSanitizer.swift`
- Modify: `CreditCardRecord/Features/QuickAdd/QuickAddView.swift`
- Test: `CreditCardRecordTests/AmountInputSanitizerTests.swift`

- [x] Add tests that pasted text keeps only digits, one decimal separator, and two decimal places.
- [x] Implement `AmountInputSanitizer.sanitize(_:)`.
- [x] Apply sanitizer with `onChange(of: amount)` in `QuickAddView`.

### Task 2: Consumption Charts

**Files:**
- Create: `CreditCardRecord/Core/ConsumptionAnalytics.swift`
- Create: `CreditCardRecord/Features/Charts/ChartsView.swift`
- Modify: `CreditCardRecord/ContentView.swift`
- Test: `CreditCardRecordTests/ConsumptionAnalyticsTests.swift`

- [x] Add tests for category totals and monthly totals sorted by display order.
- [x] Implement pure aggregation helpers.
- [x] Add Swift Charts UI for category and monthly spending.

### Task 3: Cards Presets

**Files:**
- Create: `CreditCardRecord/Core/HongKongCardCatalog.swift`
- Create: `CreditCardRecord/Features/Cards/CardsView.swift`
- Modify: `CreditCardRecord/ContentView.swift`
- Test: `CreditCardRecordTests/HongKongCardCatalogTests.swift`

- [x] Add tests for common HK issuer presets.
- [x] Implement static card/issuer catalog.
- [x] Add Cards screen with preset issuer picker and manual fields.

### Task 4: Verify

**Files:**
- No code files.

- [x] Run syntax/config checks.
- [x] Run available Xcode build/test commands.
- [x] Report any local Xcode platform/simulator blockers explicitly.
