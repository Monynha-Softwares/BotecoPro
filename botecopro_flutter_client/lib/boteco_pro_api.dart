import 'package:dio/dio.dart';

/// Minimal Dart client for Boteco Pro Supabase RPC endpoints.
/// Generated 2025-07-25.
class BotecoProApi {
  final Dio _dio;
  final String baseUrl;

  BotecoProApi({
    Dio? dio,
    this.baseUrl = 'https://YOUR_SUPABASE_URL.supabase.co/rest/v1',
    required String jwt,
  }) : _dio = dio ??
            Dio(BaseOptions(
              headers: {'Authorization': 'Bearer $jwt', 'apikey': 'YOUR_SUPABASE_ANON_KEY'},
            ));

  /// Creates a new order and returns its ID.
  Future<int> createOrder({
    required int tableId,
    required int employeeId,
    int? clientId,
    String? notes,
  }) async {
    final response = await _dio.post(
      '$baseUrl/rpc/sp_createorder',
      data: {
        'table_id': tableId,
        'employee_id': employeeId,
        'client_id': clientId,
        'notes': notes,
      },
    );
    return response.data as int;
  }

  /// Returns the list of orders for the current employee (based on JWT).
  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final response = await _dio.post('$baseUrl/rpc/get_my_orders');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}
