import 'package:idearadar/features/ideas/domain/idea.dart';
import 'package:idearadar/features/ideas/domain/idea_assumption.dart';
import 'package:idearadar/features/ideas/domain/idea_note.dart';
import 'package:idearadar/features/ideas/domain/idea_source.dart';
import 'package:idearadar/features/questions/domain/question.dart';
import 'package:idearadar/features/questions/domain/question_idea_link.dart';

abstract interface class IdeaRepository {
  Future<void> initialize();

  Future<List<Idea>> getIdeas();

  Future<void> addIdea(Idea idea);

  Future<void> updateIdea(Idea idea);

  Future<void> deleteIdea(String ideaId);

  Future<List<IdeaNote>> getNotes(String ideaId);

  Future<void> addNote(IdeaNote note);

  Future<void> updateNote(IdeaNote note);

  Future<void> deleteNote(String noteId);

  Future<List<IdeaSource>> getSources(String ideaId);

  Future<void> addSource(IdeaSource source);

  Future<void> updateSource(IdeaSource source);

  Future<void> deleteSource(String sourceId);

  Future<List<IdeaAssumption>> getAssumptions(String ideaId);

  Future<void> addAssumption(IdeaAssumption assumption);

  Future<void> updateAssumption(IdeaAssumption assumption);

  Future<void> deleteAssumption(String assumptionId);

  Future<List<Question>> getQuestions();

  Future<void> addQuestion(Question question);

  Future<void> updateQuestion(Question question);

  Future<void> deleteQuestion(String questionId);

  Future<List<QuestionIdeaLink>> getQuestionIdeaLinks({String? questionId, String? ideaId});

  Future<void> addQuestionIdeaLink(QuestionIdeaLink link);

  Future<void> deleteQuestionIdeaLink(String questionId, String ideaId);
}
