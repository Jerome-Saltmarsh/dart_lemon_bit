
import 'dart:io';
import 'package:lemon_atlas/sync/functions/build_sync_jobs.dart';
import 'package:lemon_atlas/sync/functions/run_sync_job.dart';

void syncAll({
  required String dirRenders,
  required String dirSprites,
}) {
  final syncJobs = findSyncJobs(
      directory: Directory(dirRenders),
      dirRenders: dirRenders,
      dirSprites: dirSprites,
  );
  for (final syncJob in syncJobs) {
    runSyncJob(syncJob: syncJob, rows: 8);
  }
}
