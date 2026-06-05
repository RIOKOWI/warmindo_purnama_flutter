import 'package:mockito/annotations.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:warmindo_purnama_flutter/features/cart/domain/repositories/cart_repository.dart';
import 'package:warmindo_purnama_flutter/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/domain/repositories/table_repository.dart';
import 'package:warmindo_purnama_flutter/features/kasir/dashboard/domain/repositories/payment_list_repository.dart';

@GenerateMocks([
  DioClient,
  SecureStorage,
  AuthProvider,
  AuthRepository,
  CartRepository,
  CartRemoteDataSource,
  TableRepository,
  PaymentListRepository,
])
import 'mocks.mocks.dart';