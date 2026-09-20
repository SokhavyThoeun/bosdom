import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class EscrowScreen extends StatelessWidget {
  const EscrowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.escrowScreenTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.escrowPlaceholderText, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
