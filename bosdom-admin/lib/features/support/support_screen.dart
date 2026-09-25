import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/api/admin_api_client.dart';
import '../../core/config/api_config.dart';
import '../../core/models/admin_models.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/admin_shell.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/photo_viewer.dart';

/// Inbox for the in-app "Live Chat" with BosDom Support: conversations on
/// the left, the selected thread + reply box on the right. Polls the
/// backend so new user messages show up without a manual refresh.
class SupportScreen extends StatefulWidget {
  const SupportScreen({this.initialConversationId, super.key});

  /// Thread to open right away, e.g. when arriving from a "Message" button.
  final String? initialConversationId;

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  static const _pollInterval = Duration(seconds: 5);

  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  Timer? _timer;

  List<AdminSupportConversation> _conversations = const [];
  List<AdminSupportMessage> _messages = const [];
  String? _selectedId;
  String? _error;
  bool _loading = true;
  bool _sending = false;
  String _query = '';
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialConversationId;
    _refresh();
    _timer = Timer.periodic(_pollInterval, (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    try {
      final conversations = await AdminApiClient.fetchSupportConversations();
      final selectedId = _selectedId;
      List<AdminSupportMessage>? messages;
      if (selectedId != null) {
        // Also marks the thread read for the admin side.
        messages = await AdminApiClient.fetchSupportMessages(selectedId);
      }
      if (!mounted) return;
      setState(() {
        _error = null;
        _loading = false;
        _conversations = [
          for (final c in conversations)
            c.id == selectedId && messages != null ? _markRead(c) : c,
        ];
        if (messages != null && selectedId == _selectedId) _messages = messages;
      });
      _scrollIfNewMessages();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  AdminSupportConversation _markRead(AdminSupportConversation c) =>
      AdminSupportConversation(
        id: c.id,
        userId: c.userId,
        userName: c.userName,
        userEmail: c.userEmail,
        userRole: c.userRole,
        unreadCount: 0,
        lastMessagePreview: c.lastMessagePreview,
        lastMessageAt: c.lastMessageAt,
      );

  void _scrollIfNewMessages() {
    if (_messages.length == _lastMessageCount) return;
    _lastMessageCount = _messages.length;
    _scrollToBottom(animate: _messages.length > 1 && _wasAtBottom);
  }

  bool _wasAtBottom = true;

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  /// Photos have no known height until they load, which grows the list after
  /// we've already scrolled; keep following the bottom if the admin was there.
  void _onImageLoaded() {
    if (_wasAtBottom) _scrollToBottom(animate: false);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis == Axis.vertical) {
      _wasAtBottom = n.metrics.extentAfter < 80;
    }
    return false;
  }

  Future<void> _select(String id) async {
    setState(() {
      _selectedId = id;
      _messages = const [];
      _lastMessageCount = 0;
      _wasAtBottom = true;
    });
    await _refresh();
  }

  Future<void> _sendReply() async {
    final id = _selectedId;
    final text = _replyController.text.trim();
    if (id == null || text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await AdminApiClient.replyToSupportConversation(id, text);
      _replyController.clear();
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send reply: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendPhoto() async {
    final id = _selectedId;
    if (id == null || _sending) return;
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _sending = true);
    try {
      await AdminApiClient.replyToSupportConversationWithImage(
        id,
        await picked.readAsBytes(),
        picked.name,
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not send photo: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  AdminSupportConversation? get _selected {
    for (final c in _conversations) {
      if (c.id == _selectedId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminPageHeader(
          title: 'Support Inbox',
          subtitle: 'Live Chat conversations from buyers and sellers',
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null && _conversations.isEmpty
              ? Center(child: Text(_error!))
              : _conversations.isEmpty
              ? const EmptyState(message: 'No support conversations yet.')
              : LayoutBuilder(
                  builder: (context, constraints) {
                    // Too narrow for list + thread side by side: show one
                    // at a time, with a back button on the thread.
                    final narrow = constraints.maxWidth < 760;
                    final gutter = narrow ? 12.0 : 32.0;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(gutter, 0, gutter, gutter),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.roseDivider.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.deepBurgundy.withValues(
                                alpha: 0.06,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: narrow
                              ? (_selectedId == null
                                    ? _buildList()
                                    : _buildThread(showBack: true))
                              : Row(
                                  children: [
                                    SizedBox(
                                      width: constraints.maxWidth < 1000
                                          ? 280
                                          : 340,
                                      child: _buildList(),
                                    ),
                                    const VerticalDivider(width: 1),
                                    Expanded(child: _buildThread()),
                                  ],
                                ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildList() {
    final timeFormat = DateFormat.MMMd().add_jm();
    final q = _query.trim().toLowerCase();
    final visible = q.isEmpty
        ? _conversations
        : [
            for (final c in _conversations)
              if (c.userName.toLowerCase().contains(q) ||
                  c.userEmail.toLowerCase().contains(q) ||
                  c.lastMessagePreview.toLowerCase().contains(q))
                c,
          ];
    final totalUnread = _conversations.fold<int>(
      0,
      (sum, c) => sum + c.unreadCount,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              const Text(
                'Messages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              if (totalUnread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blushSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalUnread new',
                    style: const TextStyle(
                      color: AppColors.brandCrimson,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search conversations',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: AppColors.petalWhite,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.brandCrimson,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? const EmptyState(message: 'No matches', icon: Icons.search_off)
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final c = visible[index];
                    final at = c.lastMessageAt;
                    final selected = c.id == _selectedId;
                    final unread = c.unreadCount > 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Material(
                        color: selected
                            ? AppColors.blushSurface
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          hoverColor: AppColors.petalWhite,
                          onTap: () => _select(c.id),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Avatar(name: c.userName, size: 42),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.userName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: unread
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (at != null)
                                            Text(
                                              timeFormat.format(at.toLocal()),
                                              style: TextStyle(
                                                color: unread
                                                    ? AppColors.brandCrimson
                                                    : AppColors.warmTaupe,
                                                fontSize: 11,
                                                fontWeight: unread
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.lastMessagePreview,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: unread
                                                    ? AppColors.warmBlack
                                                    : AppColors.warmTaupe,
                                                fontSize: 13,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                          if (unread) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              constraints: const BoxConstraints(
                                                minWidth: 20,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.brandCrimson,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${c.unreadCount}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildThread({bool showBack = false}) {
    final selected = _selected;
    if (selected == null) {
      return const ColoredBox(
        color: AppColors.petalWhite,
        child: EmptyState(
          message: 'Select a conversation',
          hint: 'Pick a chat on the left to read and reply.',
          icon: Icons.forum_outlined,
        ),
      );
    }
    final meta = [
      if (selected.userEmail.isNotEmpty) selected.userEmail,
    ].join(' • ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: showBack ? 8 : 20,
            vertical: 14,
          ),
          child: Row(
            children: [
              if (showBack)
                IconButton(
                  tooltip: 'Back to conversations',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => setState(() => _selectedId = null),
                ),
              _Avatar(name: selected.userName, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (meta.isNotEmpty)
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.warmTaupe,
                          fontSize: 12.5,
                        ),
                      ),
                  ],
                ),
              ),
              if (selected.userRole.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blushSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    selected.userRole,
                    style: const TextStyle(
                      color: AppColors.brandCrimson,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ColoredBox(
            color: AppColors.petalWhite,
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  horizontal: showBack ? 12 : 24,
                  vertical: 20,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  final prev = index > 0 ? _messages[index - 1] : null;
                  final newDay =
                      prev == null ||
                      !_sameDay(
                        prev.createdAt.toLocal(),
                        m.createdAt.toLocal(),
                      );
                  return Column(
                    children: [
                      if (newDay) _DayDivider(date: m.createdAt.toLocal()),
                      _MessageBubble(
                        key: ValueKey(m.id),
                        message: m,
                        onImageLoaded: _onImageLoaded,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.roseDivider)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _sending ? null : _sendPhoto,
                tooltip: 'Send a photo',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.petalWhite,
                  minimumSize: const Size(46, 46),
                ),
                icon: const Icon(Icons.image_outlined, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _replyController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendReply(),
                  decoration: InputDecoration(
                    hintText: 'Reply as BosDom Support…',
                    filled: true,
                    fillColor: AppColors.petalWhite,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: AppColors.brandCrimson,
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                onPressed: _sending ? null : _sendReply,
                tooltip: 'Send',
                style: IconButton.styleFrom(
                  minimumSize: const Size(46, 46),
                  backgroundColor: AppColors.brandCrimson,
                ),
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    final initials = parts.isEmpty
        ? '?'
        : parts.take(2).map((p) => p[0].toUpperCase()).join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.roseMist, AppColors.brandCrimson],
        ),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final label = _sameDay(date, now)
        ? 'Today'
        : _sameDay(date, now.subtract(const Duration(days: 1)))
        ? 'Yesterday'
        : DateFormat.MMMd().format(date);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blushSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.warmTaupe,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onImageLoaded,
    super.key,
  });

  final VoidCallback onImageLoaded;

  final AdminSupportMessage message;

  @override
  Widget build(BuildContext context) {
    final fromSupport = message.fromSupport;
    final imageUrl = message.imageUrl;
    const big = Radius.circular(18);
    const small = Radius.circular(4);
    return LayoutBuilder(
      builder: (context, box) {
        // Size against the thread pane, not the whole window, so bubbles
        // stay proportionate when the inbox is narrow.
        final maxWidth = (box.maxWidth * 0.78).clamp(120.0, 480.0);
        final imageSize = (maxWidth - 28).clamp(80.0, 240.0);
        return Align(
          alignment: fromSupport ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              color: fromSupport ? AppColors.brandCrimson : Colors.white,
              border: fromSupport
                  ? null
                  : Border.all(
                      color: AppColors.roseDivider.withValues(alpha: 0.7),
                    ),
              borderRadius: BorderRadius.only(
                topLeft: big,
                topRight: big,
                bottomLeft: fromSupport ? big : small,
                bottomRight: fromSupport ? small : big,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.deepBurgundy.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // IntrinsicWidth: the right-aligned timestamp would otherwise expand
            // every bubble to full width.
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl != null)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: message.text?.isNotEmpty == true ? 8 : 0,
                      ),
                      child: InkWell(
                        onTap: () => showPhotoViewer(
                          context,
                          ApiConfig.mediaUrl(imageUrl),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            ApiConfig.mediaUrl(imageUrl),
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.cover,
                            frameBuilder: (_, child, frame, sync) {
                              if (frame != null && !sync) {
                                WidgetsBinding.instance.addPostFrameCallback(
                                  (_) => onImageLoaded(),
                                );
                              }
                              return child;
                            },
                            errorBuilder: (_, _, _) => Text(
                              '📷 Photo',
                              style: TextStyle(
                                color: fromSupport
                                    ? Colors.white
                                    : AppColors.warmBlack,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (message.text != null && message.text!.isNotEmpty)
                    Text(
                      message.text!,
                      style: TextStyle(
                        color: fromSupport ? Colors.white : AppColors.warmBlack,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormat.jm().format(message.createdAt.toLocal()),
                      style: TextStyle(
                        fontSize: 10.5,
                        color: fromSupport
                            ? Colors.white70
                            : AppColors.warmTaupe,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
