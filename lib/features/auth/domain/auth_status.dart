/// Enum untuk status autentikasi
enum AuthStatus {
  /// Status awal saat app launch
  initial,

  /// Sedang memproses request (login/register/logout)
  loading,

  /// User sudah terautentikasi
  authenticated,

  /// User belum terautentikasi
  unauthenticated,

  /// Terjadi error
  error,
}