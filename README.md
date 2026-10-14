# ZIMKit for Flutter

Baseline: ZIMKit Flutter v2.0.0 (verified against code on 2026-10-14)

ZIMKit is a Flutter UI kit for adding one-to-one and group chat to an app. It provides ready-to-use conversation and message screens, messaging APIs, and controls for adapting the UI to your app.

[![pub package](https://img.shields.io/pub/v/zego_zimkit.svg)](https://pub.dev/packages/zego_zimkit)

![ZIMKit chat preview](images/img_chat.png)

## Features

- **Conversation list:** display conversations and unread counts; pin conversations and set notification status.
- **One-to-one and group chat:** open a chat page with text, image, voice, video, and file messages. Send custom and combined messages through the API.
- **Message actions:** configure the long-press menu for reply, forward, revoke, delete, multi-select, and emoji reactions. Available actions can vary by message type and permissions.
- **Group details and member management:** use the built-in `ZIMKitGroupDetailPage` to view group information and members, invite users, and manage member roles. The host app provides the user picker; ZIMKit performs the invite.
- **Customizable composer and UI:** configure input buttons, emoji choices, message actions, styles, and visible text. Handle voice/video call buttons in the host app and connect them to your calling kit.
- **Authentication and events:** connect with a user ID and an optional server-issued token, renew tokens, and listen for connection, message, and media transfer events.

## Quick start

Add `zego_zimkit` to your `pubspec.yaml`, then initialize the SDK and connect a user before showing chat UI:

```dart
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

Future<void> initializeZIMKit() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ZIMKit().init(
    appID: yourAppID,
    appSign: yourAppSign,
  );

  final errorCode = await ZIMKit().connectUser(
    id: userID,
    name: userName,
    // For Token authentication, pass a token issued by your server.
    // token: tokenFromYourServer,
  );
  if (errorCode != 0) {
    throw StateError('ZIMKit user connection failed: $errorCode');
  }
}
```

Show the conversation list and open the selected conversation:

```dart
ZIMKitConversationListView(
  events: ZIMKitConversationListEvents(
    onPressed: (context, conversation, defaultAction) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ZIMKitMessageListPage(
            conversationID: conversation.id,
            conversationType: conversation.type,
          ),
        ),
      );
    },
  ),
)
```

## Documentation

- [UI components](doc/components.md)
- [Configuration options](doc/configs.md)
- [SDK APIs](doc/apis.md)
- [Events](doc/events.md)
