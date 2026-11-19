
class TimeHelper {
  // Mengubah waktu pengamatan ke waktu lokal perangkat.
  static DateTime? toLocalTime(DateTime? observationTime) {
    if (observationTime == null) {
      return null;
    }

    return observationTime.toLocal();
  }

  // Format waktu pengamatan.
  static String formatObservationTime(DateTime? observationTime) {
    final localTime = toLocalTime(observationTime);

    if (localTime == null) {
      return 'Waktu tidak tersedia';
    }

    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final year = localTime.year;

    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year, $hour:$minute';
  }

  // Menentukan status kesegaran data.
  static String getDataStatus(DateTime? observationTime) {
    final localTime = toLocalTime(observationTime);

    if (localTime == null) {
      return 'Waktu tidak tersedia';
    }

    final difference = DateTime.now().difference(localTime);

    if (difference.isNegative) {
      return 'Waktu pengamatan tidak valid';
    }

    if (difference.inMinutes <= 60) {
      return 'Data Terbaru';
    }

    if (difference.inMinutes <= 180) {
      return 'Data Tertunda';
    }

    return 'Data Lama';
  }
}
