import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/Widgets/custom_dialog.dart';
import 'package:jp_optical/Widgets/header.dart';
import 'package:jp_optical/Widgets/productItem_widget.dart';
import 'package:jp_optical/Widgets/redirect_uri.dart';
import 'package:jp_optical/api/api_service.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/constants/endpoints.dart';
import 'package:jp_optical/models/product_category_model.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:jp_optical/presentation/cart_screen.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shimmer/shimmer.dart';

class MenWomenListScreen extends StatefulWidget {
  final String firebaeCollectionName;
  const MenWomenListScreen({super.key, required this.firebaeCollectionName});

  @override
  State<MenWomenListScreen> createState() => _MenWomenListScreenState();
}

class _MenWomenListScreenState extends State<MenWomenListScreen> {
  late Future<List<ProductCategoryFirebaseModel>> categoryListFromFirebase;
  late Future<List<ProductItemFirebaseModel>> productList = Future.value([]);
  String productListData = '';
  String? selectedCategory;
  @override
  void initState() {
    super.initState();
    _updateProductList(widget.firebaeCollectionName);
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
        redirectUri(action, 'orderThroghWhatsApp', itemsJson);
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

  void previewImage(String imageUrl) {
    showImageViewer(
      context,
      Image.network(imageUrl).image,
      useSafeArea: true,
      swipeDismissible: true,
      doubleTapZoomable: true,
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
      case 'imageUrl':
        previewImage(data['imageUrl']);
        break;
      default:
        if (!dismissCartScreen) {
          showAnimatedDialog(context, data, 'Get details');
        }
    }
  }

  bool showNavigationDrawer = false, dismissCartScreen = false;
  void handleOnClickHamburger(String action) {
    setState(() {
      if (action == 'show_drawer') {
        showNavigationDrawer = true;
        // navigateToLoginScreen();
      } else {
        dismissCartScreen = true;
        showNavigationDrawer = false;
      }
    });
  }

  void handleCartScreen(String action) {
    setState(() {
      dismissCartScreen = false;
    });
  }

  Future<void> _updateProductList(String collectionName) async {
    try {
      // Fetch the updated product list
      final updatedProductList =
          await ApiService().fetchProductListFromFirebase(collectionName);
      setState(() {
        if (updatedProductList.isEmpty) {
          productListData = 'No data found!';
        } else {
          productListData = '';
        }
        productList = Future.value(updatedProductList);
      });
    } catch (e) {
      setState(() {
        productList = Future.value([]);
      });
    }
  }

  bool isMenTabSelected = true;
  bool isWomenTabSelected = false;

  Widget menButtonWidget(bool tabletView) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            width: isMenTabSelected ? 2.5 : 1,
            color: isMenTabSelected ? AppColors.cGreenColor : Colors.grey,
          ),
          color: Colors.white,
        ),
        child: Text(
          'Men',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: tabletView ? 25 : 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget womenButtonWidget(bool tabletView) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.only(top: 5, bottom: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            width: isWomenTabSelected ? 2.5 : 1,
            color: isWomenTabSelected ? AppColors.cGreenColor : Colors.grey,
          ),
          color: Colors.white,
        ),
        child: Text(
          'Women',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: tabletView ? 25 : 15,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var mobileView = screenSize.width < 600;
    var tabletView = screenSize.width > 600;
    var mediumTabletView = screenSize.width > 820;
    var desktopView = screenSize.width > 1300;
    return Scaffold(
        body: Stack(children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/app_bg.png', // Path to your background image
          fit: BoxFit.cover,
        ),
      ),
      Column(
        children: [
          Header(
              onClickHamburger: handleOnClickHamburger,
              showCart: true,
              showBackArrow: true,
              routeFromHome: false),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!isMenTabSelected) {
                        _updateProductList(widget.firebaeCollectionName ==
                                Endpoints.menBagProductList
                            ? Endpoints.menBagProductList
                            : Endpoints.menWatchProductList);
                        isMenTabSelected = true;
                        isWomenTabSelected = false;
                      }
                    });
                  },
                  child: menButtonWidget(tabletView),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!isWomenTabSelected) {
                        _updateProductList(widget.firebaeCollectionName ==
                                Endpoints.menBagProductList
                            ? Endpoints.womenBagProductList
                            : Endpoints.womenWatchProductList);
                        isMenTabSelected = false;
                        isWomenTabSelected = true;
                      }
                    });
                  },
                  child: womenButtonWidget(tabletView),
                ),
              ),
            ],
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Stack(alignment: Alignment.topRight, children: [
              Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    left: tabletView ? 40 : 10,
                    right: tabletView ? 40 : 10,
                  ),
                  child: FutureBuilder<List<ProductItemFirebaseModel>>(
                      future: productList,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.cGreenColor)));
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text(productListData));
                        } else {
                          List<ProductItemFirebaseModel> productList =
                              snapshot.data!;
                          productList.sort(
                              (a, b) => b.createdBy.compareTo(a.createdBy));
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
                            listViewBuilderOptions: ListViewBuilderOptions(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                            ),
                            children: List.generate(
                              productList.length,
                              (index) => ProductItemWidget(
                                tabletView: tabletView,
                                mediumTabletView: mediumTabletView,
                                desktopView: desktopView,
                                isHorizontalList: false,
                                bestSellerFirebaseList: snapshot.data![index],
                                onClickCallBack: handleClick,
                                routeFromHomeScreen: false,
                              ),
                            ),
                          );
                        }
                      }))
            ]),
          ))
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
    ]));
  }
}
