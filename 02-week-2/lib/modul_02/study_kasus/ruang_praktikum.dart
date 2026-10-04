import 'package:flutter/material.dart';

class RuangPraktikum extends StatefulWidget {
  const RuangPraktikum({super.key});

  @override
  State<RuangPraktikum> createState() => _RuangPraktikumState();
}

class _RuangPraktikumState extends State<RuangPraktikum> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Portrait
          if (constraints.maxWidth < 600) {
            return _buildPortrait();
          }

          // Landscape / tablet / desktop
          return _buildLandscape();
        },
      ),
    );
  }

  // PORTRAIT
  Widget _buildPortrait() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 16),

            _buildPraktikumCard(
              title: 'Mobile Programming',
              time: '08.00 – 10.00',
              room: 'Lab 1',
              status: 'Berlangsung',
              statusType: StatusType.ongoing,
              information: 'Sedang digunakan\noleh praktikan',
            ),

            const SizedBox(height: 12),

            _buildPraktikumCard(
              title: 'Rekayasa Perangkat Lunak',
              time: '10.00 – 12.00',
              room: 'Lab 2',
              status: 'Akan datang',
              statusType: StatusType.upcoming,
              information: 'Sesi akan dimulai\nsebentar lagi',
            ),

            const SizedBox(height: 12),

            _buildPraktikumCard(
              title: 'Basis Data',
              time: '13.00 – 15.00',
              room: 'Lab 3',
              status: 'Selesai',
              statusType: StatusType.finished,
              information: 'Sesi telah selesai',
            ),
          ],
        ),
      ),
    );
  }

  // LANDSCAPE
  Widget _buildLandscape() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 16),
            _buildSummary(),
            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildPraktikumCard(
                        title: 'Mobile Programming',
                        time: '08.00 – 10.00',
                        room: 'Lab 1',
                        status: 'Berlangsung',
                        statusType: StatusType.ongoing,
                        information: 'Sedang digunakan\noleh praktikan',
                      ),
                      const SizedBox(height: 16),
                      _buildPraktikumCard(
                        title: 'Basis Data',
                        time: '13.00 – 15.00',
                        room: 'Lab 3',
                        status: 'Selesai',
                        statusType: StatusType.finished,
                        information: 'Sesi telah selesai',
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    children: [
                      _buildPraktikumCard(
                        title: 'Rekayasa Perangkat Lunak',
                        time: '10.00 – 12.00',
                        room: 'Lab 2',
                        status: 'Akan datang',
                        statusType: StatusType.upcoming,
                        information: 'Sesi akan dimulai\nsebentar lagi',
                      ),
                      const SizedBox(height: 16),
                      _buildAvailableRoomCard(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // JUDUL
  Widget _buildTitle() {
    return const Text(
      'Ruang Praktikum Hari Ini',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Color(0xFF101B3A),
      ),
    );
  }

  // =========================
  // SUMMARY
  // =========================

  Widget _buildSummary() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Color(0xFF1688D8),
                size: 21,
              ),
              SizedBox(width: 10),
              Text(
                '3 sesi',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF155A8A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFE4F5EC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.meeting_room,
                color: Color(0xFF168B59),
                size: 21,
              ),
              SizedBox(width: 10),
              Text(
                '1 ruang tersedia',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF23754F),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PRAKTIKUM CARD
  Widget _buildPraktikumCard({
    required String title,
    required String time,
    required String room,
    required String status,
    required StatusType statusType,
    required String information,
  }) {
    Color statusColor;
    Color statusTextColor;
    Color infoBackground;
    IconData infoIcon;

    switch (statusType) {
      case StatusType.ongoing:
        statusColor = const Color(0xFF168BD8);
        statusTextColor = Colors.white;
        infoBackground = const Color(0xFFE1F2FF);
        infoIcon = Icons.groups;
        break;

      case StatusType.upcoming:
        statusColor = const Color(0xFFFFE5AD);
        statusTextColor = const Color(0xFF805000);
        infoBackground = const Color(0xFFFFF7E4);
        infoIcon = Icons.access_time;
        break;

      case StatusType.finished:
        statusColor = const Color(0xFFE3E5E8);
        statusTextColor = const Color(0xFF435064);
        infoBackground = const Color(0xFFF0F2F5);
        infoIcon = Icons.check_circle;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFDDE3EA),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101B3A),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Color(0xFF445268),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF263752),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF445268),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                room,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF263752),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: infoBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  infoIcon,
                  size: 28,
                  color: statusType == StatusType.ongoing
                      ? const Color(0xFF168BD8)
                      : statusType == StatusType.upcoming
                          ? const Color(0xFF704A00)
                          : const Color(0xFF445268),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    information,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF263752),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RUANG TERSEDIA
  Widget _buildAvailableRoomCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3FBF7),
        border: Border.all(
          color: const Color(0xFFD5EDE1),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lab 2',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101B3A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2B9A70),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'Tersedia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Row(
            children: [
              Icon(
                Icons.meeting_room,
                color: Color(0xFF445268),
                size: 28,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Ruang tersedia\ndi luar jadwal sesi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF263752),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFDDF3E8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.meeting_room,
                  color: Color(0xFF21895F),
                  size: 28,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Siap digunakan\nuntuk praktikum lain',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF263752),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType {
  ongoing,
  upcoming,
  finished,
}