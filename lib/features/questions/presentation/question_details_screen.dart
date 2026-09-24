import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/question_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/presentation/add_idea_screen.dart';
import 'package:idearadar/features/questions/domain/question.dart';
import 'package:idearadar/features/questions/domain/question_idea_link.dart';
import 'package:idearadar/features/questions/presentation/question_editor_screen.dart';

class QuestionDetailsScreen extends StatefulWidget {
  const QuestionDetailsScreen({
    required this.question,
    required this.repository,
    super.key,
  });

  final Question question;
  final IdeaRepository repository;

  @override
  State<QuestionDetailsScreen> createState() => _QuestionDetailsScreenState();
}

class _QuestionDetailsScreenState extends State<QuestionDetailsScreen> {
  late Question _question;
  final List<QuestionIdeaLink> _links = [];
  final List<Idea> _ideas = [];
  bool _loadingLinks = true;

  @override
  void initState() {
    super.initState();
    _question = widget.question;
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    final results = await Future.wait([
      widget.repository.getQuestionIdeaLinks(questionId: _question.id),
      widget.repository.getIdeas(),
    ]);
    if (!mounted) return;
    setState(() {
      _links
        ..clear()
        ..addAll(results[0] as List<QuestionIdeaLink>);
      _ideas
        ..clear()
        ..addAll(results[1] as List<Idea>);
      _loadingLinks = false;
    });
  }

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<Question>(
      MaterialPageRoute(
        builder: (_) => QuestionEditorScreen(question: _question),
      ),
    );
    if (!mounted || updated == null) return;
    try {
      await widget.repository.updateQuestion(updated);
      if (!mounted) return;
      setState(() => _question = updated);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(qtx(context, 'question_save_error'))),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(qtx(dialogContext, 'delete_question_confirm')),
        content: Text(qtx(dialogContext, 'delete_question_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(qtx(dialogContext, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(qtx(dialogContext, 'delete_question')),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      await widget.repository.deleteQuestion(_question.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(qtx(context, 'question_delete_error'))),
      );
    }
  }

  Future<void> _createIdea() async {
    final idea = await Navigator.of(context).push<Idea>(
      MaterialPageRoute(
        builder: (_) => AddIdeaScreen(
          initialTitle: _question.title,
          initialSummary: _question.details,
        ),
      ),
    );
    if (!mounted || idea == null) return;

    await widget.repository.addIdea(idea);
    await widget.repository.addQuestionIdeaLink(
      QuestionIdeaLink(
        questionId: _question.id,
        ideaId: idea.id,
        relationType: QuestionIdeaRelationType.questionCreatedIdea,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) await _loadLinks();
  }

  Future<void> _linkIdea() async {
    final linkedIds = _links.map((link) => link.ideaId).toSet();
    final available = _ideas
        .where((idea) => !idea.isArchived && !linkedIds.contains(idea.id))
        .toList();
    if (available.isEmpty) return;

    final selected = await showDialog<Idea>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(qtx(dialogContext, 'select_idea')),
        children: [
          for (final idea in available)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(idea),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(idea.title),
              ),
            ),
        ],
      ),
    );
    if (!mounted || selected == null) return;

    await widget.repository.addQuestionIdeaLink(
      QuestionIdeaLink(
        questionId: _question.id,
        ideaId: selected.id,
        relationType: QuestionIdeaRelationType.related,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) await _loadLinks();
  }

  Future<void> _unlink(QuestionIdeaLink link) async {
    await widget.repository.deleteQuestionIdeaLink(link.questionId, link.ideaId);
    if (mounted) await _loadLinks();
  }

  Idea? _ideaFor(String id) {
    for (final idea in _ideas) {
      if (idea.id == id) return idea;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(qtx(context, 'question')),
        actions: [
          IconButton(
            onPressed: _edit,
            tooltip: qtx(context, 'edit_question'),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _delete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'delete',
                child: Text(qtx(context, 'delete_question')),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 34,
                    color: cs.onSecondaryContainer,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _question.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSecondaryContainer,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(
                      localizedQuestionStatus(context, _question.status),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_question.details.trim().isNotEmpty)
              _QuestionSection(
                title: qtx(context, 'question_details'),
                text: _question.details,
                icon: Icons.subject_outlined,
              ),
            _QuestionSection(
              title: qtx(context, 'answer'),
              text: _question.answer.trim().isEmpty ? '—' : _question.answer,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('create_idea_from_question_button'),
                    onPressed: _createIdea,
                    icon: const Icon(Icons.lightbulb_outline),
                    label: Text(qtx(context, 'create_idea_from_question')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  qtx(context, 'linked_ideas'),
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _linkIdea,
                  icon: const Icon(Icons.link),
                  label: Text(qtx(context, 'link_idea')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_loadingLinks)
              const Center(child: CircularProgressIndicator())
            else if (_links.isEmpty)
              Text(qtx(context, 'no_linked_ideas'))
            else
              for (final link in _links)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: Text(_ideaFor(link.ideaId)?.title ?? link.ideaId),
                    subtitle: Text(
                      localizedRelationType(context, link.relationType),
                    ),
                    trailing: IconButton(
                      onPressed: () => _unlink(link),
                      tooltip: qtx(context, 'unlink'),
                      icon: const Icon(Icons.link_off),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _QuestionSection extends StatelessWidget {
  const _QuestionSection({
    required this.title,
    required this.text,
    required this.icon,
  });

  final String title;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(text),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
