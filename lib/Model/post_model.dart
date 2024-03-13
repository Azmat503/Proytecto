import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PostModel {
  late VideoPlayerController videoPlayer;
  late ChewieController chewieController;
  final Map<String, dynamic> post;
  final String postType;

  PostModel({
    required String videoUrl,
    required this.post,
    required this.postType,
  }) {
    videoPlayer = VideoPlayerController.networkUrl(Uri.parse((videoUrl)));
    chewieController = ChewieController(
      videoPlayerController: videoPlayer,
    );
  }
}
