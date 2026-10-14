import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zego_zim/zego_zim.dart';
import 'package:zego_zimkit/src/services/core/core.dart';

ZIMUserFullInfo testUser() => ZIMUserFullInfo(
  baseInfo: ZIMUserInfo(
    userID: 'user-1',
    userName: 'User One',
    userAvatarUrl: '',
  ),
);

void main() {
  final core = ZIMKitCore.instance;

  tearDown(() {
    core.clear();
    core.currentToken = '';
    core.loginCompleter = null;
  });

  test('failed login clears provisional user and wakes login waiters', () {
    core.currentUser = testUser();
    core.currentToken = 'expired-token';
    final loginCompleter = Completer<void>();
    core.loginCompleter = loginCompleter;

    core.resetAfterFailedConnect();

    expect(core.currentUser, isNull);
    expect(core.currentToken, isEmpty);
    expect(loginCompleter.isCompleted, isTrue);
    expect(core.loginCompleter, isNull);
  });

  test('relogin uses the current user and token after a not-logged error', () {
    final credentials = resolveZIMKitReloginCredentials(
      PlatformException(code: '${ZIMErrorCode.networkModuleUserIsNotLogged}'),
      testUser(),
      'renewed-token',
    );

    expect(credentials, (
      userID: 'user-1',
      userName: 'User One',
      token: 'renewed-token',
    ));
  });

  test('relogin is skipped when user or error is not eligible', () {
    expect(
      resolveZIMKitReloginCredentials(
        PlatformException(code: '${ZIMErrorCode.networkModuleUserIsNotLogged}'),
        null,
        'token',
      ),
      isNull,
    );
    expect(
      resolveZIMKitReloginCredentials(
        PlatformException(code: '-1'),
        testUser(),
        'token',
      ),
      isNull,
    );
  });
}
