import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/app/localization/problem_localization.dart';
import 'package:idearadar/app/localization/question_localization.dart';
import 'package:idearadar/features/dashboard/presentation/dashboard_screen.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/problems/presentation/problems_screen.dart';
import 'package:idearadar/features/questions/presentation/questions_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({required this.repository, super.key});

  final IdeaRepository repository;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ProblemsScreen(repository: widget.repository),
          QuestionsScreen(repository: widget.repository),
          DashboardScreen(repository: widget.repository),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.radar_outlined),
            selectedIcon: const Icon(Icons.radar),
            label: ptx(context, 'problems'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.help_outline),
            selectedIcon: const Icon(Icons.help),
            label: qtx(context, 'questions'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.lightbulb_outline),
            selectedIcon: const Icon(Icons.lightbulb),
            label: tr(context, 'ideas'),
          ),
        ],
      ),
    );
  }
}
