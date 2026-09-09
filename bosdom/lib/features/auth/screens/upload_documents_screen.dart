import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../profile/services/profile_service.dart';
import '../models/merchant_role.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({
    required this.role,
    this.standalone = false,
    super.key,
  });

  final MerchantRole role;

  /// True when reached from the profile's "Become a Seller" card rather
  /// than the account signup wizard — shortens the step counter to this
  /// flow's own 2 steps and always pops back to the profile screen.
  final bool standalone;

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  static const _nationalId = 'national_id';
  static const _passport = 'passport';
  static const _businessCertificate = 'business_certificate';

  final _picker = ImagePicker();
  bool _nationalIdUploaded = false;
  bool _passportUploaded = false;
  bool _businessCertUploaded = false;
  String? _uploadingDocType;

  Future<void> _pickAndUpload(String docType) async {
    if (_uploadingDocType != null) return;
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (picked == null || !mounted) return;
      setState(() => _uploadingDocType = docType);
      await ProfileService.uploadKycDocument(
        docType: docType,
        file: File(picked.path),
      );
      if (!mounted) return;
      setState(() {
        switch (docType) {
          case _nationalId:
            _nationalIdUploaded = true;
          case _passport:
            _passportUploaded = true;
          case _businessCertificate:
            _businessCertUploaded = true;
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $error')));
    } finally {
      if (mounted) setState(() => _uploadingDocType = null);
    }
  }

  void _goBack() {
    if (widget.standalone) {
      context.pop();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed('personalDetails', extra: widget.role);
    }
  }

  void _continue() {
    if (!_nationalIdUploaded) return;
    context.pushNamed(
      widget.standalone ? 'becomeSellerBusinessInfo' : 'businessInfo',
      extra: widget.role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          _Header(
            colorScheme: colorScheme,
            textTheme: textTheme,
            currentStep: widget.standalone ? 1 : 3,
            totalSteps: widget.standalone ? 2 : widget.role.totalSteps,
            onBack: _goBack,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _IdentityBanner(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 20),
                    _DocumentCard(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      icon: Icons.credit_card_outlined,
                      title: 'National ID Card',
                      required: true,
                      subtitle: 'Front and back of your Cambodian National ID',
                      uploaded: _nationalIdUploaded,
                      uploading: _uploadingDocType == _nationalId,
                      onTap: () => _pickAndUpload(_nationalId),
                    ),
                    const SizedBox(height: 16),
                    _DocumentCard(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      icon: Icons.badge_outlined,
                      title: 'Passport',
                      optional: true,
                      subtitle: 'Alternative to National ID (optional)',
                      uploaded: _passportUploaded,
                      uploading: _uploadingDocType == _passport,
                      onTap: () => _pickAndUpload(_passport),
                    ),
                    const SizedBox(height: 16),
                    _DocumentCard(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      icon: Icons.description_outlined,
                      title: 'Business Certificate',
                      optional: true,
                      subtitle:
                          'MOC registration certificate (optional but speeds up verification)',
                      uploaded: _businessCertUploaded,
                      uploading: _uploadingDocType == _businessCertificate,
                      onTap: () => _pickAndUpload(_businessCertificate),
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _nationalIdUploaded ? _continue : null,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.colorScheme,
    required this.textTheme,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 16,
          24,
          24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onBack,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, color: colorScheme.onPrimary),
                    Text(
                      'Back',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload Documents',
              style: textTheme.headlineMedium?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Step $currentStep of $totalSteps',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(totalSteps, (index) {
                return Expanded(
                  child: Container(
                    height: 6,
                    margin: EdgeInsets.only(
                      right: index == totalSteps - 1 ? 0 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: index < currentStep
                          ? colorScheme.onPrimary
                          : colorScheme.onPrimary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityBanner extends StatelessWidget {
  const _IdentityBanner({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identity Verification',
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload your ID for identity on file. Your Seller badge '
                  'activates immediately no admin confirmation needed.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
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

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.colorScheme,
    required this.textTheme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.uploaded,
    required this.onTap,
    this.uploading = false,
    this.required = false,
    this.optional = false,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool uploaded;
  final VoidCallback onTap;
  final bool uploading;
  final bool required;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: title),
                          if (required)
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: colorScheme.error),
                            ),
                          if (optional)
                            TextSpan(
                              text: ' (optional)',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: uploading
                ? const OutlinedButton(
                    onPressed: null,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : uploaded
                ? FilledButton.icon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.tertiary,
                    ),
                    icon: const Icon(Icons.check_circle, size: 18),
                    label: const Text('Uploaded'),
                  )
                : OutlinedButton.icon(
                    onPressed: onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                    ),
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Tap to Upload'),
                  ),
          ),
        ],
      ),
    );
  }
}
