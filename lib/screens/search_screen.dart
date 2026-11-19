
import 'package:flutter/material.dart';

import '../models/air_quality_station.dart';
import '../services/air_quality_service.dart';

class SearchScreen extends StatefulWidget {
  final Future<void> Function(AirQualityStation station, String city)
      onStationSelected;
  final Future<void> Function(String city) onFallbackRequested;

  const SearchScreen({
    super.key,
    required this.onStationSelected,
    required this.onFallbackRequested,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final AirQualityService _service = AirQualityService();

  List<AirQualityStation> _stations = [];
  bool _isSearching = false;
  String? _errorMessage;
  String? _searchedCity;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchCity() async {
    final city = _controller.text.trim();

    if (city.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan nama kota terlebih dahulu.';
        _stations = [];
        _searchedCity = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _stations = [];
      _searchedCity = city;
    });

    try {
      final results = await _service.searchCity(city);

      if (!mounted) return;

      if (results.isEmpty) {
        await widget.onFallbackRequested(city);
      } else {
        setState(() {
          _stations = results;
        });
      }
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().toLowerCase();

      if (message.contains('belum tersedia') ||
          message.contains('tidak tersedia')) {
        await widget.onFallbackRequested(city);
      } else {
        setState(() {
          _errorMessage = 'Pencarian gagal. Periksa koneksi internet '
              'atau konfigurasi API WAQI.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cari Kualitas Udara',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan nama kota untuk melihat informasi kualitas udara.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _searchCity(),
          decoration: InputDecoration(
            hintText: 'Contoh: Makassar, Jakarta, Surabaya',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              onPressed: _isSearching ? null : _searchCity,
              icon: const Icon(Icons.arrow_forward),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 16),

        if (_isSearching)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),

        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),

        if (!_isSearching && _stations.isNotEmpty) ...[
          Text(
            'Stasiun di $_searchedCity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._stations.map(
            (station) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.location_on),
                ),
                title: Text(station.name),
                subtitle: Text('AQI: ${station.aqi}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  widget.onStationSelected(station, _searchedCity!);
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
