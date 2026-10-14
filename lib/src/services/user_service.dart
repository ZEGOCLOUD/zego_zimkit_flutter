part of '../zimkit.dart';

/// Service mixin for user-related operations
///
/// Provides methods for connecting, disconnecting, and managing user sessions.
/// Use with [ZIMKit] to access user functionality.
mixin ZIMKitUserService {
  Future<int> connectUser({
    required String id,
    String name = '',
    String avatarUrl = '',
    String token = '',
  }) async {
    return ZIMKitCore.instance.connectUser(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      token: token,
    );
  }

  /// Renews the current user's authentication token.
  ///
  /// Returns 0 on success, or the ZIM error code on failure.
  Future<int> renewToken(String token) async {
    return ZIMKitCore.instance.renewToken(token);
  }

  Future<void> disconnectUser() async {
    return ZIMKitCore.instance.disconnectUser();
  }

  // kit user
  ZIMUserFullInfo? currentUser() {
    return ZIMKitCore.instance.currentUser;
  }

  Future<ZIMUserFullInfo> queryUser(String id) async {
    return ZIMKitCore.instance.queryUser(id);
  }

  Future<int> updateUserInfo({String name = '', String avatarUrl = ''}) async {
    return ZIMKitCore.instance.updateUserInfo(name: name, avatarUrl: avatarUrl);
  }

  Stream<ZegoSignalingPluginConnectionStateChangedEvent>
  getConnectionStateChangedEventStream() {
    return ZIMKitCore.instance.getConnectionStateChangedEventStream();
  }
}
