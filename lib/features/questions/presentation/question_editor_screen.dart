import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/question_localization.dart';
import 'package:idearadar/features/questions/domain/question.dart';

class QuestionEditorScreen extends StatefulWidget {
  const QuestionEditorScreen({this.question, this.initialTitle, super.key});

  final Question? question;
  final String? initialTitle;

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _detailsController;
  late final TextEditingController _answerController;
  late QuestionStatus _status;

  @override
  void initState() {
    super.initState();
    final question = widget.question;
    _titleController = TextEditingController(
      text: question?.title ?? widget.initialTitle ?? '',
    );
    _detailsController = TextEditingController(text: question?.details ?? '');
    _answerController = TextEditingController(text: question?.answer ?? '');
    _status = question?.status ?? QuestionStatus.open;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final original = widget.question;
    final answer = _answerController.text.trim();
    final answered = _status == QuestionStatus.answered;

    Navigator.of(context).pop(
      Question(
        id: original?.id ?? now.microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        details: _detailsController.text.trim(),
        answer: answer,
        status: _status,
        createdAt: original?.createdAt ?? now,
        updatedAt: now,
        answeredAt: answered ? (original?.answeredAt ?? now) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.question != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(qtx(context, editing ? 'edit_question' : 'new_question')),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              TextFormField(
                key: const Key('question_title_field'),
                controller: _titleController,
                autofocus: !editing,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: qtx(context, 'question'),
                  hintText: qtx(context, 'question_hint'),
                  prefixIcon: const Icon(Icons.help_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? qtx(context, 'question')
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('question_details_field'),
                controller: _detailsController,
                minLines: 3,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: qtx(context, 'question_details'),
                  hintText: qtx(context, 'question_details_hint'),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<QuestionStatus>(
                key: const Key('question_status_field'),
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: qtx(context, 'question_status'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: QuestionStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(localizedQuestionStatus(context, status)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('question_answer_field'),
                controller: _answerController,
                minLines: 3,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: qtx(context, 'answer'),
                  hintText: qtx(context, 'answer_hint'),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          key: const Key('save_question_button'),
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(qtx(context, editing ? 'save_changes' : 'save_question')),
        ),
      ),
    );
  }
}
