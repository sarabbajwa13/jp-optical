import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late FlickManager flickManager;

  @override
void initState() {
  super.initState();
  flickManager = FlickManager(
    videoPlayerController: VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          // Ensure the first frame is shown.
        });

        // Play the video for a short duration to render the first frame
        // flickManager.flickVideoManager?.videoPlayerController?.play();

        // // Delay and then pause the video
        // Future.delayed(Duration(milliseconds: 100), () {
        //   flickManager.flickVideoManager?.videoPlayerController?.pause();
        // });

        // Listener for video player changes
        flickManager.flickVideoManager?.videoPlayerController!.addListener(_onVideoPlayerChanged);
      })
      ..setLooping(true)
      ..play(),
  );
}


  void _onVideoPlayerChanged() {
    final controller = flickManager.flickVideoManager?.videoPlayerController;
    if (controller != null) {
      if (controller.value.hasError) {
        debugPrint("Video player error: ${controller.value.errorDescription}");
      }
    }
  }

  @override
  void dispose() {
    flickManager.flickVideoManager?.videoPlayerController!.removeListener(_onVideoPlayerChanged);
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: flickManager.flickVideoManager?.videoPlayerController!.value.isInitialized ?? false
             ? AspectRatio(
                aspectRatio: flickManager.flickVideoManager!.videoPlayerController!.value.aspectRatio,
                child: FlickVideoPlayer(flickManager: flickManager,),
              )
            : const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.cGreenColor)),
      ),
    );
  }
}
