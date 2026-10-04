import 'package:flutter/material.dart';

void main() {
  runApp(const PoliwangiProfileApp());
}

class PoliwangiProfileApp extends StatelessWidget {
  const PoliwangiProfileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Profil Mahasiswa TRPL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D9488)),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Data Tantangan 2
  final String? githubUsername = 'github.com/bungahr';
  final String? fokusKeahlian = 'Mobile UI/UX & Flutter Development';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // APP BAR
      appBar: AppBar(
        title: const Text(
          'Profil Mahasiswa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // BODY
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // AVATAR
              // Tantangan 1 - Kustomisasi warna Avatar
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0D9488), width: 3),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  size: 52,
                  color: Color(0xFF0D9488),
                ),
              ),

              const SizedBox(height: 16),

              // NAMA MAHASISWA
              // Tantangan 1 - Identitas asli
              const Text(
                'Bunga Hendryanda Ramadhani',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),

              const SizedBox(height: 6),

              // NIM
              // Tantangan 1 - Identitas asli
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'NIM: 362558302031',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // KARTU INFORMASI AKADEMIK
              // Tahap 7.3 + Tantangan 2
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Jurusan
                      const _InfoRow(
                        icon: Icons.business_rounded,
                        label: 'Jurusan',
                        value: 'Bisnis dan Informatika',
                      ),

                      const Divider(height: 24, color: Color(0xFFF1F5F9)),

                      // Program Studi
                      const _InfoRow(
                        icon: Icons.code_rounded,
                        label: 'Program Studi',
                        value: 'Sarjana Terapan TRPL',
                      ),

                      const Divider(height: 24, color: Color(0xFFF1F5F9)),

                      // Kampus
                      const _InfoRow(
                        icon: Icons.location_on_rounded,
                        label: 'Kampus',
                        value: 'Politeknik Negeri Banyuwangi',
                      ),

                      const Divider(height: 24, color: Color(0xFFF1F5F9)),

                      // Semester / Tahun Akademik
                      const _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Semester / TA',
                        value: 'Semester 3 (2026/2027)',
                      ),

                      const Divider(height: 24, color: Color(0xFFF1F5F9)),

                      // TANTANGAN 2 - GITHUB
                      _ProfileInfoRow(
                        icon: Icons.code_rounded,
                        label: 'Repositori GitHub',
                        value: githubUsername ?? '(belum diatur)',
                      ),

                      const Divider(height: 24, color: Color(0xFFF1F5F9)),

                      // TANTANGAN 2 - FOKUS KEAHLIAN
                      _ProfileInfoRow(
                        icon: Icons.star_rounded,
                        label: 'Fokus Keahlian',
                        value: fokusKeahlian ?? '(belum diatur)',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // TOMBOL VERIFIKASI
              // Tahap 7.4
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Status: Mahasiswa Aktif TRPL — Angkatan 2025',
                        ),
                        backgroundColor: Color(0xFF0D9488),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_user_rounded),
                  label: const Text('Verifikasi Status Mahasiswa'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

// WIDGET _INFO ROW
// Tahap 7.3

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
        // ICON
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        ),

        const SizedBox(width: 14),

        // INFORMASI
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// WIDGET _PROFILE INFO ROW
// Tantangan 2

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ICON
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        ),

        const SizedBox(width: 14),

        // INFORMASI
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
