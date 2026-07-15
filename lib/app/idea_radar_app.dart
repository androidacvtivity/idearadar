import 'package:flutter/material.dart';
import 'package:idearadar/app/theme/app_theme.dart';
import 'package:idearadar/features/dashboard/presentation/dashboard_screen.dart';

class IdeaRadarApp extends StatelessWidget {
  const IdeaRadarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IdeaRadar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
