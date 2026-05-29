/// Payment method enum for all available payment options
enum PaymentMethod {
  qris,
  bniVa,
  briVa,
  cimbNiagaVa,
  permataVa,
  maybankVa,
  sampoernaVa,
  bncVa,
  atmBersamaVa,
  arthaGrahaVa,
}

/// Extension for PaymentMethod to get value and label
extension PaymentMethodX on PaymentMethod {
  /// Get the API string value for this payment method
  String get value {
    switch (this) {
      case PaymentMethod.qris:
        return 'qris';
      case PaymentMethod.bniVa:
        return 'bni_va';
      case PaymentMethod.briVa:
        return 'bri_va';
      case PaymentMethod.cimbNiagaVa:
        return 'cimb_niaga_va';
      case PaymentMethod.permataVa:
        return 'permata_va';
      case PaymentMethod.maybankVa:
        return 'maybank_va';
      case PaymentMethod.sampoernaVa:
        return 'sampoerna_va';
      case PaymentMethod.bncVa:
        return 'bnc_va';
      case PaymentMethod.atmBersamaVa:
        return 'atm_bersama_va';
      case PaymentMethod.arthaGrahaVa:
        return 'artha_graha_va';
    }
  }

  /// Get the user-friendly label for this payment method
  String get label {
    switch (this) {
      case PaymentMethod.qris:
        return 'QRIS';
      case PaymentMethod.bniVa:
        return 'BNI Virtual Account';
      case PaymentMethod.briVa:
        return 'BRI Virtual Account';
      case PaymentMethod.cimbNiagaVa:
        return 'CIMB Niaga Virtual Account';
      case PaymentMethod.permataVa:
        return 'Permata Virtual Account';
      case PaymentMethod.maybankVa:
        return 'Maybank Virtual Account';
      case PaymentMethod.sampoernaVa:
        return 'Bank Sampoerna Virtual Account';
      case PaymentMethod.bncVa:
        return 'BNC Virtual Account';
      case PaymentMethod.atmBersamaVa:
        return 'ATM Bersama Virtual Account';
      case PaymentMethod.arthaGrahaVa:
        return 'Artha Graha Virtual Account';
    }
  }

  /// Check if this payment method is QRIS
  bool get isQris => this == PaymentMethod.qris;
}

/// Parse payment method from string value (from API response)
PaymentMethod paymentMethodFromString(String value) {
  switch (value) {
    case 'qris':
      return PaymentMethod.qris;
    case 'bni_va':
      return PaymentMethod.bniVa;
    case 'bri_va':
      return PaymentMethod.briVa;
    case 'cimb_niaga_va':
      return PaymentMethod.cimbNiagaVa;
    case 'permata_va':
      return PaymentMethod.permataVa;
    case 'maybank_va':
      return PaymentMethod.maybankVa;
    case 'sampoerna_va':
      return PaymentMethod.sampoernaVa;
    case 'bnc_va':
      return PaymentMethod.bncVa;
    case 'atm_bersama_va':
      return PaymentMethod.atmBersamaVa;
    case 'artha_graha_va':
      return PaymentMethod.arthaGrahaVa;
    default:
      return PaymentMethod.qris; // Default fallback
  }
}