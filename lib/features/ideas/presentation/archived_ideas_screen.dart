import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_result.dart';
import 'package:idearadar/features/ideas/presentation/idea_details_screen.dart';

class ArchivedIdeasScreen extends StatefulWidget {
  const ArchivedIdeasScreen({required this.repository, super.key});

  final IdeaRepository repository;

  @override
  State<ArchivedIdeasScreen> createState() => _ArchivedIdeasScreenState();
}

class _ArchivedIdeasScreenState extends State<ArchivedIdeasScreen> {
  final List<Idea> _ideas = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIdeas();
  }

  Future<void> _loadIdeas() async {
    try {
      final ideas = await widget.repository.getIdeas();
      final archived = ideas.where((idea) => idea.isArchived).toList()
        ..sort((a, b) => b.archivedAt!.compareTo(a.archivedAt!));

      if (!mounted) {
        return;
      }
      setState(() {
        _ideas
          ..clear()
          ..addAll(archived);
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _error = 'Archived ideas could not be loaded.';
      });
    }
  }

  Future<void> _openIdea(Idea idea) async {
    final result = await Navigator.of(context).push<IdeaDetailsResult>(
      MaterialPageRoute(
        builder: (_) =>
            IdeaDetailsScreen(idea: idea, repository: widget.repository),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    try {
      switch (result) {
        case IdeaUpdatedResult(:final idea):
          await widget.repository.updateIdea(idea);
          if (!mounted) {
            return;
          }
          setState(() {
            final index = _ideas.indexWhere((current) => current.id == idea.id);
            if (!idea.isArchived) {
              _ideas.removeWhere((current) => current.id == idea.id);
            } else if (index != -1) {
              _ideas[index] = idea;
            }
          });
        case IdeaDeletedResult(:final ideaId):
          await widget.repository.deleteIdea(ideaId);
          if (!mounted) {
            return;
          }
          setState(() {
            _ideas.removeWhere((current) => current.id == ideaId);
          });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The archived idea could not be updated.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Archived ideas')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _ArchiveError(message: _error!, onRetry: _loadIdeas)
            : _ideas.isEmpty
            ? const _EmptyArchive()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                itemCount: _ideas.length,
                itemBuilder: (context, index) {
                  final idea = _ideas[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      onTap: () => _openIdea(idea),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.archive_outlined),
                      ),
                      title: Text(
                        idea.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${idea.domain} · Archived ${_formatDate(idea.archivedAt!)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
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

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No archived ideas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ideas you archive will appear here and can be restored later.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveError extends StatelessWidget {
  const _ArchiveError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}
