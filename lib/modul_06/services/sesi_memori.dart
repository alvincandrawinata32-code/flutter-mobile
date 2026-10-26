import '../models/sesi_pengguna.dart';

class SesiMemori {
  static SesiPengguna? _sesiAktif;

  static SesiPengguna? get sesi => _sesiAktif;

  static bool get adaSesi => _sesiAktif != null && !_sesiAktif!.kedaluwarsa;

  static void simpan(SesiPengguna sesiBaru) {
    _sesiAktif = sesiBaru;
  }

  static void hapus() { 
    _sesiAktif = null; 
  }
}