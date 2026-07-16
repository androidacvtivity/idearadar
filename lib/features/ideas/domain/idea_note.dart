class IdeaNote {
  const IdeaNote({
    required this.id,
    required this.ideaId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(id != ''),
       assert(ideaId != ''),
       assert(content != '');

  final String id;
  final String ideaId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  IdeaNote copyWith({String? content, DateTime? updatedAt}) {
    return IdeaNote(
      id: id,
      ideaId: ideaId,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
