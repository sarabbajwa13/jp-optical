import 'package:flutter/material.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  const ImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      showImageViewer(
        context,
        Image.network(imageUrl).image,
        useSafeArea: true,
        swipeDismissible: true,
        doubleTapZoomable: true,
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
      ),
      body: Center(
        child: Text('Image Viewer Screen'),
      ),
    );
  }
}
