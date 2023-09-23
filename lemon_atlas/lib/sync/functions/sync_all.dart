
import 'dart:io';
import 'package:lemon_atlas/sync/consts/directories.dart';
import 'package:lemon_atlas/sync/functions/build_sync_jobs.dart';
import 'package:lemon_atlas/sync/functions/run_sync_job.dart';

void syncAll() {
  final syncJobs = findSyncJobs(Directory(dirRenders));
  for (final syncJob in syncJobs) {
    runSyncJob(syncJob: syncJob, rows: 8);
  }
}
