import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:warmindo_purnama_flutter/features/auth/domain/auth_status.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:warmindo_purnama_flutter/features/auth/presentation/pages/register_page.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthProvider = MockAuthProvider();
    // Default: tidak loading
    when(mockAuthProvider.isLoading).thenReturn(false);
    when(mockAuthProvider.status).thenReturn(AuthStatus.unauthenticated);
    when(mockAuthProvider.errorMessage).thenReturn(null);
  });

  Widget buildWidget() => ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const MaterialApp(home: RegisterPage()),
      );

  group('RegisterPage - UI elements', () {
    testWidgets('tampil semua field: nama, email, nomor HP, password', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Semua 4 field harus ada
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.widgetWithText(TextFormField, 'Nama'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Nomor HP'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
    });

    testWidgets('tampil ElevatedButton "Daftar"', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.widgetWithText(ElevatedButton, 'Daftar'), findsOneWidget);
    });

    testWidgets('tampil TextButton "Sudah punya akun? Login"', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Sudah punya akun? Login'), findsOneWidget);
    });
  });

  group('RegisterPage - form validation', () {
    testWidgets('validasi: semua field kosong → error di setiap field', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Tap tombol daftar tanpa isi apapun
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      // Semua field error
      expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Nomor HP tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('validasi password: tidak ada huruf kapital → error spesifik', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Isi semua field dengan benar, kecuali password tanpa kapital
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User'); // nama
      await tester.enterText(find.byType(TextFormField).at(1), 'test@email.com'); // email
      await tester.enterText(find.byType(TextFormField).at(2), '089512345678'); // phone
      await tester.enterText(find.byType(TextFormField).at(3), 'test123!'); // password tanpa kapital
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Harus ada huruf kapital'), findsOneWidget);
    });

    testWidgets('validasi password: tidak ada angka → error spesifik', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Isi semua field dengan benar, kecuali password tanpa angka
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '089512345678');
      await tester.enterText(find.byType(TextFormField).at(3), 'TestUser!'); // password tanpa angka
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Harus ada angka'), findsOneWidget);
    });

    testWidgets('validasi password: tidak ada simbol → error spesifik', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Isi semua field dengan benar, kecuali password tanpa simbol
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '089512345678');
      await tester.enterText(find.byType(TextFormField).at(3), 'TestUser123'); // password tanpa simbol
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      expect(find.text('Harus ada simbol'), findsOneWidget);
    });

    testWidgets('validasi password: lengkap (kapital + angka + simbol) → tidak ada error', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Isi semua field dengan benar
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '089512345678');
      await tester.enterText(find.byType(TextFormField).at(3), 'TestUser123!'); // password lengkap
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      // Tidak boleh ada error message
      expect(find.text('Harus ada huruf kapital'), findsNothing);
      expect(find.text('Harus ada angka'), findsNothing);
      expect(find.text('Harus ada simbol'), findsNothing);
    });
  });

  group('RegisterPage - register behavior', () {
    testWidgets('auth.register() dipanggil dengan semua field yang benar', (tester) async {
      when(mockAuthProvider.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        phone: anyNamed('phone'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => true);

      await tester.pumpWidget(buildWidget());

      // Enter all fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '089512345678');
      await tester.enterText(find.byType(TextFormField).at(3), 'TestUser123!');
      await tester.tap(find.text('Daftar'));
      await tester.pump();

      verify(mockAuthProvider.register(
        name: 'Test User',
        email: 'test@email.com',
        phone: '089512345678',
        password: 'TestUser123!',
      )).called(1);
    });
  });

  group('RegisterPage - loading state', () {
    testWidgets('tombol Daftar disable saat isLoading true', (tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildWidget());

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull); // null = disabled
    });

    testWidgets('CircularProgressIndicator muncul di dalam tombol saat isLoading true', (tester) async {
      when(mockAuthProvider.isLoading).thenReturn(true);

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('RegisterPage - error handling', () {
    testWidgets('SnackBar muncul jika register gagal', (tester) async {
      when(mockAuthProvider.register(
        name: anyNamed('name'),
        email: anyNamed('email'),
        phone: anyNamed('phone'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => false);
      when(mockAuthProvider.errorMessage).thenReturn('Email sudah terdaftar');

      await tester.pumpWidget(buildWidget());

      // Enter valid fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'test@email.com');
      await tester.enterText(find.byType(TextFormField).at(2), '089512345678');
      await tester.enterText(find.byType(TextFormField).at(3), 'TestUser123!');
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Email sudah terdaftar'), findsOneWidget);
    });
  });
}