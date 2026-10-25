import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_storage.dart';
import '../widgets/task_tile.dart';

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
        bottom: _sedangMenyimpan
            ? const PreferredSize(
                preferredSize: Size.fromHeight(4.0),
                child: LinearProgressIndicator(),
              )
            : null,
      ),
      body: _error != null
          ? Center(child: Text('Gagal memuat tugas:\n$_error', textAlign: TextAlign.center))
          : _tugas == null
              ? _tampilanMemuat()
              : _tugas!.isEmpty
                  ? const Center(child: Text('Belum ada tugas. Silakan tambah tugas baru!'))
                  : _tampilanDaftar(_tugas!),
      

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 1. Ambil data tugas lama, jika null jadikan list kosong
          final List<Task> daftarBaru = List<Task>.from(_tugas ?? []);
          
          // 2. Tambahkan tugas baru dengan ID unik berdasarkan waktu
          daftarBaru.add(
            Task(
              id: 'T${DateTime.now().millisecondsSinceEpoch}',
              title: 'Tugas Baru #${daftarBaru.length + 1}',
              course: 'Pemrograman Mobile',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
          
          // 3. Simpan perubahan menggunakan fungsi penyimpanan yang sudah ada
          _simpanDaftar(daftarBaru, pesan: 'Tugas berhasil ditambahkan');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _tampilanDaftar(List<Task> tugas) {
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
}