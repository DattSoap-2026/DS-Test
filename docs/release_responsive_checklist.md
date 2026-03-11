# Pre-Release Responsive Checklist

Run this checklist before every release candidate.

## Viewport Widths
Validate each major flow at:
- `360`
- `600`
- `900`
- `1200`
- `1600`

## Required Verifications
- No overflow warnings.
- No clipped/truncated critical content.
- No broken `Wrap`/card layouts.
- No dialog content cut-off.
- Tables remain usable (horizontal scroll works where needed).
- Button/action rows do not overflow.
- Side panels/drawers remain adaptive (no rigid fixed-width failures).
- No vertical scroll traps (content still reachable).

## Static Guard Commands
Run all commands and ensure clean results:

```bash
flutter analyze
dart run scripts/responsive_guard.dart
```

## Pattern Audit Commands

```bash
rg -n "MediaQuery\\.of\\(context\\)" lib
rg -n "\\bAlertDialog\\(" lib
rg -n "height\\s*:" lib/screens lib/widgets lib/modules
rg -n "width\\s*:" lib/screens lib/widgets lib/modules
```

## Release Gate
Release is blocked if any required verification fails.
