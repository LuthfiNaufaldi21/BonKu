import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/preferensi_provider.dart';
import 'main_nav_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<PreferensiProvider>().masuk(
          email: _emailController.text,
          nama: _isSignUp ? _nameController.text : null,
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainNavScreen()),
    );
  }

  void _toggleMode(bool isSignUp) {
    setState(() {
      _isSignUp = isSignUp;
    });
  }

  String? _requiredValidator(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            )
                          ],
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    Text(
                      _isSignUp ? 'Mulai Perjalananmu' : 'Selamat Datang Kembali',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp
                          ? 'Buat akun BonKu dan pantau arus kasmu dengan lebih cerdas.'
                          : 'Masuk untuk melanjutkan evaluasi keuangan otomatis.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildToggleTab('Masuk', !_isSignUp, colors),
                          ),
                          Expanded(
                            child: _buildToggleTab('Daftar', _isSignUp, colors),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _buildInputDecoration(
                          'Nama lengkap',
                          Icons.person_outline_rounded,
                          colors,
                        ),
                        validator: (value) => _requiredValidator(value, 'Nama lengkap'),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _buildInputDecoration(
                        'Email',
                        Icons.email_outlined,
                        colors,
                      ).copyWith(hintText: 'user@email.com'),
                      validator: (value) {
                        final required = _requiredValidator(value, 'Email');
                        if (required != null) return required;
                        if (!value!.contains('@')) return 'Masukkan email yang valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: _buildInputDecoration(
                        'Kata sandi',
                        Icons.lock_outline_rounded,
                        colors,
                      ).copyWith(
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Tampilkan' : 'Sembunyikan',
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      validator: (value) {
                        final required = _requiredValidator(value, 'Kata sandi');
                        if (required != null) return required;
                        if (value!.length < 6) return 'Minimal 6 karakter';
                        return null;
                      },
                    ),
                    
                    if (!_isSignUp)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => _LupaSandiDialog(emailAwal: _emailController.text),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: const Text('Lupa kata sandi?', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      )
                    else
                      const SizedBox(height: 24),
                      
                    const SizedBox(height: 8),

                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.primary.withBlue(180)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          _isSignUp ? Icons.person_add_alt_1_rounded : Icons.login_rounded,
                          color: colors.onPrimary,
                        ),
                        label: Text(
                          _isSignUp ? 'Daftar Sekarang' : 'Masuk',
                          style: TextStyle(
                            color: colors.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTab(String text, bool isSelected, ColorScheme colors) {
    return GestureDetector(
      onTap: () => _toggleMode(text == 'Daftar'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, ColorScheme colors) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colors.onSurfaceVariant),
      filled: true,
      fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.3),
      labelStyle: TextStyle(color: colors.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }
}

class _LupaSandiDialog extends StatefulWidget {
  final String emailAwal;

  const _LupaSandiDialog({required this.emailAwal});

  @override
  State<_LupaSandiDialog> createState() => _LupaSandiDialogState();
}

class _LupaSandiDialogState extends State<_LupaSandiDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailC = TextEditingController(text: widget.emailAwal);
  bool _mengirim = false;

  @override
  void dispose() {
    _emailC.dispose();
    super.dispose();
  }

  Future<void> _kirim() async {
    if (!(_formKey.currentState?.validate() ?? false) || _mengirim) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final email = _emailC.text.trim();

    setState(() => _mengirim = true);
    await Future<void>.delayed(const Duration(milliseconds: 800)); 
    navigator.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Tautan reset kata sandi dikirim ke $email (simulasi).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lupa kata sandi?'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan email akunmu. Kami akan mengirim tautan untuk mengatur ulang kata sandi.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Email wajib diisi';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                  return 'Masukkan email yang valid';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _mengirim ? null : () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _mengirim ? null : _kirim,
          child: _mengirim
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Kirim Tautan'),
        ),
      ],
    );
  }
}