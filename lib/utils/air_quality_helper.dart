
import 'package:flutter/material.dart';

class AirQualityHelper {
  // Menentukan kategori kualitas udara berdasarkan nilai AQI.
  static String getCategory(int? aqi) {
    if (aqi == null || aqi < 0) {
      return 'Tidak tersedia';
    }

    if (aqi <= 50) return 'Baik';
    if (aqi <= 100) return 'Sedang';
    if (aqi <= 150) return 'Tidak Sehat bagi Kelompok Sensitif';
    if (aqi <= 200) return 'Tidak Sehat';
    if (aqi <= 300) return 'Sangat Tidak Sehat';

    return 'Berbahaya';
  }

  // Menentukan warna indikator berdasarkan kategori AQI.
  static Color getColor(int? aqi) {
    if (aqi == null || aqi < 0) {
      return Colors.grey;
    }

    if (aqi <= 50) return const Color(0xFF22A06B);
    if (aqi <= 100) return const Color(0xFFE5B52A);
    if (aqi <= 150) return const Color(0xFFED8B32);
    if (aqi <= 200) return const Color(0xFFE34D59);
    if (aqi <= 300) return const Color(0xFF8956B8);

    return const Color(0xFF7E263D);
  }

  // Memberikan rekomendasi kesehatan berdasarkan AQI.
  static String getRecommendation(int? aqi) {
    if (aqi == null || aqi < 0) {
      return 'Data kualitas udara belum tersedia. '
          'Silakan coba perbarui data beberapa saat lagi.';
    }

    if (aqi <= 50) {
      return 'Kualitas udara baik. Aktivitas di luar ruangan '
          'umumnya dapat dilakukan seperti biasa.';
    }

    if (aqi <= 100) {
      return 'Kualitas udara masih dapat diterima. '
          'Kelompok yang sangat sensitif sebaiknya '
          'memperhatikan kondisi kesehatan saat beraktivitas.';
    }

    if (aqi <= 150) {
      return 'Kelompok sensitif seperti anak-anak, lansia, '
          'dan penderita gangguan pernapasan sebaiknya '
          'membatasi aktivitas berat di luar ruangan.';
    }

    if (aqi <= 200) {
      return 'Masyarakat sebaiknya mengurangi aktivitas '
          'berat di luar ruangan. Kelompok sensitif '
          'disarankan menghindari aktivitas luar ruangan.';
    }

    if (aqi <= 300) {
      return 'Hindari aktivitas berat di luar ruangan. '
          'Gunakan perlindungan pernapasan yang sesuai '
          'dan perhatikan kondisi kesehatan.';
    }

    return 'Kondisi udara berbahaya. Hindari aktivitas '
        'di luar ruangan dan ikuti arahan dari pihak berwenang.';
  }

  // Memberikan penjelasan singkat kondisi kualitas udara.
  static String getDescription(int? aqi) {
    if (aqi == null || aqi < 0) {
      return 'Belum ada informasi kualitas udara.';
    }

    if (aqi <= 50) {
      return 'Udara bersih dengan tingkat pencemaran rendah.';
    }

    if (aqi <= 100) {
      return 'Kualitas udara cukup baik, tetapi perlu diperhatikan '
          'oleh individu yang sangat sensitif.';
    }

    if (aqi <= 150) {
      return 'Kelompok sensitif dapat mulai mengalami dampak '
          'kesehatan akibat kualitas udara.';
    }

    if (aqi <= 200) {
      return 'Dampak kesehatan dapat dirasakan oleh masyarakat.';
    }

    if (aqi <= 300) {
      return 'Risiko kesehatan meningkat bagi seluruh kelompok.';
    }

    return 'Kualitas udara sangat buruk dan berisiko tinggi '
        'bagi kesehatan.';
  }
}
