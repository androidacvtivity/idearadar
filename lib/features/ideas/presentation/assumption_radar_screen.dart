import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/features/ideas/data/idea_repository.dart';
import 'package:idearadar/features/ideas/domain/assumption_radar.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';
import 'package:idearadar/features/ideas/domain/starter_assumptions.dart';

class AssumptionRadarScreen extends StatefulWidget {
  const AssumptionRadarScreen({
    required this.idea,
    required this.repository,
    super.key,
  });
  final Idea idea;
  final IdeaRepository repository;
  @override
  State<AssumptionRadarScreen> createState() => _AssumptionRadarScreenState();
}

class _AssumptionRadarScreenState extends State<AssumptionRadarScreen> {
  List<IdeaAssumption> _assumptions = const [];
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final a = await widget.repository.getAssumptions(widget.idea.id);
    if (!mounted) return;
    setState(() {
      _assumptions = a;
      _loading = false;
    });
  }

  Future<void> _createStarterRadar() async {
    final assumptions = buildStarterAssumptions(
      widget.idea,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    for (final a in assumptions) {
      await widget.repository.addAssumption(a);
    }
    await _load();
  }

  Future<void> _changeConfidence(IdeaAssumption assumption) async {
    final selected = await showModalBottomSheet<AssumptionConfidence>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in AssumptionConfidence.values)
              ListTile(
                title: Text(_confidenceText(context, c)),
                trailing: assumption.confidence == c
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(c),
              ),
          ],
        ),
      ),
    );
    if (selected == null || selected == assumption.confidence) return;
    await widget.repository.updateAssumption(
      assumption.copyWith(confidence: selected),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = AssumptionRadar.analyze(_assumptions);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(tr(context, 'assumption_radar'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  widget.idea.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                if (_assumptions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.radar, size: 48, color: cs.primary),
                          const SizedBox(height: 16),
                          Text(
                            tr(context, 'assumption_radar_subtitle'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _createStarterRadar,
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(tr(context, 'create_assumption_radar')),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  _MetricCard(
                    title: tr(context, 'overall_confidence'),
                    value: '${analysis.overallConfidence}%',
                    icon: Icons.radar,
                  ),
                  const SizedBox(height: 12),
                  _MetricCard(
                    title: tr(context, 'weakest_signal'),
                    value: analysis.weakestSignal?.title ?? '—',
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 12),
                  _MetricCard(
                    title: tr(context, 'next_experiment'),
                    value: analysis.nextExperiment ?? '—',
                    icon: Icons.science_outlined,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    tr(context, 'critical_assumptions'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tr(context, 'tap_to_change_confidence'),
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  for (final a in _assumptions)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        onTap: () => _changeConfidence(a),
                        leading: CircleAvatar(
                          child: Text('${a.confidencePercent}'),
                        ),
                        title: Text(a.title),
                        subtitle: Text(
                          '${_confidenceText(context, a.confidence)} · ${a.evidenceCount}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                ],
              ],
            ),
    );
  }

  String _confidenceText(
    BuildContext context,
    AssumptionConfidence confidence,
  ) => switch (confidence) {
    AssumptionConfidence.untested => tr(context, 'untested'),
    AssumptionConfidence.weak => tr(context, 'weak'),
    AssumptionConfidence.uncertain => tr(context, 'uncertain'),
    AssumptionConfidence.supported => tr(context, 'supported'),
    AssumptionConfidence.strong => tr(context, 'strong'),
  };
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });
  final String title, value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
