
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lemon_atlas/sync/functions/sync_all.dart';
import 'package:lemon_atlas/sync/classes/sync_job.dart';
import 'package:lemon_atlas/sync/consts/directories.dart';
import 'package:lemon_atlas/sync/functions/build_sync_jobs.dart';
import 'package:lemon_atlas/sync/functions/run_sync_job.dart';
import 'package:lemon_atlas/sync/ui/sync_jobs_column.dart';
import 'package:lemon_watch/src.dart';
import 'package:lemon_widgets/lemon_widgets.dart';

class SyncUI extends StatelessWidget {

  final syncJobs = Watch(<SyncJob>[]);

  SyncUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RENDERS SYNC',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('RENDERS SYNC'),
          actions: [
            onPressed(
              action: loadFiles,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: buildText('LOAD'),
              ),
            ),
            onPressed(
              action: refreshSyncJobs,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: buildText('REFRESH'),
              ),
            ),
            onPressed(
              action: syncAll,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: buildText('SYNCHRONIZE'),
              ),
            ),
          ],
        ),
        body:  Builder(
          builder: (context) {
            return WatchBuilder(syncJobs, (syncJobs) => SyncJobsColumn(
                syncJobs: syncJobs,
                onClickedFlat: (syncJob){
                  tryRunSyncJob(syncJob: syncJob, context: context, rows: 1);
                  refreshSyncJobs();
                },
                onClicked: (syncJob){
                  tryRunSyncJob(syncJob: syncJob, context: context, rows: 8);
                  refreshSyncJobs();
                },
            ));
          }
        ),
      ),
    );
  }

  void tryRunSyncJob({
    required SyncJob syncJob,
    required BuildContext context,
    required int rows,
  }) {
    try {
      runSyncJob(
          syncJob: syncJob,
          rows: rows,
       );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
            title: const Text('Error'),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
      );
    }
  }

  void refreshSyncJobs() =>
      syncJobs.value = findSyncJobs(Directory(dirRenders));


  void loadFiles(){

  }
}