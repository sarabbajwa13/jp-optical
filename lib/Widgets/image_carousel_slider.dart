import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';

class ImageCarouselSlider extends StatelessWidget {
  final List<String> items;
  final double imageHeight;
  final Color dotColor;

  ImageCarouselSlider({
    required this.items,
    required this.imageHeight,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: imageHeight,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        enlargeCenterPage: false,
        enableInfiniteScroll: true,
        viewportFraction: 1.0
      ),
      items: items.map((item) => Container(
        child: Center(
          child: Image.network(item, fit: BoxFit.fill, height: imageHeight),
        ),
      )).toList(),
    );
  }
}