import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/app/localization/idea_localization.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';

class AddIdeaScreen extends StatefulWidget {
  const AddIdeaScreen({this.idea, super.key});

  final Idea? idea;

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
  final _targetUsersController = TextEditingController();
  final _payingCustomerController = TextEditingController();

  IdeaStatus _status = IdeaStatus.newIdea;
  bool _showValidationErrors = false;

  @override
  void initState() {
    super.initState();
    final idea = widget.idea;
    if (idea == null) return;
    _titleController.text = idea.title;
    _summaryController.text = idea.summary;
    _problemController.text = idea.problem;
    _solutionController.text = idea.solution;
    _domainController.text = idea.domain;
    _targetUsersController.text = idea.targetUsers;
    _payingCustomerController.text = idea.payingCustomer;
    _status = idea.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _problemController.dispose();
    _solutionController.dispose();
    _domainController.dispose();
    _targetUsersController.dispose();
    _payingCustomerController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  void _saveIdea() {
    _dismissKeyboard();
    setState(() => _showValidationErrors = true);
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final originalIdea = widget.idea;
    Navigator.of(context).pop(
      Idea(
        id: originalIdea?.id ?? now.microsecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        problem: _problemController.text.trim(),
        solution: _solutionController.text.trim(),
        domain: _domainController.text.trim(),
        targetUsers: _targetUsersController.text.trim(),
        payingCustomer: _payingCustomerController.text.trim(),
        status: _status,
        evaluation: originalIdea?.evaluation,
        createdAt: originalIdea?.createdAt ?? now,
        updatedAt: now,
        nextReviewAt: originalIdea?.nextReviewAt,
        archivedAt: originalIdea?.archivedAt,
      ),
    );
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName ${itx(context, 'required')}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.idea != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? tr(context, 'edit_idea') : itx(context, 'add_new_idea'))),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: Form(
            key: _formKey,
            autovalidateMode: _showValidationErrors ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                Text(
                  itx(context, isEditing ? 'update_opportunity' : 'capture_opportunity'),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  itx(context, isEditing ? 'update_opportunity_desc' : 'capture_opportunity_desc'),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  key: const Key('idea_title_field'), controller: _titleController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: itx(context, 'title'), hintText: itx(context, 'title_hint'), prefixIcon: const Icon(Icons.lightbulb_outline)),
                  validator: (value) => _requiredValidator(value, itx(context, 'title')),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('idea_domain_field'), controller: _domainController, textCapitalization: TextCapitalization.words, textInputAction: TextInputAction.next,
                  decoration: InputDecoration(labelText: itx(context, 'domain'), hintText: itx(context, 'domain_hint'), prefixIcon: const Icon(Icons.category_outlined)),
                  validator: (value) => _requiredValidator(value, itx(context, 'domain')),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<IdeaStatus>(
                  key: const Key('idea_status_field'), initialValue: _status,
                  decoration: InputDecoration(labelText: itx(context, 'status'), prefixIcon: const Icon(Icons.flag_outlined)),
                  items: IdeaStatus.values.map((status) => DropdownMenuItem(value: status, child: Text(localizedIdeaStatus(context, status)))).toList(),
                  onChanged: (status) { if (status != null) setState(() => _status = status); },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('idea_summary_field'), controller: _summaryController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next, minLines: 2, maxLines: 4,
                  decoration: InputDecoration(labelText: tr(context, 'summary'), hintText: itx(context, 'summary_hint'), alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('idea_problem_field'), controller: _problemController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next, minLines: 3, maxLines: 6,
                  decoration: InputDecoration(labelText: tr(context, 'problem'), hintText: itx(context, 'problem_hint'), alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('idea_solution_field'), controller: _solutionController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next, minLines: 3, maxLines: 6,
                  decoration: InputDecoration(labelText: tr(context, 'proposed_solution'), hintText: itx(context, 'solution_hint'), alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('idea_target_users_field'), controller: _targetUsersController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.next, minLines: 2, maxLines: 4,
                  decoration: InputDecoration(labelText: tr(context, 'target_users'), hintText: itx(context, 'target_users_hint'), prefixIcon: const Icon(Icons.groups_outlined), alignLabelWithHint: true),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('idea_paying_customer_field'), controller: _payingCustomerController, textCapitalization: TextCapitalization.sentences, textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _dismissKeyboard(), minLines: 2, maxLines: 4,
                  decoration: InputDecoration(labelText: tr(context, 'paying_customer'), hintText: itx(context, 'paying_customer_hint'), prefixIcon: const Icon(Icons.payments_outlined), alignLabelWithHint: true),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          key: const Key('save_idea_button'), onPressed: _saveIdea, icon: const Icon(Icons.save_outlined),
          label: Text(itx(context, isEditing ? 'save_changes' : 'save_idea')),
        ),
      ),
    );
  }
}
