import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/social_media_footer.dart';
import 'splash_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _walletAddress;
  bool _requireVerification = true;
  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletAddress = prefs.getString('wallet_address') ?? 'Not available';
      _requireVerification = prefs.getBool('require_verification') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _twoFactorEnabled = prefs.getBool('two_factor_enabled') ?? false;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('require_verification', _requireVerification);
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('two_factor_enabled', _twoFactorEnabled);
    await prefs.setString('selected_language', _selectedLanguage);
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Information
                    _buildSection(
                      title: AppConstants.profileSettingsText,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return _buildInfoTile(
                              'Username',
                              authProvider.currentUser ?? 'Not available',
                              Icons.person,
                            );
                          },
                        ),
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return _buildInfoTile(
                              'Email',
                              authProvider.currentEmail ?? 'Not available',
                              Icons.email,
                            );
                          },
                        ),
                        _buildInfoTile(
                          AppConstants.walletAddressText,
                          _walletAddress ?? 'Not available',
                          Icons.account_balance_wallet,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Security Settings
                    _buildSection(
                      title: 'Security',
                      children: [
                        _buildSwitchTile(
                          AppConstants.requireVerificationText,
                          _requireVerification,
                          Icons.security,
                          (value) {
                            setState(() {
                              _requireVerification = value;
                            });
                            _saveSettings();
                          },
                        ),
                        _buildListTile(
                          AppConstants.trustedDevicesText,
                          Icons.devices,
                          () {
                            // Navigate to trusted devices screen
                          },
                        ),
                        _buildListTile(
                          AppConstants.changePasswordText,
                          Icons.lock,
                          _showChangePasswordDialog,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Preferences
                    _buildSection(
                      title: 'Preferences',
                      children: [
                        _buildSwitchTile(
                          AppConstants.notificationSettingsText,
                          _notificationsEnabled,
                          Icons.notifications,
                          (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            _saveSettings();
                          },
                        ),
                        _buildSwitchTile(
                          AppConstants.twoFactorAuthText,
                          _twoFactorEnabled,
                          Icons.verified_user,
                          (value) {
                            setState(() {
                              _twoFactorEnabled = value;
                            });
                            _saveSettings();
                          },
                        ),
                        _buildListTile(
                          AppConstants.languageSelectionText,
                          Icons.language,
                          () {
                            _showLanguageDialog();
                          },
                          trailing: Text(
                            _selectedLanguage,
                            style: const TextStyle(
                              color: AppConstants.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Support
                    _buildSection(
                      title: AppConstants.supportText,
                      children: [
                        _buildListTile(
                          'Contact Support',
                          Icons.support_agent,
                          () {
                            // Open support email
                          },
                          trailing: Text(
                            AppConstants.supportEmail,
                            style: const TextStyle(
                              color: AppConstants.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Logout button
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        AppConstants.logoutText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Social media footer
            const SocialMediaFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppConstants.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppConstants.textColor,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: AppConstants.secondaryTextColor,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppConstants.textColor,
          fontSize: 16,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildListTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppConstants.textColor,
          fontSize: 16,
        ),
      ),
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: AppConstants.secondaryTextColor,
      ),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppConstants.surfaceColor,
        title: Text(
          AppConstants.languageSelectionText,
          style: const TextStyle(
            color: AppConstants.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Spanish', 'French', 'German'].map((language) {
            return ListTile(
              title: Text(
                language,
                style: const TextStyle(
                  color: AppConstants.textColor,
                ),
              ),
              trailing: _selectedLanguage == language
                  ? const Icon(
                      Icons.check,
                      color: AppConstants.primaryColor,
                    )
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = language;
                });
                _saveSettings();
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.passwordsDoNotMatchMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate password change
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppConstants.passwordChangedMessage),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.surfaceColor,
      title: Text(
        AppConstants.changePasswordText,
        style: const TextStyle(
          color: AppConstants.textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _oldPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppConstants.oldPasswordText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppConstants.backgroundColor,
              labelStyle: const TextStyle(color: AppConstants.secondaryTextColor),
            ),
            style: const TextStyle(color: AppConstants.textColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppConstants.newPasswordText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppConstants.backgroundColor,
              labelStyle: const TextStyle(color: AppConstants.secondaryTextColor),
            ),
            style: const TextStyle(color: AppConstants.textColor),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppConstants.confirmNewPasswordText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: AppConstants.backgroundColor,
              labelStyle: const TextStyle(color: AppConstants.secondaryTextColor),
            ),
            style: const TextStyle(color: AppConstants.textColor),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            AppConstants.cancelButtonText,
            style: const TextStyle(color: AppConstants.secondaryTextColor),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(AppConstants.saveButtonText),
        ),
      ],
    );
  }
} 