import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_theme.dart';
import 'screens/home/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file (gitignored — never pushed to GitHub)
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with credentials from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!, // ignore: deprecated_member_use
  );

  runApp(const BugaReportApp());
}

class BugaReportApp extends StatelessWidget {
  const BugaReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BugaReport',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
