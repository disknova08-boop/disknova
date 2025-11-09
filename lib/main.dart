import 'package:disknova_project/agency.dart';
import 'package:disknova_project/sign_up_login.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'demo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(const Dev2DeskApp());
}
const supabaseUrl = 'https://evajqtqydxmtezgeaief.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2YWpxdHF5ZHhtdGV6Z2VhaWVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5MzI3NDQsImV4cCI6MjA3NzUwODc0NH0.WzRv37Tm7PHH7D1bxE4QnO1lmH2UV2IQ_TqgF1QYUM8';

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
    );
  }
}
//  vercel --prod --confirm --name disknova1
//  bot token==AAGkMYPVLp7K5DUs8HLkCvI6IWMD4Zu5NbA
