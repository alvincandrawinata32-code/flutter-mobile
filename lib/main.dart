import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Tambahkan import ini
import 'modul_02/academic_dashboard_screen.dart';
import 'modul_04/screens/announcement_list_screen.dart';
import 'modul_04/services/announcement_api.dart';
import 'modul_05/screens/task_list_screen.dart';
import 'modul_06/screens/login_screen.dart';

const bool kModeSimulasi = bool.fromEnvironment('SIMULASI');

void main() {
  // 2. Bungkus runApp dengan ProviderScope di titik paling atas aplikasi
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Poliwangi',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0284C7),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Profil Mahasiswa', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar Profil
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0284C7),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 52,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 16),

              // Nama Mahasiswa
              const Text(
                'Alvin Candra Winata',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 6),

              // Badge NIM
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NIM: 362558302055',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Kartu Informasi Akademik
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.business_rounded,
                        label: 'Jurusan',
                        value: 'Bisnis dan Informatika',
                      ),
                      Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _InfoRow(
                        icon: Icons.code_rounded,
                        label: 'Program Studi',
                        value: 'Sarjana Terapan TRPL',
                      ),
                      Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Kampus',
                        value: 'Politeknik Negeri Banyuwangi',
                      ),
                      Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Semester / TA',
                        value: 'Semester 5 (2026/2027)',
                      ),
                      Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _InfoRow(
                        icon: Icons.link_rounded,
                        label: 'Repositori GitHub',
                        value: 'github.com/alvincandrawinata32-code',
                      ),
                      Divider(height: 24, color: Color(0xFFF1F5F9)),
                      _InfoRow(
                        icon: Icons.devices_rounded,
                        label: 'Fokus Keahlian',
                        value: 'Mobile UI/UX & Flutter Development',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // TOMBOL 1: Navigasi Pindah ke Dashboard Akademik TRPL (Modul 02)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AcademicDashboardScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.dashboard_rounded),
                  label: const Text('Buka Dashboard Akademik TRPL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // TOMBOL 2: Verifikasi Status Mahasiswa (SnackBar Modul 01)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status: Mahasiswa Aktif TRPL — Angkatan 2024'),
                        backgroundColor: Color(0xFF0284C7),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text('Verifikasi Status Mahasiswa'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0284C7),
                    side: const BorderSide(color: Color(0xFF0284C7)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // TOMBOL 3: Navigasi Pindah ke Daftar Pengumuman (Modul 04)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnouncementListScreen(
                          api: AnnouncementApi(modeSimulasi: kModeSimulasi),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Lihat Daftar Pengumuman'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
                            const SizedBox(height: 12),

              // TOMBOL 4: Navigasi Pindah ke Daftar Tugas (Modul 05)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TaskListScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.checklist_rounded),
                  label: const Text('Buka Daftar Tugas'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0284C7)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}