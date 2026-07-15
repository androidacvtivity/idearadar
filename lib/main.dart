import 'package:flutter/material.dart';
import 'package:idearadar/app/idea_radar_app.dart';
import 'package:idearadar/features/ideas/data/idea_database.dart';
import 'package:idearadar/features/ideas/data/sqlite_idea_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(IdeaRadarApp(repository: SqliteIdeaRepository(IdeaDatabase())));
}
