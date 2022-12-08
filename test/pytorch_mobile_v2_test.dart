import 'package:flutter_test/flutter_test.dart';
import 'package:pytorch_mobile_v2/pytorch_mobile_v2.dart';
import 'package:pytorch_mobile_v2/pytorch_mobile_v2_platform_interface.dart';
import 'package:pytorch_mobile_v2/pytorch_mobile_v2_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPyTorchMobileV2Platform
    with MockPlatformInterfaceMixin
    implements PyTorchMobileV2Platform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PyTorchMobileV2Platform initialPlatform =
      PyTorchMobileV2Platform.instance;

  test('$MethodChannelPyTorchMobileV2 is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPyTorchMobileV2>());
  });

  test('getPlatformVersion', () async {
    PyTorchMobileV2 pytorchMobileV2Plugin = PyTorchMobileV2();
    MockPyTorchMobileV2Platform fakePlatform = MockPyTorchMobileV2Platform();
    PyTorchMobileV2Platform.instance = fakePlatform;

    expect(await pytorchMobileV2Plugin.getPlatformVersion(), '42');
  });
}
