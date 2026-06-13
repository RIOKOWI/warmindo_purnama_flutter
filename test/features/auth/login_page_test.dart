import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_text_field.dart';
import 'package:warmindo_purnama_flutter/core/widgets/neo/neo_button.dart';
import 'package:warmindo_purnama_flutter/features/auth/domain/auth_status.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/pages/login_page.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    // Default: tidak loading
    when(mockAuthProvider.isLoading).thenReturn(false);
    when(mockAuthProvider.status).thenReturn(AuthStatus.unauthenticated);
    when(mockAuthProvider.errorMessage).thenReturn(null);
    when(mockAuthProvider.role).thenReturn('customer');
  });

  Widget buildWidget() => ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const MaterialApp(home: LoginPage()),
      );

  group('LoginPage - UI elements', () {
    testWidgets('tampil NeoTextField email dan password', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Email field
      expect(find.byType(NeoTextField), findsNWidgets(2));
      expect(find.widgetWithText(NeoTextField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(NeoTextField, 'Password'), findsOneWidget);
    });

    testWidgets('tampil NeoButton "MASUK"', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.widgetWithText(NeoButton, 'MASUK'), findsOneWidget);
    });

    testWidgets('tampil TextButton "Belum punya akun? Daftar"', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Belum punya akun? Daftar'), findsOneWidget);
    });
  });

  group('LoginPage - form validation', () {
    testWidgets('validasi: submit dengan field kosong menampilkan error message', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Tap tombol login tanpa isi apapun
      await tester.tap(find.text('MASUK'));
      await tester.pump();

      // Validasi email dan password error
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('validasi: email kosong → "Email tidak boleh kosong"', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Masukkan password saja
      await tester.enterText(find.byType(TextField).last, 'Password123!');
      await tester.tap(find.text('MASUK'));
      await tester.pump();

      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('validasi: password kosong → "Password tidak boleh kosong"', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Masukkan email saja
      await tester.enterText(find.byType(TextField).first, 'test@email.com');
      await tester.tap(find.text('MASUK'));
      await tester.pump();

      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });
  });

  group('LoginPage - login behavior', () {
    testWidgets('auth.login() dipanggil dengan email dan password yang benar saat submit valid', (tester) async {
      when(mockAuthProvider.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget());

      // Enter email and password
      await tester.enterText(find.byType(TextField).first, 'test@email.com');
      await tester.enterText(find.byType(TextField).last, 'Test123@');
      await tester.tap(find.text('MASUK'));
      await tester.pump();

      verify(mockAuthProvider.login(
        email: 'test@email.com',
        password: 'Test123@',
      )).called(1);
    });
  });

  group('LoginPage - loading state', () {
    testWidgets('tombol NeoButton disable saat isLoading true', (tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildWidget());

      final button = tester.widget<NeoButton>(find.byType(NeoButton));
      expect(button.isLoading, isTrue);
    });

    testWidgets('CircularProgressIndicator muncul di dalam tombol saat isLoading true', (tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoginPage - error handling', () {
    testWidgets('SnackBar muncul dengan errorMessage jika login gagal', (tester) async {
      when(mockAuthProvider.login(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => false);
      when(mockAuthProvider.errorMessage).thenReturn('Email atau password salah.');

      await tester.pumpWidget(buildWidget());

      // Enter valid email and password
      await tester.enterText(find.byType(TextField).first, 'test@email.com');
      await tester.enterText(find.byType(TextField).last, 'Test123@');
      await tester.tap(find.text('MASUK'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email atau password salah.'), findsOneWidget);
    });
  });
}
