// lib/screens/onboarding/pages/registration_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../../l10n/app_localizations.dart';

class RegistrationPage extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  const RegistrationPage({
    super.key,
    required this.onContinue,
    required this.onSkip,
    this.onBack,
  });

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  Timer? _debounceTimer;

  PasswordStrength _passwordStrength = PasswordStrength.weak;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _validateEmail(value);
    });
  }

  void _validateEmail(String email) {
    setState(() {
      if (email.isEmpty) {
        _isEmailValid = false;
        _emailError = null;
      } else if (_isValidEmail(email)) {
        _isEmailValid = true;
        _emailError = null;
      } else {
        _isEmailValid = false;
        _emailError = 'Неверный формат email';
      }
    });
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _onPasswordChanged(String value) {
    setState(() {
      if (value.isEmpty) {
        _isPasswordValid = false;
        _passwordError = null;
        _passwordStrength = PasswordStrength.weak;
      } else if (value.length < 8) {
        _isPasswordValid = false;
        _passwordError = 'Минимум 8 символов';
        _passwordStrength = PasswordStrength.weak;
      } else {
        _isPasswordValid = true;
        _passwordError = null;
        _passwordStrength = _calculatePasswordStrength(value);
      }
    });
  }

  PasswordStrength _calculatePasswordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  bool get _canSubmit => _isEmailValid && _isPasswordValid && !_isLoading;

  Future<void> _createAccount() async {
    if (!_canSubmit) return;

    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Симуляция создания аккаунта
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Реальная регистрация через Firebase Auth или API

      if (mounted) {
        widget.onContinue();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailError = 'Email уже используется';
          _isEmailValid = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Симуляция входа через Google
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Реальная авторизация через Google

      if (mounted) {
        widget.onContinue();
      }
    } catch (e) {
      // Обработка ошибки
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() {
      _isLoading = true;
    });

    HapticFeedback.lightImpact();

    try {
      // Симуляция входа через Apple
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Реальная авторизация через Apple

      if (mounted) {
        widget.onContinue();
      }
    } catch (e) {
      // Обработка ошибки
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Заголовок
                Text(
                  'Создайте аккаунт',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 8),

                Text(
                  'Сохраним ваш прогресс и настройки',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Email поле
                _buildEmailField(),

                const SizedBox(height: 20),

                // Password поле
                _buildPasswordField(),

                const SizedBox(height: 32),

                // Кнопка создания аккаунта
                _buildCreateAccountButton(),

                const SizedBox(height: 24),

                // Разделитель
                _buildDivider(),

                const SizedBox(height: 24),

                // Social login кнопки
                _buildSocialButtons(),

                const SizedBox(height: 32),

                // Skip ссылка
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : widget.onSkip,
                    child: Text(
                      'Попробовать без регистрации',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          autofocus: true,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            hintText: 'email@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _emailError != null
                    ? Colors.red
                    : _isEmailValid
                        ? Colors.green
                        : const Color(0xFF2EC5FF),
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: _emailController.text.isNotEmpty
                ? Icon(
                    _isEmailValid ? Icons.check_circle : Icons.error,
                    color: _isEmailValid ? Colors.green : Colors.red,
                  )
                : null,
            errorText: _emailError,
          ),
          onChanged: _onEmailChanged,
        ),
      ],
    ).animate().slideX(begin: -0.2, delay: 300.ms).fadeIn(delay: 300.ms);
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Пароль',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Минимум 8 символов',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _passwordError != null
                    ? Colors.red
                    : _isPasswordValid
                        ? Colors.green
                        : const Color(0xFF2EC5FF),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
                HapticFeedback.lightImpact();
              },
            ),
            errorText: _passwordError,
          ),
          onChanged: _onPasswordChanged,
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(),
        ],
      ],
    ).animate().slideX(begin: -0.2, delay: 400.ms).fadeIn(delay: 400.ms);
  }

  Widget _buildPasswordStrengthIndicator() {
    Color strengthColor;
    String strengthText;
    double strengthValue;

    switch (_passwordStrength) {
      case PasswordStrength.weak:
        strengthColor = Colors.red;
        strengthText = 'Слабый';
        strengthValue = 0.33;
        break;
      case PasswordStrength.medium:
        strengthColor = Colors.orange;
        strengthText = 'Средний';
        strengthValue = 0.66;
        break;
      case PasswordStrength.strong:
        strengthColor = Colors.green;
        strengthText = 'Сильный';
        strengthValue = 1.0;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Сложность пароля',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: strengthValue,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          minHeight: 4,
        ),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return ElevatedButton(
      onPressed: _canSubmit ? _createAccount : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2EC5FF),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 0,
        disabledBackgroundColor: Colors.grey[300],
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Создать аккаунт',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
    ).animate().slideY(begin: 0.2, delay: 500.ms).fadeIn(delay: 500.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'или',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        // Google
        OutlinedButton(
          onPressed: _isLoading ? null : _signInWithGoogle,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Продолжить с Google',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Apple (только для iOS)
        if (Theme.of(context).platform == TargetPlatform.iOS)
          OutlinedButton(
            onPressed: _isLoading ? null : _signInWithApple,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: Colors.black,
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.apple,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Продолжить с Apple',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
      ],
    ).animate().slideY(begin: 0.2, delay: 700.ms).fadeIn(delay: 700.ms);
  }
}

enum PasswordStrength {
  weak,
  medium,
  strong,
}