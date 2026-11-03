import 'dart:io';
import 'package:e_commerce_flutter/core/data/data_provider.dart';
import 'package:e_commerce_flutter/utility/snack_bar_helper.dart';
import '../login_screen/login_screen.dart';
import '../my_address_screen/my_address_screen.dart';
import '../../utility/extensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utility/marketplace_design.dart';
import '../../utility/constants.dart';
import '../my_order_screen/my_order_screen.dart';
import '../../widget/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widget/retailer_contact_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _profileImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _deletePasswordController =
      TextEditingController();

  bool _isEditing = false;
  bool _isChangingPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _deletePasswordController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = context.userProvider.getLoginUsr();
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _profileImage = context.profileProvider.profileImagePath != null
        ? File(context.profileProvider.profileImagePath!)
        : null;
  }

  Future<void> _pickImage() async {
    await context.profileProvider.pickProfileImage();
    if (!mounted) return;
    setState(() {
      _profileImage = context.profileProvider.profileImagePath != null
          ? File(context.profileProvider.profileImagePath!)
          : null;
    });
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      SnackBarHelper.showErrorSnackBar(context.l10n.username_required);
      return;
    }

    if (_currentPasswordController.text.isEmpty) {
      SnackBarHelper.showErrorSnackBar(context.l10n.current_password_required);
      return;
    }

    if (_isChangingPassword) {
      if (_newPasswordController.text.isEmpty) {
        SnackBarHelper.showErrorSnackBar(context.l10n.new_password_required);
        return;
      }
      if (_newPasswordController.text != _confirmPasswordController.text) {
        SnackBarHelper.showErrorSnackBar(context.l10n.passwords_do_not_match);
        return;
      }
      if (_newPasswordController.text.length < 6) {
        SnackBarHelper.showErrorSnackBar(context.l10n.password_minimum_length);
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.userProvider.getLoginUsr();
      if (user == null) {
        SnackBarHelper.showErrorSnackBar(context.l10n.user_not_found);
        return;
      }

      final updated = await context.userProvider.updateProfile(
        userId: user.sId!,
        name: _nameController.text,
        currentPassword: _currentPasswordController.text,
        newPassword: _isChangingPassword ? _newPasswordController.text : null,
      );

      if (!mounted || !updated) {
        return;
      }

      setState(() {
        _isEditing = false;
        _isChangingPassword = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      });

      _loadUserData();
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showErrorSnackBar(context.l10n.an_error_occurred);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.userProvider.getLoginUsr();
    context.watch<DataProvider>();
    final dark = MarketPalette.isDark(context);
    final ink = dark ? Colors.white : MarketPalette.ink;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MarketBackdrop(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: () async => _loadUserData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 42),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _isEditing ? _pickImage : null,
                              child: CircleAvatar(
                                radius: 27,
                                backgroundColor: dark
                                    ? MarketPalette.homeSurfaceRaised
                                    : Colors.white.withValues(alpha: .72),
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? Icon(Icons.person_rounded,
                                        color: dark
                                            ? MarketPalette.homeMuted
                                            : MarketPalette.blueDeep,
                                        size: 31)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.name ?? context.l10n.user,
                                      style: TextStyle(
                                          color: ink,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 3),
                                  Text(user?.email ?? '',
                                      style: TextStyle(
                                          color: dark
                                              ? MarketPalette.homeMuted
                                              : MarketPalette.muted,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: context.l10n.profile_preferences_tooltip,
                              onPressed: _showProfilePreferences,
                              icon: Icon(Icons.tune_rounded,
                                  color: dark
                                      ? Colors.white
                                      : MarketPalette.muted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        _profileAction(
                          icon: Icons.edit_outlined,
                          title: context.l10n.edit_profile,
                          onTap: () => setState(() {
                            _isEditing = true;
                            _isChangingPassword = false;
                          }),
                          dark: dark,
                        ),
                        const SizedBox(height: 8),
                        _profileAction(
                          icon: Icons.location_on_outlined,
                          title: context.l10n.delivery_information,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyAddressPage())),
                          dark: dark,
                        ),
                        const SizedBox(height: 8),
                        _profileAction(
                          icon: Icons.lock_outline_rounded,
                          title: context.l10n.change_password,
                          onTap: () => setState(() {
                            _isEditing = true;
                            _isChangingPassword = true;
                          }),
                          dark: dark,
                        ),
                        const SizedBox(height: 8),
                        _profileAction(
                          icon: Icons.receipt_long_outlined,
                          title: context.l10n.my_orders,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyOrderScreen())),
                          dark: dark,
                        ),
                        const SizedBox(height: 8),
                        _profileAction(
                          icon: Icons.privacy_tip_outlined,
                          title: context.l10n.privacy_security,
                          onTap: _openPrivacyPolicy,
                          dark: dark,
                        ),
                        const SizedBox(height: 8),
                        _profileAction(
                          icon: Icons.help_outline_rounded,
                          title: context.l10n.help_support,
                          onTap: _showHelpSupportDialog,
                          dark: dark,
                        ),
                        if (_isEditing) ...[
                          const SizedBox(height: 18),
                          _buildProfileEditor(ink),
                        ],
                        const Spacer(),
                        const SizedBox(height: 38),
                        SizedBox(
                          height: 50,
                          child: TextButton(
                            key: const ValueKey('logout_button'),
                            onPressed: _showLogoutConfirmation,
                            style: TextButton.styleFrom(
                              backgroundColor: (dark
                                  ? MarketPalette.homeSurfaceRaised
                                  : const Color(0x66FFFFFF)),
                              foregroundColor: const Color(0xFFE45A61),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(17)),
                            ),
                            child: Text(context.l10n.logout,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          key: const ValueKey('delete_account_button'),
                          onPressed: _showDeleteAccountConfirmation,
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          label: Text(context.l10n.delete_account),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFE45A61),
                            minimumSize: const Size.fromHeight(44),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool dark,
  }) {
    final ink = dark ? Colors.white : MarketPalette.ink;
    return Material(
      color: dark
          ? MarketPalette.homeSurface.withValues(alpha: .88)
          : Colors.white.withValues(alpha: .58),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
                color: dark
                    ? MarketPalette.homeBorder.withValues(alpha: .7)
                    : Colors.white.withValues(alpha: .78)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                    color: dark
                        ? Colors.white.withValues(alpha: .08)
                        : const Color(0xBFFFFFFF),
                    shape: BoxShape.circle),
                child: Icon(icon,
                    color: dark ? MarketPalette.homeMuted : MarketPalette.muted,
                    size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(title,
                      style: TextStyle(
                          color: ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w600))),
              Icon(Icons.chevron_right_rounded,
                  color:
                      dark ? MarketPalette.homeMuted : const Color(0xFF9CB4D0),
                  size: 23),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAccountConfirmation() async {
    _deletePasswordController.clear();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.delete_account),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dialogContext.l10n.delete_account_confirmation),
            const SizedBox(height: 16),
            TextField(
              controller: _deletePasswordController,
              obscureText: true,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: dialogContext.l10n.current_password,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE45A61),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(dialogContext.l10n.delete_account),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final password = _deletePasswordController.text;
    _deletePasswordController.clear();
    if (password.isEmpty) {
      SnackBarHelper.showErrorSnackBar(context.l10n.current_password_required);
      return;
    }
    await context.userProvider.deleteAccount(password);
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.tryParse(privacyPolicyUrl);
    if (uri == null ||
        !uri.hasAuthority ||
        !{'https', 'http'}.contains(uri.scheme)) {
      SnackBarHelper.showErrorSnackBar(
          context.l10n.privacy_policy_not_configured);
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!opened && mounted) {
      SnackBarHelper.showErrorSnackBar(context.l10n.privacy_policy_open_failed);
    }
  }

  Widget _buildProfileEditor(Color ink) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .68),
          borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          CustomTextField(
              controller: _nameController,
              labelText: context.l10n.username,
              marketStyle: true),
          const SizedBox(height: 10),
          CustomTextField(
              controller: _currentPasswordController,
              labelText: context.l10n.current_password,
              marketStyle: true,
              obscureText: true),
          if (_isChangingPassword) ...[
            const SizedBox(height: 10),
            CustomTextField(
                controller: _newPasswordController,
                labelText: context.l10n.new_password,
                marketStyle: true,
                obscureText: true),
            const SizedBox(height: 10),
            CustomTextField(
                controller: _confirmPasswordController,
                labelText: context.l10n.confirm_new_password,
                marketStyle: true,
                obscureText: true),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              TextButton(
                  onPressed: () => setState(() {
                        _isEditing = false;
                        _isChangingPassword = false;
                        _loadUserData();
                      }),
                  child: Text(context.l10n.cancel)),
              const Spacer(),
              FilledButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: Text(
                      _isLoading ? context.l10n.saving : context.l10n.save)),
            ],
          ),
          Text(context.l10n.profile_change_note,
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: ink.withValues(alpha: .65), fontSize: 11)),
        ],
      ),
    );
  }

  void _showProfilePreferences() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final dark = MarketPalette.isDark(dialogContext);
        return AlertDialog(
          backgroundColor:
              dark ? MarketPalette.homeSurface : const Color(0xFFF2F7FD),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: dark ? MarketPalette.homeBorder : const Color(0xFFDDE8F3),
            ),
          ),
          titleTextStyle: TextStyle(
            color: dark ? Colors.white : MarketPalette.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          title: Text(context.l10n.preferences),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<DataProvider>(
                builder: (context, data, _) => SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(context.l10n.dark_mode),
                  value: data.isDarkMode,
                  onChanged: (_) => data.toggleDarkMode(),
                ),
              ),
              ListTile(
                iconColor: dark ? const Color(0xFF69B5FF) : MarketPalette.blue,
                textColor: dark ? Colors.white : MarketPalette.ink,
                leading: const Icon(Icons.language_rounded),
                title: Text(context.l10n.language),
                subtitle:
                    Text(context.dataProvider.currentLanguage.toUpperCase()),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showLanguageDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpSupportDialog() {
    final dark = MarketPalette.isDark(context);
    final data = context.read<DataProvider>();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor:
            dark ? MarketPalette.homeSurface : const Color(0xFFF2F7FD),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: dark ? MarketPalette.homeBorder : const Color(0xFFDDE8F3),
          ),
        ),
        title: Text(context.l10n.help_support),
        content: RetailerContactList(
          contacts: data.retailerContacts,
          placement: 'support_page',
          loading: data.isRetailerContactsLoading,
          error: data.retailerContactsError,
          onRetry: () {
            data.getRetailerContacts();
            Navigator.pop(dialogContext);
          },
          emptyMessage: context.l10n.support_contact_unavailable,
          onSelected: (uri) {
            _launchSupportUri(uri);
            Navigator.pop(dialogContext);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.close),
          ),
        ],
      ),
    );
  }

  Future<void> _launchSupportUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.could_not_launch_url)),
      );
    }
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final dark = MarketPalette.isDark(context);
            return AlertDialog(
              backgroundColor:
                  dark ? MarketPalette.homeSurface : const Color(0xFFF2F7FD),
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color:
                      dark ? MarketPalette.homeBorder : const Color(0xFFDDE8F3),
                ),
              ),
              titleTextStyle: TextStyle(
                color: dark ? Colors.white : MarketPalette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              title: Text(
                context.l10n.select_language,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageTile(context, 'English', 'en'),
                  _buildLanguageTile(context, 'Amharic', 'am'),
                  _buildLanguageTile(context, 'Spanish', 'es'),
                  _buildLanguageTile(context, 'French', 'fr'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    String languageName,
    String languageCode,
  ) {
    return ListTile(
      title: Text(languageName),
      leading: Icon(
        Icons.language,
        color: MarketPalette.isDark(context)
            ? const Color(0xFF69B5FF)
            : MarketPalette.blue,
      ),
      trailing: context.dataProvider.currentLanguage == languageCode
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        _changeLanguage(context, languageCode);
      },
    );
  }

  void _changeLanguage(BuildContext context, String languageCode) {
    final dataProvider = context.dataProvider;
    dataProvider.changeLanguage(languageCode);
    Get.updateLocale(Locale(languageCode));
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final languageName = switch (languageCode) {
        'am' => 'አማርኛ',
        'es' => 'Español',
        'fr' => 'Français',
        _ => 'English',
      };
      SnackBarHelper.showSuccessSnackBar(
        SnackBarHelper.localized(
          (strings) => strings.language_changed(languageName),
          fallback: 'Language changed to $languageName.',
        ),
      );
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${context.l10n.logout}?'),
          content: Text(context.l10n.logout_confirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.userProvider.logOutUser();
                Get.offAll(() => const LoginScreen());
              },
              child: Text(
                context.l10n.logout,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
