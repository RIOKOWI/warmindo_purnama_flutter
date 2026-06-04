import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:warmindo_purnama_flutter/features/splash/pages/app.dart';
import 'core/injection/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  runApp(
    MultiProvider(
      providers: DependencyInjection.providers,
      child: const App(),
    ),
  );
}
