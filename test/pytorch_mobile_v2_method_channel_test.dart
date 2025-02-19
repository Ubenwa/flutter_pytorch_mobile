import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pytorch_mobile_v2/pytorch_mobile_v2_method_channel.dart';

void main() {
  MethodChannelPyTorchMobileV2 platform = MethodChannelPyTorchMobileV2();
  const MethodChannel channel = MethodChannel('pytorch_mobile_v2');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
