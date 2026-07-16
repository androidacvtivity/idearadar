import 'package:flutter_test/flutter_test.dart';
import 'package:idearadar/features/ideas/data/in_memory_idea_repository.dart';
import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';
import 'package:idearadar/features/ideas/domain/idea_source.dart';

void main() {
  test('stores and returns ideas', () async {
    final repository = InMemoryIdeaRepository();
    final now = DateTime(2026, 7, 15);
    final idea = Idea(
      id: 'idea-001',
      title: 'IdeaRadar',
      domain: 'Productivity',
      createdAt: now,
      updatedAt: now,
    );

    await repository.initialize();
    await repository.addIdea(idea);
    final ideas = await repository.getIdeas();

    expect(ideas, hasLength(1));
    expect(ideas.single.id, 'idea-001');
    expect(ideas.single.title, 'IdeaRadar');

    final updatedIdea = idea.copyWith(
      title: 'Updated IdeaRadar',
      updatedAt: DateTime(2026, 7, 16),
    );
    await repository.updateIdea(updatedIdea);

    final updatedIdeas = await repository.getIdeas();
    expect(updatedIdeas.single.id, 'idea-001');
    expect(updatedIdeas.single.title, 'Updated IdeaRadar');

    final note = IdeaNote(
      id: 'note-001',
      ideaId: idea.id,
      content: 'Potential customers need offline access.',
      createdAt: now,
      updatedAt: now,
    );
    await repository.addNote(note);
    expect(await repository.getNotes(idea.id), [note]);

    final updatedNote = note.copyWith(
      content: 'Validated with two potential customers.',
      updatedAt: DateTime(2026, 7, 16),
    );
    await repository.updateNote(updatedNote);
    expect((await repository.getNotes(idea.id)).single.content, contains('Validated'));

    final source = IdeaSource(
      id: 'source-001',
      ideaId: idea.id,
      title: 'Market report',
      url: 'https://example.com/report',
      sourceType: IdeaSourceType.report,
      note: 'Supports the demand assumption.',
      accessedAt: now,
      createdAt: now,
    );
    await repository.addSource(source);
    expect((await repository.getSources(idea.id)).single, source);

    final updatedSource = source.copyWith(title: 'Updated market report');
    await repository.updateSource(updatedSource);
    expect(
      (await repository.getSources(idea.id)).single.title,
      'Updated market report',
    );

    await repository.deleteIdea('idea-001');
    expect(await repository.getIdeas(), isEmpty);
    expect(await repository.getNotes(idea.id), isEmpty);
    expect(await repository.getSources(idea.id), isEmpty);
  });
}
