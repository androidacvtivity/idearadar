import 'package:idearadar/features/ideas/domain/idea_status.dart';

enum IdeaSort {
  updated('Recently updated'),
  score('Highest score'),
  created('Newest created'),
  nextReview('Next review');

  const IdeaSort(this.label);

  final String label;
}

class IdeaListOptions {
  const IdeaListOptions({
    this.status,
    this.minimumScore,
    this.sort = IdeaSort.updated,
  });

  final IdeaStatus? status;
  final int? minimumScore;
  final IdeaSort sort;

  int get activeFilterCount =>
      (status == null ? 0 : 1) + (minimumScore == null ? 0 : 1);

  bool get hasFilters => activeFilterCount > 0;
}
