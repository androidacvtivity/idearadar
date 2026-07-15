import 'package:flutter/material.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_evaluation.dart';

class IdeaEvaluationScreen extends StatefulWidget {
  const IdeaEvaluationScreen({required this.idea, super.key});

  final Idea idea;

  @override
  State<IdeaEvaluationScreen> createState() => _IdeaEvaluationScreenState();
}

class _IdeaEvaluationScreenState extends State<IdeaEvaluationScreen> {
  final _rationaleController = TextEditingController();

  int _problemScore = 3;
  int _marketScore = 3;
  int _demandScore = 3;
  int _competitionScore = 3;
  int _dataAccessScore = 3;
  int _technicalFeasibilityScore = 3;
  int _monetizationScore = 3;
  int _firstClientScore = 3;

  int get _totalScore =>
      _problemScore +
      _marketScore +
      _demandScore +
      _competitionScore +
      _dataAccessScore +
      _technicalFeasibilityScore +
      _monetizationScore +
      _firstClientScore;

  @override
  void initState() {
    super.initState();

    final evaluation = widget.idea.evaluation;
    if (evaluation == null) {
      return;
    }

    _problemScore = evaluation.problemScore;
    _marketScore = evaluation.marketScore;
    _demandScore = evaluation.demandScore;
    _competitionScore = evaluation.competitionScore;
    _dataAccessScore = evaluation.dataAccessScore;
    _technicalFeasibilityScore = evaluation.technicalFeasibilityScore;
    _monetizationScore = evaluation.monetizationScore;
    _firstClientScore = evaluation.firstClientScore;
    _rationaleController.text = evaluation.rationale;
  }

  @override
  void dispose() {
    _rationaleController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _saveEvaluation() {
    _dismissKeyboard();

    final evaluation = IdeaEvaluation(
      problemScore: _problemScore,
      marketScore: _marketScore,
      demandScore: _demandScore,
      competitionScore: _competitionScore,
      dataAccessScore: _dataAccessScore,
      technicalFeasibilityScore: _technicalFeasibilityScore,
      monetizationScore: _monetizationScore,
      firstClientScore: _firstClientScore,
      rationale: _rationaleController.text.trim(),
    );

    Navigator.of(context).pop(
      widget.idea.copyWith(evaluation: evaluation, updatedAt: DateTime.now()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.idea.evaluation != null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit evaluation' : 'Evaluate idea'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissKeyboard,
        child: SafeArea(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 36,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Opportunity score',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Adjust each criterion from 1 to 5.',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$_totalScore/40',
                      key: const Key('evaluation_total_score'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _ScoreControl(
                label: 'Problem severity',
                description: 'How important and frequent is the problem?',
                value: _problemScore,
                onChanged: (value) => setState(() => _problemScore = value),
              ),
              _ScoreControl(
                label: 'Market potential',
                description: 'How large and reachable is the market?',
                value: _marketScore,
                onChanged: (value) => setState(() => _marketScore = value),
              ),
              _ScoreControl(
                label: 'Demand evidence',
                description: 'How strong is the evidence of real demand?',
                value: _demandScore,
                onChanged: (value) => setState(() => _demandScore = value),
              ),
              _ScoreControl(
                label: 'Competition favorability',
                description: '5 means lower competition and a better position.',
                value: _competitionScore,
                onChanged: (value) => setState(() => _competitionScore = value),
              ),
              _ScoreControl(
                label: 'Data access',
                description: 'Can the required data be obtained legally?',
                value: _dataAccessScore,
                onChanged: (value) => setState(() => _dataAccessScore = value),
              ),
              _ScoreControl(
                label: 'Technical feasibility',
                description: 'Can the MVP be built with available resources?',
                value: _technicalFeasibilityScore,
                onChanged: (value) =>
                    setState(() => _technicalFeasibilityScore = value),
              ),
              _ScoreControl(
                label: 'Monetization potential',
                description: 'Is there a credible paying customer or model?',
                value: _monetizationScore,
                onChanged: (value) =>
                    setState(() => _monetizationScore = value),
              ),
              _ScoreControl(
                label: 'Access to first client',
                description: 'How easily can the first client be reached?',
                value: _firstClientScore,
                onChanged: (value) => setState(() => _firstClientScore = value),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('evaluation_rationale_field'),
                controller: _rationaleController,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _dismissKeyboard(),
                decoration: const InputDecoration(
                  labelText: 'Evaluation rationale',
                  hintText: 'Record the evidence behind the scores',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: FilledButton.icon(
          key: const Key('save_evaluation_button'),
          onPressed: _saveEvaluation,
          icon: const Icon(Icons.save_outlined),
          label: Text(
            isEditing ? 'Save evaluation changes' : 'Save evaluation',
          ),
        ),
      ),
    );
  }
}

class _ScoreControl extends StatelessWidget {
  const _ScoreControl({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$value',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '$value',
              onChanged: (newValue) => onChanged(newValue.round()),
            ),
          ],
        ),
      ),
    );
  }
}
