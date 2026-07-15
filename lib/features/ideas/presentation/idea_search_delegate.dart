import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';

class IdeaSearchDelegate extends SearchDelegate<Idea> {
  IdeaSearchDelegate({required this.ideas});

  final List<Idea> ideas;

  @override
  String get searchFieldLabel => 'Search ideas';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          tooltip: 'Clear search',
          icon: const Icon(Icons.clear),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      tooltip: 'Close search',
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _SearchResults(
      query: query,
      ideas: _matchingIdeas,
      onSelected: (idea) => close(context, idea),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _SearchResults(
      query: query,
      ideas: _matchingIdeas,
      onSelected: (idea) => close(context, idea),
    );
  }

  List<Idea> get _matchingIdeas {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return List<Idea>.unmodifiable(ideas);
    }

    return ideas.where((idea) {
      final searchableText = [
        idea.title,
        idea.domain,
        idea.status.label,
        idea.summary,
        idea.problem,
        idea.solution,
        idea.targetUsers,
        idea.payingCustomer,
      ].join(' ').toLowerCase();

      return searchableText.contains(normalizedQuery);
    }).toList(growable: false);
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
                'No ideas found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                query.trim().isEmpty
                    ? 'Add an idea to start searching.'
                    : 'Try another title, domain, status, or keyword.',
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
          title: Text(
            idea.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${idea.domain} · ${idea.status.label}',
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
