import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/components.dart';
import 'package:zego_zimkit/src/components/messages/style.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/widgets/checkbox.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/zimkit.dart';

import 'long_press_event.dart';

class ZIMKitMessageListView extends StatefulWidget {
  const ZIMKitMessageListView({
    super.key,
    required this.conversationID,
    required this.config,
    this.conversationType = ZIMConversationType.peer,
    this.events,
    this.style,
  });

  final String conversationID;
  final ZIMConversationType conversationType;

  /// Configuration for message list
  final ZIMKitMessageListConfigs config;

  /// Events for message list
  final ZIMKitMessageListEvents? events;

  /// Style for message list
  final ZIMKitMessageListStyles? style;

  @override
  State<ZIMKitMessageListView> createState() => _ZIMKitMessageListViewState();
}

class _ZIMKitMessageListViewState extends State<ZIMKitMessageListView> {
  Completer? _loadMoreCompleter;
  final bottomOnLoadedNotifier = ValueNotifier<bool>(false);

  Set<ZIMKitMessage> get selectedMessages =>
      ZIMKitMessageListMultiSelectProcessor().selectedMessages;

  ScrollController get _scrollController =>
      widget.config.scrollController ?? ScrollController();

  void toggleMessageSelection(ZIMKitMessage message) {
    if (selectedMessages.contains(message)) {
      ZIMKitMessageListMultiSelectProcessor().removeSelectedMessage(message);
    } else {
      ZIMKitMessageListMultiSelectProcessor().addSelectedMessage(message);
    }

    widget.events?.onMultiSelectChanged?.call(
      ZIMKitMessageListMultiSelectProcessor().modeNotifier.value.isMultiMode,
      selectedMessages,
    );
  }

  bool isMessageSelected(ZIMKitMessage message) {
    return selectedMessages.any(
      (m) => m.info.messageID == message.info.messageID,
    );
  }

  Widget get defaultLoadingWidget {
    const defaultWidget = Center(child: CircularProgressIndicator());

    return widget.style?.loadingBuilder?.call(context, defaultWidget) ??
        defaultWidget;
  }

  @override
  void initState() {
    ZIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.addListener(scrollControllerListener);

    ZIMKitMessageListMultiSelectProcessor().modeNotifier.addListener(
          _onMultiSelectModeChanged,
        );

    super.initState();
  }

  @override
  void dispose() {
    ZIMKit().clearUnreadCount(widget.conversationID, widget.conversationType);
    _scrollController.removeListener(scrollControllerListener);

    ZIMKitMessageListMultiSelectProcessor().modeNotifier.removeListener(
          _onMultiSelectModeChanged,
        );

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    bottomOnLoadedNotifier.value = false;

    return Theme(
      data: widget.style?.theme ?? Theme.of(context),
      child: FutureBuilder(
        future: ZIMKit().getMessageListNotifier(
          widget.conversationID,
          widget.conversationType,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ValueListenableBuilder(
              valueListenable: snapshot.data!,
              builder: (
                BuildContext context,
                List<ValueNotifier<ZIMKitMessage>> messageList,
                Widget? child,
              ) {
                ZIMKit().clearUnreadCount(
                  widget.conversationID,
                  widget.conversationType,
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  jumpToBottom();
                  bottomOnLoadedNotifier.value = true;
                });

                return listview(messageList);
              },
            );
          } else if (snapshot.hasError) {
            // defaultWidget
            final Widget defaultWidget = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  Text(snapshot.error.toString()),
                  Text(ZIMKitCore.instance.innerText.loadMessageListError),
                ],
              ),
            );

            // customWidget
            return GestureDetector(
              onTap: () => setState(() {}),
              child: widget.style?.errorBuilder?.call(context, defaultWidget) ??
                  defaultWidget,
            );
          } else {
            return defaultLoadingWidget;
          }
        },
      ),
    );
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void jumpToBottom() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  Future<void> scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >=
          0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 ==
            await ZIMKit().loadMoreMessage(
              widget.conversationID,
              widget.conversationType,
            )) {
          _scrollController.removeListener(scrollControllerListener);
        }
        _loadMoreCompleter!.complete();
      }
    }
  }

  Widget listview(List<ValueNotifier<ZIMKitMessage>> messageList) {
    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        DateTime previousDateTime = messageList.isEmpty
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(
                messageList[0].value.info.timestamp,
              );
        DateTime nowDateTime = DateTime.now();

        return Stack(
          children: [
            Positioned.fill(
              child: widget.style?.backgroundBuilder?.call(
                    context,
                    const SizedBox.shrink(),
                  ) ??
                  Container(
                    color: ZIMKitMessageStyle.messageListBackgroundColor,
                  ),
            ),
            ListView.builder(
              cacheExtent: constraints.maxHeight * 3,
              controller: _scrollController,
              itemCount: messageList.length,
              dragStartBehavior: DragStartBehavior.down,
              itemBuilder: (context, index) {
                final messageNotifier = messageList[index];

                return ValueListenableBuilder(
                  valueListenable: messageNotifier,
                  builder: (
                    BuildContext context,
                    ZIMKitMessage message,
                    Widget? child,
                  ) {
                    final currentDatetime = DateTime.fromMillisecondsSinceEpoch(
                      message.info.timestamp,
                    );

                    final nowDuration = nowDateTime.difference(
                      currentDatetime,
                    );
                    final previousDuration = currentDatetime.difference(
                      previousDateTime,
                    );
                    final isLastWeek = nowDuration.inDays > 7;
                    final isToday = nowDuration.inDays <= 1;
                    final isFiveMinutesBefore = previousDuration.inMinutes > 5;
                    final isSameDayAsPrevious =
                        previousDuration.inDays.abs() < 1;
                    String formattedDateTime = '';
                    if (isToday) {
                      if (!isSameDayAsPrevious || isFiveMinutesBefore) {
                        formattedDateTime = DateFormat(
                          'HH:mm',
                        ).format(currentDatetime);
                      }
                    } else if (!isSameDayAsPrevious ||
                        0 == index ||
                        isFiveMinutesBefore) {
                      if (isLastWeek) {
                        formattedDateTime = DateFormat(
                          'yyyy/MM/dd HH:mm',
                        ).format(currentDatetime);
                      } else {
                        /// in week
                        formattedDateTime = DateFormat(
                          'EEEE HH:mm',
                        ).format(currentDatetime);
                      }
                    }
                    previousDateTime = currentDatetime;

                    // defaultWidget
                    final defaultWidget = defaultMessageWidget(
                      message: message,
                      constraints: constraints,
                    );

                    return widget.style?.itemBuilder?.call(
                          context,
                          message,
                          defaultWidget,
                        ) ??
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: formattedDateTime.isNotEmpty,
                              child: Container(
                                width: constraints.maxWidth,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    formattedDateTime,
                                    style: TextStyle(
                                      color:
                                          ZIMKitMessageStyle.timestampTextColor,
                                      fontSize:
                                          ZIMKitMessageStyle.timestampTextSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            defaultWidget,
                          ],
                        );
                  },
                );
              },
            ),
            scrollMask(constraints),
          ],
        );
      },
    );
  }

  Widget scrollMask(BoxConstraints constraints) {
    return ValueListenableBuilder<bool>(
      valueListenable: bottomOnLoadedNotifier,
      builder: (context, bottomOnLoaded, _) {
        return Visibility(
          visible: !bottomOnLoaded,
          child: SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: widget.style?.backgroundBuilder?.call(
                  context,
                  const SizedBox.shrink(),
                ) ??
                const SizedBox.shrink(),
          ),
        );
      },
    );
  }

  Widget defaultMessageWidget({
    required ZIMKitMessage message,
    required BoxConstraints constraints,
  }) {
    /// Wrap the onLongPress callback to hide keyboard before calling user's callback
    void Function(
      BuildContext context,
      LongPressStartDetails details,
      ZIMKitMessage message,
      Function defaultAction,
    )? _wrapOnLongPress(
      void Function(
        BuildContext context,
        LongPressStartDetails details,
        ZIMKitMessage message,
        Function defaultAction,
      )? userCallback,
    ) {
      if (userCallback == null) return null;

      return (context, details, message, defaultAction) {
        // Hide keyboard before showing menu (like iOS implementation)
        widget.config.inputFocusNode?.unfocus();

        // Call user's callback
        userCallback(context, details, message, defaultAction);
      };
    }

    final longPressEvent = ZIMKitMessageListViewItemLongPressEvent(
      context: context,
      onReplyMessage: widget.events?.onReplyMessage,
    );

    messageWidgetCreator(bool isMultiSelectMode) {
      return ZIMKitMessageWidget(
        key: ValueKey(message.hashCode),
        message: message,
        onPressed: isMultiSelectMode
            ? (context, msg, defaultAction) {
                toggleMessageSelection(msg);
              }
            : (context, msg, defaultAction) {
                if (null == widget.events?.onPressed) {
                  defaultAction.call();
                } else {
                  widget.events?.onPressed?.call(context, msg, defaultAction);
                }
              },
        onLongPress: _wrapOnLongPress(
          widget.events?.onLongPress ?? longPressEvent.onMessageItemLongPress,
        ),
        onReplyMessageTap: (messageID) {
          widget.events?.onReplyMessageTap?.call(messageID);
        },
        messageContentBuilder: widget.style?.messageContentBuilder,
        avatarBuilder: widget.style?.avatarBuilder,
        statusBuilder: widget.style?.statusBuilder,
      );
    }

    return ValueListenableBuilder<ZIMKitMessageListMultiModeData>(
      valueListenable: ZIMKitMessageListMultiSelectProcessor().modeNotifier,
      builder: (context, multiSelectModeData, _) {
        return multiSelectModeData.isMultiMode
            ?
            // In multi-select mode, show checkbox
            SizedBox(
                width: constraints.maxWidth,
                child: Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: ZIMKitMessageListMultiSelectProcessor()
                          .selectedMessagesNotifier,
                      builder: (context, selectedMessages, _) {
                        return RoundBlueCheckbox(
                          value: isMessageSelected(message),
                          onChanged: (value) {
                            toggleMessageSelection(message);
                          },
                        );
                      },
                    ),
                    // Message content
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth - 48,
                          maxHeight: message.type == ZIMMessageType.text
                              ? double.maxFinite
                              : constraints.maxHeight * 0.5,
                        ),
                        child: messageWidgetCreator(
                          multiSelectModeData.isMultiMode,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : SizedBox(
                width: constraints.maxWidth,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: message.type == ZIMMessageType.text
                        ? double.maxFinite
                        : constraints.maxHeight * 0.5,
                  ),
                  child: messageWidgetCreator(
                    multiSelectModeData.isMultiMode,
                  ),
                ),
              );
      },
    );
  }

  void _onMultiSelectModeChanged() {
    widget.events?.onMultiSelectChanged?.call(
      ZIMKitMessageListMultiSelectProcessor().modeNotifier.value.isMultiMode,
      selectedMessages,
    );
  }
}
