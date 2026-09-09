import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_logo_badge.dart';
import '../models/conversation.dart';
import '../widgets/chat_widgets.dart';

/// A scripted "BosDom Support" concierge — kept fully local (no backend
/// conversation) since the real chat backend (Phase 14) has no notion of a
/// support-agent account for the buyer/seller to converse with. Inventing
/// one server-side was explicitly out of scope for wiring real peer-to-peer
/// chat, so this stays a canned FAQ-style assistant instead.
class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  int _nextLocalId = 0;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _supportMessage(
        "Hi! I'm the BosDom Support concierge. Pick a topic below or type "
        'your question and our team will follow up.',
      ),
    );
  }

  ChatMessage _localMessage({
    required bool isMine,
    String? text,
    File? imageFile,
  }) {
    return ChatMessage(
      id: 'local-${_nextLocalId++}',
      senderId: isMine ? 'me' : 'support',
      isMine: isMine,
      createdAt: DateTime.now(),
      text: text,
      imageFile: imageFile,
    );
  }

  ChatMessage _supportMessage(String text) =>
      _localMessage(isMine: false, text: text);

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final trimmed = (text ?? _messageController.text).trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _messages.add(_localMessage(isMine: true, text: trimmed));
      _isTyping = true;
    });
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(
          _supportMessage(
            "Thanks for reaching out — our team will follow up shortly. "
            "In the meantime, only pay through Bosdom Secure Pay.",
          ),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });
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
      setState(() {
        _messages.add(
          _localMessage(isMine: true, imageFile: File(picked.path)),
        );
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatPhotoAttachmentComingSoon)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length) {
                            return const TypingBubble();
                          }
                          final message = _messages[index];
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
