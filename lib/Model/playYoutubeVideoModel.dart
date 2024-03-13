import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PlayYoutubeVideoModel {
  bool isThumnailHide = false;
  bool isPlaying = false;
  YoutubePlayerController? controller;
  PlayYoutubeVideoModel({
    required this.controller,
  });
}
