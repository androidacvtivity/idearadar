enum IdeaSourceType {
  website('Website'),
  article('Article'),
  report('Report'),
  statistics('Statistics'),
  interview('Interview'),
  other('Other');

  const IdeaSourceType(this.label);

  final String label;
}

class IdeaSource {
  const IdeaSource({
    required this.id,
    required this.ideaId,
    required this.title,
    required this.sourceType,
    required this.accessedAt,
    required this.createdAt,
    this.url = '',
    this.note = '',
  }) : assert(id != ''),
       assert(ideaId != ''),
       assert(title != '');

  final String id;
  final String ideaId;
  final String title;
  final String url;
  final IdeaSourceType sourceType;
  final String note;
  final DateTime accessedAt;
  final DateTime createdAt;

  IdeaSource copyWith({
    String? title,
    String? url,
    IdeaSourceType? sourceType,
    String? note,
    DateTime? accessedAt,
  }) {
    return IdeaSource(
      id: id,
      ideaId: ideaId,
      title: title ?? this.title,
      url: url ?? this.url,
      sourceType: sourceType ?? this.sourceType,
      note: note ?? this.note,
      accessedAt: accessedAt ?? this.accessedAt,
      createdAt: createdAt,
    );
  }
}
