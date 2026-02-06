# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Zego ZIMKit is a Flutter low-code plugin providing in-app chat UI components built on top of Zego's ZIM (Zego Instant Messaging) SDK. It enables peer-to-peer and group chat with support for text, images, GIFs, videos, files, message reactions, and replies.

## Common Commands

```bash
# Format and sort imports
flutter pub run import_sorter:main

# Analyze code
flutter analyze

# Run lints
flutter pub run lints

# Run tests
flutter test

# Build for release (Android)
flutter build apk --release

# Build for release (iOS)
flutter build ios --release

# Build a module for integration into other Flutter apps
flutter build appbundle
```

## Architecture

### Core Entry Point
- `lib/src/zimkit.dart` - Main `ZIMKit` singleton class that aggregates all services via mixins
- `lib/src/services/core/core.dart` - `ZIMKitCore` singleton managing global state, caches, and event handlers

### Service Layer (Mixins on ZIMKit)
All services are implemented as mixins on the `ZIMKit` class:
- `ZIMKitConversationService` - Conversation CRUD operations, loading, unread counts
- `ZIMKitMessageService` - Send/receive/delete messages, reactions, media
- `ZIMKitUserService` - User connection, profile queries
- `ZIMKitGroupService` - Group creation, management, member operations
- `ZIMKitInputService` - Input box state management
- `ZIMKitHelperService` - Utility functions
- `ZIMKitDefaultDialogService` - Default dialog implementations

### Component Layer (`lib/src/components/`)
UI widgets follow a modular structure:
- `conversation/` - `ZIMKitConversationListView`, list items, configs, styles
- `messages/` - Message widgets: input, list, list_page (chat screen), individual message types (text, image, video, audio, file), reactions
- `audio/` - Voice recording UI (record button, cancel slider, lock button)
- `toolbar/` - Rich input toolbar (emoji picker, media picker, file picker)
- `select/` - Multi-select UI for forwarding messages
- `settings/` - Chat settings widget
- `common/` - Shared components like avatar

### Data Layer
- `ZIMKitCore.db` - Local database (conversations, messages, users)
- Memory caches in `ZIMKitCore`: `_userInfoMemoryCache`, `_queryUserCache`, `_queryGroupCache`
- `ValueNotifier` based reactivity for UI updates

### Configuration
- `ZIMKitConfig` - Main config with nested configs for input, message, conversation, notifications
- `ZIMKitInnerText` - Internationalization strings
- `ZIMKitEvents` - Event callbacks

### Platform Integration
- `lib/src/channel/` - Method channel for native platform communication
- `lib/src/callkit/` - Call notification handling (Android/iOS)
- Native plugins: `zego_zim`, `zego_uikit_signaling_plugin`, `zego_zpns`

### File Organization Pattern
- Each component directory has: `widget.dart` (main), `configs.dart`, `styles.dart`, `events.dart`, `defines.dart`
- Services use `part of` and `part` directives to split large files

## Key Patterns

1. **Singleton Access**: Use `ZIMKit()` for APIs, `ZIMKitCore.instance` for internal operations
2. **Reactive Data**: Use `ValueNotifier` and `ZIMKit*Notifier` types for UI binding
3. **Service Mixins**: Services are mixed into `ZIMKit` class for clean API surface
4. **Config Objects**: Deeply nested config classes for customization (inputConfig, messageConfig, etc.)
5. **Event Streams**: `StreamController` broadcasting for group/user events

## Dependencies

Key external dependencies:
- `zego_zim` - Core IM SDK
- `zego_uikit_signaling_plugin` - Signaling/notification
- `zego_zpns` - Push notifications
- `provider` - State management
- `file_picker`, `wechat_assets_picker` - File/media picking
- `chewie` + `video_player` - Video playback
- `emoji_picker_flutter` - Emoji input

## Import Sorting

This project uses `import_sorter` with `comments: false`. Run `flutter pub run import_sorter:main` after adding new imports.
