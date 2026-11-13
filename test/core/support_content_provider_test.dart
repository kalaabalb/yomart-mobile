import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/services/http_services.dart';

class _SupportApi extends HttpService {
  final List<List<Map<String, dynamic>>> replies;
  _SupportApi(this.replies);
  @override
  Future<Response> getItems({required String endpointUrl}) async {
    expect(endpointUrl, 'support-content');
    final rows = replies.removeAt(0);
    return Response(statusCode: 200, body: {'success': true, 'data': rows});
  }
}

void main() {
  test(
      'customer support view refetches active server content when opened again',
      () async {
    final provider = DataProvider(loadInitialData: false)
      ..service = _SupportApi([
        [
          {
            'title': 'Published help',
            'body': 'Server-managed text',
            'sortOrder': 1
          }
        ],
        [
          {
            'title': 'Updated help',
            'body': 'Changed by an administrator',
            'sortOrder': 1
          }
        ],
      ]);
    await provider.getSupportContent();
    expect(provider.supportContent.single.title, 'Published help');
    await provider.getSupportContent();
    expect(provider.supportContent.single.title, 'Updated help');
    provider.dispose();
  });
}
