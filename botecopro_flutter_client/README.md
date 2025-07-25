# Boteco Pro API – Flutter Client (Minimal)

This package is an **auto‑generated minimal** Flutter/Dart client for the Boteco Pro Supabase backend.

## Usage

```dart
import 'package:boteco_pro_api/boteco_pro_api.dart';

final api = BotecoProApi(
  jwt: '<your-user-jwt>',
  baseUrl: 'https://<project>.supabase.co/rest/v1',
);

final newOrderId = await api.createOrder(
  tableId: 5,
  employeeId: 42,
  notes: 'Mesa 5 – Chopp x2',
);

final myOrders = await api.getMyOrders();
```

> **Note**: For a fully‑typed client covering **all** endpoints, run:
> ```bash
> openapi-generator-cli generate -i ../openapi.yaml -g dart -o boteco_pro_api_full --additional-properties=pubName=boteco_pro_api
> ```

