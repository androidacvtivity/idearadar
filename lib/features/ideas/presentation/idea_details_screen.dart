import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';
import 'package:idearadar/features/ideas/presentation/add_idea_screen.dart';
import 'package:idearadar/features/ideas/presentation/assumption_radar_screen.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_result.dart';
import 'package:idearadar/features/ideas/presentation/idea_evaluation_screen.dart';
import 'package:idearadar/features/ideas/presentation/idea_notes_screen.dart';
import 'package:idearadar/features/ideas/presentation/idea_sources_screen.dart';

class IdeaDetailsScreen extends StatelessWidget {
  const IdeaDetailsScreen({
    required this.idea,
    required this.repository,
    super.key,
  });

  final Idea idea;
  final IdeaRepository repository;

  Future<void> _editIdea(BuildContext context) async {
    final updatedIdea = await Navigator.of(
      context,
    ).push<Idea>(MaterialPageRoute(builder: (_) => AddIdeaScreen(idea: idea)));
    if (!context.mounted || updatedIdea == null) return;
    Navigator.of(context).pop(IdeaUpdatedResult(updatedIdea));
  }

  Future<void> _evaluateIdea(BuildContext context) async {
    final updatedIdea = await Navigator.of(context).push<Idea>(
      MaterialPageRoute(builder: (_) => IdeaEvaluationScreen(idea: idea)),
    );
    if (!context.mounted || updatedIdea == null) return;
    Navigator.of(context).pop(IdeaUpdatedResult(updatedIdea));
  }

  Future<void> _scheduleReview(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final currentDate = idea.nextReviewAt;
    final initialDate = currentDate != null && !currentDate.isBefore(today)
        ? currentDate
        : today.add(const Duration(days: 7));
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(today.year + 10, 12, 31),
      helpText: tr(context, 'select_next_review_date'),
    );
    if (!context.mounted || selectedDate == null) return;
    Navigator.of(context).pop(
      IdeaUpdatedResult(
        idea.copyWith(nextReviewAt: selectedDate, updatedAt: DateTime.now()),
      ),
    );
  }

  Future<void> _clearReview(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(tr(dialogContext, 'remove_review_date_question')),
        content: Text(tr(dialogContext, 'remove_review_date_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(tr(dialogContext, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(tr(dialogContext, 'remove')),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    Navigator.of(context).pop(
      IdeaUpdatedResult(
        idea.copyWith(clearNextReviewAt: true, updatedAt: DateTime.now()),
      ),
    );
  }

  Future<void> _toggleArchive(BuildContext context) async {
    final restoring = idea.isArchived;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          tr(
            dialogContext,
            restoring ? 'restore_idea_question' : 'archive_idea_question',
          ),
        ),
        content: Text(
          tr(
            dialogContext,
            restoring ? 'restore_idea_desc' : 'archive_idea_desc',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(tr(dialogContext, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(tr(dialogContext, restoring ? 'restore' : 'archive')),
          ),
        ],
      ),
    );
    if (!context.mounted || confirmed != true) return;
    Navigator.of(context).pop(
      IdeaUpdatedResult(
        idea.copyWith(
          archivedAt: restoring ? null : DateTime.now(),
          clearArchivedAt: restoring,
          updatedAt: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> _deleteIdea(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final cs = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          title: Text(tr(dialogContext, 'delete_idea_question')),
          content: Text(tr(dialogContext, 'delete_idea_desc')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(tr(dialogContext, 'cancel')),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(tr(dialogContext, 'delete')),
            ),
          ],
        );
      },
    );
    if (!context.mounted || confirmed != true) return;
    Navigator.of(context).pop(IdeaDeletedResult(idea.id));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'idea_details')),
        actions: [
          IconButton(
            onPressed: () => _editIdea(context),
            tooltip: tr(context, 'edit_idea'),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<_IdeaMenuAction>(
            tooltip: tr(context, 'more_actions'),
            onSelected: (action) {
              switch (action) {
                case _IdeaMenuAction.toggleArchive:
                  _toggleArchive(context);
                case _IdeaMenuAction.delete:
                  _deleteIdea(context);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: _IdeaMenuAction.toggleArchive,
                child: Row(
                  children: [
                    Icon(
                      idea.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tr(
                        context,
                        idea.isArchived ? 'restore_idea' : 'archive_idea',
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: _IdeaMenuAction.delete,
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline),
                    const SizedBox(width: 12),
                    Text(tr(context, 'delete_idea')),
                  ],
                ),
              ),
            ],
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
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: cs.onPrimaryContainer,
                    size: 34,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    idea.title,
                    style: tt.headlineSmall?.copyWith(
                      color: cs.onPrimaryContainer,
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
                  backgroundColor: cs.secondaryContainer,
                  foregroundColor: cs.onSecondaryContainer,
                  child: const Icon(Icons.analytics_outlined),
                ),
                title: Text(tr(context, 'opportunity_score')),
                subtitle: Text(
                  idea.totalScore == null
                      ? tr(context, 'not_evaluated')
                      : '${idea.totalScore} / 40',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                key: const Key('assumption_radar_tile'),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => AssumptionRadarScreen(
                      idea: idea,
                      repository: repository,
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  child: const Icon(Icons.radar),
                ),
                title: Text(tr(context, 'assumption_radar')),
                subtitle: Text(tr(context, 'assumption_radar_subtitle')),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                key: const Key('research_notes_tile'),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => IdeaNotesScreen(
                      repository: repository,
                      ideaId: idea.id,
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: cs.tertiaryContainer,
                  foregroundColor: cs.onTertiaryContainer,
                  child: const Icon(Icons.sticky_note_2_outlined),
                ),
                title: Text(tr(context, 'research_notes')),
                subtitle: Text(tr(context, 'research_notes_subtitle')),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                key: const Key('research_sources_tile'),
                onTap: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => IdeaSourcesScreen(
                      repository: repository,
                      ideaId: idea.id,
                    ),
                  ),
                ),
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  foregroundColor: cs.onSecondaryContainer,
                  child: const Icon(Icons.travel_explore),
                ),
                title: Text(tr(context, 'research_sources')),
                subtitle: Text(tr(context, 'research_sources_subtitle')),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                key: const Key('next_review_tile'),
                onTap: () => _scheduleReview(context),
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  foregroundColor: cs.onPrimaryContainer,
                  child: const Icon(Icons.event_repeat_outlined),
                ),
                title: Text(tr(context, 'next_review')),
                subtitle: Text(
                  idea.nextReviewAt == null
                      ? tr(context, 'not_scheduled')
                      : _formatDate(idea.nextReviewAt!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (idea.nextReviewAt != null)
                      IconButton(
                        key: const Key('clear_next_review_button'),
                        onPressed: () => _clearReview(context),
                        tooltip: tr(context, 'remove_review_date'),
                        icon: const Icon(Icons.event_busy_outlined),
                      ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _DetailSection(
              title: tr(context, 'summary'),
              icon: Icons.subject,
              content: idea.summary,
            ),
            _DetailSection(
              title: tr(context, 'problem'),
              icon: Icons.report_problem_outlined,
              content: idea.problem,
            ),
            _DetailSection(
              title: tr(context, 'proposed_solution'),
              icon: Icons.auto_awesome_outlined,
              content: idea.solution,
            ),
            _DetailSection(
              title: tr(context, 'target_users'),
              icon: Icons.groups_outlined,
              content: idea.targetUsers,
            ),
            _DetailSection(
              title: tr(context, 'paying_customer'),
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
                      label: tr(context, 'created'),
                      value: _formatDate(idea.createdAt),
                    ),
                    const Divider(height: 24),
                    _DateRow(
                      label: tr(context, 'updated'),
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

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
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
    final cs = Theme.of(context).colorScheme;
    final displayed = content.trim().isEmpty
        ? tr(context, 'not_added_yet')
        : content;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary),
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
                    displayed,
                    style: TextStyle(
                      color: content.trim().isEmpty
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
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
  Widget build(BuildContext context) => Row(
    children: [
      Text(label),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ],
  );
}

enum _IdeaMenuAction { toggleArchive, delete }
