import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/theme_service.dart';
import '../../config/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool notifications = true;
  bool realtimeAlerts = true;
  bool _loadingPrefs = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.bgLight,
      appBar: AppBar(
        title: Text('Pengaturan',
            style: TextStyle(
                color: isDark ? AppTheme.darkText2 : Colors.black,
                fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? AppTheme.darkText2 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loadingPrefs
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _SectionCard(
                  title: 'Profil & Akun',
                  children: [
                    _SettingTile(
                      icon: Icons.person,
                      title: 'Profil',
                      subtitle: 'Kelola data akun dan nomor ponsel',
                      onTap: () => _showInfo('Profil',
                          'Navigasi ke halaman profil akan ditambahkan.'),
                    ),
                    _SettingTile(
                      icon: Icons.lock_outline,
                      title: 'Keamanan',
                      subtitle: 'Ubah kata sandi dan verifikasi',
                      onTap: () => _showInfo(
                          'Keamanan', 'Navigasi ke keamanan akan ditambahkan.'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Preferensi Aplikasi',
                  children: [
                    _SwitchTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark mode',
                      value: darkMode,
                      onChanged: (v) {
                        setState(() => darkMode = v);
                        context.read<ThemeService>().setTheme(v);
                      },
                    ),
                    _SwitchTile(
                      icon: Icons.notifications_none,
                      title: 'Notifikasi',
                      value: notifications,
                      onChanged: (v) => _savePref('notifications', v),
                    ),
                    _SwitchTile(
                      icon: Icons.bolt,
                      title: 'Real-time alert',
                      value: realtimeAlerts,
                      onChanged: (v) => _savePref('realtimeAlerts', v),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Transaksi',
                  children: [
                    _SettingTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Riwayat Pembelian',
                      subtitle: 'Lihat semua pembelian Anda',
                      onTap: () => Navigator.pushNamed(context, '/purchase_history'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: 'Sistem & Bantuan',
                  children: [
                    _SettingTile(
                      icon: Icons.help_outline,
                      title: 'Bantuan',
                      subtitle: 'FAQ dan panduan',
                      onTap: () => _showInfo('Bantuan', 'FAQ akan dibuka.'),
                    ),
                    _SettingTile(
                      icon: Icons.description_outlined,
                      title: 'Kebijakan privasi',
                      subtitle: 'Pelajari bagaimana data digunakan',
                      onTap: () => _showInfo(
                          'Kebijakan Privasi', 'Tautan kebijakan akan dibuka.'),
                    ),
                    _SettingTile(
                      icon: Icons.logout,
                      title: 'Keluar',
                      subtitle: 'Sign out dari akun ini',
                      onTap: _confirmLogout,
                      isDestructive: true,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SupportCard(
                    onChat: () => _showInfo('Support', 'Chat dibuka.')),
              ],
            ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
      notifications = prefs.getBool('notifications') ?? true;
      realtimeAlerts = prefs.getBool('realtimeAlerts') ?? true;
      _loadingPrefs = false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    setState(() {
      if (key == 'darkMode') darkMode = value;
      if (key == 'notifications') notifications = value;
      if (key == 'realtimeAlerts') realtimeAlerts = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _showInfo(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi keluar'),
        content: const Text('Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _logout();
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDestructive
        ? Colors.red
        : (isDark ? AppTheme.darkText2 : AppTheme.darkText);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryGold),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w700, color: color),
      ),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: isDark ? AppTheme.darkText2.withOpacity(0.6) : Colors.black54)),
      trailing: Icon(Icons.chevron_right,
          color: isDark ? AppTheme.darkText2.withOpacity(0.5) : Colors.black38),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryGold),
      ),
      title: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primaryGold,
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.onChat});

  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: isDark
              ? [AppTheme.primaryGold.withOpacity(0.2), AppTheme.darkCard]
              : [AppTheme.primaryGold.withOpacity(0.12), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.headset_mic, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Butuh bantuan cepat?',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkText2 : AppTheme.darkText)),
                const SizedBox(height: 4),
                Text('Hubungi tim support untuk konsultasi energi solar.',
                    style: TextStyle(
                        color: isDark
                            ? AppTheme.darkText2.withOpacity(0.6)
                            : Colors.black54)),
              ],
            ),
          ),
          TextButton(
            onPressed: onChat,
            child: const Text('Chat'),
          ),
        ],
      ),
    );
  }
}
