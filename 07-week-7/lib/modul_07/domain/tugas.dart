class Tugas {
  final String id;

  final String judul;
  final String mataKuliah;
  final bool selesai;

  // Format tanggal pada contoh ini adalah ISO-8601. Entity juga dapat
  // menggunakan DateTime; pemilihan String bukan aturan arsitektur.
  final String dibuatPada;

  final int prioritas;

  const Tugas({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.dibuatPada,
    this.selesai = false,
    this.prioritas = 2,
  });

  Tugas salinDengan({
    String? judul,
    String? mataKuliah,
    bool? selesai,
    int? prioritas,
  }) {
    return Tugas(
      id: id,
      judul: judul ?? this.judul,
      mataKuliah: mataKuliah ?? this.mataKuliah,
      dibuatPada: dibuatPada,
      selesai: selesai ?? this.selesai,
      prioritas: prioritas ?? this.prioritas,
    );
  }

  static String labelPrioritas(int prioritas) {
    switch (prioritas) {
      case 1:
        return 'Tinggi';
      case 3:
        return 'Rendah';
      default:
        return 'Sedang';
    }
  }

  static DateTime? bacaTanggal(Tugas tugas) =>
      DateTime.tryParse(tugas.dibuatPada);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tugas && other.id == id && other.selesai == selesai);

  @override
  int get hashCode => Object.hash(id, selesai);

  @override
  String toString() => 'Tugas($id, "$judul", selesai: $selesai)';
}
