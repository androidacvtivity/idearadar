import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';
import 'package:idearadar/features/ideas/presentation/idea_list_options.dart';

class IdeaFilterSheet extends StatefulWidget {
  const IdeaFilterSheet({required this.options, super.key});

  final IdeaListOptions options;

  @override
  State<IdeaFilterSheet> createState() => _IdeaFilterSheetState();
}

class _IdeaFilterSheetState extends State<IdeaFilterSheet> {
  IdeaStatus? _status;
  int? _minimumScore;
  late IdeaSort _sort;

  @override
  void initState() {
    super.initState();
    _status = widget.options.status;
    _minimumScore = widget.options.minimumScore;
    _sort = widget.options.sort;
  }

  void _reset() {
    setState(() {
      _status = null;
      _minimumScore = null;
      _sort = IdeaSort.updated;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      IdeaListOptions(
        status: _status,
        minimumScore: _minimumScore,
        sort: _sort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Filter and sort',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  key: const Key('reset_idea_filters_button'),
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IdeaStatus?>(
              key: const Key('idea_status_filter'),
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: [
                const DropdownMenuItem<IdeaStatus?>(
                  value: null,
                  child: Text('All statuses'),
                ),
                ...IdeaStatus.values.map(
                  (status) => DropdownMenuItem<IdeaStatus?>(
                    value: status,
                    child: Text(status.label),
                  ),
                ),
              ],
              onChanged: (status) => setState(() => _status = status),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              key: const Key('idea_score_filter'),
              initialValue: _minimumScore,
              decoration: const InputDecoration(
                labelText: 'Minimum score',
                prefixIcon: Icon(Icons.analytics_outlined),
              ),
              items: const [
                DropdownMenuItem<int?>(value: null, child: Text('Any score')),
                DropdownMenuItem(value: 20, child: Text('20 or higher')),
                DropdownMenuItem(value: 25, child: Text('25 or higher')),
                DropdownMenuItem(value: 30, child: Text('30 or higher')),
                DropdownMenuItem(value: 35, child: Text('35 or higher')),
              ],
              onChanged: (score) => setState(() => _minimumScore = score),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IdeaSort>(
              key: const Key('idea_sort_field'),
              initialValue: _sort,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                prefixIcon: Icon(Icons.sort),
              ),
              items: IdeaSort.values
                  .map(
                    (sort) =>
                        DropdownMenuItem(value: sort, child: Text(sort.label)),
                  )
                  .toList(),
              onChanged: (sort) {
                if (sort != null) {
                  setState(() => _sort = sort);
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('apply_idea_filters_button'),
              onPressed: _apply,
              icon: const Icon(Icons.check),
              label: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
