library terminate_restart;

export 'src/terminate_restart_base.dart';
export 'terminate_restart_platform_interface.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Options for restarting the app
class TerminateRestartOptions {
  /// Whether to terminate the app or just restart the UI
  final bool terminate;
  
  /// Whether to clear app data
  final bool clearData;
  
  /// Whether to preserve keychain data
  final bool preserveKeychain;
  
  /// Whether to preserve user defaults
  final bool preserveUserDefaults;

  /// Constructor
  const TerminateRestartOptions({
    this.terminate = true,
    this.clearData = false,
    this.preserveKeychain = false,
    this.preserveUserDefaults = false,
  });
}

/// Enum to specify the restart mode
enum RestartMode {
  /// Restart immediately without showing a dialog
  immediate,

  /// Show a confirmation dialog before restarting
  withConfirmation,
}

/// The main plugin class for restarting Flutter apps
class TerminateRestart {
  static TerminateRestart? _instance;
  
  /// Get the singleton instance
  static TerminateRestart get instance {
    _instance ??= TerminateRestart._();
    return _instance!;
  }

  /// Private constructor
  TerminateRestart._();

  static const MethodChannel _channel =
      MethodChannel('com.ahmedsleem.terminate_restart/restart');
  
  static const MethodChannel _internalChannel =
      MethodChannel('com.ahmedsleem.terminate_restart/internal');
  
  bool _initialized = false;
  VoidCallback? _onRootReset;

  /// Initialize the plugin and set up internal handlers
  void initialize({VoidCallback? onRootReset}) {
    if (!_initialized) {
      _onRootReset = onRootReset;
      _internalChannel.setMethodCallHandler(_handleInternalMessages);
      _initialized = true;
    }
  }

  Future<dynamic> _handleInternalMessages(MethodCall call) async {
    switch (call.method) {
      case 'resetToRoot':
        _onRootReset?.call();
        break;
    }
  }

  /// Restarts the app with the given options.
  Future<bool> restartApp({
    required TerminateRestartOptions options,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('restart', {
        'terminate': options.terminate,
        'clearData': options.clearData,
        'preserveKeychain': options.preserveKeychain,
        'preserveUserDefaults': options.preserveUserDefaults,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('Error restarting app: $e');
      return false;
    }
  }
}
