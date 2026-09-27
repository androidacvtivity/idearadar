enum ProblemStatus { observed, researching, validated, parked, rejected }

class Problem {
  const Problem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.affectedUsers = '',
    this.frequency = '',
    this.severity = '',
    this.currentWorkaround = '',
    this.evidence = '',
    this.status = ProblemStatus.observed,
  }) : assert(id != ''),
       assert(title != '');

  final String id;
  final String title;
  final String description;
  final String affectedUsers;
  final String frequency;
  final String severity;
  final String currentWorkaround;
  final String evidence;
  final ProblemStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Problem copyWith({
    String? title,
    String? description,
    String? affectedUsers,
    String? frequency,
    String? severity,
    String? currentWorkaround,
    String? evidence,
    ProblemStatus? status,
    DateTime? updatedAt,
  }) {
    return Problem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      affectedUsers: affectedUsers ?? this.affectedUsers,
      frequency: frequency ?? this.frequency,
      severity: severity ?? this.severity,
      currentWorkaround: currentWorkaround ?? this.currentWorkaround,
      evidence: evidence ?? this.evidence,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
