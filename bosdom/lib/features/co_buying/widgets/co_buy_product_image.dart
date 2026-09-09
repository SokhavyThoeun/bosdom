import 'package:flutter/material.dart';

import '../models/co_buy_session.dart';

/// Renders a co-buy session's product photo ([CoBuySession.imageUrl]): a
/// real seller-uploaded photo when one exists, otherwise the curated mock
/// photo. Centralizes the fallback so every screen that shows this photo
/// (marketplace card, seller deal card, detail banner) stays in sync
/// automatically when a seller updates it.
class CoBuyProductImage extends StatelessWidget {
  const CoBuyProductImage({
    super.key,
    required this.session,
    this.fit = BoxFit.cover,
    this.iconSize = 24,
  });

  final CoBuySession session;
  final BoxFit fit;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget fallback(BuildContext context) => Container(
      color: colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Icon(session.icon, color: colorScheme.primary, size: iconSize),
    );

    return Image.network(
      session.imageUrl,
      fit: fit,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : fallback(context),
      errorBuilder: (context, error, stackTrace) => fallback(context),
    );
  }
}
