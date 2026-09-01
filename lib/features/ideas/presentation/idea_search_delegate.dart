import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/app/localization/idea_localization.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';

class IdeaSearchDelegate extends SearchDelegate<Idea?> {
  IdeaSearchDelegate({required this.ideas});
  final List<Idea> ideas;

  @override
  String get searchFieldLabel => ideaRadarLocale.value.languageCode == 'ro'
      ? 'Caută idei'
      : 'Search ideas';

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        onPressed: () => query = '',
        tooltip: itx(context, 'clear_search'),
        icon: const Icon(Icons.clear),
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    onPressed: () => close(context, null),
    tooltip: itx(context, 'close_search'),
    icon: const Icon(Icons.arrow_back),
  );

  @override
  Widget buildResults(BuildContext context) => _SearchResults(
    query: query,
    ideas: _matchingIdeas,
    onSelected: (idea) => close(context, idea),
  );

  @override
  Widget buildSuggestions(BuildContext context) => _SearchResults(
    query: query,
    ideas: _matchingIdeas,
    onSelected: (idea) => close(context, idea),
  );

  List<Idea> get _matchingIdeas {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List<Idea>.unmodifiable(ideas);
    return ideas
        .where(
          (idea) => [
            idea.title,
            idea.domain,
            idea.status.label,
            idea.summary,
            idea.problem,
            idea.solution,
            idea.targetUsers,
            idea.payingCustomer,
          ].join(' ').toLowerCase().contains(q),
        )
        .toList(growable: false);
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.query,
    required this.ideas,
    required this.onSelected,
  });
  final String query;
  final List<Idea> ideas;
  final ValueChanged<Idea> onSelected;

  @override
  Widget build(BuildContext context) {
    if (ideas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                itx(context, 'no_ideas_found'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                itx(
                  context,
                  query.trim().isEmpty
                      ? 'search_empty_desc'
                      : 'search_no_results_desc',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: ideas.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final idea = ideas[index];
        return ListTile(
          onTap: () => onSelected(idea),
          leading: const Icon(Icons.lightbulb_outline),
          title: Text(idea.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${idea.domain} · ${localizedIdeaStatus(context, idea.status)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: idea.totalScore == null
              ? const Icon(Icons.chevron_right)
              : Text(
                  '${idea.totalScore}/40',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
        );
      },
    );
  }
}
