
import 'package:flutter/material.dart';

import '../models/air_quality_model.dart';

class PollutantCard extends StatelessWidget {
  final Map<String, double> pollutants;

  const PollutantCard({
    super.key,
    required this.pollutants,
  });

  @override
  Widget build(BuildContext context) {
    const importantPollutants = [
      'pm25',
      'pm10',
      'o3',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kondisi Udara',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          ...importantPollutants.map((code) {
            final value = pollutants[code];

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F3F2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.air,
                      color: Color(0xFF159A9C),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      AirQuality.getPollutantName(code),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  Text(
                    value == null
                        ? '—'
                        : value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF159A9C),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
