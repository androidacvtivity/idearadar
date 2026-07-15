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
    return switch (this) {
      IdeaStatus.newIdea => 'New',
      IdeaStatus.researching => 'Researching',
      IdeaStatus.evaluating => 'Evaluating',
      IdeaStatus.validated => 'Validated',
      IdeaStatus.onHold => 'On hold',
      IdeaStatus.rejected => 'Rejected',
      IdeaStatus.inDevelopment => 'In development',
      IdeaStatus.launched => 'Launched',
    };
  }
}
