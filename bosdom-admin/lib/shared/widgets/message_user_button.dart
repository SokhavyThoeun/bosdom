import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/admin_api_client.dart';

/// Opens (creating if needed) the BosDom Support thread with [userId] and
/// jumps to the Support Inbox, so an admin can contact a user directly.
class MessageUserButton extends StatelessWidget {
  const MessageUserButton({
    required this.userId,
    this.label = 'Message',
    super.key,
  });

  final String userId;
  final String label;

  Future<void> _open(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final id = await AdminApiClient.startSupportConversation(userId);
      router.go('/support?conversation=$id');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open conversation: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _open(context),
      icon: const Icon(Icons.chat_bubble_outline, size: 16),
      label: Text(label),
    );
  }
}
