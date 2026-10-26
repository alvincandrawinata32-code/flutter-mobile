import 'package:flutter/material.dart';
import '../services/auth_api.dart';
import '../services/sesi_memori.dart';
import '../widgets/field_kata_sandi.dart';
import '../widgets/kartu_sesi.dart';

enum StatusAuth { memeriksa, keluar, memproses, masuk, gagal }

class LoginScreen extends StatefulWidget {
  final AuthApi? api;

  const LoginScreen({super.key, this.api});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthApi _api = widget.api ?? const AuthApi();

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _sandiController = TextEditingController();

  StatusAuth _status = StatusAuth.memeriksa;
  String? _pesanError;

  @override
  void initState() {
    super.initState();
    _periksaSesiAwal();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _sandiController.dispose();
    super.dispose();
  }

  void _periksaSesiAwal() {
    if (SesiMemori.adaSesi) {
      setState(() => _status = StatusAuth.masuk);
    } else {
      setState(() => _status = StatusAuth.keluar);
    }
  }

  Future<void> _prosesLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _status = StatusAuth.memproses;
      _pesanError = null;
    });

    try {
      final sesiBaru = await _api.login(
        email: _emailController.text,
        kataSandi: _sandiController.text,
      );

      SesiMemori.simpan(sesiBaru);
      setState(() {
        _status = StatusAuth.masuk;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang kembali, ${sesiBaru.nama}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (e) {
      setState(() {
        _status = StatusAuth.gagal;
        _pesanError = e.pesan;
      });
    } catch (e) {
      setState(() {
        _status = StatusAuth.gagal;
        _pesanError = 'Terjadi kesalahan tidak terduga: $e';
      });
    }
  }

  // Sebelumnya dipanggil di KartuSesi (onKeluar) tapi belum didefinisikan.
  void _prosesLogout() {
    SesiMemori.hapus();
    setState(() {
      _status = StatusAuth.keluar;
      _pesanError = null;
    });
  }

  void _isiKredensialUji(String email, String sandi) {
    _emailController.text = email;
    _sandiController.text = sandi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Portal Autentikasi TRPL'),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. STATE MEMERIKSA (Loading Sesi Awal)
    if (_status == StatusAuth.memeriksa) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF0284C7)),
            SizedBox(height: 16),
            Text(
              'Memeriksa status sesi...',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ],
        ),
      );
    }

    // 2. STATE MASUK (Sesi Aktif Ditemukan / Beranda Mahasiswa)
    if (_status == StatusAuth.masuk && SesiMemori.adaSesi) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Beranda Mahasiswa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anda berada dalam sesi aktif yang valid.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            KartuSesi(
              sesi: SesiMemori.sesi!,
              sekarang: DateTime.now(),
              onKeluar: _prosesLogout,
            ),
          ],
        ),
      );
    }

    // 3. STATE KELUAR / MEMPROSES / GAGAL (Form Login)
    final sedangMemproses = _status == StatusAuth.memproses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_person_rounded,
            size: 64,
            color: Color(0xFF0284C7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Masuk Akun TRPL',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gunakan email dan kata sandi institusi Anda',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 28),

          // Banner Pesan Gagal
          if (_status == StatusAuth.gagal && _pesanError != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFCA5A5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _pesanError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Form Autentikasi
          Form(
            key: _formKey,
            child: Column(
              children: [
                // Field Email
                TextFormField(
                  controller: _emailController,
                  enabled: !sedangMemproses,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email Institusi',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi!';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Field Kata Sandi
                FieldKataSandi(
                  controller: _sandiController,
                  enabled: !sedangMemproses,
                  onSubmitted: sedangMemproses ? null : _prosesLogin,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi wajib diisi!';
                    }
                    if (value.length < 6) {
                      return 'Kata sandi minimal 6 karakter!';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Masuk
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: sedangMemproses ? null : _prosesLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: sedangMemproses
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Memproses...'),
                            ],
                          )
                        : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 12),

          // Chip Kredensial Uji Coba
          const Text(
            'Kredensial Uji Coba (Klik untuk mengisi):',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ActionChip(
                label: const Text('Mahasiswa'),
                avatar: const Icon(Icons.school, size: 16),
                onPressed: sedangMemproses
                    ? null
                    : () => _isiKredensialUji(
                          'mahasiswa@trpl.ac.id',
                          'trpl1234',
                        ),
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text('Dosen'),
                avatar: const Icon(Icons.person, size: 16),
                onPressed: sedangMemproses
                    ? null
                    : () => _isiKredensialUji(
                          'dosen@trpl.ac.id',
                          'dosen1234',
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
