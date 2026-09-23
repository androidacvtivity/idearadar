import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/question_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/questions/domain/question.dart';
import 'package:idearadar/features/questions/domain/question_idea_link.dart';
import 'package:idearadar/features/questions/presentation/question_details_screen.dart';
import 'package:idearadar/features/questions/presentation/question_editor_screen.dart';

class IdeaQuestionsScreen extends StatefulWidget {
  const IdeaQuestionsScreen({
    required this.idea,
    required this.repository,
    super.key,
  });

  final Idea idea;
  final IdeaRepository repository;

  @override
  State<IdeaQuestionsScreen> createState() => _IdeaQuestionsScreenState();
}

class _IdeaQuestionsScreenState extends State<IdeaQuestionsScreen> {
  final List<Question> _questions = [];
  final List<QuestionIdeaLink> _links = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      widget.repository.getQuestions(),
      widget.repository.getQuestionIdeaLinks(ideaId: widget.idea.id),
    ]);
    if (!mounted) return;
    setState(() {
      final allQuestions = results[0] as List<Question>;
      _links
        ..clear()
        ..addAll(results[1] as List<QuestionIdeaLink>);
      final linkedIds = _links.map((link) => link.questionId).toSet();
      _questions
        ..clear()
        ..addAll(
          allQuestions.where((question) => linkedIds.contains(question.id)),
        );
      _loading = false;
    });
  }

  Future<void> _createQuestion() async {
    final question = await Navigator.of(context).push<Question>(
      MaterialPageRoute(builder: (_) => const QuestionEditorScreen()),
    );
    if (!mounted || question == null) return;

    await widget.repository.addQuestion(question);
    await widget.repository.addQuestionIdeaLink(
      QuestionIdeaLink(
        questionId: question.id,
        ideaId: widget.idea.id,
        relationType: QuestionIdeaRelationType.ideaCreatedQuestion,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _linkExisting() async {
    final allQuestions = await widget.repository.getQuestions();
    final linkedIds = _links.map((link) => link.questionId).toSet();
    final available =
        allQuestions.where((question) => !linkedIds.contains(question.id)).toList();
    if (!mounted || available.isEmpty) return;

    final selected = await showDialog<Question>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(qtx(dialogContext, 'question')),
        children: [
          for (final question in available)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(question),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(question.title),
              ),
            ),
        ],
      ),
    );
    if (!mounted || selected == null) return;

    await widget.repository.addQuestionIdeaLink(
      QuestionIdeaLink(
        questionId: selected.id,
        ideaId: widget.idea.id,
        relationType: QuestionIdeaRelationType.related,
        createdAt: DateTime.now(),
      ),
    );
    if (mounted) await _load();
  }

  Future<void> _open(Question question) async {
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
    return Scaffold(
      appBar: AppBar(title: Text(qtx(context, 'related_questions'))),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  Text(
                    widget.idea.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(qtx(context, 'related_questions_subtitle')),
                  const SizedBox(height: 20),
                  if (_questions.isEmpty)
                    Text(qtx(context, 'no_questions'))
                  else
                    for (final question in _questions)
                      Card(
                        child: ListTile(
                          onTap: () => _open(question),
                          leading: const Icon(Icons.help_outline),
                          title: Text(question.title),
                          subtitle: Text(
                            localizedQuestionStatus(context, question.status),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      ),
                ],
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'link_question',
            onPressed: _linkExisting,
            child: const Icon(Icons.link),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create_question',
            onPressed: _createQuestion,
            icon: const Icon(Icons.add),
            label: Text(qtx(context, 'new_question')),
          ),
        ],
      ),
    );
  }
}
