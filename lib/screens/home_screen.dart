
import 'package:flutter/material.dart';

import '../models/air_quality_model.dart';
import '../models/air_quality_station.dart';
import '../models/open_meteo_model.dart';
import '../services/air_quality_service.dart';
import '../services/open_meteo_service.dart';
import '../widgets/top_navigation.dart';
import 'about_screen.dart';
import 'detail_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primary = Color(0xFF087F70);
  static const Color background = Color(0xFFF3F8F7);

  int _selectedIndex = 0;

  final AirQualityService _waqiService = AirQualityService();
  final OpenMeteoService _openMeteoService = OpenMeteoService();

  AirQuality? _waqiData;
  OpenMeteoAirQuality? _openMeteoData;

  bool _isLoading = false;
  String? _statusMessage;

  String _category(int? aqi) {
    if (aqi == null) return 'Data tidak tersedia';
    if (aqi <= 50) return 'Baik';
    if (aqi <= 100) return 'Sedang';
    if (aqi <= 150) return 'Tidak Sehat bagi Kelompok Sensitif';
    if (aqi <= 200) return 'Tidak Sehat';
    if (aqi <= 300) return 'Sangat Tidak Sehat';
    return 'Berbahaya';
  }

  Color _categoryColor(int? aqi) {
    if (aqi == null) return Colors.grey;
    if (aqi <= 50) return const Color(0xFF2EAA70);
    if (aqi <= 100) return const Color(0xFFE5A52E);
    if (aqi <= 150) return const Color(0xFFE77C35);
    if (aqi <= 200) return const Color(0xFFD94B4B);
    if (aqi <= 300) return const Color(0xFF8955B5);
    return const Color(0xFF7D3434);
  }

  Future<void> _loadWaqiData(
    AirQualityStation station,
    String city,
  ) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengambil data dari stasiun WAQI...';
      _waqiData = null;
      _openMeteoData = null;
    });

    try {
      final result = await _waqiService.fetchAirQuality(station, city);

      if (!mounted) return;

      if (result.aqi == null) {
        await _loadOpenMeteoData(city);
        return;
      }

      setState(() {
        _waqiData = result;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      await _loadOpenMeteoData(city);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadOpenMeteoData(String city) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Mengambil estimasi kualitas udara...';
      _waqiData = null;
      _openMeteoData = null;
    });

    try {
      final result = await _openMeteoService.fetchAirQuality(city);

      if (!mounted) return;

      setState(() {
        _openMeteoData = result;
        _statusMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _statusMessage =
            'Data kualitas udara untuk $city belum berhasil diperoleh '
            'dari WAQI maupun Open-Meteo.';
      });
    }
  }

  void _openWaqiDetail() {
    if (_waqiData == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(airQuality: _waqiData),
      ),
    );
  }

  void _openOpenMeteoDetail() {
    final data = _openMeteoData;
    if (data == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OpenMeteoDetailScreen(data: data),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087F70),
            Color(0xFF20A995),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.air,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AirWatch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pantau kualitas udara di sekitarmu',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.eco_outlined,
            color: Colors.white70,
            size: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF263B38),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EFEC)),
      ),
      child: SearchScreen(
        onStationSelected: _loadWaqiData,
        onFallbackRequested: _loadOpenMeteoData,
      ),
    );
  }

  Widget _buildAQIResult({
    required int? aqi,
    required String city,
    required String location,
    required String source,
    required VoidCallback onDetail,
    required bool isEstimate,
  }) {
    final color = _categoryColor(aqi);

    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EFEC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: primary, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  city,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isEstimate
                      ? const Color(0xFFFFF2DF)
                      : const Color(0xFFE4F5EF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isEstimate ? 'Estimasi' : 'Data Stasiun',
                  style: TextStyle(
                    color: isEstimate
                        ? const Color(0xFFB9781D)
                        : primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      aqi?.toString() ?? '-',
                      style: TextStyle(
                        color: color,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'US AQI',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _category(aqi),
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.cloud_outlined,
                  color: primary,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    source,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDetail,
              icon: const Icon(Icons.analytics_outlined),
              label: const Text('Lihat Detail Kualitas Udara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 23,
            height: 23,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: primary,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              'Sedang mengambil data kualitas udara...',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              _buildSectionTitle(
                'Cari Kota',
                'Temukan informasi kualitas udara berdasarkan kota.',
              ),
              const SizedBox(height: 14),
              _buildSearchCard(),
              if (_isLoading) _buildLoading(),
              if (_statusMessage != null && !_isLoading)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.deepOrange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_waqiData != null) ...[
                _buildSectionTitle(
                  'Hasil Pemantauan',
                  'Informasi berdasarkan pengukuran stasiun.',
                ),
                _buildAQIResult(
                  aqi: _waqiData!.aqi,
                  city: _waqiData!.city,
                  location: _waqiData!.stationName,
                  source: 'WAQI · Pengukuran stasiun',
                  onDetail: _openWaqiDetail,
                  isEstimate: false,
                ),
              ],
              if (_openMeteoData != null) ...[
                _buildSectionTitle(
                  'Hasil Pemantauan',
                  'Estimasi kualitas udara berdasarkan model.',
                ),
                _buildAQIResult(
                  aqi: _openMeteoData!.aqi,
                  city: _openMeteoData!.city,
                  location:
                      'Data koordinat lokasi: ${_openMeteoData!.latitude}, ${_openMeteoData!.longitude}',
                  source: 'Open-Meteo · Estimasi berbasis model',
                  onDetail: _openOpenMeteoDetail,
                  isEstimate: true,
                ),
              ],
              const SizedBox(height: 25),
              Center(
                child: Text(
                  'AirWatch · Informasi Kualitas Udara',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: TopNavigation(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: _selectedIndex == 0
                  ? _buildHomeContent()
                  : const AboutScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class OpenMeteoDetailScreen extends StatelessWidget {
  final OpenMeteoAirQuality data;

  const OpenMeteoDetailScreen({
    super.key,
    required this.data,
  });

  static const Color primary = Color(0xFF087F70);

  String _pollutantName(String code) {
    const names = {
      'pm2_5': 'PM2.5',
      'pm10': 'PM10',
      'ozone': 'Ozon (O₃)',
      'nitrogen_dioxide': 'Nitrogen Dioksida (NO₂)',
      'sulphur_dioxide': 'Sulfur Dioksida (SO₂)',
    };

    return names[code] ?? code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F7),
      appBar: AppBar(
        title: const Text('Detail Estimasi Udara'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF087F70),
                  Color(0xFF20A995),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi Pemantauan',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  data.city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'US AQI: ${data.aqi ?? '-'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Koordinat: ${data.latitude}, ${data.longitude}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text(
            'Konsentrasi Polutan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...data.pollutants.entries.map((entry) {
            final unit = data.units[entry.key] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 17,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F5EF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.air,
                      color: primary,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Text(
                      _pollutantName(entry.key),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${entry.value} $unit',
                    style: const TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE4F5EF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Catatan: Data Open-Meteo merupakan estimasi berbasis model '
              'kualitas udara. Nilainya dapat berbeda dari pengukuran '
              'langsung stasiun.',
              style: TextStyle(
                color: Color(0xFF376B61),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
