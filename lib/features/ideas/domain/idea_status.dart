import 'package:idearadar/app/localization/app_localization.dart';

enum IdeaStatus {
  newIdea,
  researching,
  evaluating,
  validated,
  onHold,
  rejected,
  inDevelopment,
  launched,
}

extension IdeaStatusLabel on IdeaStatus {
  String get label {
    final ro = ideaRadarLocale.value.languageCode == 'ro';
    return switch (this) {
      IdeaStatus.newIdea => ro ? 'Nouă' : 'New',
      IdeaStatus.researching => ro ? 'În cercetare' : 'Researching',
      IdeaStatus.evaluating => ro ? 'În evaluare' : 'Evaluating',
      IdeaStatus.validated => ro ? 'Validată' : 'Validated',
      IdeaStatus.onHold => ro ? 'În așteptare' : 'On hold',
      IdeaStatus.rejected => ro ? 'Respinsă' : 'Rejected',
      IdeaStatus.inDevelopment => ro ? 'În dezvoltare' : 'In development',
      IdeaStatus.launched => ro ? 'Lansată' : 'Launched',
    };
  }
}
