import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/app/theme/app_theme.dart';
import 'package:idearadar/features/dashboard/presentation/dashboard_screen.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';

class IdeaRadarApp extends StatelessWidget {
  const IdeaRadarApp({required this.repository, super.key});

  final IdeaRepository repository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: ideaRadarLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Idea Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          locale: locale,
          supportedLocales: supportedIdeaRadarLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: DashboardScreen(repository: repository),
        );
      },
    );
  }
}
