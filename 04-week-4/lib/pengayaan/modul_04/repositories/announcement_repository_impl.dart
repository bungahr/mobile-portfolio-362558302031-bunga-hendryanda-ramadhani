import 'package:dio/dio.dart';

import '../../../modul_04/models/announcement.dart';
import '../datasources/announcement_remote_datasource.dart';
import 'announcement_repository.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  AnnouncementRepositoryImpl({AnnouncementRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? AnnouncementRemoteDataSource();

  final AnnouncementRemoteDataSource _remoteDataSource;

  @override
  Future<List<Announcement>> getAnnouncements({String? category}) async {
    try {
      final List<Announcement> list = await _remoteDataSource
          .fetchAnnouncements();

      if (category == null || category == 'Semua') {
        return list;
      }

      return list
          .where(
            (Announcement item) =>
                item.category.toLowerCase() == category.toLowerCase(),
          )
          .toList(growable: false);
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'Koneksi ke server timeout. '
              'Periksa sambungan internet Anda.';
          break;

        case DioExceptionType.connectionError:
          errorMessage =
              'Gagal terhubung ke server. '
              'Periksa koneksi data atau Wi-Fi Anda.';
          break;

        case DioExceptionType.badResponse:
          errorMessage =
              'Server merespons dengan kesalahan '
              '(${e.response?.statusCode}).';
          break;

        default:
          errorMessage =
              'Terjadi kendala jaringan: '
              '${e.message ?? 'Kesalahan tidak diketahui'}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Gagal memuat pengumuman: $e');
    }
  }

  @override
  Future<Announcement> addAnnouncement(Announcement announcement) async {
    try {
      return await _remoteDataSource.createAnnouncement(announcement);
    } on DioException catch (e) {
      throw Exception(
        'Gagal mengirim pengumuman: '
        '${e.message}',
      );
    }
  }
}
