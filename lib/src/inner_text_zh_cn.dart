import 'inner_text.dart';

/// ZIMKit 简体中文文本配置
///
/// 使用方式：
/// ```dart
/// ZIMKitConfig(
///   innerText: ZIMKitInnerTextZhCN(),
/// )
/// ```
class ZIMKitInnerTextZhCN extends ZIMKitInnerText {
  ZIMKitInnerTextZhCN()
      : super(
          /// 消息输入相关
          messageEmptyText: '说点什么吧...',

          /// 消息操作相关
          copyMenuText: '复制',
          replyMenuText: '回复',
          forwardMenuText: '转发',
          revokeMenuText: '撤回',
          deleteMenuText: '删除',
          multipleChoiceMenuText: '多选',
          reactionMenuText: '表情回复',
          speakerMenuText: '扬声器',
          cancelMenuText: '取消',

          /// Toast 提示
          copySuccessToast: '已复制到剪贴板',
          revokeSuccessToast: '消息已撤回',
          deleteSuccessToast: '消息已删除',
          deletedToast: '已删除',
          forwardSuccessToast: '转发成功',
          networkErrorToast: '网络错误',

          /// 确认对话框
          deleteMessageTitle: '删除消息',
          deleteMessageContent: '确定要删除此消息？',
          deleteMessagesTitle: '删除消息',
          deleteMessagesContentFormat: '确定删除%d条消息吗？',
          revokeMessageTitle: '撤回消息',
          revokeMessageContent: '确定要撤回此消息？',
          confirmButtonText: '确定',
          cancelButtonText: '取消',

          /// 多选模式
          selectedCountText: '已选择 %d 条',
          selectAllText: '全选',
          deselectAllText: '取消全选',

          /// 转发相关
          forwardTitle: '转发',
          forwardSeparatelyText: '逐条转发',
          forwardCombinedText: '合并转发',
          forwardSelectTitle: '选择会话',
          forwardConfirmTitle: '确认转发',
          forwardToText: '发送给:',

          /// 回复相关
          replyToText: '回复 %s',
          replyMessageDeletedText: '原消息已删除',

          /// 会话相关
          conversationPinText: '置顶',
          conversationUnpinText: '取消置顶',
          conversationDeleteText: '删除',
          conversationMuteText: '免打扰',
          conversationUnmuteText: '取消免打扰',

          /// 群聊相关
          groupNameText: '群名称',
          groupMembersText: '成员',
          groupNoticeText: '公告',
          groupLeaveText: '退出群聊',
          groupDismissText: '解散群聊',

          /// 消息类型显示
          imageMessageText: '[图片]',
          videoMessageText: '[视频]',
          audioMessageText: '[语音]',
          fileMessageText: '[文件]',
          combineMessageText: '[聊天记录]',
          customMessageText: '[自定义消息]',
          revokeMessageText: '消息已撤回',

          /// 撤回消息显示
          youRevokedMessage: '你撤回了一条消息',
          someoneRevokedMessageFormat: '%s 撤回了一条消息',

          /// 会话操作相关
          deleteConversationTitle: '删除会话',
          deleteConversationContent: '确定要删除此会话？',
          leaveGroupTitle: '退出群聊',
          leaveGroupContent: '确定要退出此群聊？',
          quitGroupText: '退出',
          okButtonText: '确定',

          /// 对话框标题
          newChatTitle: '新建聊天',
          newGroupTitle: '新建群组',
          joinGroupTitle: '加入群组',

          /// 输入框标签
          userIdLabel: '用户 ID',
          groupNameLabel: '群组名称',
          groupIdOptionalLabel: 'ID（可选）',
          groupIdLabel: '群组 ID',
          inviteUserIdsLabel: '邀请用户 IDs',
          inviteUserIdsHint: '用逗号分隔，例如：123,987,229',

          /// 回复消息显示
          replyingToFormat: '正在回复 %s',

          /// 错误提示
          loadCombineMessageError: '加载聊天记录失败',
          loadMessageListError: '加载失败，请点击重试',
          messageNotFoundToast: '未找到该消息',

          /// 视频直播相关
          liveText: '直播',

          /// 聊天设置相关
          chatSettingsTitle: '聊天设置',
          chatPinnedTitle: '聊天置顶',
          chatNotDisturbTitle: '聊天免打扰',
          pinnedToast: '已置顶',
          unpinnedToast: '已取消置顶',
          notDisturbEnabledToast: '已开启免打扰',
          notDisturbDisabledToast: '已关闭免打扰',
          operationFailedFormat: '操作失败: %s',

          /// 时间显示
          justNowText: '刚刚',
          minutesAgoFormat: '%d 分钟前',
          hoursAgoFormat: '%d 小时前',

          /// 录音相关
          slideToCancelText: '滑动取消',

          /// 更多操作面板
          takePhotoText: '拍摄',
          photoText: '相册',
          fileText: '文件',

          /// Badge相关
          maxBadgeCountText: '9999+',
        );
}
