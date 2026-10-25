import 'models/task.dart';
import 'services/task_storage.dart'; 
import 'widgets/task_tile.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, this.storage});

  /// Dapat disuntikkan dari luar (widget test atau praktikum keadaan memuat).
  final TaskStorage? storage;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late final TaskStorage _storage = widget.storage ?? const TaskStorage();

  List<Task>? _tugas;
  Object? _error;
  bool _sedangMenyimpan = false;

  @override
  void initState() {
    super.initState();
    unawaited(_muat());
  }

  Future<void> _muat() async {
    setState(() {
      _tugas = null;
      _error = null;
    });

    try {
      final List<Task> hasil = await _storage.muat();
      if (!mounted) return;
      setState(() => _tugas = hasil);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<bool> _simpanDaftar(
    List<Task> daftarBaru, {
    String? pesan,
    List<Task>? daftarSebelumnya,
  }) async {
    final List<Task>? cadangan = daftarSebelumnya ?? _tugas;

    setState(() {
      _tugas = daftarBaru;
      _sedangMenyimpan = true;
    });

    try {
      await _storage.simpan(daftarBaru);
      if (!mounted) return true;
      setState(() => _sedangMenyimpan = false);
      if (pesan != null) _pesan(pesan);
      return true;
    } catch (e) {
      if (!mounted) return false;
      // Gulung balik: layar dikembalikan ke kondisi terakhir yang
      // benar-benar tersimpan.
      setState(() {
        _tugas = cadangan;
        _sedangMenyimpan = false;
      });
      _pesan('Gagal menyimpan: ${_rapikanPesan(e)}');
      return false;
    }
  }

  Future<void> _ubahStatus(Task tugas) async {
    final List<Task>? sekarang = _tugas;
    if (sekarang == null) return;

    // `map` + `copyWith`, bukan mengubah objek di tempat.
    final List<Task> baru = sekarang
        .map((Task t) => t.id == tugas.id ? t.copyWith(done: !t.done) : t)
        .toList(growable: true);

    await _simpanDaftar(baru, daftarSebelumnya: sekarang);
  }

  // --- Kumpulan kode baru yang ditambahkan ---

  void _pesan(String teks) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  String _rapikanPesan(Object e) {
    if (e is FormatException) return e.message;
    final String s = e.toString();
    return s.startsWith('Exception: ') ? s.substring('Exception: '.length) : s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas'),
        // 1. Menggunakan _sedangMenyimpan untuk memunculkan loading bar saat proses simpan
        bottom: _sedangMenyimpan
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      // 2. Menggunakan _error untuk menampilkan pesan eror di layar jika gagal memuat data
      body: _error != null
          ? Center(child: Text('Gagal memuat tugas:\n$_error', textAlign: TextAlign.center))
          : _tugas == null
              ? _tampilanMemuat()
              : _tampilanDaftar(_tugas!),
    );
  }

  Widget _tampilanDaftar(List<Task> tugas) { // Menambahkan <Task> agar tipe datanya jelas
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: tugas.length,
      itemBuilder: (BuildContext context, int i) {
        final Task t = tugas[i];
        return TaskTile(task: t, onToggle: _ubahStatus);
      },
    );
  }

  Widget _tampilanMemuat() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Memuat tugas dari penyimpanan...'),
        ],
      ),
    );
  }
} // Penutup class _TaskListScreenState