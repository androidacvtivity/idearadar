import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';
import 'package:idearadar/features/ideas/presentation/add_idea_screen.dart';
import 'package:idearadar/features/ideas/presentation/archived_ideas_screen.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_result.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_screen.dart';
import 'package:idearadar/features/ideas/presentation/idea_filter_sheet.dart';
import 'package:idearadar/features/ideas/presentation/idea_list_options.dart';
import 'package:idearadar/features/ideas/presentation/idea_search_delegate.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.repository, super.key});
  final IdeaRepository repository;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Idea> _ideas = [];
  bool _isLoading = true;
  String? _loadError;
  IdeaListOptions _listOptions = const IdeaListOptions();

  @override
  void initState() { super.initState(); _loadIdeas(); }

  Future<void> _loadIdeas() async {
    setState(() { _isLoading = true; _loadError = null; });
    try {
      await widget.repository.initialize();
      final ideas = await widget.repository.getIdeas();
      if (!mounted) return;
      setState(() { _ideas..clear()..addAll(ideas); _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _isLoading = false; _loadError = tr(context, 'ideas_load_error'); });
    }
  }

  List<Idea> get _activeIdeas => _ideas.where((idea) => !idea.isArchived).toList(growable: false);
  List<Idea> get _archivedIdeas => _ideas.where((idea) => idea.isArchived).toList(growable: false);
  int get _validatedIdeas => _activeIdeas.where((idea) => idea.status == IdeaStatus.validated).length;

  List<Idea> get _visibleIdeas {
    final visibleIdeas = _activeIdeas.where((idea) {
      final statusMatches = _listOptions.status == null || idea.status == _listOptions.status;
      final minimumScore = _listOptions.minimumScore;
      return statusMatches && (minimumScore == null || (idea.totalScore != null && idea.totalScore! >= minimumScore));
    }).toList();
    visibleIdeas.sort((a, b) => switch (_listOptions.sort) {
      IdeaSort.updated => b.updatedAt.compareTo(a.updatedAt),
      IdeaSort.score => (b.totalScore ?? -1).compareTo(a.totalScore ?? -1),
      IdeaSort.created => b.createdAt.compareTo(a.createdAt),
      IdeaSort.nextReview => _compareReviewDates(a, b),
    });
    return visibleIdeas;
  }

  int _compareReviewDates(Idea a, Idea b) {
    if (a.nextReviewAt == null && b.nextReviewAt == null) return 0;
    if (a.nextReviewAt == null) return 1;
    if (b.nextReviewAt == null) return -1;
    return a.nextReviewAt!.compareTo(b.nextReviewAt!);
  }

  Future<void> _addIdea() async {
    final idea = await Navigator.of(context).push<Idea>(MaterialPageRoute(builder: (_) => const AddIdeaScreen()));
    if (!mounted || idea == null) return;
    try {
      await widget.repository.addIdea(idea);
      if (!mounted) return;
      setState(() => _ideas.insert(0, idea));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'idea_save_error'))));
    }
  }

  Future<void> _openIdea(Idea idea) async {
    final result = await Navigator.of(context).push<IdeaDetailsResult>(MaterialPageRoute(builder: (_) => IdeaDetailsScreen(idea: idea, repository: widget.repository)));
    if (!mounted || result == null) return;
    switch (result) {
      case IdeaUpdatedResult(:final idea): await _persistUpdatedIdea(idea);
      case IdeaDeletedResult(:final ideaId): await _persistDeletedIdea(ideaId);
    }
  }

  Future<void> _persistUpdatedIdea(Idea updatedIdea) async {
    try {
      await widget.repository.updateIdea(updatedIdea);
      if (!mounted) return;
      setState(() { final index = _ideas.indexWhere((e) => e.id == updatedIdea.id); if (index != -1) _ideas[index] = updatedIdea; });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'idea_update_error'))));
    }
  }

  Future<void> _persistDeletedIdea(String ideaId) async {
    try {
      await widget.repository.deleteIdea(ideaId);
      if (!mounted) return;
      setState(() => _ideas.removeWhere((idea) => idea.id == ideaId));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'idea_deleted'))));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'idea_delete_error'))));
    }
  }

  Future<void> _openArchive() async {
    await Navigator.of(context).push<void>(MaterialPageRoute(builder: (_) => ArchivedIdeasScreen(repository: widget.repository)));
    if (mounted) await _loadIdeas();
  }

  Future<void> _openFilters() async {
    final options = await showModalBottomSheet<IdeaListOptions>(context: context, isScrollControlled: true, builder: (_) => IdeaFilterSheet(options: _listOptions));
    if (!mounted || options == null) return;
    setState(() => _listOptions = options);
  }

  void _clearFilters() => setState(() => _listOptions = const IdeaListOptions());

  Future<void> _searchIdeas() async {
    final activeIdeas = _activeIdeas;
    if (activeIdeas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(context, 'search_requires_idea'))));
      return;
    }
    final selectedIdea = await showSearch<Idea?>(context: context, delegate: IdeaSearchDelegate(ideas: activeIdeas));
    if (!mounted || selectedIdea == null) return;
    await _openIdea(selectedIdea);
  }

  void _selectLanguage(String code) { ideaRadarLocale.value = Locale(code); }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final activeIdeas = _activeIdeas;
    final archivedIdeas = _archivedIdeas;
    final visibleIdeas = _visibleIdeas;
    final currentLanguage = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(context, 'app_title'), style: const TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          PopupMenuButton<String>(
            key: const Key('language_selector'),
            tooltip: tr(context, 'language'),
            icon: const Icon(Icons.language),
            onSelected: _selectLanguage,
            itemBuilder: (_) => [
              CheckedPopupMenuItem(value: 'en', checked: currentLanguage == 'en', child: Text(tr(context, 'english'))),
              CheckedPopupMenuItem(value: 'ro', checked: currentLanguage == 'ro', child: Text(tr(context, 'romanian'))),
            ],
          ),
          IconButton(onPressed: _isLoading ? null : _openArchive, tooltip: tr(context, 'archived_ideas'), icon: archivedIdeas.isEmpty ? const Icon(Icons.archive_outlined) : Badge.count(count: archivedIdeas.length, child: const Icon(Icons.archive_outlined))),
          IconButton(onPressed: _isLoading || activeIdeas.isEmpty ? null : _openFilters, tooltip: tr(context, 'filter_sort'), icon: _listOptions.activeFilterCount == 0 ? const Icon(Icons.tune) : Badge.count(count: _listOptions.activeFilterCount, child: const Icon(Icons.tune))),
          IconButton(onPressed: _isLoading ? null : _searchIdeas, tooltip: tr(context, 'search_ideas'), icon: const Icon(Icons.search)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.tertiary], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.radar, color: colorScheme.onPrimary, size: 36),
                const SizedBox(height: 28),
                Text(tr(context, 'tagline'), style: textTheme.headlineSmall?.copyWith(color: colorScheme.onPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(tr(context, 'tagline_detail'), style: textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary.withValues(alpha: 0.86))),
              ]),
            ),
            const SizedBox(height: 28),
            Text(tr(context, 'overview'), style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _SummaryCard(label: tr(context, 'all_ideas'), value: '${activeIdeas.length}', icon: Icons.lightbulb_outline, color: colorScheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: _SummaryCard(label: tr(context, 'validated'), value: '$_validatedIdeas', icon: Icons.verified_outlined, color: colorScheme.tertiary)),
            ]),
            const SizedBox(height: 28),
            if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
            else if (_loadError != null) _LoadError(message: _loadError!, onRetry: _loadIdeas)
            else if (activeIdeas.isEmpty) _EmptyState(onAddIdea: _addIdea)
            else ...[
              Row(children: [Text(tr(context, 'ideas'), style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)), const Spacer(), Text('${visibleIdeas.length} / ${activeIdeas.length}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))]),
              const SizedBox(height: 12),
              if (visibleIdeas.isEmpty) _NoFilterResults(onClear: _clearFilters) else for (final idea in visibleIdeas) _IdeaCard(idea: idea, onTap: () => _openIdea(idea)),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _addIdea, icon: const Icon(Icons.add), label: Text(tr(context, 'new_idea'))),
    );
  }
}

class _NoFilterResults extends StatelessWidget {
  const _NoFilterResults({required this.onClear}); final VoidCallback onClear;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [Icon(Icons.filter_alt_off_outlined, size: 44, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 12), Text(tr(context, 'no_filter_results'), textAlign: TextAlign.center), const SizedBox(height: 16), OutlinedButton(key: const Key('clear_idea_filters_button'), onPressed: onClear, child: Text(tr(context, 'clear_filters')))])));
}
class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry}); final String message; final VoidCallback onRetry;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [Icon(Icons.error_outline, size: 44, color: Theme.of(context).colorScheme.error), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center), const SizedBox(height: 16), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(tr(context, 'try_again')))])));
}
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddIdea}); final VoidCallback onAddIdea;
  @override Widget build(BuildContext context) { final cs = Theme.of(context).colorScheme; final tt = Theme.of(context).textTheme; return Card(child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [Icon(Icons.explore_outlined, size: 48, color: cs.primary), const SizedBox(height: 16), Text(tr(context, 'idea_radar_ready'), textAlign: TextAlign.center, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 8), Text(tr(context, 'add_first_idea_desc'), textAlign: TextAlign.center, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)), const SizedBox(height: 20), FilledButton.icon(onPressed: onAddIdea, icon: const Icon(Icons.add), label: Text(tr(context, 'add_first_idea')))]))); }
}
class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.idea, required this.onTap}); final Idea idea; final VoidCallback onTap;
  @override Widget build(BuildContext context) { final cs = Theme.of(context).colorScheme; return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), leading: CircleAvatar(backgroundColor: cs.primaryContainer, foregroundColor: cs.onPrimaryContainer, child: const Icon(Icons.lightbulb_outline)), title: Text(idea.title, maxLines: 2, overflow: TextOverflow.ellipsis), subtitle: Text('${idea.domain} · ${idea.status.label}'), trailing: idea.totalScore == null ? const Icon(Icons.chevron_right) : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('${idea.totalScore}/40', style: const TextStyle(fontWeight: FontWeight.w700)), const Icon(Icons.chevron_right, size: 18)]))); }
}
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color}); final String label; final String value; final IconData icon; final Color color;
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color), const SizedBox(height: 12), Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(label)])));
}
