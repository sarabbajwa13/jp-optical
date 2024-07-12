import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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

class ClothListScreen extends StatefulWidget {
  final String firebaeCollectionName;
  const ClothListScreen({super.key, required this.firebaeCollectionName});

  @override
  State<ClothListScreen> createState() => _ClothListScreenState();
}

class _ClothListScreenState extends State<ClothListScreen> {
  late Future<List<ProductCategoryFirebaseModel>> categoryListFromFirebase;
  late Future<List<ProductItemFirebaseModel>> productList = Future.value([]);
  String productListData = '';
  String? selectedCategory;
  @override
  void initState() {
    super.initState();
    categoryListFromFirebase = ApiService()
        .fetchMenClothCategoryListFromFirebase(widget.firebaeCollectionName);
    _initializeProductList();
  }

  Future<void> _updateProductList(String collectionName) async {
    try {
      // Fetch the updated product list
      final updatedProductList =
          await ApiService().fetchMenJacektListFromFirebase(collectionName);
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

  Future<void> _initializeProductList() async {
    try {
      // Await the completion of category list fetching
      final categories = await categoryListFromFirebase;

      if (categories.isNotEmpty) {
        // Get the first category's product list name
        final firstCategory = categories.first;
        final collectionName = firstCategory.productListName;
        setState(() {
          selectedCategory = categories.first.productListName;
        });
        // Call _updateProductList with the collection name
        await _updateProductList(collectionName);
      }
    } catch (e) {
      print('Error initializing product list: $e');
    }
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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var mobileView = screenSize.width < 600;
    var tabletView = screenSize.width > 600;
    var mediumTabletView = screenSize.width > 820;
    var desktopView = screenSize.width > 1300;
    return Scaffold(
        body: Stack(children: [
      Column(
        children: [
          Header(
            onClickHamburger: handleOnClickHamburger,
            showCart: true,
            showBackArrow: true,
            routeFromHome: false
          ),
          Container( 
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: FutureBuilder<List<ProductCategoryFirebaseModel>>(
                  future: categoryListFromFirebase,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView(
                          scrollDirection: Axis.horizontal,
                          children: List.generate(
                              7,
                              (index) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: desktopView
                                        ? 365
                                        : tabletView
                                            ? 165
                                            : 365,
                                    height: desktopView
                                        ? 620
                                        : tabletView
                                            ? 500
                                            : 620,
                                    color: Colors.grey[300]!,
                                  ))));
                    } else if (snapshot.hasError) {
                      return Center();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center();
                    } else {
                      return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final category = snapshot.data![index];
                            final isSelected =
                                selectedCategory == category.productListName;

                            return GestureDetector(
                                onTap: () => {
                                      if (!isSelected)
                                        {
                                          setState(() {
                                            selectedCategory =
                                                category.productListName;
                                          }),
                                          _updateProductList(
                                              category.productListName)
                                        }
                                    },
                                child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left: 20,
                                            right: index ==
                                                    snapshot.data!.length - 1
                                                ? 20
                                                : 0),
                                        padding: EdgeInsets.only(
                                            left: desktopView ? 25 : 15,
                                            right: desktopView ? 25 : 15,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            border: Border.all(
                                                width: isSelected ? 2.5 : 1,
                                                color: isSelected
                                                    ? AppColors.cGreenColor
                                                    : Colors.grey),
                                            color: Colors.white),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.network(
                                              snapshot
                                                  .data![index].productImage,
                                              width: 35,
                                              height: 50,
                                              fit: BoxFit.fill,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              snapshot
                                                  .data![index].productTitle,
                                              style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ))));
                          });
                    }
                  })),
          Expanded(
              child: SingleChildScrollView(
            child: Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  left: tabletView ? 40 : 10,
                  right: tabletView ? 40 : 10,
                ),
                child: FutureBuilder<List<ProductItemFirebaseModel>>(
                    future: productList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text(productListData));
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
                          listViewBuilderOptions: ListViewBuilderOptions(
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
                              bestSellerFirebaseList: snapshot.data![index],
                              onClickCallBack: handleClick,
                              routeFromHomeScreen: false,
                            ),
                          ),
                        );
                      }
                    })),
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
