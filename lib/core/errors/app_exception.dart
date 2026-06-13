/// Exception standar yang digunakan di seluruh aplikasi.
///
/// Semua error dari API / network akan dikonversi menjadi [AppException]
/// agar user hanya melihat pesan yang ramah, bukan pesan teknis.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}
