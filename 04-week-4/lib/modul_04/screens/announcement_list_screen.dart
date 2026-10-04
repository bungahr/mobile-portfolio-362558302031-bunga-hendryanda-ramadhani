import 'package:flutter/material.dart';

import '../models/announcement.dart';
import '../services/announcement_api.dart';
import '../widgets/announcement_card.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key, this.api});

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

  List<Announcement>? _dataTersimpan;

  String _kategoriTerpilih = 'Semua';
  String _kataPencarian = '';

  int _percobaan = 0;
  bool _sedangMenyegarkan = false;

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
    if (_sedangMenyegarkan) {
      return;
    }

    setState(() {
      _percobaan++;
      _sedangMenyegarkan = true;
    });

    try {
      final List<Announcement> dataBaru = await _api.ambilPengumuman();

      if (!mounted) {
        return;
      }

      setState(() {
        _dataTersimpan = dataBaru;
        _sedangMenyegarkan = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _sedangMenyegarkan = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  Future<void> _cobaLagi() async {
    if (_sedangMenyegarkan) {
      return;
    }

    setState(() {
      _percobaan++;
      _sedangMenyegarkan = true;
    });

    final Future<List<Announcement>> futureBaru = _api.ambilPengumuman();

    setState(() {
      _futurePengumuman = futureBaru;
    });

    try {
      final List<Announcement> dataBaru = await futureBaru;

      if (!mounted) {
        return;
      }

      setState(() {
        _dataTersimpan = dataBaru;
        _sedangMenyegarkan = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _sedangMenyegarkan = false;
      });
    }
  }

  void _pilihKategori(String kategori) {
    if (kategori == _kategoriTerpilih) {
      return;
    }

    setState(() {
      _kategoriTerpilih = kategori;
    });
  }

  void _bukaDetail(Announcement announcement, List<Announcement> semua) {
    final int jumlahKategori = semua
        .where(
          (Announcement item) =>
              item.category.toLowerCase() ==
              announcement.category.toLowerCase(),
        )
        .length;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => AnnouncementDetailScreen(
          announcement: announcement,
          jumlahKategori: jumlahKategori,
        ),
      ),
    );
  }

  Widget _buildBarisPencarian() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        onChanged: (String value) {
          setState(() {
            _kataPencarian = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan judul...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _kataPencarian.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Hapus pencarian',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _kataPencarian = '';
                    });
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
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
            Text(
              error.toString().replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _cobaLagi,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong() {
    final String pesan = _kataPencarian.isEmpty
        ? 'Belum ada pengumuman untuk kategori '
              '$_kategoriTerpilih.'
        : 'Tidak ada pengumuman untuk kategori '
              '$_kategoriTerpilih dengan judul '
              '"$_kataPencarian".';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.inbox_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftar(List<Announcement> pengumuman, List<Announcement> semua) {
    return RefreshIndicator(
      onRefresh: _muatUlang,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pengumuman.length,
        itemBuilder: (BuildContext context, int index) {
          final Announcement announcement = pengumuman[index];

          return AnnouncementCard(
            announcement: announcement,
            onTap: () {
              _bukaDetail(announcement, semua);
            },
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
        title: Text('Portal Pengumuman TRPL ($_percobaan)'),
        backgroundColor: const Color(0xFF0284C7),
        foregroundColor: Colors.white,
        centerTitle: true,
        bottom: _sedangMenyegarkan
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: Colors.white,
                  backgroundColor: Color(0xFF7DD3FC),
                ),
              )
            : null,
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
          _buildBarisPencarian(),
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
                    // Loading awal
                    if (snapshot.connectionState != ConnectionState.done) {
                      return _buildMemuat();
                    }

                    // Error awal / retry
                    if (snapshot.hasError) {
                      return _buildGagal(snapshot.error!);
                    }

                    final List<Announcement> semua =
                        _dataTersimpan ??
                        snapshot.data ??
                        const <Announcement>[];

                    final String kataKunci = _kataPencarian
                        .trim()
                        .toLowerCase();

                    final List<Announcement> tampil = semua
                        .where((Announcement item) {
                          final bool cocokKategori =
                              _kategoriTerpilih == 'Semua' ||
                              item.category.toLowerCase() ==
                                  _kategoriTerpilih.toLowerCase();

                          final bool cocokJudul =
                              kataKunci.isEmpty ||
                              item.title.toLowerCase().contains(kataKunci);

                          return cocokKategori && cocokJudul;
                        })
                        .toList(growable: false);

                    if (tampil.isEmpty) {
                      return _buildKosong();
                    }

                    return _buildDaftar(tampil, semua);
                  },
            ),
          ),
        ],
      ),
    );
  }
}
