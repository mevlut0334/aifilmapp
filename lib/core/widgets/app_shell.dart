import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asilov/l10n/app_localizations.dart';
import 'package:asilov/core/constants/app_colors.dart';
import 'package:asilov/core/providers/token_provider.dart';
import 'package:asilov/features/auth/presentation/providers/auth_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final int currentIndex;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/my-templates');
      case 2:
        _showCreateBottomSheet();
      case 3:
        context.go('/my-images');
      case 4:
        context.go('/my-videos');
    }
  }

  void _showCreateBottomSheet() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                _CreateOption(
                  icon: Icons.image_outlined,
                  label: l10n.createImage,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/create-image');
                  },
                ),
                const SizedBox(height: 12),
                _CreateOption(
                  icon: Icons.videocam_outlined,
                  label: l10n.createVideo,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/create-video');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final tokenBalance = ref.watch(tokenBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          l10n.appName,
          style: const TextStyle(
            color: AppColors.gold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () => context.go('/packages'),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.toll_outlined,
                      color: AppColors.gold, size: 16),
                  const SizedBox(width: 4),
                  tokenBalance.when(
                    data: (balance) => Text(
                      '$balance',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    loading: () => const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        color: AppColors.gold,
                        strokeWidth: 1.5,
                      ),
                    ),
                    error: (_, __) => const Text(
                      '—',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF2A2A2A), height: 1),
        ),
      ),
      drawer: _AppDrawer(l10n: l10n, authState: authState),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A2A)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.gold,
          unselectedItemColor: AppColors.textDisabled,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.grid_view_outlined),
              activeIcon: const Icon(Icons.grid_view),
              label: l10n.navTemplates,
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, Color(0xFFF5D97A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: AppColors.background,
                  size: 26,
                ),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.image_outlined),
              activeIcon: const Icon(Icons.image),
              label: l10n.navImages,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.videocam_outlined),
              activeIcon: const Icon(Icons.videocam),
              label: l10n.navVideos,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer ───────────────────────────────────────────────────────────────────

class _AppDrawer extends ConsumerWidget {
  final AppLocalizations l10n;
  final AuthState authState;

  const _AppDrawer({required this.l10n, required this.authState});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = authState.user;
    final locale = l10n.localeName; // 'en' veya 'tr'

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.gold,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? '${user.firstName} ${user.lastName}'
                              : l10n.drawerProfile,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user != null)
                          Text(
                            user.email,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.diamond_outlined,
              label: l10n.packages,
              onTap: () {
                Navigator.pop(context);
                context.go('/packages');
              },
            ),
            _DrawerItem(
              icon: Icons.info_outline,
              label: l10n.aboutUs,
              onTap: () {
                Navigator.pop(context);
                _launchUrl('https://asilov.com/$locale/about');
              },
            ),
            _DrawerItem(
              icon: Icons.privacy_tip_outlined,
              label: l10n.consentPrivacy,
              onTap: () {
                Navigator.pop(context);
                _launchUrl('https://asilov.com/$locale/privacy-policy');
              },
            ),
            _DrawerItem(
              icon: Icons.description_outlined,
              label: l10n.consentTerms,
              onTap: () {
                Navigator.pop(context);
                _launchUrl('https://asilov.com/$locale/terms-of-service');
              },
            ),
            _DrawerItem(
              icon: Icons.mail_outline,
              label: l10n.contact,
              onTap: () {
                Navigator.pop(context);
                _launchUrl('https://asilov.com/$locale/contact');
              },
            ),
            const Spacer(),
            const Divider(color: Color(0xFF2A2A2A), height: 1),
            if (user != null)
              _DrawerItem(
                icon: Icons.logout,
                label: l10n.logout,
                color: Colors.redAccent,
                onTap: () {
                  Navigator.pop(context);
                  ref.read(authProvider.notifier).logout();
                },
              )
            else
              _DrawerItem(
                icon: Icons.login,
                label: l10n.loginButton,
                color: AppColors.gold,
                onTap: () {
                  Navigator.pop(context);
                  context.go('/login');
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Drawer Item ──────────────────────────────────────────────────────────────

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: itemColor, size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: itemColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
    );
  }
}

// ─── Create Option ────────────────────────────────────────────────────────────

class _CreateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CreateOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textDisabled),
          ],
        ),
      ),
    );
  }
}