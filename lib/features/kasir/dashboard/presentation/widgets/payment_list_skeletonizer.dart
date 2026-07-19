import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/data/models/payment_list_model.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/presentation/widgets/payment_list_tile.dart';

/// Fake data for skeleton loader
final fakePayments = List.generate(7, (i) => PaymentListItemModel(
  id: i,
  orderId: i,
  amount: 0,
  fee: 0,
  totalPayment: 0,
  paymentNumber: 'PAY-$i',
  paymentMethod: 'qris',
  status: 'pending',
  expiredAt: DateTime(2024, 1, 1),
  order: PaymentOrderModel(
    id: i,
    invoiceNumber: 'INV-0000',
    totalAmount: 0,
    status: 'pending',
  ),
));

/// Skeletonizer widget for payment list
class PaymentListSkeletonizer extends StatelessWidget {
  const PaymentListSkeletonizer({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: fakePayments.length,
        itemBuilder: (context, index) {
          final payment = fakePayments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PaymentListTile(
              payment: payment,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}