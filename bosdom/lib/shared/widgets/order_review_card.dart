import 'package:flutter/material.dart';

import '../../features/orders/models/order.dart';

/// Read-only display of a buyer's completed-order [OrderReview] — stars,
/// written comment, and any photos — used by both the buyer's and the
/// seller's order detail screens so the review looks identical wherever it
/// shows up (matches [OrderStatusBadge]'s "one shared widget" precedent).
class OrderReviewCard extends StatelessWidget {
  const OrderReviewCard({
    super.key,
    required this.review,
    this.maskName = false,
  });

  final OrderReview review;

  /// Hides the middle of each word of the reviewer's name ("khavy" becomes
  /// "k***y") for public places like the storefront's Reviews tab.
  final bool maskName;

  static String maskReviewerName(String name) => name
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) {
        final chars = word.characters;
        if (chars.length <= 1) return word;
        if (chars.length == 2) return '${chars.first}*';
        return '${chars.first}${'*' * (chars.length - 2)}${chars.last}';
      })
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final buyerName = maskName && review.buyerName != null
        ? maskReviewerName(review.buyerName!)
        : review.buyerName;
    final avatarUrl = review.buyerAvatarUrl;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: (avatarUrl == null || avatarUrl.isEmpty)
                    ? null
                    : NetworkImage(avatarUrl),
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (buyerName != null && buyerName.isNotEmpty)
                      Text(
                        buyerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    _StarRow(rating: review.rating),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review.dateLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.comment,
              style: textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
          if (review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: review.photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => _ReviewPhotoThumbnail(
                  photoUrls: review.photoUrls,
                  index: index,
                  colorScheme: colorScheme,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 16,
            color: Colors.amber.shade700,
          ),
      ],
    );
  }
}

class _ReviewPhotoThumbnail extends StatelessWidget {
  const _ReviewPhotoThumbnail({
    required this.photoUrls,
    required this.index,
    required this.colorScheme,
  });

  final List<String> photoUrls;
  final int index;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final url = photoUrls[index];
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openViewer(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          url,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : ColoredBox(color: colorScheme.primaryContainer),
          errorBuilder: (context, error, stackTrace) => ColoredBox(
            color: colorScheme.primaryContainer,
            child: Icon(
              Icons.broken_image_outlined,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  void _openViewer(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) =>
          _ReviewPhotoViewer(photoUrls: photoUrls, initialIndex: index),
    );
  }
}

class _ReviewPhotoViewer extends StatelessWidget {
  const _ReviewPhotoViewer({
    required this.photoUrls,
    required this.initialIndex,
  });

  final List<String> photoUrls;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          PageView.builder(
            controller: PageController(initialPage: initialIndex),
            itemCount: photoUrls.length,
            itemBuilder: (context, index) => InteractiveViewer(
              child: Image.network(photoUrls[index], fit: BoxFit.contain),
            ),
          ),
          SafeArea(
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
