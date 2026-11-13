import 'dart:ui' show ImageFilter;

import 'package:e_commerce_flutter/utility/extensions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../utility/marketplace_design.dart';
import '../../utility/snack_bar_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _loadingMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _registrationAttempted = false;
  String? _registrationError;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_refreshRegistrationHints);
    _confirmPasswordController.addListener(_refreshRegistrationHints);
    _emailController.addListener(_refreshRegistrationHints);
  }

  void _refreshRegistrationHints() {
    if (mounted && !_isLogin) setState(() {});
  }

  bool _validEmail(String email) => RegExp(
        r"^[A-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+[A-Z]{2,63}$",
        caseSensitive: false,
      ).hasMatch(email.trim());

  List<(String, bool)> get _passwordChecks {
    final password = _passwordController.text;
    return [
      (
        context.l10n.eight_characters_count('${password.length}'),
        password.length >= 8
      ),
      (
        context.l10n.uppercase_and_lowercase,
        RegExp(r'[A-Z]').hasMatch(password) &&
            RegExp(r'[a-z]').hasMatch(password)
      ),
      (context.l10n.number_requirement, RegExp(r'\d').hasMatch(password)),
      (
        context.l10n.special_character_requirement,
        RegExp(r'[^A-Za-z0-9]').hasMatch(password)
      ),
    ];
  }

  bool get _passwordIsValid => _passwordChecks.every((check) => check.$2);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!_isLogin) {
      setState(() => _registrationAttempted = true);
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userProvider = context.userProvider;
    setState(() {
      _isLoading = true;
      _registrationError = null;
      _loginError = null;
      _loadingMessage =
          _isLogin ? context.l10n.signing_in : context.l10n.creating_account;
    });

    try {
      if (_isLogin) {
        await userProvider.loginUser(
          _usernameController.text,
          _passwordController.text,
        );
      } else {
        await userProvider.registerUser(
          _usernameController.text,
          _emailController.text,
          _passwordController.text,
        );
      }
    } catch (error) {
      if (mounted) {
        final message = SnackBarHelper.toUserFriendlyMessage(error.toString());
        setState(() {
          if (_isLogin) {
            _loginError = message;
          } else {
            _registrationError = message;
          }
        });
        if (_isLogin) SnackBarHelper.showErrorSnackBar(message);
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingMessage = null;
      });
    }
  }

  void _switchMode() {
    if (_isLoading) return;
    setState(() {
      // Recreate field validation state when changing modes while the external
      // controllers preserve anything the user has already typed.
      _formKey = GlobalKey<FormState>();
      _isLogin = !_isLogin;
      _registrationAttempted = false;
      _registrationError = null;
      _loginError = null;
    });
  }

  Widget _buildPasswordHint() {
    final remaining = _passwordChecks
        .where((check) => !check.$2)
        .map((check) => check.$1)
        .toList();
    if (remaining.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        remaining.join(', '),
        style: TextStyle(
          fontSize: 12,
          color: _registrationAttempted
              ? MarketPalette.error
              : MarketPalette.muted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFEAF1FA),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
            _isLogin ? const Color(0xFFEAF2FC) : const Color(0xFFE6EEF8),
        resizeToAvoidBottomInset: true,
        body: _AuthBackdrop(
          login: _isLogin,
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight * 0.96,
                      ),
                      child: MarketGlassCard(
                        radius: 26,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 14),
                        flat: true,
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!_isLogin)
                                Transform.translate(
                                  offset: const Offset(-9, 0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints:
                                          const BoxConstraints.tightFor(
                                              width: 40, height: 36),
                                      onPressed: _switchMode,
                                      icon: const Icon(Icons.chevron_left,
                                          color: MarketPalette.muted, size: 27),
                                    ),
                                  ),
                                ),
                              if (_isLogin) const SizedBox(height: 20),
                              if (_loginError != null) ...[
                                _AuthMessage(
                                    message: _loginError!, error: true),
                                const SizedBox(height: 12),
                              ],
                              SizedBox(
                                height: _isLogin ? 132 : 108,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      top: _isLogin ? 0 : -73,
                                      right: _isLogin ? -8 : -10,
                                      child: _AuthPhoneArtwork(
                                        register: !_isLogin,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: _isLogin ? 14 : 4),
                              // Title
                              Text(
                                _isLogin
                                    ? context.l10n.welcome_title
                                    : context.l10n.create_account,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: _isLogin ? 25 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: MarketPalette.ink,
                                ),
                              ),
                              SizedBox(height: _isLogin ? 10 : 8),
                              Text(
                                _isLogin
                                    ? context.l10n.sign_in_to_continue
                                    : context.l10n.join_and_shop,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: _isLogin ? 14 : 12,
                                  color: MarketPalette.muted,
                                ),
                              ),
                              SizedBox(height: _isLogin ? 20 : 24),
                              if (_registrationError != null) ...[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0x22BA2F4A),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 19,
                                        color: MarketPalette.error,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _registrationError!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.35,
                                            color: MarketPalette.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              ...[
                                // Username field
                                TextFormField(
                                  controller: _usernameController,
                                  style: const TextStyle(fontSize: 14),
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: _isLogin
                                        ? context.l10n.email_or_username
                                        : context.l10n.username,
                                    hintText: null,
                                    hintStyle: const TextStyle(fontSize: 14),
                                    labelStyle: const TextStyle(fontSize: 14),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    floatingLabelStyle: const TextStyle(
                                      color: MarketPalette.muted,
                                      fontSize: 12,
                                    ),
                                    prefixIcon: Icon(
                                      _isLogin
                                          ? Icons.mail_outline
                                          : Icons.person_outline,
                                      size: 19,
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 42, minHeight: 50),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F5FC),
                                    isDense: false,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: _isLogin ? 10 : 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDCE8F5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDCE8F5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.blue,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.error,
                                        width: 1,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.error,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    final username = value?.trim() ?? '';
                                    if (username.isEmpty) {
                                      return context.l10n.enter_a_username;
                                    }
                                    if (!_isLogin && username.length < 3) {
                                      return context.l10n.username_min_length;
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: _isLogin ? 24 : 18),
                              ],

                              // Email field (only for register)
                              if (!_isLogin) ...[
                                TextFormField(
                                  controller: _emailController,
                                  style: const TextStyle(fontSize: 14),
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: context.l10n.email_address,
                                    hintText: null,
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    floatingLabelStyle: const TextStyle(
                                      color: MarketPalette.muted,
                                      fontSize: 12,
                                    ),
                                    helperText: _emailController.text.isEmpty ||
                                            _validEmail(_emailController.text)
                                        ? null
                                        : context.l10n.email_format_hint(
                                            context.l10n.email_example,
                                          ),
                                    helperStyle: TextStyle(
                                      color: _registrationAttempted
                                          ? MarketPalette.error
                                          : MarketPalette.muted,
                                      fontSize: 12,
                                    ),
                                    hintStyle: const TextStyle(fontSize: 14),
                                    labelStyle: const TextStyle(fontSize: 14),
                                    prefixIcon: const Icon(Icons.mail_outline,
                                        size: 19),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 42, minHeight: 50),
                                    filled: true,
                                    fillColor: const Color(0xFFF0F5FC),
                                    isDense: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDCE8F5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDCE8F5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.blue,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.error,
                                        width: 1,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.error,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    final email = value?.trim() ?? '';
                                    if (email.isEmpty) {
                                      return _registrationAttempted
                                          ? context.l10n.enter_email_address
                                          : null;
                                    }
                                    if (!_validEmail(email) &&
                                        _registrationAttempted) {
                                      return context.l10n.invalid_email_format(
                                        context.l10n.email_example,
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 18),
                              ],

                              // Password field with visibility toggle
                              ...[
                                TextFormField(
                                  controller: _passwordController,
                                  style: const TextStyle(fontSize: 14),
                                  obscureText: _obscurePassword,
                                  textInputAction: _isLogin
                                      ? TextInputAction.done
                                      : TextInputAction.next,
                                  onFieldSubmitted: (_) => _isLogin
                                      ? _submit()
                                      : FocusScope.of(context).nextFocus(),
                                  decoration: InputDecoration(
                                    labelText: context.l10n.password_label,
                                    hintText: null,
                                    hintStyle: const TextStyle(fontSize: 14),
                                    labelStyle: const TextStyle(fontSize: 14),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.auto,
                                    floatingLabelStyle: const TextStyle(
                                      color: MarketPalette.muted,
                                      fontSize: 12,
                                    ),
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        size: 19),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 42, minHeight: 50),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: MarketPalette.muted,
                                        size: 19,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    suffixIconConstraints: _isLogin
                                        ? const BoxConstraints(
                                            minWidth: 40, minHeight: 50)
                                        : null,
                                    filled: true,
                                    fillColor: const Color(0xFFF0F5FC),
                                    isDense: false,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: _isLogin ? 10 : 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDCE8F5)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: Color(0xFFDCE8F5)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.blue,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.error,
                                        width: 1,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: MarketPalette.error,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return _isLogin || _registrationAttempted
                                          ? context.l10n.enter_password
                                          : null;
                                    }
                                    if (!_isLogin &&
                                        !_passwordIsValid &&
                                        _registrationAttempted) {
                                      return context
                                          .l10n.password_requirements_below;
                                    }
                                    return null;
                                  },
                                ),
                                if (!_isLogin) ...[
                                  if (_passwordController.text.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    _buildPasswordHint(),
                                  ],
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    style: const TextStyle(fontSize: 14),
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: InputDecoration(
                                      labelText: context.l10n.confirm_password,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.auto,
                                      floatingLabelStyle: const TextStyle(
                                        color: MarketPalette.muted,
                                        fontSize: 12,
                                      ),
                                      labelStyle: const TextStyle(fontSize: 14),
                                      hintStyle: const TextStyle(fontSize: 14),
                                      helperText: _confirmPasswordController
                                                  .text.isEmpty ||
                                              _confirmPasswordController.text ==
                                                  _passwordController.text ||
                                              _registrationAttempted
                                          ? null
                                          : context
                                              .l10n.passwords_do_not_match_hint,
                                      helperStyle: const TextStyle(
                                        color: MarketPalette.muted,
                                        fontSize: 12,
                                      ),
                                      prefixIcon: const Icon(Icons.lock_outline,
                                          size: 19),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                              minWidth: 42, minHeight: 50),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: MarketPalette.muted,
                                        ),
                                        onPressed: () => setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        }),
                                      ),
                                      suffixIconConstraints:
                                          const BoxConstraints(
                                              minWidth: 40, minHeight: 50),
                                      filled: true,
                                      fillColor: const Color(0xFFF0F5FC),
                                      isDense: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFDCE8F5)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Color(0xFFDCE8F5)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: MarketPalette.blue,
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: MarketPalette.error,
                                          width: 1,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: MarketPalette.error,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return _registrationAttempted
                                            ? context.l10n.confirm_your_password
                                            : null;
                                      }
                                      if (value != _passwordController.text &&
                                          _registrationAttempted) {
                                        return context
                                            .l10n.passwords_do_not_match_hint;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                ],
                                if (_isLogin) const SizedBox(height: 24),
                              ],

                              // Submit button
                              MarketPrimaryButton(
                                text: _isLogin
                                    ? context.l10n.sign_in
                                    : context.l10n.register,
                                loadingText:
                                    _loadingMessage ?? context.l10n.please_wait,
                                onPressed: _isLoading ? null : _submit,
                                loading: _isLoading,
                                dark: true,
                                height: 48,
                                softShadow: _isLogin,
                              ),
                              SizedBox(height: _isLogin ? 18 : 16),

                              // Switch between login/register
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _isLogin
                                        ? context.l10n.dont_have_account_prompt
                                        : context
                                            .l10n.already_have_account_prompt,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: MarketPalette.muted,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading ? null : _switchMode,
                                    style: TextButton.styleFrom(
                                      foregroundColor: MarketPalette.blueDeep,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                    ),
                                    child: Text(
                                      _isLogin
                                          ? context.l10n.register
                                          : context.l10n.sign_in,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).viewInsets.bottom > 0
                                        ? 100
                                        : 20,
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
          ),
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({required this.child, required this.login});

  final Widget child;
  final bool login;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: login
                  ? const [
                      Color(0xFFEFF4FC),
                      Color(0xFFF9FBFE),
                      Color(0xFFEAF2FB),
                    ]
                  : const [
                      Color(0xFFEFF4FC),
                      Color(0xFFF9FBFE),
                      Color(0xFFEAF2FB),
                    ],
            ),
          ),
        ),
        Positioned(
          right: -38,
          top: 8,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              width: 220,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x667DBAF2),
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          top: login ? 78 : 18,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: login ? 38 : 48,
              sigmaY: login ? 38 : 48,
            ),
            child: Container(
              width: login ? 138 : 168,
              height: login ? 124 : 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x78E9A9F2),
              ),
            ),
          ),
        ),
        Positioned(
          left: -38,
          bottom: -18,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
            child: Container(
              width: 240,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x4479BFFF),
              ),
            ),
          ),
        ),
        Positioned(
          left: -20,
          right: -20,
          bottom: -1,
          height: 150,
          child: CustomPaint(painter: _LoginBottomCurves()),
        ),
        child,
      ],
    );
  }
}

class _LoginBottomCurves extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pale = Paint()..color = const Color(0x5EFFFFFF);
    final blue = Paint()..color = const Color(0x1E3E91D7);
    final whitePath = Path()
      ..moveTo(0, size.height * .58)
      ..quadraticBezierTo(size.width * .22, size.height * .14, size.width * .52,
          size.height * .62)
      ..quadraticBezierTo(
          size.width * .8, size.height * 1.08, size.width, size.height * .42)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final bluePath = Path()
      ..moveTo(0, size.height * .78)
      ..quadraticBezierTo(size.width * .24, size.height * .4, size.width * .48,
          size.height * .82)
      ..quadraticBezierTo(
          size.width * .78, size.height * 1.18, size.width, size.height * .66)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(whitePath, pale);
    canvas.drawPath(bluePath, blue);
  }

  @override
  bool shouldRepaint(covariant _LoginBottomCurves oldDelegate) => false;
}

class _AuthMessage extends StatelessWidget {
  const _AuthMessage({required this.message, required this.error});

  final String message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final color = error ? MarketPalette.error : MarketPalette.blueDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: error ? const Color(0x22BA2F4A) : const Color(0x222D84D8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(error ? Icons.error_outline : Icons.info_outline,
              size: 19, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(fontSize: 13, height: 1.35, color: color)),
          ),
        ],
      ),
    );
  }
}

class _AuthPhoneArtwork extends StatelessWidget {
  const _AuthPhoneArtwork({required this.register});

  final bool register;

  @override
  Widget build(BuildContext context) {
    if (!register) return const _LoginPhoneArtwork();

    return SizedBox(
      width: 260,
      height: 200,
      child: Image.asset(
        'assets/images/register_phone_reference.png',
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class _LoginPhoneArtwork extends StatelessWidget {
  const _LoginPhoneArtwork();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 250,
      child: Image.asset(
        'assets/images/login_phones_reference.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        alignment: Alignment.topCenter,
      ),
    );
  }
}
