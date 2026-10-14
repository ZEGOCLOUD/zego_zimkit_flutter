/// ZIMKit 内部文本配置
///
/// 用于配置 ZIMKit 中所有可见文本的国际化。
/// 所有文本都可以通过这个类进行自定义。
///
/// 示例：
/// ```dart
/// ZIMKitInnerText(
///   messageEmptyText: 'Say something...',
///   copySuccessToast: 'Copied to clipboard',
/// )
/// ```
/// ZIMKit Internal Text Configuration
///
/// Used to configure the internationalization of all visible texts in ZIMKit.
/// All texts can be customized through this class.
///
/// Example:
/// ```dart
/// ZIMKitInnerText(
///   messageEmptyText: 'Say something...',
///   copySuccessToast: 'Copied to clipboard',
/// )
/// ```
class ZIMKitInnerText {
  ZIMKitInnerText({
    /// Message Input Related
    String? messageEmptyText,

    /// Message Operation Related
    String? copyMenuText,
    String? replyMenuText,
    String? forwardMenuText,
    String? revokeMenuText,
    String? deleteMenuText,
    String? multipleChoiceMenuText,
    String? reactionMenuText,
    String? speakerMenuText,
    String? cancelMenuText,

    /// Toast Notifications
    String? copySuccessToast,
    String? revokeSuccessToast,
    String? deleteSuccessToast,
    String? deletedToast,
    String? forwardSuccessToast,
    String? networkErrorToast,

    /// Confirmation Dialogs
    String? deleteMessageTitle,
    String? deleteMessageContent,
    String? deleteMessagesTitle,
    String? deleteMessagesContentFormat,
    String? revokeMessageTitle,
    String? revokeMessageContent,
    String? confirmButtonText,
    String? cancelButtonText,

    /// Multiple Selection Mode
    String? selectedCountText,
    String? selectAllText,
    String? deselectAllText,

    /// Forward Related
    String? forwardTitle,
    String? forwardSeparatelyText,
    String? forwardCombinedText,
    String? forwardSelectTitle,
    String? forwardConfirmTitle,
    String? forwardToText,

    /// Reply Related
    String? replyToText,
    String? replyMessageDeletedText,

    /// Conversation Related
    String? conversationPinText,
    String? conversationUnpinText,
    String? conversationDeleteText,
    String? conversationMuteText,
    String? conversationUnmuteText,

    /// Group Chat Related
    String? groupNameText,
    String? groupMembersText,
    String? groupNoticeText,
    String? groupLeaveText,
    String? groupDismissText,
    String? groupDetailTitle,
    String? groupAddMemberText,
    String? groupNoMembersText,
    String? groupRetryText,
    String? groupOwnerRoleText,
    String? groupAdminRoleText,
    String? groupMemberRoleText,
    String? groupRemoveMemberText,
    String? groupMakeAdminText,
    String? groupRemoveAdminText,
    String? groupTransferOwnershipText,
    String? groupPickerUnavailableText,

    /// Message Type Display
    String? imageMessageText,
    String? videoMessageText,
    String? audioMessageText,
    String? fileMessageText,
    String? combineMessageText,
    String? customMessageText,
    String? revokeMessageText,

    /// Revoked Message Display
    String? youRevokedMessage,
    String? someoneRevokedMessageFormat,

    /// Conversation Operation Related
    String? deleteConversationTitle,
    String? deleteConversationContent,
    String? leaveGroupTitle,
    String? leaveGroupContent,
    String? quitGroupText,
    String? okButtonText,

    /// Dialog Titles
    String? newChatTitle,
    String? newGroupTitle,
    String? joinGroupTitle,

    /// Input Field Labels
    String? userIdLabel,
    String? groupNameLabel,
    String? groupIdOptionalLabel,
    String? groupIdLabel,
    String? inviteUserIdsLabel,
    String? inviteUserIdsHint,

    /// Reply Message Display
    String? replyingToFormat,

    /// Error Notifications
    String? loadCombineMessageError,
    String? loadMessageListError,
    String? messageNotFoundToast,

    /// Video Live Streaming Related
    String? liveText,

    /// Chat Settings Related
    String? chatSettingsTitle,
    String? chatPinnedTitle,
    String? chatNotDisturbTitle,
    String? pinnedToast,
    String? unpinnedToast,
    String? notDisturbEnabledToast,
    String? notDisturbDisabledToast,
    String? operationFailedFormat,

    /// Time Display
    String? justNowText,
    String? minutesAgoFormat,
    String? hoursAgoFormat,

    /// Voice Recording Related
    String? slideToCancelText,
    String? holdToTalkText,
    String? releaseToSendText,
    String? slideLeftToCancelText,
    String? slideUpToLockText,
    String? releaseToLockText,
    String? releaseToCancelText,
    String? recordingLockedText,
    String? recordingStartingText,
    String? discardRecordingText,
    String? discardRecordingLabelText,
    String? sendRecordingText,
    String? startVoiceRecordingLabelText,
    String? startVoiceRecordingHintText,
    String? recordingStartFailedText,

    /// More Operation Panel
    String? takePhotoText,
    String? photoText,
    String? fileText,
    String? voiceInputText,
    String? emojiInputText,
    String? voiceCallInputText,
    String? videoCallInputText,

    /// Badge Related
    String? maxBadgeCountText,
  }) : /// Message Input Related
       messageEmptyText = messageEmptyText ?? 'Say something...',

       /// Message Operation Related
       copyMenuText = copyMenuText ?? 'Copy',
       replyMenuText = replyMenuText ?? 'Reply',
       forwardMenuText = forwardMenuText ?? 'Forward',
       revokeMenuText = revokeMenuText ?? 'Revoke',
       deleteMenuText = deleteMenuText ?? 'Delete',
       multipleChoiceMenuText = multipleChoiceMenuText ?? 'Select',
       reactionMenuText = reactionMenuText ?? 'React',
       speakerMenuText = speakerMenuText ?? 'Speaker',
       cancelMenuText = cancelMenuText ?? 'Cancel',

       /// Toast Notifications
       copySuccessToast = copySuccessToast ?? 'Copied to clipboard',
       revokeSuccessToast = revokeSuccessToast ?? 'Message revoked',
       deleteSuccessToast = deleteSuccessToast ?? 'Message deleted',
       deletedToast = deletedToast ?? 'Deleted',
       forwardSuccessToast = forwardSuccessToast ?? 'Message forwarded',
       networkErrorToast = networkErrorToast ?? 'Network error',

       /// Confirmation Dialogs
       deleteMessageTitle = deleteMessageTitle ?? 'Delete Message',
       deleteMessageContent =
           deleteMessageContent ?? 'Are you sure to delete this message?',
       deleteMessagesTitle = deleteMessagesTitle ?? 'Delete Messages',
       deleteMessagesContentFormat =
           deleteMessagesContentFormat ?? 'Delete %d messages?',
       revokeMessageTitle = revokeMessageTitle ?? 'Revoke Message',
       revokeMessageContent =
           revokeMessageContent ?? 'Are you sure to revoke this message?',
       confirmButtonText = confirmButtonText ?? 'Confirm',
       cancelButtonText = cancelButtonText ?? 'Cancel',

       /// Multiple Selection Mode
       selectedCountText = selectedCountText ?? '%d selected',
       selectAllText = selectAllText ?? 'Select All',
       deselectAllText = deselectAllText ?? 'Deselect All',

       /// Forward Related
       forwardTitle = forwardTitle ?? 'Forward',
       forwardSeparatelyText = forwardSeparatelyText ?? 'Forward Separately',
       forwardCombinedText = forwardCombinedText ?? 'Forward as Combined',
       forwardSelectTitle = forwardSelectTitle ?? 'Select Conversation',
       forwardConfirmTitle = forwardConfirmTitle ?? 'Confirm Forward',
       forwardToText = forwardToText ?? 'Forward to:',

       /// Reply Related
       replyToText = replyToText ?? 'Reply to %s',
       replyMessageDeletedText =
           replyMessageDeletedText ?? 'Original message deleted',

       /// Conversation Related
       conversationPinText = conversationPinText ?? 'Pin',
       conversationUnpinText = conversationUnpinText ?? 'Unpin',
       conversationDeleteText = conversationDeleteText ?? 'Delete',
       conversationMuteText = conversationMuteText ?? 'Mute',
       conversationUnmuteText = conversationUnmuteText ?? 'Unmute',

       /// Group Chat Related
       groupNameText = groupNameText ?? 'Group Name',
       groupMembersText = groupMembersText ?? 'Members',
       groupNoticeText = groupNoticeText ?? 'Notice',
       groupLeaveText = groupLeaveText ?? 'Leave Group',
       groupDismissText = groupDismissText ?? 'Dismiss Group',
       groupDetailTitle = groupDetailTitle ?? 'Group details',
       groupAddMemberText = groupAddMemberText ?? 'Add',
       groupNoMembersText = groupNoMembersText ?? 'No members found',
       groupRetryText = groupRetryText ?? 'Retry',
       groupOwnerRoleText = groupOwnerRoleText ?? 'Owner',
       groupAdminRoleText = groupAdminRoleText ?? 'Admin',
       groupMemberRoleText = groupMemberRoleText ?? 'Member',
       groupRemoveMemberText = groupRemoveMemberText ?? 'Remove member',
       groupMakeAdminText = groupMakeAdminText ?? 'Make admin',
       groupRemoveAdminText = groupRemoveAdminText ?? 'Remove admin',
       groupTransferOwnershipText =
           groupTransferOwnershipText ?? 'Transfer ownership',
       groupPickerUnavailableText =
           groupPickerUnavailableText ??
           'The host app has not provided a member picker.',

       /// Message Type Display
       imageMessageText = imageMessageText ?? '[Image]',
       videoMessageText = videoMessageText ?? '[Video]',
       audioMessageText = audioMessageText ?? '[Audio]',
       fileMessageText = fileMessageText ?? '[File]',
       combineMessageText = combineMessageText ?? '[Chat History]',
       customMessageText = customMessageText ?? '[Custom Message]',
       revokeMessageText = revokeMessageText ?? 'Message revoked',

       /// Revoked Message Display
       youRevokedMessage = youRevokedMessage ?? 'You recalled a message',
       someoneRevokedMessageFormat =
           someoneRevokedMessageFormat ?? '%s recalled a message',

       /// Conversation Operation Related
       deleteConversationTitle =
           deleteConversationTitle ?? 'Delete Conversation',
       deleteConversationContent =
           deleteConversationContent ??
           'Do you want to delete this conversation?',
       leaveGroupTitle = leaveGroupTitle ?? 'Leave Group',
       leaveGroupContent =
           leaveGroupContent ?? 'Do you want to leave this group?',
       quitGroupText = quitGroupText ?? 'Quit',
       okButtonText = okButtonText ?? 'OK',

       /// Dialog Titles
       newChatTitle = newChatTitle ?? 'New Chat',
       newGroupTitle = newGroupTitle ?? 'New Group',
       joinGroupTitle = joinGroupTitle ?? 'Join Group',

       /// Input Field Labels
       userIdLabel = userIdLabel ?? 'User ID',
       groupNameLabel = groupNameLabel ?? 'Group Name',
       groupIdOptionalLabel = groupIdOptionalLabel ?? 'ID(optional)',
       groupIdLabel = groupIdLabel ?? 'Group ID',
       inviteUserIdsLabel = inviteUserIdsLabel ?? 'Invite User IDs',
       inviteUserIdsHint =
           inviteUserIdsHint ?? 'separate by comma, e.g. 123,987,229',

       /// Reply Message Display
       replyingToFormat = replyingToFormat ?? 'Replying to %s',

       /// Error Notifications
       loadCombineMessageError =
           loadCombineMessageError ?? 'Failed to load chat history',
       loadMessageListError =
           loadMessageListError ?? 'Load failed, please click to retry',
       messageNotFoundToast =
           messageNotFoundToast ?? 'Message not found in current conversation',

       /// Video Live Streaming Related
       liveText = liveText ?? 'LIVE',

       /// Chat Settings Related
       chatSettingsTitle = chatSettingsTitle ?? 'Chat Settings',
       chatPinnedTitle = chatPinnedTitle ?? 'Pin Chat',
       chatNotDisturbTitle = chatNotDisturbTitle ?? 'Mute Notifications',
       pinnedToast = pinnedToast ?? 'Pinned',
       unpinnedToast = unpinnedToast ?? 'Unpinned',
       notDisturbEnabledToast = notDisturbEnabledToast ?? 'Muted',
       notDisturbDisabledToast = notDisturbDisabledToast ?? 'Unmuted',
       operationFailedFormat = operationFailedFormat ?? 'Operation failed: %s',

       /// Time Display
       justNowText = justNowText ?? 'just now',
       minutesAgoFormat = minutesAgoFormat ?? '%d minutes ago',
       hoursAgoFormat = hoursAgoFormat ?? '%d hours ago',

       /// Voice Recording Related
       slideToCancelText = slideToCancelText ?? 'slide to cancel',
       holdToTalkText = holdToTalkText ?? 'Hold to talk',
       releaseToSendText = releaseToSendText ?? 'Release to send',
       slideLeftToCancelText = slideLeftToCancelText ?? 'Slide left to cancel',
       slideUpToLockText = slideUpToLockText ?? 'Slide up to lock',
       releaseToLockText = releaseToLockText ?? 'Release to lock',
       releaseToCancelText = releaseToCancelText ?? 'Release to cancel',
       recordingLockedText = recordingLockedText ?? 'Recording locked',
       recordingStartingText = recordingStartingText ?? 'Starting recording…',
       discardRecordingText = discardRecordingText ?? 'Discard',
       discardRecordingLabelText =
           discardRecordingLabelText ?? 'Discard current recording',
       sendRecordingText = sendRecordingText ?? 'Send',
       startVoiceRecordingLabelText =
           startVoiceRecordingLabelText ?? 'Start voice recording',
       startVoiceRecordingHintText =
           startVoiceRecordingHintText ??
           'Starts a locked recording. Use Send or Discard when finished.',
       recordingStartFailedText =
           recordingStartFailedText ??
           'Recording could not start. Please try again.',

       /// More Operation Panel
       takePhotoText = takePhotoText ?? 'Take Photo',
       photoText = photoText ?? 'Photo',
       fileText = fileText ?? 'File',
       voiceInputText = voiceInputText ?? 'Voice',
       emojiInputText = emojiInputText ?? 'Emoji',
       voiceCallInputText = voiceCallInputText ?? 'Voice call',
       videoCallInputText = videoCallInputText ?? 'Video call',

       /// Badge Related
       maxBadgeCountText = maxBadgeCountText ?? '9999+';

  /// ========== Message Input Related ==========

  /// Hint text when message is empty
  final String messageEmptyText;

  /// ========== Message Operation Related ==========

  /// Copy menu text
  final String copyMenuText;

  /// Reply menu text
  final String replyMenuText;

  /// Forward menu text
  final String forwardMenuText;

  /// Revoke menu text
  final String revokeMenuText;

  /// Delete menu text
  final String deleteMenuText;

  /// Multiple selection menu text
  final String multipleChoiceMenuText;

  /// Reaction menu text
  final String reactionMenuText;

  /// Speaker menu text
  final String speakerMenuText;

  /// Cancel menu text
  final String cancelMenuText;

  /// ========== Toast Notifications ==========

  /// Copy success notification
  final String copySuccessToast;

  /// Revoke success notification
  final String revokeSuccessToast;

  /// Delete success notification
  final String deleteSuccessToast;

  /// Deleted notification
  final String deletedToast;

  /// Forward success notification
  final String forwardSuccessToast;

  /// Network error notification
  final String networkErrorToast;

  /// ========== Confirmation Dialogs ==========

  /// Delete message dialog title
  final String deleteMessageTitle;

  /// Delete message dialog content
  final String deleteMessageContent;

  /// Delete multiple messages dialog title
  final String deleteMessagesTitle;

  /// Delete multiple messages dialog content (%d will be replaced with count)
  final String deleteMessagesContentFormat;

  /// Revoke message dialog title
  final String revokeMessageTitle;

  /// Revoke message dialog content
  final String revokeMessageContent;

  /// Confirm button text
  final String confirmButtonText;

  /// Cancel button text
  final String cancelButtonText;

  /// ========== Multiple Selection Mode ==========

  /// Selected count text (%d will be replaced with count)
  final String selectedCountText;

  /// Select all text
  final String selectAllText;

  /// Deselect all text
  final String deselectAllText;

  /// ========== Forward Related ==========

  /// Forward title
  final String forwardTitle;

  /// Forward separately text
  final String forwardSeparatelyText;

  /// Forward as combined text
  final String forwardCombinedText;

  /// Select conversation title
  final String forwardSelectTitle;

  /// Confirm forward title
  final String forwardConfirmTitle;

  /// Forward to text
  final String forwardToText;

  /// ========== Reply Related ==========

  /// Reply to text (%s will be replaced with username)
  final String replyToText;

  /// Original message deleted text
  final String replyMessageDeletedText;

  /// ========== Conversation Related ==========

  /// Pin text
  final String conversationPinText;

  /// Unpin text
  final String conversationUnpinText;

  /// Delete conversation text
  final String conversationDeleteText;

  /// Mute text
  final String conversationMuteText;

  /// Unmute text
  final String conversationUnmuteText;

  /// ========== Group Chat Related ==========

  /// Group name text
  final String groupNameText;

  /// Group members text
  final String groupMembersText;

  /// Group notice text
  final String groupNoticeText;

  /// Leave group text
  final String groupLeaveText;

  /// Dismiss group text
  final String groupDismissText;

  /// Group details page title and member management labels
  final String groupDetailTitle;
  final String groupAddMemberText;
  final String groupNoMembersText;
  final String groupRetryText;
  final String groupOwnerRoleText;
  final String groupAdminRoleText;
  final String groupMemberRoleText;
  final String groupRemoveMemberText;
  final String groupMakeAdminText;
  final String groupRemoveAdminText;
  final String groupTransferOwnershipText;
  final String groupPickerUnavailableText;

  /// ========== Message Type Display ==========

  /// Image message text
  final String imageMessageText;

  /// Video message text
  final String videoMessageText;

  /// Audio message text
  final String audioMessageText;

  /// File message text
  final String fileMessageText;

  /// Combined message text
  final String combineMessageText;

  /// Custom message text
  final String customMessageText;

  /// Revoked message text
  final String revokeMessageText;

  /// ========== Revoked Message Display ==========

  /// You recalled a message
  final String youRevokedMessage;

  /// Someone recalled a message (%s will be replaced with username)
  final String someoneRevokedMessageFormat;

  /// ========== Conversation Operation Related ==========

  /// Delete conversation dialog title
  final String deleteConversationTitle;

  /// Delete conversation dialog content
  final String deleteConversationContent;

  /// Leave group dialog title
  final String leaveGroupTitle;

  /// Leave group dialog content
  final String leaveGroupContent;

  /// Quit group text
  final String quitGroupText;

  /// OK button text
  final String okButtonText;

  /// ========== Dialog Titles ==========

  /// New chat dialog title
  final String newChatTitle;

  /// New group dialog title
  final String newGroupTitle;

  /// Join group dialog title
  final String joinGroupTitle;

  /// ========== Input Field Labels ==========

  /// User ID input field label
  final String userIdLabel;

  /// Group name input field label
  final String groupNameLabel;

  /// Group ID (optional) input field label
  final String groupIdOptionalLabel;

  /// Group ID input field label
  final String groupIdLabel;

  /// Invite User IDs input field label
  final String inviteUserIdsLabel;

  /// Invite User IDs input field hint
  final String inviteUserIdsHint;

  /// ========== Reply Message Display ==========

  /// Replying to text (%s will be replaced with username)
  final String replyingToFormat;

  /// ========== Error Notifications ==========

  /// Failed to load combined message notification
  final String loadCombineMessageError;

  /// Failed to load message list notification
  final String loadMessageListError;

  /// Message not found notification
  final String messageNotFoundToast;

  /// ========== Video Live Streaming Related ==========

  /// Live tag text
  final String liveText;

  /// ========== Chat Settings Related ==========

  /// Chat settings title
  final String chatSettingsTitle;

  /// Chat pin title
  final String chatPinnedTitle;

  /// Chat do not disturb title
  final String chatNotDisturbTitle;

  /// Pin success notification
  final String pinnedToast;

  /// Unpin success notification
  final String unpinnedToast;

  /// Do not disturb enabled notification
  final String notDisturbEnabledToast;

  /// Do not disturb disabled notification
  final String notDisturbDisabledToast;

  /// Operation failed format (%s will be replaced with error message)
  final String operationFailedFormat;

  /// ========== Time Display ==========

  /// Just now
  final String justNowText;

  /// X minutes ago format (%d will be replaced with minutes)
  final String minutesAgoFormat;

  /// X hours ago format (%d will be replaced with hours)
  final String hoursAgoFormat;

  /// ========== Voice Recording Related ==========

  /// Slide to cancel text
  final String slideToCancelText;

  /// Label shown on the hold-to-talk recording button
  final String holdToTalkText;

  /// Hint shown while holding to send the recording.
  final String releaseToSendText;

  /// Hint shown for the left-swipe cancel gesture.
  final String slideLeftToCancelText;

  /// Hint shown for the upward lock gesture.
  final String slideUpToLockText;

  /// Hint shown when the pointer is over the lock target.
  final String releaseToLockText;

  /// Hint shown while the cancel gesture is active.
  final String releaseToCancelText;

  /// Status shown while a recording is locked.
  final String recordingLockedText;

  /// Status shown while the native recorder is starting.
  final String recordingStartingText;

  /// Short action label that discards the current recording.
  final String discardRecordingText;

  /// Accessible label that explains which recording will be discarded.
  final String discardRecordingLabelText;

  /// Action that sends the current recording.
  final String sendRecordingText;

  /// Accessible label for starting a voice recording.
  final String startVoiceRecordingLabelText;

  /// Accessible instructions for completing an accessible voice recording.
  final String startVoiceRecordingHintText;

  /// Message shown when the native recorder cannot start.
  final String recordingStartFailedText;

  /// ========== More Operation Panel ==========

  /// Take photo text
  final String takePhotoText;

  /// Photo album text
  final String photoText;

  /// File text
  final String fileText;

  /// Configurable input panel labels
  final String voiceInputText;
  final String emojiInputText;
  final String voiceCallInputText;
  final String videoCallInputText;

  /// ========== Badge Related ==========

  /// Maximum badge count text
  final String maxBadgeCountText;

  @override
  String toString() {
    return 'ZIMKitInnerText{'
        'copyMenuText:$copyMenuText, '
        'replyMenuText:$replyMenuText, '
        'forwardMenuText:$forwardMenuText, '
        '... (more properties)'
        '}';
  }
}
