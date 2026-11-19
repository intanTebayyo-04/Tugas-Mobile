
class AirQuality {
  final String city;
  final String stationName;
  final String location;
  final int? aqi;
  final String dominantPollutant;
  final Map<String, double> pollutants;
  final DateTime? observationTime;
  final String source;

  AirQuality({
    required this.city,
    required this.stationName,
    required this.location,
    required this.aqi,
    required this.dominantPollutant,
    required this.pollutants,
    required this.observationTime,
    required this.source,
  });

  // Mengubah data menjadi Map yang aman untuk dibaca.
  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  // Mengambil informasi lokasi stasiun.
  static String _getLocation(Map<String, dynamic> cityData) {
    final location = cityData['location']?.toString().trim() ?? '';

    if (location.isNotEmpty) {
      return location;
    }

    final geo = cityData['geo'];

    if (geo is List && geo.length >= 2) {
      return 'Latitude: ${geo[0]}, Longitude: ${geo[1]}';
    }

    return 'Lokasi tidak tersedia';
  }

  // Mengubah kode polutan menjadi nama yang mudah dipahami.
  static String getPollutantName(String code) {
    const pollutantNames = {
      'pm25': 'PM2.5',
      'pm10': 'PM10',
      'o3': 'Ozon (O₃)',
      'no2': 'Nitrogen Dioksida (NO₂)',
      'so2': 'Sulfur Dioksida (SO₂)',
      'co': 'Karbon Monoksida (CO)',
      'h': 'Kelembapan',
      'p': 'Tekanan Udara',
      't': 'Suhu',
      'w': 'Kecepatan Angin',
      'dew': 'Titik Embun',
    };

    return pollutantNames[code.toLowerCase()] ?? code.toUpperCase();
  }

  // Mengubah JSON dari WAQI menjadi objek AirQuality.
  factory AirQuality.fromJson(
    Map<String, dynamic> json, {
    required String selectedCity,
  }) {
    final cityData = _asMap(json['city']);
    final timeData = _asMap(json['time']);
    final iaqiData = _asMap(json['iaqi']);

    // Membaca nilai AQI.
    // Jika API mengembalikan "-", nilai akan menjadi null.
    final rawAqi = json['aqi'];
    final int? parsedAqi = int.tryParse(rawAqi?.toString() ?? '');

    // Membaca seluruh parameter kualitas udara.
    final Map<String, double> parsedPollutants = {};

    iaqiData.forEach((key, value) {
      final pollutantData = _asMap(value);
      final rawValue = pollutantData['v'];

      if (rawValue != null) {
        final number = double.tryParse(rawValue.toString());

        if (number != null) {
          parsedPollutants[key.toString()] = number;
        }
      }
    });

    // Membaca sumber data.
    final rawAttributions = json['attributions'];

    final List<dynamic> attributions =
        rawAttributions is List ? rawAttributions : [];

    final String source = attributions
        .whereType<Map>()
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .join(', ');

    // Membaca waktu pengamatan.
    final observationTime = DateTime.tryParse(
      timeData['iso']?.toString() ??
          timeData['s']?.toString() ??
          '',
    );

    return AirQuality(
      city: selectedCity,
      stationName:
          cityData['name']?.toString() ?? 'Tidak diketahui',
      location: _getLocation(cityData),
      aqi: parsedAqi,
      dominantPollutant:
          json['dominentpol']?.toString() ?? '-',
      pollutants: parsedPollutants,
      observationTime: observationTime,
      source: source.isEmpty ? 'Tidak diketahui' : source,
    );
  }
}
