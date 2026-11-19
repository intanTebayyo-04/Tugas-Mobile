
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang AirWatch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kenali aplikasi dan informasi di balik pemantauan kualitas udara.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.air_rounded,
                  size: 65,
                  color: Color(0xFF00897B),
                ),
                SizedBox(height: 12),
                Text(
                  'AirWatch',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00695C),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Pantau Udara, Jaga Kesehatan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF00796B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSection(
            icon: Icons.info_outline,
            title: 'Apa itu AirWatch?',
            description:
                'AirWatch merupakan aplikasi pemantauan kualitas udara yang menyediakan informasi indeks kualitas udara (AQI) dan parameter polutan dari berbagai stasiun pemantauan. Aplikasi ini membantu pengguna memahami kondisi udara di suatu wilayah.',
          ),

          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.flag_outlined,
            title: 'Tujuan Aplikasi',
            description:
                'Meningkatkan kesadaran masyarakat terhadap kualitas udara melalui penyajian informasi yang mudah dipahami, sehingga pengguna dapat mempertimbangkan kondisi udara dalam aktivitas sehari-hari.',
          ),

          const SizedBox(height: 16),

          _buildSection(
            icon: Icons.cloud_outlined,
            title: 'Sumber Data',
            description:
                'Data kualitas udara diperoleh melalui API World Air Quality Index (WAQI). Ketersediaan data bergantung pada stasiun pemantauan dan pembaruan dari penyedia data.',
          ),

          const SizedBox(height: 24),

          const Text(
            'Kategori Indeks Kualitas Udara',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _buildCategory(
            'Baik',
            '0–50',
            Colors.green,
          ),
          _buildCategory(
            'Sedang',
            '51–100',
            Colors.yellow.shade800,
          ),
          _buildCategory(
            'Tidak Sehat bagi Kelompok Sensitif',
            '101–150',
            Colors.orange,
          ),
          _buildCategory(
            'Tidak Sehat',
            '151–200',
            Colors.red,
          ),
          _buildCategory(
            'Sangat Tidak Sehat',
            '201–300',
            Colors.purple,
          ),
          _buildCategory(
            'Berbahaya',
            '301 ke atas',
            Colors.red.shade900,
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Pengembang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'AirWatch dikembangkan sebagai aplikasi pemantauan kualitas udara berbasis Flutter.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: Text(
              'AirWatch © 2026',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF00897B),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    String name,
    String range,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
