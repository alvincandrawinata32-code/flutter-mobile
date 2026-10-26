import 'package:flutter/material.dart'; 
import '../models/sesi_pengguna.dart';

class KartuSesi extends StatelessWidget {
  final SesiPengguna sesi; 
  final DateTime sekarang; 
  final VoidCallback? onKeluar; 
  final bool sedangKeluar; 
  final bool tampilkanToken; 
  
  const KartuSesi({ 
    super.key, 
    required this.sesi, 
    required this.sekarang, 
    this.onKeluar, 
    this.sedangKeluar = false, 
    this.tampilkanToken = false, 
  });

  static String samarkanToken(String token) {
    if (token.isEmpty) return '(kosong)'; 
    if (token.length <= 6) return _titik(token.length); 
    return '${token.substring(0, 6)}${_titik(12)}';
  }

  static String _titik(int jumlah) => List.filled(jumlah, '\u2022').join(); 
  
  static String formatWaktu(String iso) {
    const List<String> bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    final DateTime? waktu = DateTime.tryParse(iso); 
    if (waktu == null) return 'tidak diketahui'; 
    final String jam = waktu.hour.toString().padLeft(2, '0');
    final String menit = waktu.minute.toString().padLeft(2, '0'); 
    return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year}, $jam:$menit';
  }

  static String formatSisa(Duration sisa) {
    if (sisa.inSeconds <= 0) return 'sudah berakhir'; 
    if (sisa.inMinutes < 1) return '${sisa.inSeconds} detik'; 
    if (sisa.inHours < 1) return '${sisa.inMinutes} menit'; 
    final int menit = sisa.inMinutes.remainder(60); 
    return menit == 0 ? '${sisa.inHours} jam' : '${sisa.inHours} jam $menit menit';
  }

  @override 
  Widget build(BuildContext context) {
    final sisa = sesi.sisaWaktu(sekarang); 
    return Card(
      elevation: 2, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
      child: Padding(
        padding: const EdgeInsets.all(20), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE0F2FE), 
                  foregroundColor: Color(0xFF0284C7), 
                  child: Icon(Icons.person_rounded),
                ),
                const SizedBox(width: 12), 
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text(
                        sesi.nama, style: 
                        const TextStyle(
                          fontSize: 16, fontWeight: 
                          FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${sesi.email} • ${SesiPengguna.labelPeran(sesi.peran)}', 
                        style: const TextStyle( color: Color(0xFF64748B), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                const Text('Masuk Pada:', style: TextStyle(color: Color(0xFF64748B), 
                fontSize: 13)), Text(formatWaktu(sesi.masukPada), 
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                const Text('Sisa Sesi:', style: TextStyle(color: Color(0xFF64748B), 
                fontSize: 13)), Text(formatSisa(sisa), 
                style: const TextStyle(fontWeight: FontWeight.w600, 
                color: Color(0xFF0284C7), fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                const Text('Token Sesi:', style: 
                TextStyle(color: Color(0xFF64748B), 
                fontSize: 13)), 
                Text(
                  tampilkanToken ? sesi.token : samarkanToken(sesi.token), 
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
            if (onKeluar != null) ...[
              const SizedBox(height: 20), 
              SizedBox(
                width: double.infinity, 
                child: OutlinedButton.icon(
                  onPressed: sedangKeluar ? null : onKeluar, 
                  icon: sedangKeluar ? const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2), 
                  ) 
                  
                  : const Icon(Icons.logout_rounded, color: Colors.redAccent), 
                  label: Text( 
                    sedangKeluar ? 'Keluar...' : 'Keluar dari Sesi', 
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}