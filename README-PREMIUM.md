# CaterPro Premium UI Edition

A refreshed Flutter UI edition based on the supplied CaterPro project. The existing product scope is intentionally preserved:

- Home dashboard and financial snapshot
- Works: create, view, edit and delete event/work records
- Event, venue, reporting time and pax details
- Income, received and pending amount calculations
- Expenses and expense categories
- Monthly reports and financial summary
- Calendar
- Light and dark themes (saved locally)
- PDF export/sharing
- Hive local storage, backup/restore and notifications

## UI refresh

- Premium forest-green + soft-mint visual system
- Updated light/dark themes, surfaces, cards, inputs and buttons
- Refined rounded bottom navigation with animated selection and icon scaling
- Dashboard fade/slide entrance animation
- Material 3 components and responsive Flutter layouts

## Run

```bash
flutter pub get
flutter run
```

## Build web

```bash
flutter build web --release --base-href "/CaterPro-Web/"
```

For a different GitHub Pages repository, change the base-href to `/<repository-name>/`.

This is a UI-focused refresh. It does not add staff, inventory, payroll, multi-business, or cloud-sync modules; those were intentionally excluded from the requested scope.
