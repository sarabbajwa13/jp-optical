import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/constants/redirection_string.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  

  const CustomDialog(
      {Key? key,
      required this.title,
      required this.data,
      required this.onConfirm, })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var desktopView = screenSize.width > 1300;
    var tabletView = screenSize.width > 600;
    return Container(
        margin: EdgeInsets.only(
            left: desktopView
                ? 500
                : tabletView
                    ? 100
                    : 0,
            right: desktopView
                ? 500
                : tabletView
                    ? 100
                    : 0),
        child: Stack(
          children: [
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Stack(children: [
                    title == 'Add to cart'
                        ? Container(
                            margin: EdgeInsets.only(top: 90),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Added to cart',
                                        style: GoogleFonts.outfit(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Container(
                                          alignment: Alignment.center,
                                          width: 200,
                                          height: 80,
                                          child: Text(
                                            data['productTitle'] ?? '',
                                            textAlign: TextAlign.center,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ]))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/shop_icon.svg',
                                              height: 15,
                                              width: 15,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'Contact us at!',
                                              style: GoogleFonts.outfit(
                                                  fontSize:
                                                      tabletView ? 20 : 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(width: 10),
                                            SvgPicture.asset(
                                              'assets/icons/glass_icon.svg',
                                              height: 15,
                                              width: 15,
                                            ),
                                          ]),
                                      Container(
                                        color: Colors.black,
                                        width: 120,
                                        height: 1,
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'R -  ',
                                            style: GoogleFonts.outfit(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                          InkWell(
                                              onTap: () => { 
                                                   onConfirm({
                                                      'action': RedirectionString.firstMobileNumber,
                                                      'productId': data['productId'] ?? '', 
                                                      'productTitle': data['productTitle'] ?? '',
                                                      'productImage': data['productImage'] ?? '',
                                                      'productSize': data['productSize'] ?? '',
                                                    }),
                                                  },
                                              child:  whatsNumberWidget(
                                                      RedirectionString
                                                          .firstMobileNumber,
                                                      tabletView, false)),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                       Row(
                                        children: [
                                          Text(
                                            'J -  ',
                                            style: GoogleFonts.outfit(
                                                fontSize:  20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                      InkWell(
                                          onTap: () => {
                                                onConfirm({
                                                      'action': RedirectionString.secondMobileNumber,
                                                      'productId': data['productId'] ?? '', 
                                                      'productTitle': data['productTitle'] ?? '',
                                                      'productImage': data['productImage'] ?? '',
                                                      'productSize': data['productSize'] ?? '',
                                                    }),
                                              },
                                          child:   whatsNumberWidget(
                                                  RedirectionString
                                                      .secondMobileNumber,
                                                  tabletView, true))]),
                                      const SizedBox(
                                        height: 15,
                                      )
                                    ])
                              ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () => onConfirm({'action': 'close'}),
                            icon: const Icon(
                              Icons.close_sharp,
                              color: Colors.black,
                              size: 25,
                            ))
                      ],
                    ),
                  ])),
            ),
            title == 'Add to cart'
                ? Center(
                    child: Container(
                        margin: EdgeInsets.only(bottom: 200),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              data['productImage'] ?? '',
                              fit: BoxFit.fill,
                              width: 150,
                              height: 120,
                            ))))
                : Container()
          ],
        ));
  }
}

Widget whatsNumberWidget(String number, bool tabletView, bool giveSpace) {
  return Container(
    padding: EdgeInsets.only(left: giveSpace ? 20 : 15, right: 15, top: 5, bottom: 5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.white,
        border: Border.all(width: 2, color: Colors.green)),
    child: Row(
      children: [
        Text(
          number,
          style: GoogleFonts.outfit(
              fontSize: tabletView ? 20 : 15,
              fontWeight: FontWeight.normal,
              color: Colors.black),
        ),
        const SizedBox(
          width: 15,
        ),
        SvgPicture.asset(
          'assets/icons/whatsapp_icon.svg',
          fit: BoxFit.fill,
          height: tabletView ? 30 : 25,
          width: tabletView ? 30 : 25,
        )
      ],
    ),
  );
}
