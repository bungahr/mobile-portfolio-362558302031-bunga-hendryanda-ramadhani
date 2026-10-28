import 'package:flutter/material.dart';

import 'dart:async';

import '../models/sesi_pengguna.dart';
import '../services/auth_api.dart';
import '../services/sesi_memori.dart';
import '../widgets/field_kata_sandi.dart';
import '../widgets/kartu_sesi.dart';

enum StatusAuth { memeriksa, keluar, memproses, masuk, gagal }

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.api,
    required this.sesiMemori,
    this.jam = DateTime.now,
  });

  final AuthApi api;
  final SesiMemori sesiMemori;
  final DateTime Function() jam;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _kataSandiController = TextEditingController();

  StatusAuth _status = StatusAuth.memeriksa;
  String? _pesanGagal;
  SesiPengguna? _sesi;
  bool _sedangKeluar = false;
  Timer? _timerSesi;
  int _generasiLogin = 0;

  @override
  void initState() {
    super.initState();
    _pulihkanSesi();
    _timerSesi = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      if (_status == StatusAuth.masuk && _sesi != null) {
        setState(() {});
      }
    });
  }

  Future<void> _pulihkanSesi() async {
    final sesi = widget.sesiMemori.baca();

    if (!mounted) return;

    if (sesi == null || sesi.sudahKedaluwarsa(widget.jam())) {
      if (sesi != null) {
        await widget.sesiMemori.hapus();
      }

      if (!mounted) return;
      setState(() {
        _sesi = null;
        _status = StatusAuth.keluar;
      });
      return;
    }

    setState(() {
      _sesi = sesi;
      _status = StatusAuth.masuk;
    });
  }

  Future<void> _login() async {
    if (_status == StatusAuth.memproses) return;
    if (!_formKey.currentState!.validate()) return;

    final generasi = ++_generasiLogin;

    setState(() {
      _status = StatusAuth.memproses;
      _pesanGagal = null;
    });

    try {
      final sesi = await widget.api.masuk(
        email: _emailController.text.trim(),
        sandi: _kataSandiController.text,
      );

      if (!mounted || generasi != _generasiLogin) return;

      await widget.sesiMemori.simpan(sesi);

      if (!mounted || generasi != _generasiLogin) return;

      setState(() {
        _sesi = sesi;
        _status = StatusAuth.masuk;
        _kataSandiController.clear();
      });
    } on AuthException catch (e) {
      if (!mounted || generasi != _generasiLogin) return;

      setState(() {
        _pesanGagal = e.pesan;
        _status = StatusAuth.gagal;
      });
    } catch (_) {
      if (!mounted || generasi != _generasiLogin) return;

      setState(() {
        _pesanGagal = 'Terjadi kesalahan tak terduga. Coba lagi.';
        _status = StatusAuth.gagal;
      });
    }
  }

  void _batalkanLogin() {
    if (_status != StatusAuth.memproses) return;

    ++_generasiLogin;

    setState(() {
      _status = StatusAuth.keluar;
      _pesanGagal = null;
      _kataSandiController.clear();
    });
  }

  Future<void> _logout() async {
    if (_sedangKeluar) return;

    setState(() {
      _sedangKeluar = true;
    });

    await widget.sesiMemori.hapus();
    if (!mounted) return;

    setState(() {
      _sesi = null;
      _status = StatusAuth.keluar;
      _pesanGagal = null;
      _sedangKeluar = false;
      _emailController.clear();
      _kataSandiController.clear();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _kataSandiController.dispose();
    _timerSesi?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_status == StatusAuth.memeriksa) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_status == StatusAuth.masuk && _sesi != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Beranda Mahasiswa')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_circle, size: 76),
                  const SizedBox(height: 12),
                  Text(
                    'Login berhasil!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  KartuSesi(
                    sesi: _sesi!,
                    sekarang: widget.jam(),
                    onKeluar: _logout,
                    sedangKeluar: _sedangKeluar,
                  ),
                  const SizedBox(height: 12),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Sesi disimpan di memori aplikasi. '
                        'Jika proses aplikasi ditutup sepenuhnya, '
                        'sesi ini tidak dipulihkan kembali.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final sedangMemproses = _status == StatusAuth.memproses;

    return Scaffold(
      appBar: AppBar(title: const Text('Login Mahasiswa TRPL')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.lock_outline, size: 56),
                      const SizedBox(height: 12),
                      Text(
                        'Masuk ke akun',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Praktikum Authentication & Session Security',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _emailController,
                        enabled: !sedangMemproses,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        autofillHints: const [AutofillHints.email],
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'student@trpl.test',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final email = value?.trim() ?? '';

                          if (email.isEmpty) {
                            return 'Email wajib diisi.';
                          }
                          if (!email.contains('@') || !email.contains('.')) {
                            return 'Format email belum benar.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      FieldKataSandi(
                        controller: _kataSandiController,
                        enabled: !sedangMemproses,
                        onSubmitted: _login,
                        validator: (value) {
                          final kataSandi = value ?? '';

                          if (kataSandi.isEmpty) {
                            return 'Kata sandi wajib diisi.';
                          }
                          if (kataSandi.length < 8) {
                            return 'Kata sandi minimal 8 karakter.';
                          }
                          return null;
                        },
                      ),
                      if (_pesanGagal != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _pesanGagal!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: sedangMemproses ? null : _login,
                        child: sedangMemproses
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Memproses...'),
                                ],
                              )
                            : const Text('Login'),
                      ),
                      if (sedangMemproses) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _batalkanLogin,
                          child: const Text('Batalkan login'),
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(),
                      const Text(
                        'Akun untuk pengujian',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Berhasil:\n'
                        'student@trpl.test\n'
                        'belajar123\n\n'
                        'Akun terkunci:\n'
                        'terkunci@trpl.test\n\n'
                        'Simulasi gangguan server:\n'
                        'gangguan@trpl.test\n\n'
                        'Akun belum diverifikasi:\n'
                        'verifikasi@trpl.test\n\n'
                        'Email lainnya dapat digunakan untuk '
                        'menguji pesan kesalahan login.',
                      ),
                    ],
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
