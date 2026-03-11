# flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Theme System: Neutral Future

The application uses a custom "Neutral Future" design system focused on eye safety and long-term usage comfort.

### Key Tokens
- **Typography**: 
  - Headings: `Inter Tight`
  - Body: `Inter`
  - KPIs/Code: `JetBrains Mono`
- **Colors**:
  - Defined in `lib/core/theme/app_colors.dart`.
  - **No pure black or white** is used to reduce eye strain.
  - Primary Color: `#4F5BFF` (Light), `#6D7CFF` (Dark).

### Usage Guidelines
1.  **Always use `Theme.of(context)`**: Avoid hardcoding colors.
    ```dart
    color: Theme.of(context).colorScheme.surface // Good
    color: Colors.white // Bad
    ```
2.  **No Gradients**: Gradients are deprecated. Use solid primary colors or subtle alpha blends.
3.  **Mobile First**: Ensure all touch targets are at least 44x44px.
# DattSoap
