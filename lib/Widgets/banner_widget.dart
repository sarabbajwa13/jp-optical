import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BannerWidget extends StatelessWidget {
final bool tabletView, desktopView;
final String imageUrl;

  const BannerWidget({Key? key, required this.tabletView , required this.desktopView, required this.imageUrl})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: tabletView ? 50 : 10, right: tabletView ? 50 : 10),
      child: Column(
        children: [
          // Container(
          //     width: double.infinity,
          //     height: desktopView ? 598 : tabletView ?  298 : 181,
          //     child: Image.asset(
          //       'assets/images/second_banner.png',
          //       fit: BoxFit.fill,
          //     )),
          //   SizedBox(
          //   height: tabletView ? 80 : 30,
          // ),
          Container(
              
              width: double.infinity,
              height: desktopView ? 480 : tabletView ? 320 : 180,
              child: Image.network(
                imageUrl,
                fit: BoxFit.fill,
              )),
        ],
      ),
    );
  }
}
