import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';
import 'package:idearadar/features/ideas/presentation/add_idea_screen.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_result.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      await widget.repository.initialize();
      final ideas = await widget.repository.getIdeas();

      if (!mounted) {
        return;
      }

      setState(() {
        _ideas
          ..clear()
          ..addAll(ideas);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _loadError = 'Ideas could not be loaded.';
      });
    }
  }

  int get _validatedIdeas {
    return _ideas.where((idea) => idea.status == IdeaStatus.validated).length;
  }

  Future<void> _addIdea() async {
    final idea = await Navigator.of(
      context,
    ).push<Idea>(MaterialPageRoute(builder: (_) => const AddIdeaScreen()));

    if (!mounted || idea == null) {
      return;
    }

    try {
      await widget.repository.addIdea(idea);

      if (!mounted) {
        return;
      }

      setState(() {
        _ideas.insert(0, idea);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The idea could not be saved.')),
      );
    }
  }

  Future<void> _openIdea(Idea idea) async {
    final result = await Navigator.of(context).push<IdeaDetailsResult>(
      MaterialPageRoute(builder: (_) => IdeaDetailsScreen(idea: idea)),
    );

    if (!mounted || result == null) {
      return;
    }

    switch (result) {
      case IdeaUpdatedResult(:final idea):
        await _persistUpdatedIdea(idea);
      case IdeaDeletedResult(:final ideaId):
        await _persistDeletedIdea(ideaId);
    }
  }

  Future<void> _persistUpdatedIdea(Idea updatedIdea) async {
    try {
      await widget.repository.updateIdea(updatedIdea);

      if (!mounted) {
        return;
      }

      setState(() {
        final index = _ideas.indexWhere(
          (currentIdea) => currentIdea.id == updatedIdea.id,
        );
        if (index != -1) {
          _ideas[index] = updatedIdea;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The idea could not be updated.')),
      );
    }
  }

  Future<void> _persistDeletedIdea(String ideaId) async {
    try {
      await widget.repository.deleteIdea(ideaId);

      if (!mounted) {
        return;
      }

      setState(() {
        _ideas.removeWhere((idea) => idea.id == ideaId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Idea deleted.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The idea could not be deleted.')),
      );
    }
  }

  Future<void> _searchIdeas() async {
    if (_ideas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an idea before searching.')),
      );
      return;
    }

    final selectedIdea = await showSearch<Idea?>(
      context: context,
      delegate: IdeaSearchDelegate(ideas: _ideas),
    );

    if (!mounted || selectedIdea == null) {
      return;
    }

    await _openIdea(selectedIdea);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IdeaRadar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _searchIdeas,
            tooltip: 'Search ideas',
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 104),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.radar, color: colorScheme.onPrimary, size: 36),
                  const SizedBox(height: 28),
                  Text(
                    'From idea to opportunity.',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Capture, evaluate, and develop ideas with evidence.',
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.86),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Overview',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'All ideas',
                    value: '${_ideas.length}',
                    icon: Icons.lightbulb_outline,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Validated',
                    value: '$_validatedIdeas',
                    icon: Icons.verified_outlined,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_loadError != null)
              _LoadError(message: _loadError!, onRetry: _loadIdeas)
            else if (_ideas.isEmpty)
              _EmptyState(onAddIdea: _addIdea)
            else ...[
              Text(
                'Recent ideas',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              for (final idea in _ideas)
                _IdeaCard(idea: idea, onTap: () => _openIdea(idea)),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addIdea,
        icon: const Icon(Icons.add),
        label: const Text('New idea'),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 44,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddIdea});

  final VoidCallback onAddIdea;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.explore_outlined, size: 48, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Your idea radar is ready',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first idea and evaluate its potential.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddIdea,
              icon: const Icon(Icons.add),
              label: const Text('Add your first idea'),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaCard extends StatelessWidget {
  const _IdeaCard({required this.idea, required this.onTap});

  final Idea idea;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          child: const Icon(Icons.lightbulb_outline),
        ),
        title: Text(
          idea.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
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
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 20),
            Text(
              value,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
