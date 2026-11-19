
import 'package:flutter/material.dart';
import '../models/air_quality_model.dart';

class DetailScreen extends StatelessWidget {
  final AirQuality? airQuality;

  const DetailScreen({
    super.key,
    required this.airQuality,
  });

  static const Color primary = Color(0xFF087F70);
  static const Color background = Color(0xFFF3F8F7);

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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Waktu tidak tersedia';

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day/$month/$year, $hour:$minute';
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
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
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAQICard(AirQuality data) {
    final color = _categoryColor(data.aqi);

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087F70),
            Color(0xFF20A995),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.17),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70),
              SizedBox(width: 6),
              Text(
                'Lokasi Pemantauan',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            data.city,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.stationName,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        data.aqi?.toString() ?? '-',
                        style: TextStyle(
                          color: color,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'US AQI',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori Kualitas Udara',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _category(data.aqi),
                        style: TextStyle(
                          color: color,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        'Polutan dominan: ${AirQuality.getPollutantName(data.dominantPollutant)}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AirQuality data) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EFEC)),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.place_outlined,
            'Lokasi Stasiun',
            data.location,
          ),
          const Divider(height: 22),
          _infoRow(
            Icons.cloud_outlined,
            'Sumber Data',
            data.source,
          ),
          const Divider(height: 22),
          _infoRow(
            Icons.access_time,
            'Waktu Pengamatan',
            _formatDate(data.observationTime),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE4F5EF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF263B38),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPollutantCard(AirQuality data) {
    if (data.pollutants.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
        ),
        child: const Text(
          'Informasi parameter polutan belum tersedia.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EFEC)),
      ),
      child: Column(
        children: data.pollutants.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F5EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.air,
                    color: primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AirQuality.getPollutantName(entry.key),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF263B38),
                    ),
                  ),
                ),
                Text(
                  entry.value.toStringAsFixed(1),
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = airQuality;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Detail Kualitas Udara',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: primary,
        elevation: 0,
      ),
      body: data == null
          ? const Center(
              child: Text('Data kualitas udara tidak tersedia.'),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildAQICard(data),
                const SizedBox(height: 25),
                _sectionTitle(
                  'Informasi Pemantauan',
                  'Detail lokasi dan sumber pengukuran.',
                ),
                _buildInfoCard(data),
                const SizedBox(height: 25),
                _sectionTitle(
                  'Parameter Polutan',
                  'Nilai indeks parameter yang dilaporkan WAQI.',
                ),
                _buildPollutantCard(data),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4F5EF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: primary,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Catatan: Nilai parameter pada bagian ini '
                          'merupakan indeks individual yang dilaporkan '
                          'WAQI, bukan konsentrasi fisik polutan.',
                          style: TextStyle(
                            color: Color(0xFF376B61),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
