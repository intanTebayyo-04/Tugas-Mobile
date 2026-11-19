
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/open_meteo_model.dart';

class OpenMeteoService {
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const String _airQualityUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  Future<OpenMeteoAirQuality> fetchAirQuality(
    String city,
  ) async {
    try {
      // 1. Cari koordinat kota di Indonesia.
      final geocodingUri = Uri.parse(_geocodingUrl).replace(
        queryParameters: {
          'name': city,
          'count': '10',
          'language': 'en',
          'format': 'json',
          'countryCode': 'ID',
        },
      );

      final geoResponse = await http
          .get(geocodingUri)
          .timeout(const Duration(seconds: 20));

      if (geoResponse.statusCode != 200) {
        throw Exception('Gagal mencari koordinat kota.');
      }

      final geoData = jsonDecode(geoResponse.body)
          as Map<String, dynamic>;

      final results = geoData['results'] as List?;

      if (results == null || results.isEmpty) {
        throw Exception('Koordinat kota tidak ditemukan.');
      }

      // 2. Ambil koordinat hasil pencarian pertama.
      final cityData = results.first as Map<String, dynamic>;

      final latitude = (cityData['latitude'] as num).toDouble();
      final longitude = (cityData['longitude'] as num).toDouble();

      // 3. Ambil data kualitas udara.
      final airQualityUri = Uri.parse(_airQualityUrl).replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current':
              'us_aqi,pm2_5,pm10,ozone,nitrogen_dioxide,sulphur_dioxide',
          'hourly': 'us_aqi,pm2_5,pm10',
          'timezone': 'Asia/Makassar',
        },
      );

      final airResponse = await http
          .get(airQualityUri)
          .timeout(const Duration(seconds: 20));

      if (airResponse.statusCode != 200) {
        throw Exception('Gagal mengambil data kualitas udara.');
      }

      final airData = jsonDecode(airResponse.body)
          as Map<String, dynamic>;

      return OpenMeteoAirQuality.fromJson(
        airData,
        city: cityData['name']?.toString() ?? city,
      );
    } catch (e) {
      throw Exception('Open-Meteo: ${e.toString()}');
    }
  }
}
