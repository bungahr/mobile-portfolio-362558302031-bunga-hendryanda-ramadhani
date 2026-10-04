import '../../../modul_04/models/announcement.dart';

abstract class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements({String? category});

  Future<Announcement> addAnnouncement(Announcement announcement);
}
