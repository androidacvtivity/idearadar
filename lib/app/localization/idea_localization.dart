import 'package:flutter/material.dart';
import 'package:idearadar/app/localization/app_localization.dart';
import 'package:idearadar/features/ideas/domain/idea_source.dart';
import 'package:idearadar/features/ideas/domain/idea_status.dart';
import 'package:idearadar/features/ideas/presentation/idea_list_options.dart';

String itx(BuildContext context, String key) {
  final code = Localizations.localeOf(context).languageCode;
  return (_ideaTranslations[code] ?? _ideaTranslations['en']!)[key] ?? tr(context, key);
}

String localizedIdeaStatus(BuildContext context, IdeaStatus status) => switch (status) {
  IdeaStatus.newIdea => itx(context, 'status_new'),
  IdeaStatus.researching => itx(context, 'status_researching'),
  IdeaStatus.evaluating => itx(context, 'status_evaluating'),
  IdeaStatus.validated => itx(context, 'status_validated'),
  IdeaStatus.onHold => itx(context, 'status_on_hold'),
  IdeaStatus.rejected => itx(context, 'status_rejected'),
  IdeaStatus.inDevelopment => itx(context, 'status_in_development'),
  IdeaStatus.launched => itx(context, 'status_launched'),
};

String localizedSourceType(BuildContext context, IdeaSourceType type) => switch (type) {
  IdeaSourceType.website => itx(context, 'source_type_website'),
  IdeaSourceType.article => itx(context, 'source_type_article'),
  IdeaSourceType.report => itx(context, 'source_type_report'),
  IdeaSourceType.statistics => itx(context, 'source_type_statistics'),
  IdeaSourceType.interview => itx(context, 'source_type_interview'),
  IdeaSourceType.other => itx(context, 'source_type_other'),
};

String localizedIdeaSort(BuildContext context, IdeaSort sort) => switch (sort) {
  IdeaSort.updated => itx(context, 'sort_recently_updated'),
  IdeaSort.score => itx(context, 'sort_highest_score'),
  IdeaSort.created => itx(context, 'sort_newest_created'),
  IdeaSort.nextReview => itx(context, 'sort_next_review'),
};

const _ideaTranslations = <String, Map<String, String>>{
  'en': {
    'add_new_idea': 'Add new idea', 'update_opportunity': 'Update the opportunity', 'capture_opportunity': 'Capture the opportunity',
    'update_opportunity_desc': 'Keep the idea accurate as your research develops.', 'capture_opportunity_desc': 'Start with the problem. You can add evidence and scores later.',
    'title': 'Title', 'title_hint': 'Example: IdeaRadar', 'domain': 'Domain', 'domain_hint': 'Example: Productivity', 'status': 'Status',
    'summary_hint': 'Describe the idea in a few sentences', 'problem_hint': 'What problem does this idea solve?', 'solution_hint': 'How could the problem be solved?',
    'target_users_hint': 'Who experiences the problem and uses the solution?', 'paying_customer_hint': 'Who decides to buy or fund the solution?',
    'save_idea': 'Save idea', 'save_changes': 'Save changes', 'required': 'is required',
    'edit_evaluation': 'Edit evaluation', 'evaluate_idea': 'Evaluate idea', 'adjust_criterion': 'Adjust each criterion from 1 to 5.',
    'problem_severity': 'Problem severity', 'problem_severity_desc': 'How important and frequent is the problem?',
    'market_potential': 'Market potential', 'market_potential_desc': 'How large and reachable is the market?',
    'demand_evidence': 'Demand evidence', 'demand_evidence_desc': 'How strong is the evidence of real demand?',
    'competition_favorability': 'Competition favorability', 'competition_favorability_desc': '5 means lower competition and a better position.',
    'data_access': 'Data access', 'data_access_desc': 'Can the required data be obtained legally?',
    'technical_feasibility': 'Technical feasibility', 'technical_feasibility_desc': 'Can the MVP be built with available resources?',
    'monetization_potential': 'Monetization potential', 'monetization_potential_desc': 'Is there a credible paying customer or model?',
    'first_client_access': 'Access to first client', 'first_client_access_desc': 'How easily can the first client be reached?',
    'evaluation_rationale': 'Evaluation rationale', 'evaluation_rationale_hint': 'Record the evidence behind the scores',
    'save_evaluation': 'Save evaluation', 'save_evaluation_changes': 'Save evaluation changes',
    'notes_load_error': 'Notes could not be loaded.', 'note_save_error': 'The note could not be saved.', 'note_delete_error': 'The note could not be deleted.',
    'delete_note_question': 'Delete note?', 'delete_note_desc': 'This research note will be permanently deleted.', 'note_actions': 'Note actions',
    'new_note': 'New note', 'new_research_note': 'New research note', 'edit_research_note': 'Edit research note', 'note': 'Note',
    'note_hint': 'Add an observation, assumption, or research finding', 'save_note': 'Save note', 'no_research_notes': 'No research notes yet',
    'no_research_notes_desc': 'Record assumptions, observations, and findings as the idea develops.',
    'sources_load_error': 'Sources could not be loaded.', 'source_save_error': 'The source could not be saved.', 'source_delete_error': 'The source could not be deleted.',
    'delete_source_question': 'Delete source?', 'delete_source_desc': 'This research source will be permanently deleted.', 'source_actions': 'Source actions',
    'new_source': 'New source', 'edit_source': 'Edit source', 'add_source': 'Add source', 'source_title_hint': 'Example: Moldova agriculture report',
    'url_optional': 'URL (optional)', 'source_type': 'Source type', 'access_date': 'Access date', 'research_note_optional': 'Research note (optional)',
    'source_note_hint': 'What does this source confirm or contradict?', 'save_source': 'Save source',
    'invalid_url': 'Enter a complete URL starting with http:// or https://', 'no_research_sources': 'No research sources yet',
    'no_research_sources_desc': 'Add links, reports, interviews, and statistics that support the idea.',
    'archive_load_error': 'Archived ideas could not be loaded.', 'archive_update_error': 'The archived idea could not be updated.', 'archived': 'Archived',
    'no_archived_ideas': 'No archived ideas', 'no_archived_ideas_desc': 'Ideas you archive will appear here and can be restored later.',
    'filter_and_sort': 'Filter and sort', 'reset': 'Reset', 'all_statuses': 'All statuses', 'minimum_score': 'Minimum score', 'any_score': 'Any score',
    'or_higher': 'or higher', 'sort_by': 'Sort by', 'apply': 'Apply', 'clear_search': 'Clear search', 'close_search': 'Close search',
    'no_ideas_found': 'No ideas found', 'search_empty_desc': 'Add an idea to start searching.', 'search_no_results_desc': 'Try another title, domain, status, or keyword.',
    'edit': 'Edit', 'delete': 'Delete', 'try_again': 'Try again',
    'status_new': 'New', 'status_researching': 'Researching', 'status_evaluating': 'Evaluating', 'status_validated': 'Validated',
    'status_on_hold': 'On hold', 'status_rejected': 'Rejected', 'status_in_development': 'In development', 'status_launched': 'Launched',
    'source_type_website': 'Website', 'source_type_article': 'Article', 'source_type_report': 'Report', 'source_type_statistics': 'Statistics',
    'source_type_interview': 'Interview', 'source_type_other': 'Other',
    'sort_recently_updated': 'Recently updated', 'sort_highest_score': 'Highest score', 'sort_newest_created': 'Newest created', 'sort_next_review': 'Next review',
  },
  'ro': {
    'add_new_idea': 'Adaugă o idee nouă', 'update_opportunity': 'Actualizează oportunitatea', 'capture_opportunity': 'Capturează oportunitatea',
    'update_opportunity_desc': 'Păstrează ideea actualizată pe măsură ce cercetarea avansează.', 'capture_opportunity_desc': 'Începe cu problema. Dovezile și scorurile pot fi adăugate ulterior.',
    'title': 'Titlu', 'title_hint': 'Exemplu: IdeaRadar', 'domain': 'Domeniu', 'domain_hint': 'Exemplu: Productivitate', 'status': 'Statut',
    'summary_hint': 'Descrie ideea în câteva propoziții', 'problem_hint': 'Ce problemă rezolvă această idee?', 'solution_hint': 'Cum ar putea fi rezolvată problema?',
    'target_users_hint': 'Cine întâmpină problema și folosește soluția?', 'paying_customer_hint': 'Cine decide să cumpere sau să finanțeze soluția?',
    'save_idea': 'Salvează ideea', 'save_changes': 'Salvează modificările', 'required': 'este obligatoriu',
    'edit_evaluation': 'Editează evaluarea', 'evaluate_idea': 'Evaluează ideea', 'adjust_criterion': 'Ajustează fiecare criteriu de la 1 la 5.',
    'problem_severity': 'Gravitatea problemei', 'problem_severity_desc': 'Cât de importantă și frecventă este problema?',
    'market_potential': 'Potențialul pieței', 'market_potential_desc': 'Cât de mare și accesibilă este piața?',
    'demand_evidence': 'Dovezi privind cererea', 'demand_evidence_desc': 'Cât de puternice sunt dovezile unei cereri reale?',
    'competition_favorability': 'Poziția față de concurență', 'competition_favorability_desc': '5 înseamnă concurență mai redusă și o poziție mai bună.',
    'data_access': 'Acces la date', 'data_access_desc': 'Datele necesare pot fi obținute legal?',
    'technical_feasibility': 'Fezabilitate tehnică', 'technical_feasibility_desc': 'Poate fi construit MVP-ul cu resursele disponibile?',
    'monetization_potential': 'Potențial de monetizare', 'monetization_potential_desc': 'Există un client plătitor sau un model credibil?',
    'first_client_access': 'Acces la primul client', 'first_client_access_desc': 'Cât de ușor poate fi contactat primul client?',
    'evaluation_rationale': 'Argumentarea evaluării', 'evaluation_rationale_hint': 'Notează dovezile care justifică scorurile',
    'save_evaluation': 'Salvează evaluarea', 'save_evaluation_changes': 'Salvează modificările evaluării',
    'notes_load_error': 'Notițele nu au putut fi încărcate.', 'note_save_error': 'Notița nu a putut fi salvată.', 'note_delete_error': 'Notița nu a putut fi ștearsă.',
    'delete_note_question': 'Ștergem notița?', 'delete_note_desc': 'Această notiță de cercetare va fi ștearsă definitiv.', 'note_actions': 'Acțiuni pentru notiță',
    'new_note': 'Notiță nouă', 'new_research_note': 'Notiță nouă de cercetare', 'edit_research_note': 'Editează notița de cercetare', 'note': 'Notiță',
    'note_hint': 'Adaugă o observație, ipoteză sau constatare din cercetare', 'save_note': 'Salvează notița', 'no_research_notes': 'Nu există încă notițe de cercetare',
    'no_research_notes_desc': 'Înregistrează ipoteze, observații și constatări pe măsură ce ideea se dezvoltă.',
    'sources_load_error': 'Sursele nu au putut fi încărcate.', 'source_save_error': 'Sursa nu a putut fi salvată.', 'source_delete_error': 'Sursa nu a putut fi ștearsă.',
    'delete_source_question': 'Ștergem sursa?', 'delete_source_desc': 'Această sursă de cercetare va fi ștearsă definitiv.', 'source_actions': 'Acțiuni pentru sursă',
    'new_source': 'Sursă nouă', 'edit_source': 'Editează sursa', 'add_source': 'Adaugă sursa', 'source_title_hint': 'Exemplu: Raport despre agricultura Moldovei',
    'url_optional': 'URL (opțional)', 'source_type': 'Tipul sursei', 'access_date': 'Data accesării', 'research_note_optional': 'Notiță de cercetare (opțional)',
    'source_note_hint': 'Ce confirmă sau contrazice această sursă?', 'save_source': 'Salvează sursa',
    'invalid_url': 'Introdu un URL complet care începe cu http:// sau https://', 'no_research_sources': 'Nu există încă surse de cercetare',
    'no_research_sources_desc': 'Adaugă linkuri, rapoarte, interviuri și statistici care susțin ideea.',
    'archive_load_error': 'Ideile arhivate nu au putut fi încărcate.', 'archive_update_error': 'Ideea arhivată nu a putut fi actualizată.', 'archived': 'Arhivată',
    'no_archived_ideas': 'Nu există idei arhivate', 'no_archived_ideas_desc': 'Ideile arhivate vor apărea aici și pot fi restaurate ulterior.',
    'filter_and_sort': 'Filtrare și sortare', 'reset': 'Resetează', 'all_statuses': 'Toate statuturile', 'minimum_score': 'Scor minim', 'any_score': 'Orice scor',
    'or_higher': 'sau mai mare', 'sort_by': 'Sortează după', 'apply': 'Aplică', 'clear_search': 'Șterge căutarea', 'close_search': 'Închide căutarea',
    'no_ideas_found': 'Nu au fost găsite idei', 'search_empty_desc': 'Adaugă o idee pentru a începe căutarea.', 'search_no_results_desc': 'Încearcă alt titlu, domeniu, statut sau cuvânt-cheie.',
    'edit': 'Editează', 'delete': 'Șterge', 'try_again': 'Încearcă din nou',
    'status_new': 'Nouă', 'status_researching': 'În cercetare', 'status_evaluating': 'În evaluare', 'status_validated': 'Validată',
    'status_on_hold': 'În așteptare', 'status_rejected': 'Respinsă', 'status_in_development': 'În dezvoltare', 'status_launched': 'Lansată',
    'source_type_website': 'Site web', 'source_type_article': 'Articol', 'source_type_report': 'Raport', 'source_type_statistics': 'Statistici',
    'source_type_interview': 'Interviu', 'source_type_other': 'Alt tip',
    'sort_recently_updated': 'Actualizate recent', 'sort_highest_score': 'Scorul cel mai mare', 'sort_newest_created': 'Cele mai noi', 'sort_next_review': 'Următoarea revizuire',
  },
};
