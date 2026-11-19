
class AirQualityStation {
  final int uid;
  final String name;
  final String url;
  final String aqi;

  AirQualityStation({
    required this.uid,
    required this.name,
    required this.url,
    required this.aqi,
  });

  factory AirQualityStation.fromJson(Map<String, dynamic> json) {
    final stationData = json['station'];

    final Map<String, dynamic> station =
        stationData is Map
            ? Map<String, dynamic>.from(stationData)
            : <String, dynamic>{};

    return AirQualityStation(
      uid: int.tryParse(json['uid']?.toString() ?? '') ?? 0,
      name: station['name']?.toString() ?? 'Stasiun tidak diketahui',
      url: station['url']?.toString() ?? '',
      aqi: json['aqi']?.toString() ?? '-',
    );
  }
}
