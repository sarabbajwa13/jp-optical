import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerContainer extends StatefulWidget {
  final String videoPath;
  final Function(String) onVideoSelected;
  const VideoPlayerContainer({required this.videoPath, required this.onVideoSelected, Key? key}) : super(key: key);

  @override
  _VideoPlayerContainerState createState() => _VideoPlayerContainerState();
}

class _VideoPlayerContainerState extends State<VideoPlayerContainer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        setState(() {}); // Ensure the first frame is shown after the video is initialized
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onVideoSelected(widget.videoPath);
      },child:
      Container(
      margin: const EdgeInsets.all(8),
      height: 200, // Adjust the height as needed
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Center(child: CircularProgressIndicator()),
    ));
  }
}
