// import 'package:disknova_project/agency.dart';
// import 'package:disknova_project/sign_up_login.dart';
// import 'package:disknova_project/telegram_verification.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import 'demo.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Supabase.initialize(
//     url: supabaseUrl,
//     anonKey: supabaseKey,
//   );
//
//   runApp(const DiskNovaApp());
// }
// // const supabaseUrl = 'https://evajqtqydxmtezgeaief.supabase.co';
// // const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8';
// const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
// const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
// class DiskNovaApp extends StatelessWidget {
//   const DiskNovaApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'DiskNova',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFF2563EB),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF2563EB),
//           primary: const Color(0xFF2563EB),
//         ),
//         scaffoldBackgroundColor: const Color(0xFFF8FAFC),
//         useMaterial3: true,
//       ),
//       home: const AuthCheck(),
//       routes: {
//         // In your router configuration
//         '/verify-telegram': (context) {
//           final uri = Uri.base;
//           final token = uri.queryParameters['token'];
//           return TelegramVerificationScreen(token: token);
//         },
//       },
//     );
//   }
// }
// //  vercel --prod --confirm --name disknova1
// //  bot token==8029120671:AAGkMYPVLp7K5DUs8HLkCvI6IWMD4Zu5NbA
import 'package:disknova_project/agency.dart';
import 'package:disknova_project/dashboard.dart';
import 'package:disknova_project/sign_up_login.dart';
import 'package:disknova_project/telegram_verification.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const DiskNovaApp());
}

// Production credentials (uncomment for production)
// const supabaseUrl = 'https://evajqtqydxmtezgeaief.supabase.co';
// const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE7NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8';

// Environment variables (for Vercel deployment)
const supabaseUrl = String.fromEnvironment('SUPABASE_URL',
    defaultValue: 'https://evajqtqydxmtezgeaief.supabase.co');
const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8');

class DiskNovaApp extends StatelessWidget {
  const DiskNovaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DiskNova',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2563EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const AuthCheck(),
      onGenerateRoute: _handleRoute,
    );
  }

  // Handle dynamic routes with query parameters
  Route<dynamic>? _handleRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');

    // Handle Telegram verification route
    if (uri.path == '/verify-telegram') {
      final token = uri.queryParameters['token'];
      return MaterialPageRoute(
        builder: (_) => TelegramVerificationScreen(token: token),
        settings: settings,
      );
    }

    // Handle dashboard route (if needed)
    if (uri.path == '/dashboard') {
      return MaterialPageRoute(
        builder: (_) => const DashboardScreen(), // or your dashboard
        settings: settings,
      );
    }

    // Default fallback
    return null;
  }
}
const String APP_URL = 'https://disknova-2cna-6s1ooz0i1-disknovas-projects.vercel.app';

// Deployment Info:
// Bot Token: 8029120671:AAGkMYPVLp7K5DUs8HLkCvI6IWMD4Zu5NbA
// Vercel Deploy: vercel --prod --confirm --name disknova1
// Webhook URL: https://disknova-2cna-git-temp-disknovas-projects.vercel.app/api/telegram