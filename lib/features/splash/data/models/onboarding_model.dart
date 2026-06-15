import 'package:equatable/equatable.dart';

class OnboardingData extends Equatable {
  final String lottiePath;
  final String title;
  final String description;

  const OnboardingData({
    required this.lottiePath,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [lottiePath, title, description];
}

class OnboardingContents {
  static const List<OnboardingData> screens = [
    OnboardingData(
      lottiePath: 'assets/lottie/noodle.json',
      title: 'Selamat Datang di Warmindo Purnama',
      description:
          'Nikmati berbagai menu lezat dengan harga terjangkau. Pesan makanan favorit Anda dengan mudah.',
    ),
    OnboardingData(
      lottiePath: 'assets/lottie/Order-food.json',
      title: 'Mudah & Praktis',
      description:
          'Pilih menu, tambahkan ke keranjang, dan checkout dengan beberapa sentuhan saja.',
    ),
    OnboardingData(
      lottiePath: 'assets/lottie/ScanQR-Paymeny.json',
      title: 'Pembayaran Lengkap',
      description:
          'Terima pembayaran lebih mudah dengan berbagai pilihan metode yang tersedia dalam satu aplikasi.',
    ),
  ];
}