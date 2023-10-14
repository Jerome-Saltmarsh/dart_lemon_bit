import 'dart:io';

import 'package:lemon_atlas/sync/classes/sync_job.dart';

import 'build_sync_job.dart';

List<SyncJob> findSyncJobs(Directory directory) {
  final jobs = <SyncJob>[];
  final children = directory.listSync();

  for (final child in children){
    if (child is Directory) {
      jobs.addAll(findSyncJobs(child));
    }
  }

  for (final child in children){
    if (child is File) {
      final job = buildSyncJob(child);
      if (job != null){
        jobs.add(job);
      }
      return jobs;
    }
  }

  return jobs;
}
