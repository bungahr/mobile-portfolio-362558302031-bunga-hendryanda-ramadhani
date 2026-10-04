import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_api.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key, this.api});

  /// Dapat disuntikkan dari luar (widget test atau demo offline).
  final AnnouncementApi? api;

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen> {
  static const List<String> _kategori = <String>[
    'Semua',
    'Akademik',
    'Beasiswa',
    'Kegiatan',
    'Prestasi',
  ];

  late final AnnouncementApi _api = widget.api ?? AnnouncementApi();

  late Future<List<Announcement>> _futurePengumuman;

  String _kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    _futurePengumuman = _api.ambilPengumuman();
  }

  @override
  void dispose() {
    _api.tutup();
    super.dispose();
  }

  Future<void> _muatUlang() async {
    final Future<List<Announcement>> futureBaru = _api.ambilPengumuman();

    setState(() {
      _futurePengumuman = futureBaru;
    });

    try {
      await futureBaru;
    } catch (_) {
      // Error sudah ditangani FutureBuilder lewat snapshot.hasError.
      // Blok catch ini mencegah unhandled exception.
    }
  }

  void _pilihKategori(String kategori) {
    if (kategori == _kategoriTerpilih) return;

    setState(() => _kategoriTerpilih = kategori);
  }

  void _bukaDetail(Announcement announcement) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementDetailScreen(announcement: announcement),
      ),
    );
  }

  Widget _buildBarisFilter() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _kategori.length,
        separatorBuilder: (BuildContext context, int index) {
          return const SizedBox(width: 8);
        },
        itemBuilder: (BuildContext context, int index) {
          final String kategori = _kategori[index];

          return ChoiceChip(
            label: Text(kategori),
            selected: kategori == _kategoriTerpilih,
            onSelected: (bool selected) {
              _pilihKategori(kategori);
            },
          );
        },
      ),
    );
  }

  Widget _buildMemuat() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Sedang memuat pengumuman...', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildGagal(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.cloud_off_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat pengumuman',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _muatUlang,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.inbox_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Belum ada pengumuman untuk kategori '
              '$_kategoriTerpilih.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftar(List<Announcement> pengumuman) {
    return RefreshIndicator(
      onRefresh: _muatUlang,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pengumuman.length,
        itemBuilder: (BuildContext context, int index) {
          final Announcement announcement = pengumuman[index];

          return AnnouncementCard(
            announcement: announcement,
            onTap: () => _bukaDetail(announcement),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Portal Pengumuman TRPL'),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildBarisFilter(),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Announcement>>(
              future: _futurePengumuman,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Announcement>> snapshot,
                  ) {
                    // ── Keadaan 1: LOADING ─────────────────────
                    if (snapshot.connectionState != ConnectionState.done) {
                      return _buildMemuat();
                    }

                    // ── Keadaan 2: ERROR ───────────────────────
                    if (snapshot.hasError) {
                      return _buildGagal(snapshot.error!);
                    }

                    // ── Keadaan 3 & 4: KOSONG / BERHASIL ──────
                    final List<Announcement> semua =
                        snapshot.data ?? const <Announcement>[];

                    final List<Announcement> tampil =
                        _kategoriTerpilih == 'Semua'
                        ? semua
                        : semua
                              .where(
                                (Announcement item) =>
                                    item.category.toLowerCase() ==
                                    _kategoriTerpilih.toLowerCase(),
                              )
                              .toList(growable: false);

                    if (tampil.isEmpty) {
                      return _buildKosong();
                    }

                    return _buildDaftar(tampil);
                  },
            ),
          ),
        ],
      ),
    );
  }
}
