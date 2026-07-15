import 'package:idearadar/features/ideas/domain/idea_evaluation.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';

class Idea {
  const Idea({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.summary = '',
    this.problem = '',
    this.solution = '',
    this.domain = '',
    this.targetUsers = '',
    this.payingCustomer = '',
    this.status = IdeaStatus.newIdea,
    this.evaluation,
    this.nextReviewAt,
    this.archivedAt,
  }) : assert(id != ''),
       assert(title != '');

  final String id;
  final String title;
  final String summary;
  final String problem;
  final String solution;
  final String domain;
  final String targetUsers;
  final String payingCustomer;
  final IdeaStatus status;
  final IdeaEvaluation? evaluation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? nextReviewAt;
  final DateTime? archivedAt;

  int? get totalScore => evaluation?.totalScore;

  bool get isArchived => archivedAt != null;

  Idea copyWith({
    String? title,
    String? summary,
    String? problem,
    String? solution,
    String? domain,
    String? targetUsers,
    String? payingCustomer,
    IdeaStatus? status,
    IdeaEvaluation? evaluation,
    DateTime? updatedAt,
    DateTime? nextReviewAt,
    DateTime? archivedAt,
  }) {
    return Idea(
      id: id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      problem: problem ?? this.problem,
      solution: solution ?? this.solution,
      domain: domain ?? this.domain,
      targetUsers: targetUsers ?? this.targetUsers,
      payingCustomer: payingCustomer ?? this.payingCustomer,
      status: status ?? this.status,
      evaluation: evaluation ?? this.evaluation,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}
