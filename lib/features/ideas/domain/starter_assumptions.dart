import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';

List<IdeaAssumption> buildStarterAssumptions(
  Idea idea, {
  String languageCode = 'en',
}) {
  final seed = DateTime.now().microsecondsSinceEpoch.toString();
  final ro = languageCode == 'ro';

  return [
    IdeaAssumption(
      id: '${seed}_problem',
      ideaId: idea.id,
      title: ro
          ? 'Problema este suficient de importantă pentru a fi rezolvată'
          : 'The problem is important enough to solve',
      type: IdeaAssumptionType.problem,
      nextExperiment: ro
          ? 'Intervievează 5 utilizatori țintă și cere exemple recente ale problemei.'
          : 'Interview 5 target users and ask for recent examples of the problem.',
    ),
    IdeaAssumption(
      id: '${seed}_customer',
      ideaId: idea.id,
      title: ro
          ? 'Un client țintă clar se confruntă cu această problemă'
          : 'A clear target customer experiences this problem',
      type: IdeaAssumptionType.customer,
      nextExperiment: ro
          ? 'Definește un segment restrâns de clienți și discută cu 5 persoane din el.'
          : 'Define one narrow customer segment and speak with 5 people in it.',
    ),
    IdeaAssumption(
      id: '${seed}_pay',
      ideaId: idea.id,
      title: ro
          ? 'Clienții sunt dispuși să plătească pentru o soluție'
          : 'Customers are willing to pay for a solution',
      type: IdeaAssumptionType.willingnessToPay,
      nextExperiment: ro
          ? 'Întreabă 5 clienți țintă ce preț concret ar fi dispuși să plătească.'
          : 'Ask 5 target customers for a concrete price they would pay.',
    ),
    IdeaAssumption(
      id: '${seed}_acquisition',
      ideaId: idea.id,
      title: ro
          ? 'Primii clienți pot fi contactați eficient'
          : 'You can reach the first customers efficiently',
      type: IdeaAssumptionType.acquisition,
      nextExperiment: ro
          ? 'Alege un canal de atragere și încearcă să contactezi 10 clienți țintă.'
          : 'Choose one acquisition channel and try to reach 10 target customers.',
    ),
    IdeaAssumption(
      id: '${seed}_feasibility',
      ideaId: idea.id,
      title: ro
          ? 'Un MVP util poate fi construit cu resursele disponibile'
          : 'A useful MVP can be built with available resources',
      type: IdeaAssumptionType.feasibility,
      nextExperiment: ro
          ? 'Definește cel mai mic MVP util și estimează timpul, costul și riscul tehnic.'
          : 'Define the smallest useful MVP and estimate time, cost, and technical risk.',
    ),
    IdeaAssumption(
      id: '${seed}_difference',
      ideaId: idea.id,
      title: ro
          ? 'Soluția este semnificativ mai bună decât alternativele existente'
          : 'The solution is meaningfully better than current alternatives',
      type: IdeaAssumptionType.differentiation,
      nextExperiment: ro
          ? 'Compară ideea cu 5 alternative și identifică un avantaj care poate fi apărat.'
          : 'Compare the idea with 5 alternatives and identify one defensible advantage.',
    ),
  ];
}
