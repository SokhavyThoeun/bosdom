import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_logo_badge.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_widgets.dart';

/// Dedicated "Live Chat" screen for the BosDom Support conversation —
/// distinct from the peer-to-peer buyer/seller chat threads.
class LiveChatScreen extends ConsumerStatefulWidget {
  const LiveChatScreen({super.key});

  @override
  ConsumerState<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends ConsumerState<LiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  String? _conversationId;
  bool _startFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startConversation());
  }

  Future<void> _startConversation() async {
    setState(() => _startFailed = false);
    try {
      final conversation = await ref
          .read(chatProvider.notifier)
          .startAdminConversation();
      if (!mounted) return;
      setState(() => _conversationId = conversation.id);
      await ref.read(chatProvider.notifier).loadConversation(conversation.id);
      await ref.read(chatProvider.notifier).markRead(conversation.id);
    } catch (_) {
      if (!mounted) return;
      setState(() => _startFailed = true);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final trimmed = (text ?? _messageController.text).trim();
    final conversationId = _conversationId;
    if (trimmed.isEmpty || conversationId == null) return;
    ref.read(chatProvider.notifier).sendMessage(conversationId, trimmed);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _attachPhoto() async {
    final l10n = AppLocalizations.of(context);
    final conversationId = _conversationId;
    if (conversationId == null) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.chatAttachPhotoCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chatAttachPhotoGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null || !mounted) return;
      await ref
          .read(chatProvider.notifier)
          .sendImage(conversationId, File(picked.path));
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatPhotoAttachmentComingSoon)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final conversationsAsync = ref.watch(chatProvider);
    final conversations = conversationsAsync.value;
    final conversationId = _conversationId;
    final isTyping = conversationId != null
        ? ref.watch(chatTypingProvider(conversationId))
        : false;

    Conversation? conversation;
    for (final c in conversations ?? const <Conversation>[]) {
      if (c.id == conversationId) {
        conversation = c;
        break;
      }
    }

    final loadedConversation = conversation;

    if (loadedConversation == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: _startFailed || conversationsAsync.hasError
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.chatDetailLoadError,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _startConversation,
                        child: Text(l10n.commonRetry),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _LiveChatHeader(
            conversation: loadedConversation,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: Column(
                  children: [
                    Container(
                      color: AppColors.petalWhite,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: _SecurityNoticeBanner(textTheme: textTheme),
                    ),
                    Expanded(
                      child: () {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _scrollToBottom(),
                        );
                        return Container(
                          color: AppColors.petalWhite,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                            itemCount:
                                loadedConversation.messages.length +
                                (isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index ==
                                  loadedConversation.messages.length) {
                                return const TypingBubble();
                              }
                              final message =
                                  loadedConversation.messages[index];
                              return MessageBubble(
                                message: message,
                                colorScheme: colorScheme,
                                textTheme: textTheme,
                              );
                            },
                          ),
                        );
                      }(),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SuggestedTopics(
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            onTopic: _send,
                          ),
                          Composer(
                            controller: _messageController,
                            colorScheme: colorScheme,
                            onSend: _send,
                            onAttachPhoto: _attachPhoto,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const _kLiveChatHeaderContentHeight = 112.0;

class _LiveChatHeader extends StatelessWidget {
  const _LiveChatHeader({
    required this.conversation,
    required this.colorScheme,
    required this.textTheme,
  });

  final Conversation conversation;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 12,
          16,
          16,
        ),
        child: SizedBox(
          height: _kLiveChatHeaderContentHeight,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('helpSupport'),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.commonBack,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (conversation.kind == 'support')
                      const AppLogoBadge(size: 64)
                    else
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white,
                            child: Icon(
                              conversation.avatarIcon,
                              color: conversation.avatarColor,
                              size: 22,
                            ),
                          ),
                          if (conversation.online)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppColors.trustGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          conversation.name,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (conversation.verified) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.trustGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: conversation.online
                                ? AppColors.trustGreen
                                : colorScheme.onPrimary.withValues(
                                    alpha: 0.5,
                                  ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          conversation.online
                              ? l10n.liveChatStatusOnline
                              : l10n.liveChatStatusOffline,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityNoticeBanner extends StatelessWidget {
  const _SecurityNoticeBanner({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.alertAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.alertAmber.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 18, color: AppColors.alertAmber),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.warmTaupe,
                  height: 1.4,
                ),
                children: [
                  TextSpan(
                    text: '${l10n.liveChatSecurityNoticeTitle}: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.alertAmber,
                    ),
                  ),
                  TextSpan(text: l10n.liveChatSecurityNoticeBody),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedTopics extends StatelessWidget {
  const _SuggestedTopics({
    required this.colorScheme,
    required this.textTheme,
    required this.onTopic,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<String> onTopic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final topics = <(IconData, String, String)>[
      (
        Icons.receipt_long_outlined,
        l10n.liveChatTopicOrderStatus,
        l10n.liveChatTopicOrderStatusMessage,
      ),
      (
        Icons.credit_card_outlined,
        l10n.liveChatTopicPaymentIssue,
        l10n.liveChatTopicPaymentIssueMessage,
      ),
      (
        Icons.assignment_return_outlined,
        l10n.liveChatTopicRefundReturn,
        l10n.liveChatTopicRefundReturnMessage,
      ),
      (
        Icons.local_shipping_outlined,
        l10n.liveChatTopicShippingRates,
        l10n.liveChatTopicShippingRatesMessage,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                size: 15,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.liveChatSuggestedTopicsLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: topics.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (icon, label, message) = topics[index];
              return _TopicChip(
                icon: icon,
                label: label,
                colorScheme: colorScheme,
                onTap: () => onTopic(message),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }
}

class _TopicChip extends StatelessWidget {
  const _TopicChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
