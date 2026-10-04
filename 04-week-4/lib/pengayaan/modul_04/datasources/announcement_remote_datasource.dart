import 'package:dio/dio.dart';

import '../../../modul_04/models/announcement.dart';

class AnnouncementRemoteDataSource {
  AnnouncementRemoteDataSource({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://jsonplaceholder.typicode.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: <String, String>{
                'Accept': 'application/json',
                'User-Agent': 'PoliwangiMobileApp/1.0',
              },
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          return handler.next(options);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          return handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;

  Future<List<Announcement>> fetchAnnouncements() async {
    final Response<dynamic> response = await _dio.get('/posts');

    if (response.statusCode != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message:
            'Server merespons dengan status '
            '${response.statusCode}',
      );
    }

    final List<dynamic> data = response.data as List<dynamic>;

    const List<String> categories = <String>[
      'Akademik',
      'Beasiswa',
      'Kegiatan',
      'Prestasi',
    ];

    return data
        .take(10)
        .toList()
        .asMap()
        .entries
        .map((MapEntry<int, dynamic> entry) {
          final int index = entry.key;

          final Map<String, dynamic> item = entry.value as Map<String, dynamic>;

          return Announcement(
            id: item['id'] as int? ?? index + 1,
            title: item['title'] as String? ?? 'Pengumuman Kampus',
            content: item['body'] as String? ?? 'Konten pengumuman akademik.',
            author: 'Bagian Akademik Poliwangi',
            category: categories[index % categories.length],
            date: '2026-09-${(index % 28 + 1).toString().padLeft(2, '0')}',
            readCount: (index + 1) * 37,
          );
        })
        .toList(growable: false);
  }

  Future<Announcement> createAnnouncement(Announcement announcement) async {
    final Response<dynamic> response = await _dio.post(
      '/posts',
      data: announcement.toJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return announcement;
    }

    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Gagal membuat pengumuman baru',
    );
  }
}
