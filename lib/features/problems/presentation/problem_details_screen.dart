import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/problem_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/presentation/add_idea_screen.dart';
import 'package:idearadar/features/problems/domain/problem.dart';
import 'package:idearadar/features/problems/domain/problem_idea_link.dart';
import 'package:idearadar/features/problems/domain/problem_question_link.dart';
import 'package:idearadar/features/problems/presentation/problem_editor_screen.dart';
import 'package:idearadar/features/questions/domain/question.dart';
import 'package:idearadar/features/questions/presentation/question_editor_screen.dart';

class ProblemDetailsScreen extends StatefulWidget {
  const ProblemDetailsScreen({
    required this.problem,
    required this.repository,
    super.key,
  });

  final Problem problem;
  final IdeaRepository repository;

  @override
  State<ProblemDetailsScreen> createState() => _ProblemDetailsScreenState();
}

class _ProblemDetailsScreenState extends State<ProblemDetailsScreen> {
  late Problem _problem;
  final List<Idea> _linkedIdeas = [];
  final List<Question> _linkedQuestions = [];

  @override
  void initState() {
    super.initState();
    _problem = widget.problem;
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final ideaLinks = await widget.repository.getProblemIdeaLinks(
      problemId: _problem.id,
    );
    final questionLinks = await widget.repository.getProblemQuestionLinks(
      problemId: _problem.id,
    );
    final ideas = await widget.repository.getIdeas();
    final questions = await widget.repository.getQuestions();

    if (!mounted) return;

    final ideaIds = ideaLinks.map((link) => link.ideaId).toSet();
    final questionIds = questionLinks.map((link) => link.questionId).toSet();

    setState(() {
      _linkedIdeas
        ..clear()
        ..addAll(ideas.where((idea) => ideaIds.contains(idea.id)));
      _linkedQuestions
        ..clear()
        ..addAll(
          questions.where((question) => questionIds.contains(question.id)),
        );
    });
  }

  Future<void> _editProblem() async {
    final updated = await Navigator.of(context).push<Problem>(
      MaterialPageRoute(builder: (_) => ProblemEditorScreen(problem: _problem)),
    );
    if (!mounted || updated == null) return;

    await widget.repository.updateProblem(updated);
    if (!mounted) return;
    setState(() => _problem = updated);
  }

  Future<void> _deleteProblem() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ptx(context, 'delete_problem_confirm')),
        content: Text(ptx(context, 'delete_problem_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(ptx(context, 'delete_problem')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await widget.repository.deleteProblem(_problem.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _createQuestion() async {
    final question = await Navigator.of(context).push<Question>(
      MaterialPageRoute(
        builder: (_) => QuestionEditorScreen(
          initialTitle: _problem.title,
          initialDetails: _problem.description,
        ),
      ),
    );
    if (!mounted || question == null) return;

    await widget.repository.addQuestion(question);
    await widget.repository.addProblemQuestionLink(
      ProblemQuestionLink(
        problemId: _problem.id,
        questionId: question.id,
        relationType: ProblemQuestionRelationType.problemCreatedQuestion,
        createdAt: DateTime.now(),
      ),
    );
    await _loadLinks();
  }

  Future<void> _createIdea() async {
    final idea = await Navigator.of(context).push<Idea>(
      MaterialPageRoute(
        builder: (_) => AddIdeaScreen(
          initialTitle: _problem.title,
          initialSummary: _problem.description,
          initialProblem: _problem.description,
        ),
      ),
    );
    if (!mounted || idea == null) return;

    await widget.repository.addIdea(idea);
    await widget.repository.addProblemIdeaLink(
      ProblemIdeaLink(
        problemId: _problem.id,
        ideaId: idea.id,
        relationType: ProblemIdeaRelationType.problemCreatedIdea,
        createdAt: DateTime.now(),
      ),
    );
    await _loadLinks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ptx(context, 'problem_details')),
        actions: [
          IconButton(
            tooltip: ptx(context, 'edit_problem'),
            onPressed: _editProblem,
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            tooltip: ptx(context, 'more_actions'),
            onSelected: (value) {
              if (value == 'delete') _deleteProblem();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(ptx(context, 'delete_problem')),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          Text(
            _problem.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Chip(label: Text(localizedProblemStatus(context, _problem.status))),
          const SizedBox(height: 16),
          if (_problem.description.isNotEmpty)
            _DetailSection(
              title: ptx(context, 'problem_description'),
              text: _problem.description,
            ),
          if (_problem.affectedUsers.isNotEmpty)
            _DetailSection(
              title: ptx(context, 'affected_users'),
              text: _problem.affectedUsers,
            ),
          if (_problem.frequency.isNotEmpty)
            _DetailSection(
              title: ptx(context, 'frequency'),
              text: _problem.frequency,
            ),
          if (_problem.severity.isNotEmpty)
            _DetailSection(
              title: ptx(context, 'severity'),
              text: _problem.severity,
            ),
          if (_problem.currentWorkaround.isNotEmpty)
            _DetailSection(
              title: ptx(context, 'current_workaround'),
              text: _problem.currentWorkaround,
            ),
          if (_problem.evidence.isNotEmpty)
            _DetailSection(
              title: ptx(context, 'problem_evidence'),
              text: _problem.evidence,
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('create_question_from_problem_button'),
            onPressed: _createQuestion,
            icon: const Icon(Icons.help_outline),
            label: Text(ptx(context, 'create_question_from_problem')),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('create_idea_from_problem_button'),
            onPressed: _createIdea,
            icon: const Icon(Icons.lightbulb_outline),
            label: Text(ptx(context, 'create_idea_from_problem')),
          ),
          const SizedBox(height: 24),
          Text(
            ptx(context, 'linked_questions'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_linkedQuestions.isEmpty)
            Text(ptx(context, 'no_linked_questions'))
          else
            for (final question in _linkedQuestions)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: Text(question.title),
                ),
              ),
          const SizedBox(height: 20),
          Text(
            ptx(context, 'linked_ideas'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (_linkedIdeas.isEmpty)
            Text(ptx(context, 'no_linked_ideas'))
          else
            for (final idea in _linkedIdeas)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(idea.title),
                  subtitle: Text(idea.domain),
                ),
              ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(text),
          ],
        ),
      ),
    );
  }
}
