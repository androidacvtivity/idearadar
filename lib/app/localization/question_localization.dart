import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/features/questions/domain/question.dart';
import 'package:idearadar/features/questions/domain/question_idea_link.dart';

String qtx(BuildContext context, String key) {
  final code = Localizations.localeOf(context).languageCode;
  return (_questionTranslations[code] ?? _questionTranslations['en']!)[key] ??
      tr(context, key);
}

String localizedQuestionStatus(BuildContext context, QuestionStatus status) =>
    switch (status) {
      QuestionStatus.open => qtx(context, 'question_status_open'),
      QuestionStatus.answered => qtx(context, 'question_status_answered'),
      QuestionStatus.parked => qtx(context, 'question_status_parked'),
    };

String localizedRelationType(
  BuildContext context,
  QuestionIdeaRelationType type,
) =>
    switch (type) {
      QuestionIdeaRelationType.questionCreatedIdea =>
        qtx(context, 'relation_question_created_idea'),
      QuestionIdeaRelationType.ideaCreatedQuestion =>
        qtx(context, 'relation_idea_created_question'),
      QuestionIdeaRelationType.related => qtx(context, 'relation_related'),
    };

const _questionTranslations = <String, Map<String, String>>{
  'en': {
    'questions': 'Questions',
    'questions_subtitle': 'Capture questions that can lead to ideas and answers.',
    'new_question': 'New question',
    'edit_question': 'Edit question',
    'question': 'Question',
    'question_hint': 'What do you want to understand or discover?',
    'question_details': 'Details',
    'question_details_hint': 'Add context, observations, or why this matters',
    'answer': 'Answer / conclusion',
    'answer_hint': 'Record what you learned',
    'question_status': 'Status',
    'question_status_open': 'Open',
    'question_status_answered': 'Answered',
    'question_status_parked': 'Parked',
    'save_question': 'Save question',
    'save_changes': 'Save changes',
    'no_questions': 'No questions yet',
    'no_questions_desc': 'Capture a question when something makes you curious.',
    'questions_load_error': 'Questions could not be loaded.',
    'question_save_error': 'The question could not be saved.',
    'question_delete_error': 'The question could not be deleted.',
    'delete_question': 'Delete question',
    'delete_question_confirm': 'Delete this question?',
    'delete_question_desc': 'This question and its idea links will be permanently deleted.',
    'linked_ideas': 'Linked ideas',
    'link_idea': 'Link idea',
    'no_linked_ideas': 'No linked ideas yet',
    'create_idea_from_question': 'Create idea from question',
    'related_questions': 'Questions',
    'related_questions_subtitle': 'Questions created by or connected to this idea',
    'relation_question_created_idea': 'Question created idea',
    'relation_idea_created_question': 'Idea created question',
    'relation_related': 'Related',
    'select_idea': 'Select idea',
    'unlink': 'Unlink',
    'today': 'Today',
    'open_questions': 'Open',
  },
  'ro': {
    'questions': 'Întrebări',
    'questions_subtitle': 'Capturează întrebări care pot conduce la idei și răspunsuri.',
    'new_question': 'Întrebare nouă',
    'edit_question': 'Editează întrebarea',
    'question': 'Întrebare',
    'question_hint': 'Ce vrei să înțelegi sau să descoperi?',
    'question_details': 'Detalii',
    'question_details_hint': 'Adaugă context, observații sau de ce este importantă',
    'answer': 'Răspuns / concluzie',
    'answer_hint': 'Notează ce ai aflat',
    'question_status': 'Statut',
    'question_status_open': 'Deschisă',
    'question_status_answered': 'Răspuns găsit',
    'question_status_parked': 'În așteptare',
    'save_question': 'Salvează întrebarea',
    'save_changes': 'Salvează modificările',
    'no_questions': 'Nu există încă întrebări',
    'no_questions_desc': 'Capturează o întrebare când apare ceva ce vrei să clarifici.',
    'questions_load_error': 'Întrebările nu au putut fi încărcate.',
    'question_save_error': 'Întrebarea nu a putut fi salvată.',
    'question_delete_error': 'Întrebarea nu a putut fi ștearsă.',
    'delete_question': 'Șterge întrebarea',
    'delete_question_confirm': 'Ștergem această întrebare?',
    'delete_question_desc': 'Întrebarea și legăturile ei cu ideile vor fi șterse definitiv.',
    'linked_ideas': 'Idei asociate',
    'link_idea': 'Leagă de o idee',
    'no_linked_ideas': 'Nu există încă idei asociate',
    'create_idea_from_question': 'Creează idee din întrebare',
    'related_questions': 'Întrebări',
    'related_questions_subtitle': 'Întrebări create de această idee sau legate de ea',
    'relation_question_created_idea': 'Întrebarea a creat ideea',
    'relation_idea_created_question': 'Ideea a creat întrebarea',
    'relation_related': 'Relaționate',
    'select_idea': 'Selectează ideea',
    'unlink': 'Elimină legătura',
    'today': 'Astăzi',
    'open_questions': 'Deschise',
  },
};
