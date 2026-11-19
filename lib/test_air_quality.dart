
import 'models/air_quality_station.dart';

import 'package:flutter/material.dart';

import 'models/air_quality_model.dart';

import 'services/air_quality_service.dart';

void main() {
  runApp(const TestAirQualityApp());
}

class TestAirQualityApp extends StatelessWidget {
  const TestAirQualityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestSearchPage(),
    );
  }
}

class TestSearchPage extends StatefulWidget {
  const TestSearchPage({super.key});

  @override
  State<TestSearchPage> createState() => _TestSearchPageState();
}

class _TestSearchPageState extends State<TestSearchPage> {
  final AirQualityService service = AirQualityService();
  final TextEditingController controller = TextEditingController();

  bool isLoading = false;
  bool isDetailLoading = false;

  String message = '';
  String detailMessage = '';

  List<AirQualityStation> stations = [];
  AirQuality? selectedAirQuality;

  // Mencari stasiun berdasarkan nama kota
  Future<void> searchCity() async {
    setState(() {
      isLoading = true;
      message = '';
      stations = [];
      selectedAirQuality = null;
      detailMessage = '';
    });

    try {
      final result = await service.searchCity(controller.text);

      if (!mounted) return;

      setState(() {
        stations = result;
        message = result.isEmpty
            ? 'Stasiun tidak ditemukan.'
            : 'Ditemukan ${result.length} stasiun.';
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Mengambil detail kualitas udara dari stasiun terpilih
  Future<void> selectStation(AirQualityStation station) async {
    setState(() {
      isDetailLoading = true;
      selectedAirQuality = null;
      detailMessage = '';
    });

    try {
      final result = await service.fetchAirQuality(
        station,
        controller.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        selectedAirQuality = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        detailMessage = 'Gagal mengambil detail: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isDetailLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String formatObservationTime(DateTime? time) {
  if (time == null) {
    return 'Waktu tidak tersedia';
  }

  final localTime = time.toLocal();

  final day = localTime.day.toString().padLeft(2, '0');
  final month = localTime.month.toString().padLeft(2, '0');
  final year = localTime.year;

  final hour = localTime.hour.toString().padLeft(2, '0');
  final minute = localTime.minute.toString().padLeft(2, '0');

  return '$day-$month-$year, $hour:$minute (Waktu lokal perangkat)';
}

 String getDataStatus(DateTime? time) {
    if (time == null) {
      return 'Waktu tidak tersedia';
    }

    final now = DateTime.now();
    final observationTime = time.toLocal();
    final difference = now.difference(observationTime);

    if (difference.isNegative) {
      return 'Waktu pengukuran tidak valid';
    }

    if (difference <= const Duration(hours: 1)) {
      return 'Data Terbaru';
    }

    if (difference <= const Duration(hours: 3)) {
      return 'Data Tertunda';
    }

    return 'Data Lama';
  }

  @override
  Widget build(BuildContext context) {
    final airQuality = selectedAirQuality;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tes Kualitas Udara'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Masukkan nama kota',
                hintText: 'Contoh: Makassar',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: isLoading ? null : searchCity,
              child: const Text('Cari Stasiun'),
            ),

const SizedBox(height: 12),

if (isLoading)
  const CircularProgressIndicator(),

Text(message),

Expanded(
  child: ListView(
    children: [
      // Daftar stasiun
      ...stations.map((station) {
        if (station == null) {
          return const SizedBox.shrink();
        }

        return ListTile(
          title: Text(station.name),
          subtitle: Text('AQI: ${station.aqi}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => selectStation(station),
        );
      }),
    ],
  ),
),

                  const Divider(),

                  // Detail stasiun terpilih
                  if (isDetailLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    ),

                  if (detailMessage.isNotEmpty)
                    Text(detailMessage),

                  if (airQuality != null) ...[
                    const Text(
                      'DETAIL KUALITAS UDARA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text('Kota: ${airQuality.city}'),
                    Text('Stasiun: ${airQuality.stationName}'),
                    Text('Lokasi: ${airQuality.location}'),

                    const SizedBox(height: 12),

                    Text(
                      'AQI: ${airQuality.aqi ?? "Tidak tersedia"}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      'Polutan dominan: ${airQuality.dominantPollutant}',
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Data Polutan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (airQuality.pollutants.isEmpty)
                      const Text('Data polutan tidak tersedia.'),

                   ...airQuality.pollutants.entries.map((entry) {
  final name = AirQuality.getPollutantName(entry.key);

  return Text('$name: ${entry.value}');
}),

                    const SizedBox(height: 12),

                    Text(
  'Waktu pengukuran: '
  '${formatObservationTime(airQuality.observationTime)}',
),



                    Text('Sumber: ${airQuality.source}'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
