//
// import 'package:just_audio/just_audio.dart';
//
// class AudioTracks {
//   final audioPlayer = AudioPlayer();
//   final List<AudioSource> tracks;
//
//   var _trackIndex = 0;
//
//   int get trackIndex => _trackIndex;
//
//   set trackIndex(int value){
//     if (tracks.isEmpty) return;
//     _trackIndex = value % tracks.length;
//   }
//
//   AudioTracks({
//     required this.tracks,
//   }){
//     audioPlayer.processingStateStream.listen(onProcessingStateStreamChanged);
//   }
//
//   void onProcessingStateStreamChanged(ProcessingState state){
//     if (state == ProcessingState.completed){
//       nextTrack();
//     }
//   }
//
//   Future nextTrack() async {
//     if (tracks.isEmpty) return;
//     trackIndex++;
//     play();
//   }
//
//   void play() async {
//     if (tracks.isEmpty) return;
//     audioPlayer.setAudioSource(tracks[trackIndex]);
//     await audioPlayer.seek(null);
//     audioPlayer.play();
//   }
//
//   void stop(){
//     audioPlayer.stop();
//   }
// }
