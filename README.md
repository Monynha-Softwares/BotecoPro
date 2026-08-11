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

## Flutter architecture

The connected application deliberately uses a small service-based structure:

```text
pages/widgets
    ↓
providers
    ↓
Odoo and storage services
    ↓
OdooClient → HTTPS/JSON-2 → Odoo Online
```

- `models/` contains immutable application data and the isolated
  `models/legacy/` demo types.
- `services/odoo/` owns JSON-2 transport, mapping, connection diagnostics,
  catalog and read-only POS/Restaurant access. The selected POS also exposes a
  read-only operational profile with its currency, configured pricelist,
  non-closed sessions and payment-method metadata; this grants no write
  authority.
- `services/storage/` separates credentials, synchronized snapshots and the
  local draft cart. Only the API key uses secure storage.
- `providers/` separates session/context, synchronized catalog state and the
  local cart.
- `pages/` and `widgets/` contain presentation only.

The former `lib/core/odoo` package was removed because it had become a mixed
container for models, I/O, persistence and application state. `lib/features`
was also consolidated under `pages/`; it contained only screens. This is an
intentional simple MVP architecture, not a Clean Architecture or repository
layer.

Connected mode never imports the local demo business models. Demo mode is an
explicit debug-only route and cannot act as an offline fallback.

The synchronized catalog snapshot and draft cart retain their schema-v1 JSON
keys, so this structural refactor does not invalidate data already stored by
M7. A snapshot is accepted only for the same instance, user, company and POS.
Currency and pricelist metadata may be cached for accurate offline
presentation. Session ownership and payment-method data are deliberately kept
in memory only because they are dynamic and may contain personal or operational
information.

The catalog and draft values are informational captured `lst_price` values,
not authoritative Odoo POS prices. A currency symbol is shown only when the
product currency matches the synchronized POS currency. Flutter does not
reimplement pricelist, fiscal-position, tax or payment calculations.

## Development

```bash
flutter pub get
flutter analyze --fatal-infos
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
POS configurations, currency, pricelist, non-closed sessions, payment-method
metadata, categories, Restaurant context and products. Normal tests use
sanitized fakes and never require a real credential.
