// lib/modul_02/academic_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'models/matakuliah.dart';
import 'widgets/kartu_matakuliah.dart';
import 'widgets/header_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modul_03/screens/krs_list_screen.dart';
import '../modul_06/services/sesi_memori.dart';

class AcademicDashboardScreen extends StatefulWidget {
  const AcademicDashboardScreen({super.key});

  @override
  State<AcademicDashboardScreen> createState() => _AcademicDashboardScreenState();
}

class _AcademicDashboardScreenState extends State<AcademicDashboardScreen> {
  final List<MataKuliah> _courses = MataKuliah.getSampleCourses();
  bool _isDarkMode = false;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorSchemeSeed: const Color(0xFF0284C7),
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Dashboard Akademik TRPL',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.assignment_outlined),
              tooltip: 'Kelola KRS (Modul 03)',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pembungkus ProviderScope wajib ada agar Riverpod berjalan [3]
                    builder: (context) => const ProviderScope(
                      child: KrsListScreen(),
                    ),
                  ),
                );
              },
            ),

            IconButton(
              icon: const Icon(Icons.logout_rounded), 
              tooltip: 'Keluar Sesi', onPressed: () {
                // Hapus sesi di memori 
                SesiMemori.hapus(); 
                
                // Tampilkan pesan 
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berhasil keluar dari sesi.')),
                );
                Navigator.pop(context);
              }
            ),

            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              tooltip: _isDarkMode ? 'Mode Terang' : 'Mode Gelap',
              onPressed: _toggleDarkMode,
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Breakpoint 600dp: Tablet / Landscape menggunakan 2 kolom
            if (constraints.maxWidth >= 600) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: SingleChildScrollView(
                        child: HeaderBanner(),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 3,
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 340,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 240,
                        ),
                        itemCount: _courses.length,
                        itemBuilder: (context, index) {
                          return MataKuliahCard(mataKuliah: _courses[index]);
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            // Default (smartphone < 600dp): 1 kolom vertikal
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const HeaderBanner(),
                const SizedBox(height: 16),
                Text(
                  'Mata Kuliah Semester 5 (${_courses.length} Terdaftar)',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ..._courses.map((item) => MataKuliahCard(mataKuliah: item)),
              ],
            );
          },
        ),
      ),
    );
  }
}
