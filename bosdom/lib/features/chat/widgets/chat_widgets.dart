import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/config/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/conversation.dart';

/// A single chat bubble, styled for either side of the conversation.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.colorScheme,
    required this.textTheme,
    this.avatarUrl,
    this.avatarIcon,
    this.avatarColor,
  });

  final ChatMessage message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  /// Small avatar shown beside the bubble. When [avatarIcon] is null, no
  /// avatar is rendered at all (used by the local scripted support chat,
  /// which has no real participant to show a picture for).
  final String? avatarUrl;
  final IconData? avatarIcon;
  final Color? avatarColor;

  static const double _avatarSize = 28;
  static const double _avatarGap = 8;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMine;
    final icon = avatarIcon;
    final hasAvatar = icon != null;
    final crossAxis = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: message.imageFile != null || message.imageUrl != null
          ? ImageBubble(
              message: message,
              isMe: isMe,
              colorScheme: colorScheme,
              textTheme: textTheme,
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: AppColors.roseDivider.withValues(alpha: 0.6),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.text ?? '',
                style: textTheme.bodyMedium?.copyWith(
                  color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ),
    );

    final bubbleRow = hasAvatar
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: isMe
                ? [
                    Flexible(child: bubble),
                    const SizedBox(width: _avatarGap),
                    _SmallAvatar(
                      url: avatarUrl,
                      icon: icon,
                      color: avatarColor,
                    ),
                  ]
                : [
                    _SmallAvatar(
                      url: avatarUrl,
                      icon: icon,
                      color: avatarColor,
                    ),
                    const SizedBox(width: _avatarGap),
                    Flexible(child: bubble),
                  ],
          )
        : bubble;

    // Timestamp/badge sit below the bubble, indented past the avatar so they
    // line up with the bubble's edge rather than the avatar's.
    final metaIndent = hasAvatar ? _avatarSize + _avatarGap : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: crossAxis,
        children: [
          bubbleRow,
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: !isMe ? metaIndent : 0,
              end: isMe ? metaIndent : 0,
              top: 4,
            ),
            child: Column(
              crossAxisAlignment: crossAxis,
              children: [
                if (message.flagged) ...[
                  FlaggedBadge(textTheme: textTheme),
                  const SizedBox(height: 4),
                ],
                Text(
                  message.sending
                      ? AppLocalizations.of(context).chatMessageSending
                      : message.time,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({this.url, required this.icon, this.color});

  final String? url;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(icon, color: color, size: 14);
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: url != null
            ? Image.network(
                url!,
                width: 28,
                height: 28,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : fallback,
                errorBuilder: (context, error, stackTrace) => fallback,
              )
            : fallback,
      ),
    );
  }
}

class FlaggedBadge extends StatelessWidget {
  const FlaggedBadge({super.key, required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.alertAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 13,
            color: AppColors.alertAmber,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.chatFlaggedBadge,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.alertAmber,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated three-dot "typing…" bubble shown while a reply is pending.
class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(
              color: AppColors.roseDivider.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = (_controller.value + i * 0.2) % 1.0;
                  final offset = -4 * (1 - (2 * t - 1).abs());
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Transform.translate(
                      offset: Offset(0, offset),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.warmTaupe.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ImageBubble extends StatelessWidget {
  const ImageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.colorScheme,
    required this.textTheme,
  });

  final ChatMessage message;
  final bool isMe;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final file = message.imageFile;
    final resolvedUrl = ApiConfig.resolveAvatarUrl(message.imageUrl);
    if (file == null && resolvedUrl == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(16),
        topRight: const Radius.circular(16),
        bottomLeft: Radius.circular(isMe ? 16 : 4),
        bottomRight: Radius.circular(isMe ? 4 : 16),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _openImageViewer(context, file: file, url: resolvedUrl),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: file != null
                ? Image.file(file, fit: BoxFit.cover)
                : Image.network(resolvedUrl!, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context, {File? file, String? url}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
          opacity: animation,
          child: _PhotoViewer(file: file, url: url),
        ),
      ),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  const _PhotoViewer({this.file, this.url});

  final File? file;
  final String? url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: file != null ? Image.file(file!) : Image.network(url!),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.4),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared message composer: photo attach, text field, and send button.
class Composer extends StatelessWidget {
  const Composer({
    super.key,
    required this.controller,
    required this.colorScheme,
    required this.onSend,
    required this.onAttachPhoto,
  });

  final TextEditingController controller;
  final ColorScheme colorScheme;
  final VoidCallback onSend;
  final VoidCallback onAttachPhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ColoredBox(
      color: colorScheme.surface,
      child: SafeArea(
        top: false,
        minimum: EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 10),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CircleIconButton(
                icon: Icons.camera_alt_outlined,
                background: AppColors.blushSurface,
                foreground: colorScheme.primary,
                size: 44,
                iconSize: 20,
                onTap: onAttachPhoto,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.roseDivider.withValues(alpha: 0.6),
                      ),
                    ),
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: l10n.chatComposerHint,
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                        isDense: true,
                        isCollapsed: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return _CircleIconButton(
                    icon: Icons.send_rounded,
                    background: hasText
                        ? colorScheme.primary
                        : AppColors.roseDivider.withValues(alpha: 0.4),
                    foreground: hasText
                        ? colorScheme.onPrimary
                        : AppColors.warmTaupe.withValues(alpha: 0.5),
                    size: 44,
                    onTap: hasText ? onSend : () {},
                    iconSize: 19,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.iconSize = 20,
    this.size = 44,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final double iconSize;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: foreground, size: iconSize),
        ),
      ),
    );
  }
}
