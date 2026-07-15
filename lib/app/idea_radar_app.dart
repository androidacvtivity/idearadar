import 'package:flutter/material.dart';
import 'package:idearadar/app/theme/app_theme.dart';
import 'package:idearadar/features/dashboard/presentation/dashboard_screen.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';

class IdeaRadarApp extends StatelessWidget {
  const IdeaRadarApp({required this.repository, super.key});

  final IdeaRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IdeaRadar',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: DashboardScreen(repository: repository),
    );
  }
}
