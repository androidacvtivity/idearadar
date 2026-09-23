import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/question_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/questions/domain/question.dart';
import 'package:idearadar/features/questions/presentation/question_details_screen.dart';
import 'package:idearadar/features/questions/presentation/question_editor_screen.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({required this.repository, super.key});

  final IdeaRepository repository;

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final List<Question> _questions = [];
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
      final questions = await widget.repository.getQuestions();
      if (!mounted) return;
      setState(() {
        _questions
          ..clear()
          ..addAll(questions);
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = qtx(context, 'questions_load_error');
      });
    }
  }

  Future<void> _addQuestion() async {
    final question = await Navigator.of(context).push<Question>(
      MaterialPageRoute(builder: (_) => const QuestionEditorScreen()),
    );
    if (!mounted || question == null) return;

    try {
      await widget.repository.addQuestion(question);
      if (!mounted) return;
      setState(() => _questions.insert(0, question));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(qtx(context, 'question_save_error'))),
      );
    }
  }

  Future<void> _openQuestion(Question question) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => QuestionDetailsScreen(
          question: question,
          repository: widget.repository,
        ),
      ),
    );
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _questions
        .where((question) => question.status == QuestionStatus.open)
        .length;
    final today = DateTime.now();
    final todayCount = _questions.where((question) {
      final created = question.createdAt;
      return created.year == today.year &&
          created.month == today.month &&
          created.day == today.day;
    }).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          qtx(context, 'questions'),
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
                        qtx(context, 'questions_subtitle'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _QuestionSummaryCard(
                              label: qtx(context, 'today'),
                              value: '$todayCount',
                              icon: Icons.today_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuestionSummaryCard(
                              label: qtx(context, 'open_questions'),
                              value: '$openCount',
                              icon: Icons.help_outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_questions.isEmpty)
                        _EmptyQuestions(onAdd: _addQuestion)
                      else
                        for (final question in _questions)
                          _QuestionCard(
                            question: question,
                            onTap: () => _openQuestion(question),
                          ),
                    ],
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new_question_button'),
        onPressed: _addQuestion,
        icon: const Icon(Icons.add),
        label: Text(qtx(context, 'new_question')),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question, required this.onTap});

  final Question question;
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
          backgroundColor: cs.secondaryContainer,
          foregroundColor: cs.onSecondaryContainer,
          child: const Icon(Icons.help_outline),
        ),
        title: Text(
          question.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          localizedQuestionStatus(context, question.status) +
              ' · ' +
              _formatDate(question.updatedAt),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      date.day.toString().padLeft(2, '0') +
      '.' +
      date.month.toString().padLeft(2, '0') +
      '.' +
      date.year.toString();
}

class _QuestionSummaryCard extends StatelessWidget {
  const _QuestionSummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary),
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

class _EmptyQuestions extends StatelessWidget {
  const _EmptyQuestions({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons.help_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              qtx(context, 'no_questions'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              qtx(context, 'no_questions_desc'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(qtx(context, 'new_question')),
            ),
          ],
        ),
      ),
    );
  }
}
