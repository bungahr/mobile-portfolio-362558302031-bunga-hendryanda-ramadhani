import 'package:flutter/material.dart';

import '../controllers/sesi_controller.dart';

class LoginPengayaanScreen extends StatefulWidget {
  const LoginPengayaanScreen({super.key, required this.controller});

  final SesiController controller;

  @override
  State<LoginPengayaanScreen> createState() => _LoginPengayaanScreenState();
}

class _LoginPengayaanScreenState extends State<LoginPengayaanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sandiController = TextEditingController();
  bool _sandiTerlihat = false;

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.controller.login(
      email: _emailController.text.trim(),
      sandi: _sandiController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('Login Pengayaan')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.teal),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication & Session Security',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi.';
                      }
                      if (!value.contains('@')) {
                        return 'Format email belum benar.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _sandiController,
                    obscureText: !_sandiTerlihat,
                    decoration: InputDecoration(
                      labelText: 'Kata sandi',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.key),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _sandiTerlihat = !_sandiTerlihat;
                          });
                        },
                        icon: Icon(
                          _sandiTerlihat
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi wajib diisi.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (controller.pesan != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        controller.pesan!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  FilledButton(
                    onPressed: controller.status == StatusSesi.memproses
                        ? null
                        : _login,
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Penyimpanan: ${controller.repository.nama}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
