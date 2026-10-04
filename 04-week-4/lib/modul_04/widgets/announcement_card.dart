import 'package:flutter/material.dart';

import '../models/announcement.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme warna = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Tag kategori di kiri, tanggal di kanan.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: warna.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      announcement.category,
                      style: TextStyle(
                        color: warna.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    announcement.date,
                    style: TextStyle(
                      color: warna.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                announcement.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                announcement.author,
                style: TextStyle(color: warna.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
