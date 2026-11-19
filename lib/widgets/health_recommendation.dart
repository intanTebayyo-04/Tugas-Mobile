
import 'package:flutter/material.dart';

import '../utils/air_quality_helper.dart';

class HealthRecommendation extends StatelessWidget {
  final int? aqi;

  const HealthRecommendation({
    super.key,
    required this.aqi,
  });

  @override
  Widget build(BuildContext context) {
    final recommendation =
        AirQualityHelper.getRecommendation(aqi);

    final color = AirQualityHelper.getColor(aqi);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            color: color,
            size: 28,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rekomendasi Kesehatan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF126F70),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  recommendation,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF456B69),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
