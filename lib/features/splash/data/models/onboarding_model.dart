import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OnboardingData extends Equatable {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  List<Object?> get props => [icon, title, description];
}

class OnboardingContents {
  static const List<OnboardingData> screens = [
    OnboardingData(
      icon: Icons.restaurant_menu,
      title: 'Selamat Datang di Warmindo',
      description:
          'Nikmati berbagai menu lezat dengan harga terjangkau. Pesan makanan favorit Anda dengan mudah.',
    ),
    OnboardingData(
      icon: Icons.shopping_cart,
      title: 'Mudah & Praktis',
      description:
          'Pilih menu, tambahkan ke keranjang, dan checkout dengan beberapa sentuhan saja.',
    ),
    OnboardingData(
      icon: Icons.delivery_dining,
      title: 'Pengiriman Cepat',
      description:
          'Pesanan Anda akan segera diproses dan siap diantar ke meja Anda.',
    ),
  ];
}