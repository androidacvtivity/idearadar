import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/idea_localization.dart';
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

  void _reset() => setState(() {
    _status = null;
    _minimumScore = null;
    _sort = IdeaSort.updated;
  });
  void _apply() => Navigator.of(context).pop(
    IdeaListOptions(status: _status, minimumScore: _minimumScore, sort: _sort),
  );
  @override
  Widget build(BuildContext context) => SafeArea(
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
                itx(context, 'filter_and_sort'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              TextButton(
                key: const Key('reset_idea_filters_button'),
                onPressed: _reset,
                child: Text(itx(context, 'reset')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<IdeaStatus?>(
            key: const Key('idea_status_filter'),
            initialValue: _status,
            decoration: InputDecoration(
              labelText: itx(context, 'status'),
              prefixIcon: const Icon(Icons.flag_outlined),
            ),
            items: [
              DropdownMenuItem<IdeaStatus?>(
                value: null,
                child: Text(itx(context, 'all_statuses')),
              ),
              ...IdeaStatus.values.map(
                (s) => DropdownMenuItem<IdeaStatus?>(
                  value: s,
                  child: Text(localizedIdeaStatus(context, s)),
                ),
              ),
            ],
            onChanged: (s) => setState(() => _status = s),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int?>(
            key: const Key('idea_score_filter'),
            initialValue: _minimumScore,
            decoration: InputDecoration(
              labelText: itx(context, 'minimum_score'),
              prefixIcon: const Icon(Icons.analytics_outlined),
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(itx(context, 'any_score')),
              ),
              for (final score in const [20, 25, 30, 35])
                DropdownMenuItem(
                  value: score,
                  child: Text('$score ${itx(context, 'or_higher')}'),
                ),
            ],
            onChanged: (s) => setState(() => _minimumScore = s),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<IdeaSort>(
            key: const Key('idea_sort_field'),
            initialValue: _sort,
            decoration: InputDecoration(
              labelText: itx(context, 'sort_by'),
              prefixIcon: const Icon(Icons.sort),
            ),
            items: IdeaSort.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(localizedIdeaSort(context, s)),
                  ),
                )
                .toList(),
            onChanged: (s) {
              if (s != null) setState(() => _sort = s);
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('apply_idea_filters_button'),
            onPressed: _apply,
            icon: const Icon(Icons.check),
            label: Text(itx(context, 'apply')),
          ),
        ],
      ),
    ),
  );
}
