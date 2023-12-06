
import 'package:flutter/cupertino.dart';
import 'package:lemon_atlas/sync/classes/sync_job.dart';
import 'package:lemon_widgets/lemon_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class SyncJobsColumn extends StatelessWidget {

  final List<SyncJob> syncJobs;
  final Function(SyncJob value) onClicked;
  final Function(SyncJob value) onClickedFlat;

  const SyncJobsColumn({
    super.key,
    required this.syncJobs,
    required this.onClicked,
    required this.onClickedFlat,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: syncJobs.map(buildRowSyncJob).toList(growable: false),
        ),
      ),
    );
  }

  Widget buildRowSyncJob(SyncJob syncJob)=> Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Column(
          children: [
            onPressed(
              action: (){
                final url = Uri.parse(syncJob.source);
                launchUrl(url);
              },
              child: buildText("open"),
            ),
            onPressed(
              action: (){
                final url = Uri.parse(syncJob.target);
                launchUrl(url);
              },
              child: buildText("open"),
            ),
          ],
        ),
        const SizedBox(width: 24),
        onPressed(
          action: () => onClickedFlat(syncJob),
          child: buildText("flat"),
        ),
        const SizedBox(width: 24),
        onPressed(
          action: () => onClicked(syncJob),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText(syncJob.source),
              buildText(syncJob.target),
            ],
          ),
        ),
      ],
    ),
  );
}