class KrsCourse {
  final String code;
  final String name;
  final String lecturer;
  final int sks;
  final String description;

  const KrsCourse({
    required this.code,
    required this.name,
    required this.lecturer,
    required this.sks,
    this.description = '',
  });

  static List<KrsCourse> getInitialCourses() {
    return const [
      KrsCourse(
        code: 'TRPL501',
        name: 'Pemrograman Perangkat Bergerak',
        lecturer: 'Sepyan Purnama Kristanto, M.Kom.',
        sks: 3,
        description:
            'Membangun aplikasi mobile cross-platform modern dengan Flutter.',
      ),
      KrsCourse(
        code: 'TRPL502',
        name: 'Rekayasa Perangkat Lunak Lanjut',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        description:
            'Penerapan konsep pengembangan perangkat lunak dan design pattern.',
      ),
      KrsCourse(
        code: 'TRPL503',
        name: 'Manajemen Basis Data Terdistribusi',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        description:
            'Mempelajari pengelolaan basis data untuk sistem berskala besar.',
      ),
      KrsCourse(
        code: 'TRPL504',
        name: 'Interoperabilitas Sistem',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        description: 'Mempelajari komunikasi dan pertukaran data antar sistem.',
      ),
      KrsCourse(
        code: 'TRPL505',
        name: 'Analisis dan Perancangan Sistem',
        lecturer: 'Tim Dosen TRPL',
        sks: 3,
        description:
            'Menganalisis kebutuhan dan merancang solusi sistem informasi.',
      ),
    ];
  }
}
