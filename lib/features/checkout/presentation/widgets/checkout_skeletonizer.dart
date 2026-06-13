import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_colors.dart';
import 'package:warmindo_purnama_flutter/core/theme/app_text_styles.dart';
import 'package:warmindo_purnama_flutter/features/checkout/data/models/order_type_model.dart';
import '../widgets/order_type_selector.dart';

/// Fake data for skeleton loading
final fakeOrderTypes = [
  const OrderTypeModel(id: 1, name: 'dine_in'),
  const OrderTypeModel(id: 2, name: 'take_away'),
];

/// Skeletonizer widget for checkout page
class CheckoutSkeletonizer extends StatelessWidget {
  const CheckoutSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order summary skeleton
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dark, width: 3),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 150,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 2,
                    color: AppColors.dark,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 18,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              height: 3,
              color: AppColors.dark,
              margin: const EdgeInsets.symmetric(vertical: 16),
            ),
            Text('TIPE PESANAN', style: AppTextStyles.title),
            const SizedBox(height: 12),
            OrderTypeSelector(
              orderTypes: fakeOrderTypes,
              selected: null,
              onSelect: (_) {},
            ),
          ],
        ),
      ),
    );
  }
}