// lib/features/auth/presentation/screens/register_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asilov/l10n/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  String? _selectedCountryCode;
  List<Map<String, dynamic>> _countries = [];
  bool _countriesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final String jsonString =
        await rootBundle.loadString('assets/data/countries.json');
    final List<dynamic> data = json.decode(jsonString);
    setState(() {
      _countries = data.cast<Map<String, dynamic>>();
      _countriesLoading = false;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          countryCode: _selectedCountryCode!,
          password: _passwordController.text,
          passwordConfirmation: _passwordConfirmController.text,
        );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final lang = Localizations.localeOf(context).languageCode;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Logo / Başlık ──────────────────────────────────────────
                Text(
                  l10n.appName,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.registerSubtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // ── Form Kartı ─────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Başlık ────────────────────────────────────────
                        Text(
                          l10n.createAccount,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Ad & Soyad (yan yana) ─────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(l10n.firstName),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _firstNameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary),
                                    decoration: _inputDecoration(
                                      hint: l10n.firstNameHint,
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return l10n.firstNameRequired;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(l10n.lastName),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _lastNameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary),
                                    decoration: _inputDecoration(
                                      hint: l10n.lastNameHint,
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return l10n.lastNameRequired;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── E-posta ───────────────────────────────────────
                        _buildLabel(l10n.email),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l10n.emailHint,
                            prefixIcon: Icons.email_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return l10n.emailRequired;
                            }
                            if (!v.contains('@')) {
                              return l10n.emailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Ülke Kodu & Telefon (yan yana) ────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ülke Kodu
                            SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(l10n.countryCode),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedCountryCode,
                                    isExpanded: true,
                                    dropdownColor: const Color(0xFF1A1A1A),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: AppColors.textDisabled,
                                      size: 18,
                                    ),
                                    decoration: _inputDecoration(
                                      hint: '+--',
                                      prefixIcon: Icons.flag_outlined,
                                    ),
                                    // SONRA — ülke adı + numara gösteriyor
                                    selectedItemBuilder: (context) => _countries
                                        .map(
                                          (c) => Text(
                                            c['dial_code']
                                                as String, // seçili halde dar alanda sadece +90
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )
                                        .toList(),
                                    items: _countriesLoading
                                        ? []
                                        : _countries
                                            .map(
                                              (c) => DropdownMenuItem<String>(
                                                value: c['dial_code'] as String,
                                                child: Text(
                                                  '${c['name']} (${c['dial_code']})', // ← Afghanistan (+93)
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (v) => setState(
                                        () => _selectedCountryCode = v),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return l10n.required;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Telefon
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel(l10n.phone),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(
                                        color: AppColors.textPrimary),
                                    decoration: _inputDecoration(
                                      hint: l10n.phoneHint,
                                      prefixIcon: Icons.phone_outlined,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return l10n.phoneRequired;
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── Şifre ─────────────────────────────────────────
                        _buildLabel(l10n.password),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l10n.passwordHint,
                            prefixIcon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textDisabled,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return l10n.passwordRequired;
                            }
                            if (v.length < 8) {
                              return l10n.passwordMinLength;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // ── Şifre Tekrar ───────────────────────────────────
                        _buildLabel(l10n.passwordConfirm),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordConfirmController,
                          obscureText: _obscurePasswordConfirm,
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: _inputDecoration(
                            hint: l10n.passwordHint,
                            prefixIcon: Icons.lock_outline,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePasswordConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textDisabled,
                                size: 20,
                              ),
                              onPressed: () => setState(() =>
                                  _obscurePasswordConfirm =
                                      !_obscurePasswordConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return l10n.passwordConfirmRequired;
                            }
                            if (v != _passwordController.text) {
                              return l10n.passwordConfirmMismatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // ── Consent Metni ──────────────────────────────────
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              color: AppColors.textDisabled,
                              fontSize: 12,
                              height: 1.6,
                            ),
                            children: [
                              TextSpan(text: '${l10n.consentText} '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _launchUrl(
                                    'https://asilov.com/$lang/terms-of-service',
                                  ),
                                  child: Text(
                                    l10n.consentTerms,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      height: 1.6,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(text: ' ${l10n.consentAnd} '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _launchUrl(
                                    'https://asilov.com/$lang/privacy-policy',
                                  ),
                                  child: Text(
                                    l10n.consentPrivacy,
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontSize: 12,
                                      height: 1.6,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(text: l10n.consentEnd),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ── Kayıt Ol Butonu ────────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.background,
                              disabledBackgroundColor:
                                  AppColors.gold.withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: AppColors.background,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    l10n.registerButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Giriş Yap Linki ────────────────────────────────────────
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${l10n.haveAccount} ',
                      style: const TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 13,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRoutes.login);
                      },
                      child: Text(
                        l10n.loginTitle,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: AppColors.textDisabled, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
