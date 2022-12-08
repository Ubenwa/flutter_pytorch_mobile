import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'pytorch_mobile_v2_platform_interface.dart';

/// An implementation of [PyTorchMobileV2Platform] that uses method channels.
class MethodChannelPyTorchMobileV2 extends PyTorchMobileV2Platform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('pytorch_mobile_v2');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
