import 'package:flutter/material.dart';
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
    _reload();
  }

  Future<void> _reload() async {
    final assumptions = await widget.repository.getAssumptions(widget.idea.id);
    if (!mounted) return;
    setState(() {
      _assumptions = assumptions;
      _loading = false;
    });
  }

  Future<void> _createStarterAssumptions() async {
    final assumptions = buildStarterAssumptions(widget.idea);
    for (final assumption in assumptions) {
      await widget.repository.addAssumption(assumption);
    }
    await _reload();
  }

  Future<void> _changeConfidence(IdeaAssumption assumption) async {
    final selected = await showModalBottomSheet<AssumptionConfidence>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'How strong is the evidence?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            for (final confidence in AssumptionConfidence.values)
              ListTile(
                leading: Icon(_confidenceIcon(confidence)),
                title: Text(_confidenceLabel(confidence)),
                subtitle: Text('${_confidencePercent(confidence)}% confidence'),
                trailing: confidence == assumption.confidence
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(confidence),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected == null || selected == assumption.confidence) return;
    await widget.repository.updateAssumption(
      assumption.copyWith(confidence: selected),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Assumption Radar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _assumptions.isEmpty
          ? _EmptyRadar(
              ideaTitle: widget.idea.title,
              onCreate: _createStarterAssumptions,
            )
          : Builder(
              builder: (context) {
                final radar = AssumptionRadar.analyze(_assumptions);
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.radar,
                                size: 32,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const Spacer(),
                              Text(
                                '${radar.overallConfidence}%',
                                key: const Key('radar_overall_confidence'),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Overall confidence',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'This is not a quality score. It shows how much of the idea is supported by evidence.',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (radar.weakestSignal != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.sensors_off_outlined,
                                    color: colorScheme.error,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Weakest signal',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                radar.weakestSignal!.title,
                                key: const Key('radar_weakest_signal'),
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${radar.weakestSignal!.confidencePercent}% confidence',
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (radar.nextExperiment != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.science_outlined,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Next experiment',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                radar.nextExperiment!,
                                key: const Key('radar_next_experiment'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      'Critical assumptions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap an assumption when new evidence changes your confidence.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    for (final assumption in _assumptions)
                      _AssumptionCard(
                        assumption: assumption,
                        onTap: () => _changeConfidence(assumption),
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _EmptyRadar extends StatelessWidget {
  const _EmptyRadar({required this.ideaTitle, required this.onCreate});

  final String ideaTitle;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radar, size: 68),
            const SizedBox(height: 20),
            Text(
              'What must be true?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'IdeaRadar can create a starter set of critical assumptions for “$ideaTitle”. You then replace confidence with real evidence.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const Key('create_starter_assumptions_button'),
              onPressed: onCreate,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Create assumption radar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssumptionCard extends StatelessWidget {
  const _AssumptionCard({required this.assumption, required this.onTap});

  final IdeaAssumption assumption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = assumption.confidencePercent;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _confidenceIcon(assumption.confidence),
                    color: _confidenceColor(context, assumption.confidence),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      assumption.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('$percent%'),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(value: percent / 100),
              if ((assumption.nextExperiment ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  assumption.nextExperiment!,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _confidenceLabel(AssumptionConfidence confidence) {
  switch (confidence) {
    case AssumptionConfidence.untested:
      return 'Untested';
    case AssumptionConfidence.weak:
      return 'Weak evidence';
    case AssumptionConfidence.uncertain:
      return 'Uncertain';
    case AssumptionConfidence.supported:
      return 'Supported';
    case AssumptionConfidence.strong:
      return 'Strong evidence';
  }
}

int _confidencePercent(AssumptionConfidence confidence) {
  switch (confidence) {
    case AssumptionConfidence.untested:
      return 0;
    case AssumptionConfidence.weak:
      return 25;
    case AssumptionConfidence.uncertain:
      return 50;
    case AssumptionConfidence.supported:
      return 75;
    case AssumptionConfidence.strong:
      return 100;
  }
}

IconData _confidenceIcon(AssumptionConfidence confidence) {
  switch (confidence) {
    case AssumptionConfidence.untested:
      return Icons.help_outline;
    case AssumptionConfidence.weak:
      return Icons.error_outline;
    case AssumptionConfidence.uncertain:
      return Icons.change_circle_outlined;
    case AssumptionConfidence.supported:
      return Icons.check_circle_outline;
    case AssumptionConfidence.strong:
      return Icons.verified_outlined;
  }
}

Color _confidenceColor(BuildContext context, AssumptionConfidence confidence) {
  final scheme = Theme.of(context).colorScheme;
  switch (confidence) {
    case AssumptionConfidence.untested:
      return scheme.onSurfaceVariant;
    case AssumptionConfidence.weak:
      return scheme.error;
    case AssumptionConfidence.uncertain:
      return scheme.tertiary;
    case AssumptionConfidence.supported:
      return scheme.primary;
    case AssumptionConfidence.strong:
      return scheme.primary;
  }
}
