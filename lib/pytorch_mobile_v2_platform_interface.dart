import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'pytorch_mobile_v2_method_channel.dart';

abstract class PyTorchMobileV2Platform extends PlatformInterface {
  /// Constructs a PyTorchMobileV2Platform.
  PyTorchMobileV2Platform() : super(token: _token);

  static final Object _token = Object();

  static PyTorchMobileV2Platform _instance = MethodChannelPyTorchMobileV2();

  /// The default instance of [PyTorchMobileV2Platform] to use.
  ///
  /// Defaults to [MethodChannelPyTorchMobileV2].
  static PyTorchMobileV2Platform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PyTorchMobileV2Platform] when
  /// they register themselves.
  static set instance(PyTorchMobileV2Platform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
