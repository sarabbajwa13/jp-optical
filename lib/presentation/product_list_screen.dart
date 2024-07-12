import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:jp_optical/Widgets/custom_dialog.dart';
import 'package:jp_optical/Widgets/header.dart';
import 'package:jp_optical/Widgets/MenWomenSectiondivider_label_widget.dart';
import 'package:jp_optical/Widgets/productItem_widget.dart';
import 'package:jp_optical/Widgets/redirect_uri.dart';
import 'package:jp_optical/api/api_service.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:jp_optical/presentation/cart_screen.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher.dart';

class Productlistscreen extends StatefulWidget {
  final String routeFrom;
  final Future<List<ProductItemFirebaseModel>> productList;
  const Productlistscreen(
      {super.key, required this.routeFrom, required this.productList});

  @override
  State<Productlistscreen> createState() => _ProductlistscreenState();
}

class _ProductlistscreenState extends State<Productlistscreen> {
  void handleOnClickHamburger(String message) {
    navigateToCart();
  }

  void handleCartScreen(String action) {
    setState(() {
      dismissCartScreen = false;
    });
  }

  bool dismissCartScreen = false;
  void navigateToCart() {
    setState(() {
      dismissCartScreen = true;
    });
  }

  @override
  void initState() {
    super.initState();
  }

 

  void handleClickOnWhatsAppNumber(Map<String, dynamic> data) {
      String action = data['action'];
    switch (action) {
      case 'close':
        Navigator.of(context).pop();
        break;
      default:
        Navigator.of(context).pop();
        final itemsJson = jsonEncode([data]);
        redirectUri(action, 'orderThroghWhatsApp',itemsJson);
    }
  }
 void handleClickOnNormalWhatsAppContact(Map<String, dynamic> data) {
    String action = data['action'];
    switch (action) {
      case 'close':
        Navigator.of(context).pop();
        break;
      default:
        Navigator.of(context).pop();
        redirectUri(action, 'normalWhatsAppContact', '');
    }
  }

void showAnimatedDialog(
      BuildContext context, Map<String, dynamic> data, String title) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return CustomDialog(
          title: title,
          data: data,
          onConfirm: data['productTitle'] == null
              ? handleClickOnNormalWhatsAppContact
              : handleClickOnWhatsAppNumber,
        );
      },
      transitionBuilder: (context, animation1, animation2, child) {
        final scaleAnimation = CurvedAnimation(
          parent: animation1,
          curve: Curves.easeInOut,
        );

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
      }

     void handleClick(Map<String, dynamic> data) {
    String action = data['action'];
    switch (action) {
      case 'cart':
        if (!dismissCartScreen) {
          showAnimatedDialog(context, data, 'Add to cart');
        }
        break;
      default:
        if (!dismissCartScreen) {
          showAnimatedDialog(context, data, 'Get details');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var mobileView = screenSize.width < 600;
    var tabletView = screenSize.width > 600;
    var mediumTabletView = screenSize.width > 820;
    var desktopView = screenSize.width > 1300;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Column(
            children: [
              Header(
                onClickHamburger: handleOnClickHamburger,
                showCart: true,
                showBackArrow: true,
                routeFromHome: false
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics:
                      dismissCartScreen ? NeverScrollableScrollPhysics() : null,
                  child: Column(
                    crossAxisAlignment: widget.routeFrom == 'Men'
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        height: desktopView ? 365 : 100,
                        child: Image.asset(
                          'assets/images/third_banner.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(height: 40),
                      MenWomenSectionDividerLabelWidget(
                        label: '${widget.routeFrom} ',
                        label2: 'Section',
                        margin: EdgeInsets.only(
                            left: widget.routeFrom == 'Men' ? 50 : 0,
                            right: widget.routeFrom == 'Men' ? 0 : 50),
                        mainAxisAlignment: widget.routeFrom == 'Men'
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        crossAxisAlignment: widget.routeFrom == 'Men'
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        tabletView: tabletView,
                      ),
                      Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            left: tabletView ? 40 : 10,
                            right: tabletView ? 40 : 10,
                          ),
                          child: FutureBuilder<List<ProductItemFirebaseModel>>(
                              future: widget.productList,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(child: Text('No data found'));
                                } else {
                                  return ResponsiveGridList(
                                    horizontalGridSpacing: 5,
                                    verticalGridSpacing: 5,
                                    horizontalGridMargin: 5,
                                    verticalGridMargin: 5,
                                    minItemWidth: 600,
                                    minItemsPerRow: desktopView
                                        ? 3
                                        : tabletView
                                            ? 2
                                            : 1,
                                    maxItemsPerRow: 3,
                                    listViewBuilderOptions:
                                        ListViewBuilderOptions(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                    ),
                                    children: List.generate(
                                      snapshot.data!.length,
                                      (index) => ProductItemWidget(
                                        tabletView: tabletView,
                                        mediumTabletView: mediumTabletView,
                                        desktopView: desktopView,
                                        isHorizontalList: false,
                                        bestSellerFirebaseList:
                                            snapshot.data![index],
                                        onClickCallBack:
                                            handleClick,
                                            routeFromHomeScreen: false, // Pass the indexed data here
                                      ),
                                    ),
                                  );
                                }
                              })),
                      const SizedBox(
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          dismissCartScreen
              ? Container(
                  margin: EdgeInsets.only(top: mobileView ? 0 : 70),
                  width: mobileView ? double.infinity : 700,
                  height: mobileView ? double.infinity : 700,
                  child: CartScreen(onCloseCallBack: handleCartScreen),
                )
              : Container(),
        ],
      ),
    );
  }
}
