import '../../../modul_04/models/announcement.dart';
import 'announcement_repository.dart';

class SampleAnnouncementRepository implements AnnouncementRepository {
  final List<Announcement> _items = List<Announcement>.of(
    Announcement.getSampleAnnouncements(),
  );

  @override
  Future<List<Announcement>> getAnnouncements({String? category}) async {
    final List<Announcement> items = List<Announcement>.unmodifiable(_items);

    if (category == null || category == 'Semua') {
      return items;
    }

    return items
        .where(
          (Announcement item) =>
              item.category.toLowerCase() == category.toLowerCase(),
        )
        .toList(growable: false);
  }

  @override
  Future<Announcement> addAnnouncement(Announcement announcement) async {
    _items.add(announcement);
    return announcement;
  }
}
