part of 'core.dart';

({String userID, String userName, String token})?
resolveZIMKitReloginCredentials(
  Exception error,
  ZIMUserFullInfo? currentUser,
  String currentToken,
) {
  if (error is! PlatformException || currentUser == null) return null;
  if (int.tryParse(error.code) != ZIMErrorCode.networkModuleUserIsNotLogged) {
    return null;
  }

  return (
    userID: currentUser.baseInfo.userID,
    userName: currentUser.baseInfo.userName,
    token: currentToken,
  );
}

extension ZIMKitCoreUser on ZIMKitCore {
  Future<int> connectUser({
    required String id,
    String name = '',
    String avatarUrl = '',
    String token = '',
  }) async {
    if (!isInited) {
      ZIMKitLogger.logInfo('is not inited.');
      throw Exception('ZIMKit is not inited.');
    }

    ZIMKitLogger.logInfo(
      'login request, '
      'target user(id:$id, name:$name), '
      'currentUser user(id:${currentUser?.baseInfo.userID}, name:${currentUser?.baseInfo.userName}), ',
    );

    if (currentUser != null) {
      ZIMKitLogger.logInfo('has login, auto logout');
      await disconnectUser();
    }

    currentUser = ZIMUserFullInfo(
      baseInfo: ZIMUserInfo(
        userID: id,
        userName: name.isNotEmpty ? name : id,
        userAvatarUrl: '',
      ),
    );
    currentToken = token;

    ZIMKitLogger.logInfo('ready to login..');
    late final ZegoSignalingPluginConnectUserResult connectResult;
    try {
      connectResult = await ZegoUIKitSignalingPlugin().connectUser(
        id: id,
        name: name,
        token: token,
      );
    } catch (_) {
      resetAfterFailedConnect();
      rethrow;
    }

    if (connectResult.error == null) {
      ZIMKitLogger.logInfo('login success');

      await updateUserInfo(avatarUrl: avatarUrl);

      // query currentUser's full info
      queryUser(currentUser!.baseInfo.userID).then((ZIMUserFullInfo zimResult) {
        currentUser = zimResult;
        loginCompleter?.complete();
      });

      return 0;
    } else {
      ZIMKitLogger.logInfo('login error, ${connectResult.error}');
      resetAfterFailedConnect();
      return int.parse(connectResult.error!.code);
    }
  }

  void resetAfterFailedConnect() {
    currentToken = '';
    clear();

    final completer = loginCompleter;
    loginCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Future<void> disconnectUser() async {
    ZIMKitLogger.logInfo('logout.');
    currentToken = '';
    clear();
    final result = await ZegoUIKitSignalingPlugin().disconnectUser();
    if (result.timeout) {
      ZIMKitLogger.logWarn('logout timeout');
    }
  }

  Future<int> renewToken(String token) async {
    final result = await ZegoUIKitSignalingPlugin().renewToken(token);
    if (result.error == null) {
      currentToken = token;
      return 0;
    }
    return int.tryParse(result.error!.code) ?? -1;
  }

  Future<void> waitForLoginOrNot() async {
    if (currentUser == null) {
      ZIMKitLogger.logInfo('wait for login...');
      loginCompleter ??= Completer();
      await loginCompleter!.future;
      loginCompleter = null;
    }
  }

  Future<int> checkNeedReloginOrNot(Exception error) async {
    final credentials = resolveZIMKitReloginCredentials(
      error,
      currentUser,
      currentToken,
    );
    if (credentials == null) return -1;

    ZIMKitLogger.logInfo('try auto relogin.');
    return connectUser(
      id: credentials.userID,
      name: credentials.userName,
      token: credentials.token,
    );
  }

  // TODO 优化，如果短时间内来了大量请求，合并请求再调sdk
  Future<ZIMUserFullInfo> queryUser(
    String id, {
    bool isQueryFromServer = true,
  }) async {
    await waitForLoginOrNot();

    final queryHash = Object.hash(id, isQueryFromServer);
    if (_queryUserCache[queryHash] == null) {
      _queryUserCache[queryHash] = AsyncCache(const Duration(minutes: 5));
    }

    return _queryUserCache[queryHash]!.fetch(() async {
      ZIMKitLogger.logInfo(
        'queryUser, id:$id, isQueryFromServer:$isQueryFromServer',
      );
      final config = ZIMUserInfoQueryConfig()
        ..isQueryFromServer = isQueryFromServer;
      return ZIM
          .getInstance()!
          .queryUsersInfo([id], config)
          .then((ZIMUsersInfoQueriedResult result) {
            return result.userList.first;
          })
          .catchError((error) {
            Timer.run(() => _queryUserCache[queryHash]?.invalidate());

            final errorCode = int.tryParse(error.code) ?? -2;
            // qps limit
            if (ZIMErrorCodeExtension.isFreqLimit(errorCode)) {
              if (isQueryFromServer) {
                ZIMKitLogger.logInfo(
                  'queryUser failed, retry queryUser from sdk',
                );
                return queryUser(id, isQueryFromServer: false);
              } else {
                ZIMKitLogger.logInfo(
                  'queryUser from sdk failed, retry queryUser from server later',
                );
                return Future.delayed(
                  Duration(milliseconds: Random().nextInt(5000)),
                  () => queryUser(id),
                );
              }
            }

            return checkNeedReloginOrNot(error).then((retryCode) {
              if (retryCode == 0) {
                ZIMKitLogger.logInfo('re-login success, retry queryUser');
                return queryUser(id);
              } else {
                ZIMKitLogger.logError('queryUser failed:$error');
                throw error;
              }
            });
          });
    });
  }

  Future<int> updateUserInfo({String name = '', String avatarUrl = ''}) async {
    if (name.isNotEmpty) {
      return ZIM
          .getInstance()!
          .updateUserName(name)
          .then((value) {
            ZIMKitLogger.logInfo('updateUserName success: $name');
            currentUser?.baseInfo.userName = name;

            return 0;
          })
          .catchError((error) {
            ZIMKitLogger.logInfo('updateUserName failed:$error');
            //  throw error;
            return int.tryParse(error.code) ?? -2;
          });
    }

    if (avatarUrl.isNotEmpty) {
      return ZIM
          .getInstance()!
          .updateUserAvatarUrl(avatarUrl)
          .then((value) {
            ZIMKitLogger.logInfo('updateUserAvatarUrl success: $avatarUrl');
            currentUser?.baseInfo.userAvatarUrl = avatarUrl;

            return 0;
          })
          .catchError((error) {
            ZIMKitLogger.logInfo('updateUserAvatarUrl failed:$error');
            //  throw error;
            return int.tryParse(error.code) ?? -2;
          });
    }

    return 0;
  }
}

mixin ZIMKitCoreUserData {
  ZIMConnectionState get connectionState =>
      ZegoUIKitSignalingPlugin().eventCenter.connectionState;
}

extension ZIMKitCoreUserEvent on ZIMKitCore {
  Stream<ZegoSignalingPluginConnectionStateChangedEvent>
  getConnectionStateChangedEventStream() {
    return ZegoUIKitSignalingPlugin().getConnectionStateChangedEventStream();
  }

  Stream<ZegoSignalingPluginTokenWillExpireEvent>
  getTokenWillExpireEventStream() {
    return ZegoUIKitSignalingPlugin().getTokenWillExpireEventStream();
  }
}
