import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:e_commerce_flutter/screen/login_screen/provider/user_provider.dart';
import 'package:e_commerce_flutter/utility/constants.dart';

void main() {
  Directory? storageDirectory;
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    storageDirectory =
        await Directory.systemTemp.createTemp('yomart-get-storage-test-');
    const pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            pathProviderChannel, (call) async => storageDirectory!.path);
    await GetStorage.init();
  });
  tearDownAll(() async {
    const pathProviderChannel =
        MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    await storageDirectory?.delete(recursive: true);
  });

  test('authenticated upload persists server profile state; remove clears it',
      () async {
    final box = GetStorage();
    await box.write('auth_token', 'test-token');
    final file = File('${Directory.systemTemp.path}/yomart-profile-test.png');
    await file.writeAsBytes([137, 80, 78, 71]);
    var method = '';
    final client = MockClient((request) async {
      method = request.method;
      expect(request.url.path, endsWith('/users/profile/image'));
      expect(request.headers['authorization'], 'Bearer test-token');
      if (request.method == 'POST') {
        expect(request.headers['content-type'],
            startsWith('multipart/form-data;'));
        final multipartBody = String.fromCharCodes(request.bodyBytes);
        expect(multipartBody, contains('name="image"'));
        expect(multipartBody, contains('filename="yomart-profile-test.png"'));
        return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                '_id': 'customer-id',
                'name': 'Customer',
                'profileImageAvailable': true
              }
            }),
            200);
      }
      return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              '_id': 'customer-id',
              'name': 'Customer',
              'profileImageAvailable': false
            }
          }),
          200);
    });
    final provider = UserProvider(imageClient: client);
    await provider.uploadProfileImage(file.path);
    expect(method, 'POST');
    expect(provider.getLoginUsr()?.profileImageAvailable, isTrue);
    expect(GetStorage().read(userInfoBox)['profileImageAvailable'], isTrue);
    await provider.removeProfileImage();
    expect(method, 'DELETE');
    expect(provider.getLoginUsr()?.profileImageAvailable, isFalse);
    expect(GetStorage().read(userInfoBox)['profileImageAvailable'], isFalse);
    provider.dispose();
    client.close();
    await file.delete();
    box.remove('auth_token');
    box.remove(userInfoBox);
  });

  test(
      'unsupported or oversized profile files are rejected before network access',
      () async {
    final box = GetStorage();
    await box.write('auth_token', 'test-token');
    var called = false;
    final client = MockClient((_) async {
      called = true;
      return http.Response('{}', 500);
    });
    final provider = UserProvider(imageClient: client);
    final file = File('${Directory.systemTemp.path}/yomart-profile-test.svg')
      ..writeAsStringSync('<svg/>');
    await expectLater(provider.uploadProfileImage(file.path), throwsException);
    expect(called, isFalse);
    provider.dispose();
    client.close();
    await file.delete();
    box.remove('auth_token');
  });
}
