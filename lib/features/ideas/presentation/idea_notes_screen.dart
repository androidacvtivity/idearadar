import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';

class IdeaNotesScreen extends StatefulWidget {
  const IdeaNotesScreen({
    required this.repository,
    required this.ideaId,
    super.key,
  });

  final IdeaRepository repository;
  final String ideaId;

  @override
  State<IdeaNotesScreen> createState() => _IdeaNotesScreenState();
}

class _IdeaNotesScreenState extends State<IdeaNotesScreen> {
  final List<IdeaNote> _notes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await widget.repository.getNotes(widget.ideaId);
      if (!mounted) {
        return;
      }

      setState(() {
        _notes
          ..clear()
          ..addAll(notes);
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = 'Notes could not be loaded.';
      });
    }
  }

  Future<void> _openNoteEditor([IdeaNote? note]) async {
    final controller = TextEditingController(text: note?.content);
    final content = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  note == null ? 'New research note' : 'Edit research note',
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('note_content_field'),
                  controller: controller,
                  autofocus: true,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    hintText: 'Add an observation, assumption, or research finding',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  key: const Key('save_note_button'),
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isNotEmpty) {
                      Navigator.of(sheetContext).pop(value);
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(note == null ? 'Save note' : 'Save changes'),
                ),
              ],
            ),
          ),
        );
      },
    );
    controller.dispose();

    if (!mounted || content == null) {
      return;
    }

    final now = DateTime.now();
    try {
      if (note == null) {
        final newNote = IdeaNote(
          id: now.microsecondsSinceEpoch.toString(),
          ideaId: widget.ideaId,
          content: content,
          createdAt: now,
          updatedAt: now,
        );
        await widget.repository.addNote(newNote);
        if (!mounted) {
          return;
        }
        setState(() => _notes.insert(0, newNote));
      } else {
        final updatedNote = note.copyWith(content: content, updatedAt: now);
        await widget.repository.updateNote(updatedNote);
        if (!mounted) {
          return;
        }
        setState(() {
          final index = _notes.indexWhere((current) => current.id == note.id);
          if (index != -1) {
            _notes[index] = updatedNote;
          }
        });
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The note could not be saved.')),
      );
    }
  }

  Future<void> _deleteNote(IdeaNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This research note will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    try {
      await widget.repository.deleteNote(note.id);
      if (!mounted) {
        return;
      }
      setState(() => _notes.removeWhere((current) => current.id == note.id));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The note could not be deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Research notes')),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _NotesError(message: _error!, onRetry: _loadNotes)
            : _notes.isEmpty
            ? const _EmptyNotes()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: _notes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final note = _notes[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(note.content),
                                const SizedBox(height: 12),
                                Text(
                                  _formatDate(note.updatedAt),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<_NoteAction>(
                            tooltip: 'Note actions',
                            onSelected: (action) {
                              switch (action) {
                                case _NoteAction.edit:
                                  _openNoteEditor(note);
                                case _NoteAction.delete:
                                  _deleteNote(note);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: _NoteAction.edit,
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: _NoteAction.delete,
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNoteEditor,
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('New note'),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year} · $hour:$minute';
  }
}

enum _NoteAction { edit, delete }

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No research notes yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Record assumptions, observations, and findings as the idea develops.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotesError extends StatelessWidget {
  const _NotesError({required this.message, required this.onRetry});

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
