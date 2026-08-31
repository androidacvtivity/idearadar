import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';

List<IdeaAssumption> buildStarterAssumptions(Idea idea) {
  final seed = DateTime.now().microsecondsSinceEpoch.toString();

  return [
    IdeaAssumption(
      id: '${seed}_problem',
      ideaId: idea.id,
      title: 'The problem is important enough to solve',
      type: IdeaAssumptionType.problem,
      nextExperiment:
          'Interview 5 target users and ask for recent examples of the problem.',
    ),
    IdeaAssumption(
      id: '${seed}_customer',
      ideaId: idea.id,
      title: 'A clear target customer experiences this problem',
      type: IdeaAssumptionType.customer,
      nextExperiment:
          'Define one narrow customer segment and speak with 5 people in it.',
    ),
    IdeaAssumption(
      id: '${seed}_pay',
      ideaId: idea.id,
      title: 'Customers are willing to pay for a solution',
      type: IdeaAssumptionType.willingnessToPay,
      nextExperiment:
          'Ask 5 target customers for a concrete price they would pay.',
    ),
    IdeaAssumption(
      id: '${seed}_acquisition',
      ideaId: idea.id,
      title: 'You can reach the first customers efficiently',
      type: IdeaAssumptionType.acquisition,
      nextExperiment:
          'Choose one acquisition channel and try to reach 10 target customers.',
    ),
    IdeaAssumption(
      id: '${seed}_feasibility',
      ideaId: idea.id,
      title: 'A useful MVP can be built with available resources',
      type: IdeaAssumptionType.feasibility,
      nextExperiment:
          'Define the smallest useful MVP and estimate time, cost, and technical risk.',
    ),
    IdeaAssumption(
      id: '${seed}_difference',
      ideaId: idea.id,
      title: 'The solution is meaningfully better than current alternatives',
      type: IdeaAssumptionType.differentiation,
      nextExperiment:
          'Compare the idea with 5 alternatives and identify one defensible advantage.',
    ),
  ];
}
