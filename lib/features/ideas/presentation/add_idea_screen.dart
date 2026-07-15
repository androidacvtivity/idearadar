import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';

class AddIdeaScreen extends StatefulWidget {
  const AddIdeaScreen({super.key});

  @override
  State<AddIdeaScreen> createState() => _AddIdeaScreenState();
}

class _AddIdeaScreenState extends State<AddIdeaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _problemController = TextEditingController();
  final _solutionController = TextEditingController();
  final _domainController = TextEditingController();

  IdeaStatus _status = IdeaStatus.newIdea;
  bool _showValidationErrors = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _domainController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _saveIdea() {
    _dismissKeyboard();

    setState(() {
      _showValidationErrors = true;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final idea = Idea(
      id: now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      summary: _summaryController.text.trim(),
      problem: _problemController.text.trim(),
      solution: _solutionController.text.trim(),
      domain: _domainController.text.trim(),
      status: _status,
      createdAt: now,
      updatedAt: now,
    );

    Navigator.of(context).pop(idea);
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add new idea')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: Form(
          key: _formKey,
          autovalidateMode: _showValidationErrors
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Text(
                'Capture the opportunity',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start with the problem. You can add evidence and scores later.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                key: const Key('idea_title_field'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Example: IdeaRadar',
                  prefixIcon: Icon(Icons.lightbulb_outline),
                ),
                validator: (value) => _requiredValidator(value, 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('idea_domain_field'),
                controller: _domainController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Domain',
                  hintText: 'Example: Productivity',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                validator: (value) => _requiredValidator(value, 'Domain'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<IdeaStatus>(
                key: const Key('idea_status_field'),
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: IdeaStatus.values
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.label),
                      ),
                    )
                    .toList(),
                onChanged: (status) {
                  if (status != null) {
                    setState(() {
                      _status = status;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('idea_summary_field'),
                controller: _summaryController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Summary',
                  hintText: 'Describe the idea in a few sentences',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('idea_problem_field'),
                controller: _problemController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Problem',
                  hintText: 'What problem does this idea solve?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('idea_solution_field'),
                controller: _solutionController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _dismissKeyboard(),
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Proposed solution',
                  hintText: 'How could the problem be solved?',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          key: const Key('save_idea_button'),
          onPressed: _saveIdea,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save idea'),
        ),
      ),
    );
  }
}
