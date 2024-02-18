import 'package:lemon_atlas/sync/classes/sync_job.dart';
import 'package:lemon_atlas/sync/functions/sync.dart';

void runSyncJob({
  required SyncJob syncJob,
  required int rows,
}) => sync(
      srcDir: syncJob.source,
      targetDirectory: syncJob.target,
      name: syncJob.name,
      rows: rows,
  );