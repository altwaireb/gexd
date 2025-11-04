import 'package:get/get.dart';
// import 'package:your_project/core/services/api_service.dart';

/// {{name.pascalCase()}} Provider
///
/// Responsible for providing data for {{name.sentenceCase()}}.
/// Can be connected to a real backend or use local mock data.
///
/// ---
/// ## Integration Guide (for real API)
///
/// 1- Inject your `ApiService` (or HTTP client):
/// ```dart
/// final ApiService _api = Get.find<ApiService>();
/// ```
///
/// 2- Replace mock data with actual network calls:
/// ```dart
/// Future<Response> getAll() async {
///   return await _api.get('/{{name.paramCase()}}');
/// }
/// ```
///
/// 3- Handle errors using `.statusCode` and `.body`.
///
/// ---
/// ## Notes:
/// - Each method currently simulates data locally.
/// - Replace with your API calls once backend is available.
///
class {{name.pascalCase()}}Provider {
  // Example for later:
  // final ApiService _api = Get.find<ApiService>();

  /// Get all records (mock)
  Future<Response> getAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final data = [
      {'id': 1, 'name': 'Item 1'},
      {'id': 2, 'name': 'Item 2'},
    ];
    return Response(statusCode: 200, body: data, statusText: 'OK (Mock)');
  }

  /// Get single record by ID (mock)
  Future<Response> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final data = {'id': id, 'name': 'Item $id'};
    return Response(statusCode: 200, body: data, statusText: 'OK (Mock)');
  }

  /// Create new record (mock)
  Future<Response> create(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      statusCode: 201,
      body: {'id': DateTime.now().millisecondsSinceEpoch, ...payload},
      statusText: 'Created (Mock)',
    );
  }

  /// Update record (mock)
  Future<Response> update(int id, Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      statusCode: 200,
      body: {'id': id, ...payload},
      statusText: 'Updated (Mock)',
    );
  }

  /// Delete record (mock)
  Future<Response> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(statusCode: 204, body: null, statusText: 'Deleted (Mock)');
  }
}

