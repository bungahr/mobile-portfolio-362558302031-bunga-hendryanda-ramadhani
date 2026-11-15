import 'package:flutter/material.dart';

import '../../../modul_11/widgets/kartu_tugas_performa.dart';
import '../presentation/pengendali_halaman.dart';

class LayarDaftarBerhalaman extends StatefulWidget {
  const LayarDaftarBerhalaman({required this.pengendali, super.key});

  final PengendaliHalaman pengendali;

  @override
  State<LayarDaftarBerhalaman> createState() => _LayarDaftarBerhalamanState();
}

class _LayarDaftarBerhalamanState extends State<LayarDaftarBerhalaman> {
  static const double _ambangPemicu = 400;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _periksaDanMuat();
      }
    });
  }

  void _periksaDanMuat() {
    if (!mounted) return;

    final PengendaliHalaman p = widget.pengendali;

    if (p.galat != null || p.sedangMemuat || !p.adaBerikutnya) {
      return;
    }

    final ScrollPosition? posisi = _scrollController.hasClients
        ? _scrollController.position
        : null;

    if (posisi == null || posisi.extentAfter < _ambangPemicu) {
      p.muatBerikutnya();
    }
  }

  bool _saatGulir(ScrollNotification notifikasi) {
    final PengendaliHalaman p = widget.pengendali;

    if (p.galat != null || p.sedangMemuat || !p.adaBerikutnya) {
      return false;
    }

    if (notifikasi.metrics.extentAfter < _ambangPemicu) {
      p.muatBerikutnya();
    }

    return false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Kuliah — Berhalaman')),
      body: ListenableBuilder(
        listenable: widget.pengendali,
        builder: (BuildContext context, Widget? child) {
          final PengendaliHalaman p = widget.pengendali;

          if (p.item.isEmpty && p.sedangMemuat) {
            return const Center(child: CircularProgressIndicator());
          }

          if (p.item.isEmpty && p.galat != null) {
            return _PanelGalat(pesan: p.galat!, onCobaLagi: p.muatBerikutnya);
          }

          return NotificationListener<ScrollNotification>(
            onNotification: _saatGulir,
            child: ListView.builder(
              controller: _scrollController,
              key: const ValueKey<String>('paged-list'),
              itemCount: p.item.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index < p.item.length) {
                  return KartuTugasPerforma(tugas: p.item[index]);
                }

                if (p.galat != null) {
                  return _PanelGalat(
                    pesan: p.galat!,
                    onCobaLagi: p.muatBerikutnya,
                  );
                }

                if (p.sedangMemuat || p.adaBerikutnya) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('Semua ${p.item.length} tugas sudah dimuat.'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PanelGalat extends StatelessWidget {
  const _PanelGalat({required this.pesan, required this.onCobaLagi});

  final String pesan;
  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(pesan, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onCobaLagi, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}
