import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/problem_localization.dart';
import 'package:idearadar/features/problems/domain/problem.dart';

class ProblemEditorScreen extends StatefulWidget {
  const ProblemEditorScreen({this.problem, super.key});

  final Problem? problem;

  @override
  State<ProblemEditorScreen> createState() => _ProblemEditorScreenState();
}

class _ProblemEditorScreenState extends State<ProblemEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _affectedUsersController;
  late final TextEditingController _frequencyController;
  late final TextEditingController _severityController;
  late final TextEditingController _currentWorkaroundController;
  late final TextEditingController _evidenceController;
  late ProblemStatus _status;

  @override
  void initState() {
    super.initState();
    final problem = widget.problem;
    _titleController = TextEditingController(text: problem?.title ?? '');
    _descriptionController = TextEditingController(text: problem?.description ?? '');
    _affectedUsersController = TextEditingController(text: problem?.affectedUsers ?? '');
    _frequencyController = TextEditingController(text: problem?.frequency ?? '');
    _severityController = TextEditingController(text: problem?.severity ?? '');
    _currentWorkaroundController =
        TextEditingController(text: problem?.currentWorkaround ?? '');
    _evidenceController = TextEditingController(text: problem?.evidence ?? '');
    _status = problem?.status ?? ProblemStatus.observed;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _affectedUsersController.dispose();
    _frequencyController.dispose();
    _severityController.dispose();
    _currentWorkaroundController.dispose();
    _evidenceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final original = widget.problem;
    Navigator.of(context).pop(
      Problem(
        id: original?.id ?? now.microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        affectedUsers: _affectedUsersController.text.trim(),
        frequency: _frequencyController.text.trim(),
        severity: _severityController.text.trim(),
        currentWorkaround: _currentWorkaroundController.text.trim(),
        evidence: _evidenceController.text.trim(),
        status: _status,
        createdAt: original?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.problem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(ptx(context, editing ? 'edit_problem' : 'new_problem')),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              TextFormField(
                key: const Key('problem_title_field'),
                controller: _titleController,
                autofocus: !editing,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: ptx(context, 'problem_title'),
                  hintText: ptx(context, 'problem_title_hint'),
                  prefixIcon: const Icon(Icons.report_problem_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? ptx(context, 'problem_title')
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('problem_description_field'),
                controller: _descriptionController,
                minLines: 3,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: ptx(context, 'problem_description'),
                  hintText: ptx(context, 'problem_description_hint'),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('problem_affected_users_field'),
                controller: _affectedUsersController,
                minLines: 2,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: ptx(context, 'affected_users'),
                  hintText: ptx(context, 'affected_users_hint'),
                  prefixIcon: const Icon(Icons.groups_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('problem_frequency_field'),
                controller: _frequencyController,
                decoration: InputDecoration(
                  labelText: ptx(context, 'frequency'),
                  hintText: ptx(context, 'frequency_hint'),
                  prefixIcon: const Icon(Icons.repeat),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('problem_severity_field'),
                controller: _severityController,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: ptx(context, 'severity'),
                  hintText: ptx(context, 'severity_hint'),
                  prefixIcon: const Icon(Icons.priority_high),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('problem_workaround_field'),
                controller: _currentWorkaroundController,
                minLines: 2,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: ptx(context, 'current_workaround'),
                  hintText: ptx(context, 'current_workaround_hint'),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('problem_evidence_field'),
                controller: _evidenceController,
                minLines: 3,
                maxLines: 7,
                decoration: InputDecoration(
                  labelText: ptx(context, 'problem_evidence'),
                  hintText: ptx(context, 'problem_evidence_hint'),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProblemStatus>(
                key: const Key('problem_status_field'),
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: ptx(context, 'problem_status'),
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: ProblemStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(localizedProblemStatus(context, status)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _status = value);
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          key: const Key('save_problem_button'),
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(ptx(context, editing ? 'save_changes' : 'save_problem')),
        ),
      ),
    );
  }
}
