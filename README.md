# BotecoPRO Mobile

The `feat/odoo-online-mvp` branch starts from `stable-v0.1.2` and adds a
read-only native Flutter integration with Odoo Online through the official
JSON-2 API.

## Local Odoo connection

Keep credentials in a local, ignored `.env.local` (or the monorepo root file):

```env
ODOO_ONLINE_URL=
ODOO_ONLINE_USERNAME=
ODOO_ONLINE_API_KEY=
```

The app stores only the API key in `flutter_secure_storage`. The URL, username,
optional database and selected Odoo records are non-secret metadata. Do not
commit or print the API key.

The first release supports Android, iOS and native POS devices. Flutter Web is
not part of this direct-credential MVP because browser storage cannot protect a
long-lived Odoo API key.

## Development

```bash
flutter pub get
flutter analyze
flutter test
```

For an optional debug bootstrap, pass the ignored local values as Dart defines
(`--dart-define`); release builds do not use these values:

```bash
flutter run \
  --dart-define=ODOO_ONLINE_URL=https://empresa.odoo.com \
  --dart-define=ODOO_ONLINE_USERNAME=user@example.com \
  --dart-define=ODOO_ONLINE_API_KEY=local-only-key
```

The Odoo smoke test is opt-in and must be run locally only after a real API key
has been entered. It performs read-only calls for version, identity, companies,
POS configurations, categories and products.
