import 'dart:async';

import 'package:flutter/material.dart';

/// Loads [loader] on mount, shows a spinner/error state, and hands the
/// resolved data to [builder] along with a [reload] callback so actions
/// (verify/suspend/takedown/...) can refresh the list after mutating it —
/// every admin list screen wants exactly this shape, so it lives once here.
///
/// With a [refreshInterval] it also re-fetches in the background, keeping
/// the current data on screen until the new data lands — so a queue that
/// other users feed (e.g. seller payout requests) updates without the admin
/// having to reload the page.
class AsyncLoader<T> extends StatefulWidget {
  const AsyncLoader({
    required this.loader,
    required this.builder,
    this.refreshInterval,
    super.key,
  });

  final Future<T> Function() loader;
  final Duration? refreshInterval;
  final Widget Function(BuildContext context, T data, VoidCallback reload)
  builder;

  @override
  State<AsyncLoader<T>> createState() => _AsyncLoaderState<T>();
}

class _AsyncLoaderState<T> extends State<AsyncLoader<T>> {
  late Future<T> _future;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
    final interval = widget.refreshInterval;
    if (interval != null) {
      _timer = Timer.periodic(interval, (_) => _refreshInBackground());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Swaps in fresh data only on success; a failed background poll leaves
  /// the last good data up instead of replacing it with an error.
  Future<void> _refreshInBackground() async {
    try {
      final data = await widget.loader();
      if (!mounted) return;
      setState(() {
        _future = Future.value(data);
      });
    } catch (_) {}
  }

  void _reload() {
    // Block body on purpose: an arrow would return the Future from setState's
    // callback, which Flutter asserts against.
    setState(() {
      _future = widget.loader();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _reload, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }
        return widget.builder(context, snapshot.data as T, _reload);
      },
    );
  }
}
