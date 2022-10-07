import 'package:flutter_test/flutter_test.dart';
import 'package:pytorch_mobile_v2/pytorch_mobile_v2.dart';
import 'package:pytorch_mobile_v2/pytorch_mobile_v2_platform_interface.dart';
import 'package:pytorch_mobile_v2/pytorch_mobile_v2_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPytorchMobileV2Platform
    with MockPlatformInterfaceMixin
    implements PytorchMobileV2Platform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PytorchMobileV2Platform initialPlatform = PytorchMobileV2Platform.instance;

  test('$MethodChannelPytorchMobileV2 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPytorchMobileV2>());
  });

  test('getPlatformVersion', () async {
    PytorchMobileV2 pytorchMobileV2Plugin = PytorchMobileV2();
    MockPytorchMobileV2Platform fakePlatform = MockPytorchMobileV2Platform();
    PytorchMobileV2Platform.instance = fakePlatform;

    expect(await pytorchMobileV2Plugin.getPlatformVersion(), '42');
  });
}
