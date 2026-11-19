
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/air_quality_model.dart';
import '../models/air_quality_station.dart';

class AirQualityService {
  static const Duration _timeout = Duration(seconds: 20);

  // Batas jarak stasiun dari pusat kota.
  static const double _maxDistanceKm = 20;

  void _validateToken() {
    if (ApiConfig.token.isEmpty ||
        ApiConfig.token == 'MASUKKAN_TOKEN_WAQI_DI_SINI') {
      throw Exception(
        'Token WAQI belum diatur. Periksa api_config.dart.',
      );
    }
  }

  Map<String, dynamic> _decodeResponse(String body) {
    final decoded = jsonDecode(body);

    if (decoded is! Map) {
      throw Exception('Format respons API tidak valid.');
    }

    return Map<String, dynamic>.from(decoded);
  }

  void _checkApiStatus(Map<String, dynamic> response) {
    if (response['status'] != 'ok') {
      throw Exception(
        response['data']?.toString() ??
            'Gagal mengambil data dari WAQI.',
      );
    }
  }

  bool _isIndonesia(double lat, double lon) {
    return lat >= -11 &&
        lat <= 6 &&
        lon >= 95 &&
        lon <= 141;
  }

  double _distanceInKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;

    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;

    final a = pow(sin(dLat / 2), 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            pow(sin(dLon / 2), 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Mencari koordinat kota secara otomatis.
  Future<List<double>?> _getCityCoordinates(
    String cityName,
  ) async {
    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': cityName,
        'count': '10',
        'language': 'en',
        'format': 'json',
        'countryCode': 'ID',
      },
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mendapatkan koordinat kota.',
      );
    }

    final json = _decodeResponse(response.body);
    final results = json['results'];

    if (results is! List) {
      return null;
    }

    for (final item in results) {
      if (item is! Map) continue;

      final result = Map<String, dynamic>.from(item);

      if (result['country_code'] != 'ID') continue;

      final lat = double.tryParse(
        result['latitude']?.toString() ?? '',
      );

      final lon = double.tryParse(
        result['longitude']?.toString() ?? '',
      );

      if (lat == null || lon == null) continue;
      if (!_isIndonesia(lat, lon)) continue;

      return [lat, lon];
    }

    return null;
  }

  // Pencarian stasiun berdasarkan nama kota.
  Future<List<AirQualityStation>> _searchByName(
    String keyword,
    List<double>? cityCoordinates,
  ) async {
    final uri = Uri.https(
      'api.waqi.info',
      '/search/',
      {
        'keyword': keyword,
        'token': ApiConfig.token,
      },
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Server WAQI mengalami masalah. '
        'Kode: ${response.statusCode}',
      );
    }

    final json = _decodeResponse(response.body);
    _checkApiStatus(json);

    final rawData = json['data'];

    if (rawData is! List) {
      return [];
    }

    final results = <AirQualityStation>[];

    for (final item in rawData) {
      if (item is! Map) continue;

      final stationData = item['station'];

      if (stationData is! Map) continue;

      final station = Map<String, dynamic>.from(stationData);
      final geo = station['geo'];

      if (geo is! List || geo.length < 2) continue;

      final lat = double.tryParse(geo[0].toString());
      final lon = double.tryParse(geo[1].toString());

      if (lat == null || lon == null) continue;
      if (!_isIndonesia(lat, lon)) continue;

      // Jika koordinat kota tersedia, validasi jarak stasiun.
      if (cityCoordinates != null) {
        final distance = _distanceInKm(
          cityCoordinates[0],
          cityCoordinates[1],
          lat,
          lon,
        );

        if (distance > _maxDistanceKm) continue;
      } else {
        // Jika geocoding tidak menemukan kota,
        // gunakan kecocokan nama yang utuh.
        final stationName =
            station['name']?.toString() ?? '';

        final pattern = RegExp(
          r'\b' + RegExp.escape(keyword) + r'\b',
          caseSensitive: false,
        );

        if (!pattern.hasMatch(stationName)) continue;
      }

      final parsedStation = AirQualityStation.fromJson(
        Map<String, dynamic>.from(item),
      );

      if (parsedStation.uid <= 0) continue;

      if (!results.any(
        (station) => station.uid == parsedStation.uid,
      )) {
        results.add(parsedStation);
      }
    }

    return results;
  }

  // Mengambil stasiun terdekat berdasarkan koordinat kota.
  Future<List<AirQualityStation>> _searchByCoordinates(
    List<double> coordinates,
  ) async {
    final latitude = coordinates[0];
    final longitude = coordinates[1];

    final uri = Uri.https(
      'api.waqi.info',
      '/feed/geo:$latitude;$longitude/',
      {
        'token': ApiConfig.token,
      },
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      return [];
    }

    final json = _decodeResponse(response.body);

    if (json['status'] != 'ok') {
      return [];
    }

    final rawData = json['data'];

    if (rawData is! Map) {
      return [];
    }

    final data = Map<String, dynamic>.from(rawData);
    final cityData = data['city'];

    if (cityData is! Map) {
      return [];
    }

    final city = Map<String, dynamic>.from(cityData);
    final geo = city['geo'];

    if (geo is! List || geo.length < 2) {
      return [];
    }

    final lat = double.tryParse(geo[0].toString());
    final lon = double.tryParse(geo[1].toString());

    if (lat == null || lon == null) {
      return [];
    }

    if (!_isIndonesia(lat, lon)) {
      return [];
    }

    final distance = _distanceInKm(
      latitude,
      longitude,
      lat,
      lon,
    );

    if (distance > _maxDistanceKm) {
      return [];
    }

    final uid = int.tryParse(
      data['idx']?.toString() ?? '',
    );

    if (uid == null || uid <= 0) {
      return [];
    }

    return [
      AirQualityStation(
        uid: uid,
        name: city['name']?.toString() ??
            'Stasiun terdekat',
        url: city['url']?.toString() ?? '',
        aqi: data['aqi']?.toString() ?? '-',
      ),
    ];
  }

  // Fungsi utama pencarian kota.
  Future<List<AirQualityStation>> searchCity(
    String keyword,
  ) async {
    _validateToken();

    final searchKeyword = keyword.trim();

    if (searchKeyword.isEmpty) {
      throw Exception('Nama kota tidak boleh kosong.');
    }

    // Tahap 1: cari koordinat kota secara dinamis.
    final coordinates = await _getCityCoordinates(
      searchKeyword,
    );

    // Tahap 2: cari stasiun berdasarkan nama.
    final nameResults = await _searchByName(
      searchKeyword,
      coordinates,
    );

    // Tahap 3: cari stasiun terdekat berdasarkan koordinat.
    final coordinateResults = coordinates == null
        ? <AirQualityStation>[]
        : await _searchByCoordinates(coordinates);

    // Tahap 4: gabungkan hasil tanpa UID duplikat.
    final combinedResults = <AirQualityStation>[
      ...nameResults,
    ];

    for (final station in coordinateResults) {
      if (!combinedResults.any(
        (item) => item.uid == station.uid,
      )) {
        combinedResults.add(station);
      }
    }

    if (combinedResults.isEmpty) {
      throw Exception(
        'Data stasiun kualitas udara untuk '
        '$searchKeyword belum tersedia.',
      );
    }

    return combinedResults;
  }

  // Mengambil detail kualitas udara dari stasiun terpilih.
  Future<AirQuality> fetchAirQuality(
    AirQualityStation station,
    String selectedCity,
  ) async {
    _validateToken();

    if (station.uid <= 0) {
      throw Exception('ID stasiun tidak valid.');
    }

    final uri = Uri.https(
      'api.waqi.info',
      '/feed/@${station.uid}/',
      {
        'token': ApiConfig.token,
      },
    );

    final response = await http.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil detail kualitas udara. '
        'Kode: ${response.statusCode}',
      );
    }

    final json = _decodeResponse(response.body);
    _checkApiStatus(json);

    final rawData = json['data'];

    if (rawData is! Map) {
      throw Exception(
        'Detail kualitas udara tidak tersedia.',
      );
    }

    return AirQuality.fromJson(
      Map<String, dynamic>.from(rawData),
      selectedCity: selectedCity,
    );
  }
}
