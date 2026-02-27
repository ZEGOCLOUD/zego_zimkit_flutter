import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_plugin_adapter/zego_plugin_adapter.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/callkit/defines.dart';
import 'package:zego_zimkit/src/channel/platform_interface.dart';
import 'package:zego_zimkit/src/components/messages/list_page/widget.dart';
import 'package:zego_zimkit/src/config.dart';
import 'package:zego_zimkit/src/config.defines.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/events.dart';
import 'package:zego_zimkit/src/extensions/extensions.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/services/core/defines.dart';
import 'package:zego_zimkit/src/services/logger_service.dart';

part 'services/conversation_service.dart';

part 'services/group_service.dart';

part 'services/helper_service.dart';

part 'services/input_service.dart';

part 'services/message_service.dart';

part 'services/user_service.dart';

part 'services/dialogs_service.dart';

/// ZIMKit - Zego Instant Messaging Kit
///
/// A Flutter SDK that provides instant messaging capabilities for building
/// chat applications. ZIMKit offers a complete set of UI components and services
/// for conversations, messages, groups, and user management.
///
/// Usage:
/// ```dart
/// await ZIMKit().init(
///   appID: yourAppID,
///   appSign: yourAppSign,
/// );
/// ```
///
/// {@category Get started}
/// {@category APIs}
/// {@category Events}
/// {@category Configs}
class ZIMKit
    with
        ZIMKitConversationService,
        ZIMKitUserService,
        ZIMKitMessageService,
        ZIMKitInputService,
        ZIMKitGroupService,
        ZIMKitHelperService,
        ZIMKitDefaultDialogService {
  factory ZIMKit() => instance;

  ZIMKit._internal() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  static final ZIMKit instance = ZIMKit._internal();

  Future<void> init({
    required int appID,
    String appSign = '',
    String appSecret = '',
    ZIMKitConfig? config,
    ZIMKitEvents? events,
  }) async {
    return ZIMKitCore.instance.init(
      appID: appID,
      appSign: appSign,
      appSecret: appSecret,
      config: config,
      events: events,
    );
  }

  Future<void> uninit() async {
    return ZIMKitCore.instance.uninit();
  }

  String getVersion() {
    return ZIMKitCore.instance.version;
  }
}
