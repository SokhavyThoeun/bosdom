import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/conversation.dart';
import '../providers/chat_provider.dart';
import '../utils/off_platform_detector.dart';
import '../widgets/chat_widgets.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  const ChatDetailScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  bool _draftLooksOffPlatform = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(chatProvider.notifier)
          .loadConversation(widget.conversationId);
      await ref.read(chatProvider.notifier).markRead(widget.conversationId);
    });
    _messageController.addListener(_onDraftChanged);
  }

  void _onDraftChanged() {
    final looksOffPlatform = detectsOffPlatformAttempt(_messageController.text);
    if (looksOffPlatform != _draftLooksOffPlatform) {
      setState(() => _draftLooksOffPlatform = looksOffPlatform);
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onDraftChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(widget.conversationId, text);
    _messageController.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
      await ref
          .read(chatProvider.notifier)
          .sendImage(widget.conversationId, File(picked.path));
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chatPhotoAttachmentComingSoon)),
      );
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final conversationsAsync = ref.watch(chatProvider);
    final conversations = conversationsAsync.value;
    final isTyping = ref.watch(chatTypingProvider(widget.conversationId));
    Conversation? conversation;
    for (final c in conversations ?? const <Conversation>[]) {
      if (c.id == widget.conversationId) {
        conversation = c;
        break;
      }
    }

    final loadedConversation = conversation;
    if (loadedConversation == null) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: conversationsAsync.hasError
              ? Center(
                  child: Text(
                    l10n.chatDetailLoadError,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _Header(
            conversation: loadedConversation,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: _PolicyBanner(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      itemCount:
                          loadedConversation.messages.length +
                          (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == loadedConversation.messages.length) {
                          return const TypingBubble();
                        }
                        final message = loadedConversation.messages[index];
                        return MessageBubble(
                          message: message,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        );
                      },
                    ),
                  ),
                  _OffPlatformWarningBanner(visible: _draftLooksOffPlatform),
                  Composer(
                    controller: _messageController,
                    colorScheme: colorScheme,
                    onSend: _send,
                    onAttachPhoto: _attachPhoto,
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

const _kHeaderContentHeight = 96.0;

class _Header extends StatelessWidget {
  const _Header({
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
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          MediaQuery.of(context).padding.top + 12,
          16,
          16,
        ),
        child: SizedBox(
          height: _kHeaderContentHeight,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('chatList'),
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
                                : colorScheme.onPrimary.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          conversation.online
                              ? l10n.chatStatusOnline
                              : l10n.chatStatusOffline,
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

class _PolicyBanner extends StatefulWidget {
  const _PolicyBanner({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  State<_PolicyBanner> createState() => _PolicyBannerState();
}

class _OffPlatformWarningBanner extends StatelessWidget {
  const _OffPlatformWarningBanner({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: !visible
          ? const SizedBox(width: double.infinity)
          : Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.alertAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.alertAmber.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AppColors.alertAmber,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).chatOffPlatformWarning,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.warmTaupe,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PolicyBannerState extends State<_PolicyBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = widget.textTheme;
    final l10n = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.infoBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.infoBlue.withValues(alpha: 0.18)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: AppColors.infoBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.chatPolicySecurePayTitle,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.infoBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.infoBlue.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Padding(
                  padding: const EdgeInsets.only(top: 6, left: 24),
                  child: Text(
                    l10n.chatPolicyBannerBody,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.warmTaupe,
                      height: 1.4,
                    ),
                  ),
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
