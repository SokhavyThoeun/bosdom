import 'package:flutter/material.dart';

/// Drop-in replacement for [Image.network] that also renders bundled asset
/// photos (paths starting with `assets/`) — lets mock product/co-buy data
/// point at local sample photos while real backend-sourced photos keep
/// loading over the network, without changing call sites beyond the
/// constructor name.
class AdaptiveNetworkImage extends StatelessWidget {
  const AdaptiveNetworkImage(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final ImageLoadingBuilder? loadingBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: errorBuilder,
      );
    }
    return Image.network(
      url,
      fit: fit,
      width: width,
      height: height,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
    );
  }
}
