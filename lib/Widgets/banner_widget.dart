import 'package:flutter/cupertino.dart';

class BannerWidget extends StatelessWidget {
final bool tabletView, desktopView;

  const BannerWidget({Key? key, required this.tabletView , required this.desktopView})
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
              height: desktopView ? 365 : tabletView ? 180 : 94,
              child: Image.asset(
                'assets/images/third_banner.png',
                fit: BoxFit.cover,
              )),
        ],
      ),
    );
  }
}
