
class OpenMeteoAirQuality {
  final String city;
  final double latitude;
  final double longitude;
  final int? aqi;
  final Map<String, double> pollutants;
  final DateTime? observationTime;
  final Map<String, String> units;

  OpenMeteoAirQuality({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.aqi,
    required this.pollutants,
    required this.observationTime,
    required this.units,
  });

  factory OpenMeteoAirQuality.fromJson(
    Map<String, dynamic> json, {
    required String city,
  }) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final currentUnits =
        json['current_units'] as Map<String, dynamic>? ?? {};

    double? readValue(String key) {
      final value = current[key];
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    final pollutants = <String, double>{};

    final pollutantKeys = [
      'pm2_5',
      'pm10',
      'ozone',
      'nitrogen_dioxide',
      'sulphur_dioxide',
    ];

    for (final key in pollutantKeys) {
      final value = readValue(key);
      if (value != null) {
        pollutants[key] = value;
      }
    }

    final units = <String, String>{};

    for (final key in pollutantKeys) {
      final unit = currentUnits[key];
      if (unit != null) {
        units[key] = unit.toString();
      }
    }

    final aqiValue = readValue('us_aqi');
    final timeString = current['time']?.toString();

    return OpenMeteoAirQuality(
      city: city,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      aqi: aqiValue?.round(),
      pollutants: pollutants,
      observationTime: timeString == null
          ? null
          : DateTime.tryParse(timeString),
      units: units,
    );
  }
}
