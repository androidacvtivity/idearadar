import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/problem_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/problems/domain/problem.dart';
import 'package:idearadar/features/problems/presentation/problem_details_screen.dart';
import 'package:idearadar/features/problems/presentation/problem_editor_screen.dart';

class ProblemsScreen extends StatefulWidget {
  const ProblemsScreen({required this.repository, super.key});

  final IdeaRepository repository;

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  final List<Problem> _problems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await widget.repository.initialize();
      final problems = await widget.repository.getProblems();
      if (!mounted) return;
      setState(() {
        _problems
          ..clear()
          ..addAll(problems);
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = ptx(context, 'problems_load_error');
      });
    }
  }

  Future<void> _addProblem() async {
    final problem = await Navigator.of(context).push<Problem>(
      MaterialPageRoute(builder: (_) => const ProblemEditorScreen()),
    );
    if (!mounted || problem == null) return;

    try {
      await widget.repository.addProblem(problem);
      if (!mounted) return;
      setState(() => _problems.insert(0, problem));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ptx(context, 'problem_save_error'))),
      );
    }
  }

  Future<void> _openProblem(Problem problem) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProblemDetailsScreen(
          problem: problem,
          repository: widget.repository,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _problems
        .where(
          (problem) =>
              problem.status != ProblemStatus.parked &&
              problem.status != ProblemStatus.rejected,
        )
        .length;
    final today = DateTime.now();
    final todayCount = _problems.where((problem) {
      final created = problem.createdAt;
      return created.year == today.year &&
          created.month == today.month &&
          created.day == today.day;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          ptx(context, 'problems'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _load,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
                    children: [
                      Text(
                        ptx(context, 'problems_subtitle'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _ProblemSummaryCard(
                              label: ptx(context, 'today'),
                              value: '$todayCount',
                              icon: Icons.today_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ProblemSummaryCard(
                              label: ptx(context, 'active_problems'),
                              value: '$activeCount',
                              icon: Icons.radar_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_problems.isEmpty)
                        _EmptyProblems(onAdd: _addProblem)
                      else
                        for (final problem in _problems)
                          _ProblemCard(
                            problem: problem,
                            onTap: () => _openProblem(problem),
                          ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'problems_add_problem',
        key: const Key('new_problem_button'),
        onPressed: _addProblem,
        icon: const Icon(Icons.add),
        label: Text(ptx(context, 'new_problem')),
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({required this.problem, required this.onTap});

  final Problem problem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cs.errorContainer,
          foregroundColor: cs.onErrorContainer,
          child: const Icon(Icons.report_problem_outlined),
        ),
        title: Text(
          problem.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${localizedProblemStatus(context, problem.status)} · ${_formatDate(problem.updatedAt)}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

class _ProblemSummaryCard extends StatelessWidget {
  const _ProblemSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _EmptyProblems extends StatelessWidget {
  const _EmptyProblems({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons.radar_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              ptx(context, 'no_problems'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              ptx(context, 'no_problems_desc'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(ptx(context, 'new_problem')),
            ),
          ],
        ),
      ),
    );
  }
}
