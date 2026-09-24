enum QuestionStatus {
  open,
  answered,
  parked,
}

class Question {
  const Question({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.details = '',
    this.answer = '',
    this.status = QuestionStatus.open,
    this.answeredAt,
  }) : assert(id != ''),
       assert(title != '');

  final String id;
  final String title;
  final String details;
  final String answer;
  final QuestionStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? answeredAt;

  bool get isAnswered => status == QuestionStatus.answered;

  Question copyWith({
    String? title,
    String? details,
    String? answer,
    QuestionStatus? status,
    DateTime? updatedAt,
    DateTime? answeredAt,
    bool clearAnsweredAt = false,
  }) {
    return Question(
      id: id,
      title: title ?? this.title,
      details: details ?? this.details,
      answer: answer ?? this.answer,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answeredAt: clearAnsweredAt ? null : answeredAt ?? this.answeredAt,
    );
  }
}
