import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_logo_badge.dart';
import '../../../shared/widgets/verified_badge_icon.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_widgets.dart';

/// A real conversation with the BosDom Support team. The thread is a normal
/// backend conversation (see `POST /chat/support`); admins reply from the
/// admin panel, and replies arrive through the same Supabase Realtime
/// subscription as peer-to-peer chat, with a light poll as a fallback.
class LiveChatScreen extends ConsumerStatefulWidget {
  const LiveChatScreen({super.key});

  @override
  ConsumerState<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends ConsumerState<LiveChatScreen> {
  static const _pollInterval = Duration(seconds: 8);

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  Timer? _pollTimer;
  String? _conversationId;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _open());
  }

  Future<void> _open() async {
    setState(() => _loadFailed = false);
    try {
      final id = await ref
          .read(chatProvider.notifier)
          .openSupportConversation();
      if (!mounted) return;
      setState(() => _conversationId = id);
      await ref.read(chatProvider.notifier).markRead(id);
      _pollTimer ??= Timer.periodic(_pollInterval, (_) => _refresh());
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    }
  }

  Future<void> _refresh() async {
    final id = _conversationId;
    if (id == null || !mounted) return;
    final conversation = ref.read(chatProvider.notifier).byId(id);
    // Reloading would drop an in-flight optimistic message.
    if (conversation != null && conversation.messages.any((m) => m.sending)) {
      return;
    }
    try {
      await ref.read(chatProvider.notifier).loadConversation(id);
      if (mounted) await ref.read(chatProvider.notifier).markRead(id);
    } catch (_) {
      // Transient network failure — the next tick retries.
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final id = _conversationId;
    final trimmed = (text ?? _messageController.text).trim();
    if (id == null || trimmed.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    try {
      await ref.read(chatProvider.notifier).sendMessage(id, trimmed);
    } catch (_) {
      if (!mounted) return;
      _messageController.text = trimmed;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatSendError)));
    }
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
    final id = _conversationId;
    if (id == null) return;
    final l10n = AppLocalizations.of(context);
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      await ref.read(chatProvider.notifier).sendImage(id, File(picked.path));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.chatPhotoSendError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    // Watching keeps this rebuilding as Realtime/poll updates land.
    final conversations = ref.watch(chatProvider).value;
    final id = _conversationId;
    Conversation? conversation;
    if (id != null) {
      for (final c in conversations ?? const <Conversation>[]) {
        if (c.id == id) conversation = c;
      }
      if (conversation == null && !_loadFailed) {
        // The inbox was reset (e.g. invalidated) and dropped the thread.
        WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
      }
    }
    final messages = conversation?.messages ?? const <ChatMessage>[];

    if (conversation != null && conversation.unreadCount > 0) {
      // A support reply arrived over Realtime while the screen is open.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(chatProvider.notifier).markRead(conversation!.id),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _LiveChatHeader(colorScheme: colorScheme, textTheme: textTheme),
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
                    child: Container(
                      color: AppColors.petalWhite,
                      child: conversation == null
                          ? Center(
                              child: _loadFailed
                                  ? Column(
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
                                          onPressed: _open,
                                          child: Text(l10n.commonRetry),
                                        ),
                                      ],
                                    )
                                  : const CircularProgressIndicator(),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index];
                                return MessageBubble(
                                  message: message,
                                  colorScheme: colorScheme,
                                  textTheme: textTheme,
                                );
                              },
                            ),
                    ),
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
                          color: colorScheme.primary.withValues(alpha: 0.08),
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
  const _LiveChatHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 8,
          16,
          12,
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
                    child: Icon(
                      Icons.arrow_back,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogoBadge(size: 64),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.liveChatTitle,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const VerifiedBadgeIcon(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.trustGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          l10n.liveChatStatusOnline,
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
