import 'dart:io';

import 'package:lemon_atlas/sync/classes/sync_job.dart';

import 'build_sync_job.dart';

List<SyncJob> findSyncJobs({
  required Directory directory,
  required String dirRenders,
  required String dirSprites,
}) {
  final jobs = <SyncJob>[];
  final children = directory.listSync();

  for (final child in children){
    if (child is Directory) {
      jobs.addAll(findSyncJobs(
          directory: child,
          dirRenders: dirRenders,
          dirSprites: dirSprites,
      ));
    }
  }

  for (final child in children){
    if (child is File) {
      final job = buildSyncJob(
        file: child,
        dirRenders: dirRenders,
        dirSprites: dirSprites,
      );
      if (job != null){
        jobs.add(job);
      }
      return jobs;
    }
  }

  return jobs;
}
