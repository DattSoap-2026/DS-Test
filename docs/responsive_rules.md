# Responsive Rules (Mandatory)

This document is the canonical rule-set for responsive UI changes.

## 1) Mandatory Gateway
- Use `lib/utils/responsive.dart` for all responsive sizing decisions.
- Do not call `MediaQuery.of(context)` directly in feature code.

## 2) Breakpoint Rules
- Breakpoints are fixed in `Responsive`:
  - Mobile: `< 650`
  - Tablet: `>= 650 && < 1100`
  - Desktop: `>= 1100`
- Do not add new breakpoints without architecture approval.

## 3) Dialog Rule
- Use only:
  - `ResponsiveDialog`
  - `ResponsiveAlertDialog`
- Raw `AlertDialog(` is not allowed outside `lib/widgets/dialogs/responsive_alert_dialog.dart`.
- Dialog content must remain scroll-safe on small screens.

## 4) Table Rule
- Every `DataTable` must be wrapped with horizontal scroll:

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(...),
)
```

## 5) No Fixed Height/Width Rule
- In `lib/screens`, `lib/widgets`, `lib/modules`:
  - Avoid fixed `height >= 200`
  - Avoid fixed `width >= 300`
- Prefer `ConstrainedBox` + `Responsive.clamp(...)` for adaptive bounds.

## 6) Grid/Row Rule
- For multi-card or grid-like rows, prefer `Wrap` over rigid `Row` when layout can compress.
- Use `Expanded` / `Flexible` where row items must share constrained space.

## 7) Clamp Standard
- Use `Responsive.clamp(context, min: ..., max: ..., ratio: ...)` for responsive sizing.
- Example:

```dart
ConstrainedBox(
  constraints: BoxConstraints(
    maxWidth: Responsive.clamp(context, min: 320, max: 560, ratio: 0.85),
  ),
  child: child,
)
```

## 8) Enforcement
- Run guard script before merge/release:

```bash
dart run scripts/responsive_guard.dart
```

- Use inline suppression only for exceptional cases:
  - Add `// ignore-resp-guard` on the line.
  - Include justification in code review.
