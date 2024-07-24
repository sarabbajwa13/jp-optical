import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/colors/app_color.dart';

class MenWomenSectionDividerLabelWidget extends StatelessWidget {
  final String label, label2;
  final EdgeInsets margin;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool tabletView, routeFromHome;

  const MenWomenSectionDividerLabelWidget({
    Key? key,
    required this.label,
    required this.label2,
    required this.margin,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.crossAxisAlignment = CrossAxisAlignment.end,
    required this.tabletView,
    required this.routeFromHome
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Container(
                margin: margin,
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: tabletView? 32 : 16,
                        height: 1.2),
                    children: <TextSpan>[
                      TextSpan(text: '$label '),
                      TextSpan(
                        text: '$label2 ',
                        style:  TextStyle(
                          color: AppColors.cGreenColor,
                          fontWeight: FontWeight.w600,
                          fontSize: tabletView ? 32 : 16,
                        ),
                      ),
                    ],
                  ),
                )),
            Container(
              margin: EdgeInsets.only(top: tabletView ?10 :5, bottom: routeFromHome ? 30 : 0),
              width: tabletView ? 200 : 140,
              height: 3,
              color: AppColors.cGreenColor,
            )
          ],
        )
      ],
    );
  }
}
