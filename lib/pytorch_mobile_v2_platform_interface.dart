import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pytorch_mobile_v2_method_channel.dart';

abstract class PytorchMobileV2Platform extends PlatformInterface {
  /// Constructs a PytorchMobileV2Platform.
  PytorchMobileV2Platform() : super(token: _token);

  static final Object _token = Object();

  static PytorchMobileV2Platform _instance = MethodChannelPytorchMobileV2();

  /// The default instance of [PytorchMobileV2Platform] to use.
  ///
  /// Defaults to [MethodChannelPytorchMobileV2].
  static PytorchMobileV2Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PytorchMobileV2Platform] when
  /// they register themselves.
  static set instance(PytorchMobileV2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
