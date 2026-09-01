import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/app/localization/idea_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea_source.dart';

class IdeaSourcesScreen extends StatefulWidget {
  const IdeaSourcesScreen({
    required this.repository,
    required this.ideaId,
    super.key,
  });

  final IdeaRepository repository;
  final String ideaId;

  @override
  State<IdeaSourcesScreen> createState() => _IdeaSourcesScreenState();
}

class _IdeaSourcesScreenState extends State<IdeaSourcesScreen> {
  final List<IdeaSource> _sources = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSources();
  }

  Future<void> _loadSources() async {
    try {
      final sources = await widget.repository.getSources(widget.ideaId);
      if (!mounted) return;
      setState(() {
        _sources
          ..clear()
          ..addAll(sources);
        _isLoading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = itx(context, 'sources_load_error');
      });
    }
  }

  Future<void> _openEditor([IdeaSource? source]) async {
    final saved = await Navigator.of(context).push<IdeaSource>(
      MaterialPageRoute(
        builder: (_) =>
            _SourceEditorScreen(ideaId: widget.ideaId, source: source),
      ),
    );
    if (!mounted || saved == null) return;

    try {
      if (source == null) {
        await widget.repository.addSource(saved);
        if (!mounted) return;
        setState(() => _sources.insert(0, saved));
      } else {
        await widget.repository.updateSource(saved);
        if (!mounted) return;
        setState(() {
          final index = _sources.indexWhere(
            (current) => current.id == saved.id,
          );
          if (index != -1) _sources[index] = saved;
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(itx(context, 'source_save_error'))),
      );
    }
  }

  Future<void> _deleteSource(IdeaSource source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(itx(dialogContext, 'delete_source_question')),
        content: Text(itx(dialogContext, 'delete_source_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(tr(dialogContext, 'cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(tr(dialogContext, 'delete')),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      await widget.repository.deleteSource(source.id);
      if (!mounted) return;
      setState(
        () => _sources.removeWhere((current) => current.id == source.id),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(itx(context, 'source_delete_error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'research_sources'))),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _SourcesError(message: _error!, onRetry: _loadSources)
            : _sources.isEmpty
            ? const _EmptySources()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                itemCount: _sources.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final source = _sources[index];
                  final type = localizedSourceType(context, source.sourceType);
                  return Card(
                    child: ListTile(
                      onTap: () => _openEditor(source),
                      contentPadding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
                      leading: CircleAvatar(
                        child: Icon(_sourceIcon(source.sourceType)),
                      ),
                      title: Text(
                        source.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        source.url.isEmpty ? type : '$type · ${source.url}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: PopupMenuButton<_SourceAction>(
                        tooltip: itx(context, 'source_actions'),
                        onSelected: (action) {
                          switch (action) {
                            case _SourceAction.edit:
                              _openEditor(source);
                            case _SourceAction.delete:
                              _deleteSource(source);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: _SourceAction.edit,
                            child: Text(itx(context, 'edit')),
                          ),
                          PopupMenuItem(
                            value: _SourceAction.delete,
                            child: Text(itx(context, 'delete')),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add_link),
        label: Text(itx(context, 'new_source')),
      ),
    );
  }

  static IconData _sourceIcon(IdeaSourceType type) => switch (type) {
    IdeaSourceType.website => Icons.language,
    IdeaSourceType.article => Icons.article_outlined,
    IdeaSourceType.report => Icons.description_outlined,
    IdeaSourceType.statistics => Icons.query_stats,
    IdeaSourceType.interview => Icons.record_voice_over_outlined,
    IdeaSourceType.other => Icons.link,
  };
}

class _SourceEditorScreen extends StatefulWidget {
  const _SourceEditorScreen({required this.ideaId, this.source});

  final String ideaId;
  final IdeaSource? source;

  @override
  State<_SourceEditorScreen> createState() => _SourceEditorScreenState();
}

class _SourceEditorScreenState extends State<_SourceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _urlController;
  late final TextEditingController _noteController;
  late IdeaSourceType _sourceType;
  late DateTime _accessedAt;

  @override
  void initState() {
    super.initState();
    final source = widget.source;
    _titleController = TextEditingController(text: source?.title);
    _urlController = TextEditingController(text: source?.url);
    _noteController = TextEditingController(text: source?.note);
    _sourceType = source?.sourceType ?? IdeaSourceType.website;
    _accessedAt = source?.accessedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _accessedAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _accessedAt = date);
    }
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final original = widget.source;
    final now = DateTime.now();
    Navigator.of(context).pop(
      IdeaSource(
        id: original?.id ?? now.microsecondsSinceEpoch.toString(),
        ideaId: widget.ideaId,
        title: _titleController.text.trim(),
        url: _urlController.text.trim(),
        sourceType: _sourceType,
        note: _noteController.text.trim(),
        accessedAt: _accessedAt,
        createdAt: original?.createdAt ?? now,
      ),
    );
  }

  String? _validateUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty) {
      return itx(context, 'invalid_url');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.source != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(itx(context, isEditing ? 'edit_source' : 'add_source')),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                TextFormField(
                  key: const Key('source_title_field'),
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: itx(context, 'title'),
                    hintText: itx(context, 'source_title_hint'),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '${itx(context, 'title')} ${itx(context, 'required')}'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('source_url_field'),
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: itx(context, 'url_optional'),
                    hintText: 'https://example.com',
                    prefixIcon: const Icon(Icons.link),
                  ),
                  validator: _validateUrl,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<IdeaSourceType>(
                  key: const Key('source_type_field'),
                  initialValue: _sourceType,
                  decoration: InputDecoration(
                    labelText: itx(context, 'source_type'),
                    prefixIcon: const Icon(Icons.category_outlined),
                  ),
                  items: IdeaSourceType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(localizedSourceType(context, type)),
                        ),
                      )
                      .toList(),
                  onChanged: (type) {
                    if (type != null) {
                      setState(() => _sourceType = type);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  onTap: _selectDate,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  leading: const Icon(Icons.event_outlined),
                  title: Text(itx(context, 'access_date')),
                  subtitle: Text(_formatDate(_accessedAt)),
                  trailing: const Icon(Icons.edit_calendar_outlined),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  key: const Key('source_note_field'),
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 7,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: itx(context, 'research_note_optional'),
                    hintText: itx(context, 'source_note_hint'),
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
          key: const Key('save_source_button'),
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: Text(itx(context, isEditing ? 'save_changes' : 'save_source')),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
}

enum _SourceAction { edit, delete }

class _EmptySources extends StatelessWidget {
  const _EmptySources();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.travel_explore,
              size: 52,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              itx(context, 'no_research_sources'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              itx(context, 'no_research_sources_desc'),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcesError extends StatelessWidget {
  const _SourcesError({required this.message, required this.onRetry});

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
            label: Text(itx(context, 'try_again')),
          ),
        ],
      ),
    );
  }
}
