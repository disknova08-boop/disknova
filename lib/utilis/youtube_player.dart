import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart' show YoutubePlayer, YoutubePlayerController, YoutubePlayerFlags;
import 'package:youtube_player_iframe/youtube_player_iframe.dart' show YoutubePlayerIFrame;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformYoutubePlayer extends StatelessWidget {
  final String videoId;
  final YoutubePlayerFlags flags;

  const PlatformYoutubePlayer({
    Key? key,
    required this.videoId,
    this.flags = const YoutubePlayerFlags(autoPlay: false),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildPlayer();
  }

  Widget _buildPlayer() {
    if (kIsWeb) {
      // Web: Use iframe-based player
      return PlatformYoutubePlayer(
        videoId: videoId,
        flags: flags,
      );
    } else {
      // Mobile: Use original flutter player
      return YoutubePlayer(
        controller: YoutubePlayerController(
          initialVideoId: videoId,
          flags: flags,
        ),
      );
    }
  }
}