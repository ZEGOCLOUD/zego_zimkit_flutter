import 'dart:async';

import 'package:flutter/material.dart';

import 'package:zego_zim/zego_zim.dart';

import 'package:zego_zimkit/src/components/conversation/list_item.dart';
import 'package:zego_zimkit/src/components/messages/list_page/styles.dart';
import 'package:zego_zimkit/src/components/messages/list_page/widget.dart';
import 'package:zego_zimkit/src/defines.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util.dart';
import 'package:zego_zimkit/src/utils/screen_util/screen_util_config.dart';
import 'package:zego_zimkit/src/services/core/core.dart';
import 'package:zego_zimkit/src/zimkit.dart';
import 'configs.dart';
import 'events.dart';
import 'styles.dart';

/// Conversation list view widget with organized configuration
class ZIMKitConversationListView extends StatefulWidget {
  const ZIMKitConversationListView({
    super.key,
    this.configs,
    this.events,
    this.styles,
  });

  /// Configuration for conversation list
  final ZIMKitConversationListConfigs? configs;

  /// Events for conversation list
  final ZIMKitConversationListEvents? events;

  /// Style for conversation list
  final ZIMKitConversationListStyles? styles;

  @override
  State<ZIMKitConversationListView> createState() =>
      _ZIMKitConversationListViewState();
}

class _ZIMKitConversationListViewState
    extends State<ZIMKitConversationListView> {
  final ScrollController _defaultScrollController = ScrollController();

  ScrollController get _scrollController =>
      widget.configs?.scrollController ?? _defaultScrollController;

  Completer? _loadMoreCompleter;

  @override
  void initState() {
    _scrollController.addListener(scrollControllerListener);

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollControllerListener);

    super.dispose();
  }

  Future<void> scrollControllerListener() async {
    if (_loadMoreCompleter == null || _loadMoreCompleter!.isCompleted) {
      if (_scrollController.position.pixels >=
          0.8 * _scrollController.position.maxScrollExtent) {
        _loadMoreCompleter = Completer();
        if (0 == await ZIMKit().loadMoreConversation()) {
          _scrollController.removeListener(scrollControllerListener);
        }
        _loadMoreCompleter!.complete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ZIMScreenUtilInit(
      designSize: ZIMKitScreenUtilConfig.designSize,
      builder: (context, child) {
        return Theme(
          data: widget.styles?.theme ?? Theme.of(context),
          child: FutureBuilder<ZIMKitConversationListNotifier>(
            future: ZIMKit().getConversationListNotifier(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ValueListenableBuilder(
                  valueListenable: snapshot.data!,
                  builder: (
                    BuildContext context,
                    List<ZIMKitConversationNotifier> conversationList,
                    Widget? child,
                  ) {
                    if (conversationList.isEmpty) {
                      return widget.styles?.emptyBuilder?.call(
                            context,
                            const SizedBox.shrink(),
                          ) ??
                          const SizedBox.shrink();
                    }

                    conversationList = widget.configs?.filter?.call(
                          context,
                          conversationList,
                        ) ??
                        conversationList;
                    conversationList = widget.configs?.sorter?.call(
                          context,
                          conversationList,
                        ) ??
                        conversationList;

                    return LayoutBuilder(
                      builder: (context, BoxConstraints constraints) {
                        return ListView.builder(
                          cacheExtent: constraints.maxHeight * 3,
                          controller: _scrollController,
                          itemCount: conversationList.length,
                          itemBuilder: (context, index) {
                            final conversation = conversationList[index];

                            return ValueListenableBuilder(
                              valueListenable: conversation,
                              builder: (
                                BuildContext context,
                                ZIMKitConversation conversation,
                                Widget? child,
                              ) {
                                // defaultWidget
                                final Widget defaultWidget =
                                    ZIMKitConversationWidget(
                                  conversation: conversation,
                                  lastMessageTimeBuilder:
                                      widget.styles?.lastMessageTimeBuilder,
                                  lastMessageTextBuilder:
                                      widget.styles?.lastMessageBuilder,
                                  onLongPress: (
                                    BuildContext context,
                                    LongPressStartDetails longPressDetails,
                                  ) {
                                    void onLongPressDefaultAction() {
                                      _onLongPressDefaultAction(
                                        context,
                                        longPressDetails,
                                        conversation.id,
                                        conversation.type,
                                      );
                                    }

                                    if (widget.events?.onLongPress != null) {
                                      widget.events!.onLongPress!(
                                        context,
                                        conversation,
                                        longPressDetails,
                                        onLongPressDefaultAction,
                                      );
                                    } else {
                                      onLongPressDefaultAction();
                                    }
                                  },
                                  onPressed: (BuildContext context) {
                                    void onPressedDefaultAction() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ZIMKitMessageListPage(
                                              conversationID: conversation.id,
                                              conversationType:
                                                  conversation.type,
                                              style: widget.styles != null
                                                  ? ZIMKitMessageListPageStyle(
                                                      theme:
                                                          widget.styles!.theme,
                                                    )
                                                  : null,
                                            );
                                          },
                                        ),
                                      );
                                    }

                                    if (widget.events?.onPressed != null) {
                                      widget.events!.onPressed!(
                                        context,
                                        conversation,
                                        onPressedDefaultAction,
                                      );
                                    } else {
                                      onPressedDefaultAction();
                                    }
                                  },
                                );

                                // customWidget
                                return widget.styles?.itemBuilder?.call(
                                      context,
                                      conversation,
                                      defaultWidget,
                                    ) ??
                                    defaultWidget;
                              },
                            );
                          },
                        );
                      },
                    );
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
                      Text(ZIMKitCore.instance.innerText.loadMessageListError),
                    ],
                  ),
                );

                // customWidget
                return GestureDetector(
                  onTap: () => setState(() {}),
                  child: widget.styles?.errorBuilder?.call(
                        context,
                        defaultWidget,
                      ) ??
                      defaultWidget,
                );
              } else {
                // defaultWidget
                const Widget defaultWidget = Center(
                  child: CircularProgressIndicator(),
                );

                // customWidget
                return widget.styles?.loadingBuilder?.call(
                      context,
                      defaultWidget,
                    ) ??
                    defaultWidget;
              }
            },
          ),
        );
      },
    );
  }

  void _onLongPressDefaultAction(
    BuildContext context,
    LongPressStartDetails longPressDetails,
    String conversationID,
    ZIMConversationType conversationType,
  ) {
    final conversationBox = context.findRenderObject()! as RenderBox;
    final offset = conversationBox.localToGlobal(
      Offset(0, conversationBox.size.height / 2),
    );
    final position = RelativeRect.fromLTRB(
      longPressDetails.globalPosition.dx,
      offset.dy,
      longPressDetails.globalPosition.dx,
      offset.dy,
    );

    final innerText = ZIMKitCore.instance.innerText;
    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(value: 0, child: Text(innerText.conversationDeleteText)),
        if (conversationType == ZIMConversationType.group)
          PopupMenuItem(value: 1, child: Text(innerText.quitGroupText)),
      ],
    ).then((value) {
      switch (value) {
        case 0:
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) {
              final innerText = ZIMKitCore.instance.innerText;
              return AlertDialog(
                title: Text(innerText.deleteConversationTitle),
                content: Text(innerText.deleteConversationContent),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(innerText.cancelButtonText),
                  ),
                  TextButton(
                    onPressed: () {
                      ZIMKit().deleteConversation(
                        conversationID,
                        conversationType,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(innerText.okButtonText),
                  ),
                ],
              );
            },
          );
          break;
        case 1:
          if (!context.mounted) return;
          showDialog(
            context: context,
            builder: (context) {
              final innerText = ZIMKitCore.instance.innerText;
              return AlertDialog(
                title: Text(innerText.leaveGroupTitle),
                content: Text(innerText.leaveGroupContent),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(innerText.cancelButtonText),
                  ),
                  TextButton(
                    onPressed: () {
                      ZIMKit().leaveGroup(conversationID);
                      Navigator.pop(context);
                    },
                    child: Text(innerText.okButtonText),
                  ),
                ],
              );
            },
          );
          break;
      }
    });
  }
}

// TODO Pass the messageListPage config
