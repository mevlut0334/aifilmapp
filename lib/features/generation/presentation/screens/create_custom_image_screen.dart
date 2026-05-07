// lib/features/generation/presentation/screens/create_custom_image_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/core/router/app_router.dart';
import 'package:asilov/features/generation/presentation/providers/generation_provider.dart';
import 'package:asilov/l10n/app_localizations.dart';
import 'package:asilov/core/utils/result.dart';

class CreateCustomImageScreen extends ConsumerStatefulWidget {
  const CreateCustomImageScreen({super.key});

  @override
  ConsumerState<CreateCustomImageScreen> createState() =>
      _CreateCustomImageScreenState();
}

class _CreateCustomImageScreenState
    extends ConsumerState<CreateCustomImageScreen> {
  final _descriptionController = TextEditingController();
  String _selectedOrientation = 'portrait';
  File? _selectedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Fotoğraf Seçimi ───────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked != null && mounted) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // ─── Gönderme ──────────────────────────────────────────────────────────────

  Future<void> _submit(AppLocalizations l10n) async {
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnack(l10n.descriptionRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ref
          .read(generationRepositoryProvider)
          .createCustomImageGeneration(
            orientation: _selectedOrientation,
            description: description,
            imagePath: _selectedImage?.path,
          );

      result.when(
        success: (_) {
          if (mounted) {
            _showSnack(l10n.requestQueued);
            context.go(AppRoutes.myImages);
          }
        },
        failure: (message, __) {
          if (mounted) {
            _showSnack(message);
            setState(() => _isSubmitting = false);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          l10n.createImage,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Açıklama ───────────────────────────────────────────────────
            _SectionLabel(text: l10n.descriptionLabel),
            const SizedBox(height: 10),
            _DescriptionField(controller: _descriptionController, l10n: l10n),

            const SizedBox(height: 24),

            // ── Yön Seçimi ─────────────────────────────────────────────────
            _SectionLabel(text: l10n.orientationLabel),
            const SizedBox(height: 10),
            _OrientationSelector(
              selected: _selectedOrientation,
              onChanged: (v) => setState(() => _selectedOrientation = v),
              l10n: l10n,
            ),

            const SizedBox(height: 24),

            // ── Referans Fotoğraf ──────────────────────────────────────────
            _SectionLabel(text: l10n.referencePhotoOptional),
            const SizedBox(height: 10),
            _PhotoPicker(
              selectedImage: _selectedImage,
              onTap: _pickImage,
              l10n: l10n,
            ),

            const SizedBox(height: 36),

            // ── Gönder Butonu ──────────────────────────────────────────────
            _SubmitButton(
              isSubmitting: _isSubmitting,
              onTap: () => _submit(l10n),
              l10n: l10n,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Description Field ────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;

  const _DescriptionField({
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        maxLength: 1000,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: l10n.descriptionHint,
          hintStyle: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 14,
          ),
          contentPadding: const EdgeInsets.all(14),
          border: InputBorder.none,
          counterStyle: const TextStyle(
            color: AppColors.textDisabled,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

// ─── Orientation Selector ─────────────────────────────────────────────────────

class _OrientationSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  const _OrientationSelector({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      ('portrait',  l10n.portrait,  Icons.crop_portrait_outlined),
      ('landscape', l10n.landscape, Icons.crop_landscape_outlined),
      ('square',    l10n.square,    Icons.crop_square_outlined),
    ];

    return Row(
      children: options.map((opt) {
        final (value, label, icon) = opt;
        final isSelected = selected == value;

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold.withValues(alpha: 0.12)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gold
                      : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? AppColors.gold
                        : AppColors.textDisabled,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.gold
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Photo Picker ─────────────────────────────────────────────────────────────

class _PhotoPicker extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _PhotoPicker({
    required this.selectedImage,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedImage != null
                ? AppColors.gold.withValues(alpha: 0.5)
                : AppColors.border,
            width: selectedImage != null ? 1.5 : 1,
          ),
        ),
        child: selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(selectedImage!, fit: BoxFit.cover),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.changePhoto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.gold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.selectPhoto,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'JPEG / PNG · max 10 MB',
                    style: TextStyle(
                      color: AppColors.textDisabled,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─── Submit Button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _SubmitButton({
    required this.isSubmitting,
    required this.onTap,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          gradient: isSubmitting
              ? null
              : const LinearGradient(
                  colors: [AppColors.gold, Color(0xFFF5D97A)],
                ),
          color: isSubmitting ? AppColors.surface : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSubmitting
              ? null
              : [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.gold,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  l10n.createRequest,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}