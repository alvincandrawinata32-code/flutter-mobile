import '../models/sesi_pengguna.dart';

class AuthException implements Exception{
  final String pesan; 
  const AuthException(this.pesan); 
  
  @override 
  String toString() => pesan;
}

class AuthApi {
  final bool modeSimulasiGagal; 
  const AuthApi({this.modeSimulasiGagal = false});

  Future<SesiPengguna> login({
    required String email, 
    required String kataSandi,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    if (modeSimulasiGagal) {
      throw const AuthException('Gagal terhubung ke server autentikasi.');
    }

    final emailClean = email.trim().toLowerCase();

    if (emailClean == 'mahasiswa@trpl.ac.id' && kataSandi == 'trpl1234') {
      return SesiPengguna.contoh(
        email: emailClean, 
        nama: 'Mahasiswa TRPL', 
        peran: 'mahasiswa',
      ); 
    } else if (emailClean == 'dosen@trpl.ac.id' && kataSandi == 'dosen1234') {
      return SesiPengguna.contoh(
        email: emailClean, 
        nama: 'Dosen Pengampu TRPL', 
        peran: 'dosen',
      );
    } else {
      throw const AuthException('Email atau kata sandi tidak terdaftar.');
    }
  }
}