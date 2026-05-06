// lib/features/generation/presentation/screens/create_template_generation_screen.dart

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/core/jobs/job_model.dart';
import 'package:asilov/core/jobs/job_queue_service.dart';
import 'package:asilov/core/router/app_router.dart';
import 'package:asilov/features/templates/domain/entities/template_entity.dart';
import 'package:asilov/features/templates/presentation/providers/template_provider.dart';
import 'package:asilov/l10n/app_localizations.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class CreateTemplateGenerationScreen extends ConsumerStatefulWidget {
  final String templateUuid;

  const CreateTemplateGenerationScreen({
    super.key,
    required this.templateUuid,
  });

  @override
  ConsumerState<CreateTemplateGenerationScreen> createState() =>
      _CreateTemplateGenerationScreenState();
}

class _CreateTemplateGenerationScreenState
    extends ConsumerState<CreateTemplateGenerationScreen> {
  File? _selectedImage;
  String? _selectedOrientation; // null = opsiyonel, kullanıcı seçmedi
  bool _isSubmitting = false;

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

  Future<void> _submit(TemplateEntity template, AppLocalizations l10n) async {
    if (_selectedImage == null) {
      _showSnack(l10n.photoRequired);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(jobQueueServiceProvider).enqueue(
            type: JobType.templateVideo,
            imagePath: _selectedImage!.path,
            templateId: template.uuid,
            orientation: _selectedOrientation,
          );

      if (mounted) {
        _showSnack(l10n.requestQueued);
        context.go(AppRoutes.myTemplates);
      }
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
    final locale = Localizations.localeOf(context).languageCode;
    final templatesAsync = ref.watch(templateListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          l10n.createRequest,
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
      body: templatesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: AppColors.gold, strokeWidth: 2),
        ),
        error: (e, _) => Center(
          child: Text(
            e.toString().replaceFirst('Exception: ', ''),
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        data: (templates) {
          final template = templates.cast<TemplateEntity?>().firstWhere(
                (t) => t?.uuid == widget.templateUuid,
                orElse: () => null,
              );

          if (template == null) {
            return Center(
              child: Text(
                l10n.noTemplates,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return _buildForm(context, template, l10n, locale);
        },
      ),
    );
  }

  // ─── Form ──────────────────────────────────────────────────────────────────

  Widget _buildForm(
    BuildContext context,
    TemplateEntity template,
    AppLocalizations l10n,
    String locale,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Template Kartı ─────────────────────────────────────────────────
          _TemplateCard(template: template, locale: locale, l10n: l10n),

          const SizedBox(height: 24),

          // ── Fotoğraf Seçimi ────────────────────────────────────────────────
          _SectionLabel(text: l10n.selectPhoto),
          const SizedBox(height: 10),
          _PhotoPicker(
            selectedImage: _selectedImage,
            onTap: _pickImage,
            l10n: l10n,
          ),

          const SizedBox(height: 24),

          // ── Yönlendirme (opsiyonel) ─────────────────────────────────────────
          _SectionLabel(text: l10n.orientationOptional),
          const SizedBox(height: 10),
          _OrientationPicker(
            selected: _selectedOrientation,
            onChanged: (o) => setState(() => _selectedOrientation = o),
            l10n: l10n,
          ),

          const SizedBox(height: 36),

          // ── Gönder Butonu ───────────────────────────────────────────────────
          _SubmitButton(
            isSubmitting: _isSubmitting,
            tokenCost: template.tokenCost,
            onTap: () => _submit(template, l10n),
            l10n: l10n,
          ),
        ],
      ),
    );
  }
}

// ─── Template Kartı ───────────────────────────────────────────────────────────

class _TemplateCard extends StatelessWidget {
  final TemplateEntity template;
  final String locale;
  final AppLocalizations l10n;

  const _TemplateCard({
    required this.template,
    required this.locale,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final title = template.title.localized(locale);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Poster
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(11),
              bottomLeft: Radius.circular(11),
            ),
            child: SizedBox(
              width: 90,
              height: 80,
              child: template.posterUrl != null
                  ? CachedNetworkImage(
                      imageUrl: template.posterUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.background),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.background),
                    )
                  : Container(color: AppColors.background),
            ),
          ),

          // Bilgi
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.toll_outlined,
                          color: AppColors.gold, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        '${template.tokenCost} ${l10n.tokens}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fotoğraf Seçici ──────────────────────────────────────────────────────────

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
        height: 160,
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
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.gold,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.selectPhoto,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
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

// ─── Yönlendirme Seçici ───────────────────────────────────────────────────────

class _OrientationPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;
  final AppLocalizations l10n;

  const _OrientationPicker({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  static const _options = [
    ('portrait', Icons.stay_current_portrait_outlined),
    ('landscape', Icons.stay_current_landscape_outlined),
    ('square', Icons.crop_square_outlined),
  ];

  String _label(String key, AppLocalizations l10n) {
    switch (key) {
      case 'portrait':
        return l10n.portrait;
      case 'landscape':
        return l10n.landscape;
      case 'square':
        return l10n.square;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // "Herhangi" — seçimi sıfırla
        Expanded(
          child: _OrientationChip(
            label: l10n.orientationAny,
            icon: Icons.apps_outlined,
            isSelected: selected == null,
            onTap: () => onChanged(null),
          ),
        ),
        const SizedBox(width: 8),
        ..._options.map((o) {
          final (key, icon) = o;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _OrientationChip(
                label: _label(key, l10n),
                icon: icon,
                isSelected: selected == key,
                onTap: () => onChanged(selected == key ? null : key),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _OrientationChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrientationChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.gold : AppColors.textDisabled,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.gold : AppColors.textDisabled,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Gönder Butonu ────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final int tokenCost;
  final VoidCallback onTap;
  final AppLocalizations l10n;

  const _SubmitButton({
    required this.isSubmitting,
    required this.tokenCost,
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.createRequest,
                      style: const TextStyle(
                        color: AppColors.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.toll_outlined,
                            size: 12,
                            color: AppColors.background,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$tokenCost',
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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