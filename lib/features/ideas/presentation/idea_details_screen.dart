import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';
import 'package:idearadar/features/ideas/presentation/add_idea_screen.dart';
import 'package:idearadar/features/ideas/presentation/idea_evaluation_screen.dart';

class IdeaDetailsScreen extends StatelessWidget {
  const IdeaDetailsScreen({required this.idea, super.key});

  final Idea idea;

  Future<void> _editIdea(BuildContext context) async {
    final updatedIdea = await Navigator.of(
      context,
    ).push<Idea>(MaterialPageRoute(builder: (_) => AddIdeaScreen(idea: idea)));

    if (!context.mounted || updatedIdea == null) {
      return;
    }

    Navigator.of(context).pop(updatedIdea);
  }

  Future<void> _evaluateIdea(BuildContext context) async {
    final updatedIdea = await Navigator.of(context).push<Idea>(
      MaterialPageRoute(
        builder: (_) => IdeaEvaluationScreen(idea: idea),
      ),
    );

    if (!context.mounted || updatedIdea == null) {
      return;
    }

    Navigator.of(context).pop(updatedIdea);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Idea details'),
        actions: [
          IconButton(
            onPressed: () => _editIdea(context),
            tooltip: 'Edit idea',
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: colorScheme.onPrimaryContainer,
                    size: 34,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    idea.title,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category_outlined, size: 18),
                        label: Text(idea.domain),
                      ),
                      Chip(
                        avatar: const Icon(Icons.flag_outlined, size: 18),
                        label: Text(idea.status.label),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                onTap: () => _evaluateIdea(context),
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  foregroundColor: colorScheme.onSecondaryContainer,
                  child: const Icon(Icons.analytics_outlined),
                ),
                title: const Text('Opportunity score'),
                subtitle: Text(
                  idea.totalScore == null
                      ? 'Not evaluated'
                      : '${idea.totalScore} out of 40',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: 'Summary',
              icon: Icons.subject,
              content: idea.summary,
            ),
            _DetailSection(
              title: 'Problem',
              icon: Icons.report_problem_outlined,
              content: idea.problem,
            ),
            _DetailSection(
              title: 'Proposed solution',
              icon: Icons.auto_awesome_outlined,
              content: idea.solution,
            ),
            _DetailSection(
              title: 'Target users',
              icon: Icons.groups_outlined,
              content: idea.targetUsers,
            ),
            _DetailSection(
              title: 'Paying customer',
              icon: Icons.payments_outlined,
              content: idea.payingCustomer,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _DateRow(
                      label: 'Created',
                      value: _formatDate(idea.createdAt),
                    ),
                    const Divider(height: 24),
                    _DateRow(
                      label: 'Updated',
                      value: _formatDate(idea.updatedAt),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final String content;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayedContent = content.trim().isEmpty ? 'Not added yet' : content;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayedContent,
                    style: TextStyle(
                      color: content.trim().isEmpty
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontStyle: content.trim().isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
