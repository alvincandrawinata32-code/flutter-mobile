class SesiPengguna {
  final String token;
  final String email;
  final String nama;
  final String peran;
  final String masukPada;
  final String kedaluwarsaPada;

  SesiPengguna({
    required this.token,
    required this.email,
    required this.nama,
    required this.peran,
    required this.masukPada,
    required this.kedaluwarsaPada,
  });

  factory SesiPengguna.fromJson(Map<String, dynamic> json) {
    return SesiPengguna(
      token: json['token'] as String? ?? '', 
      email: json['email'] as String? ?? 'tanpa-email', 
      nama: json['nama'] as String? ?? 'Pengguna', 
      peran: json['peran'] as String? ?? 'mahasiswa', 
      masukPada: json['masukPada'] as String? ?? '1970-01-01T00:00:00.000', 
      kedaluwarsaPada: json['kedaluwarsaPada'] as String? ?? '1970-01-01T00:00:00.000',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic> {
    'token': token,
    'email': email,
    'nama': nama,
    'peran': peran,
    'masukPada': masukPada,
    'kedaluwarsaPada': kedaluwarsaPada,
  };

  bool sudahKedaluwarsa(DateTime sekarang) {
    final DateTime? batas = DateTime.tryParse(kedaluwarsaPada);
    if (batas == null) return true; return !sekarang.isBefore(batas);
  }

  bool get kedaluwarsa => sudahKedaluwarsa(DateTime.now());

  Duration sisaWaktu(DateTime sekarang) {
    final DateTime? batas = DateTime.tryParse(kedaluwarsaPada); 
    if (batas == null) return Duration.zero; 
    final Duration sisa = batas.difference(sekarang); 
    return sisa.isNegative ? Duration.zero : sisa;
  }

  SesiPengguna copyWith({
    String? token,
    String? email,
    String? nama,
    String? peran,
    String? masukPada,
    String? kedaluwarsaPada,
  }) {
    return SesiPengguna(
      token: token ?? this.token,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      peran: peran ?? this.peran,
      masukPada: masukPada ?? this.masukPada,
      kedaluwarsaPada: kedaluwarsaPada ?? this.kedaluwarsaPada,
    );
  }
  static String labelPeran(String peran) {
    switch (peran) {
      case 'mahasiswa':
        return 'Mahasiswa';
      case 'dosen':
        return 'Dosen';
      case 'admin':
        return 'Administrator';
      default:
        return 'Pengguna';
    }
  }

  static SesiPengguna contoh({
    String token = 'dummy-token-fase-a', 
    String email = 'student@trpl.test', 
    String nama = 'Mahasiswa TRPL', 
    String peran = 'mahasiswa', 
    Duration masaBerlaku = const 
    Duration(hours: 2), 
    DateTime? sekarang,
  }) {
    final DateTime mulai = sekarang ?? DateTime(2026, 9, 21, 8, 0);
    return SesiPengguna(
      token: token, 
      email: email, 
      nama: nama, 
      peran: peran, 
      masukPada: mulai.toIso8601String(), 
      kedaluwarsaPada: mulai.add(masaBerlaku).toIso8601String(),
    );
  }
}