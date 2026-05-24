import 'package:mockito/annotations.dart';
import 'package:warmindo_purnama_flutter/core/services/dio_client.dart';
import 'package:warmindo_purnama_flutter/core/services/secure_storage.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/features/auth/domain/repositories/auth_repository.dart';

@GenerateMocks([
  DioClient,
  SecureStorage,
  AuthProvider,
  AuthRepository,
])
import 'mocks.mocks.dart';