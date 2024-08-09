import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/Widgets/custom_dialog.dart';
import 'package:jp_optical/Widgets/header.dart';
import 'package:jp_optical/Widgets/MenWomenSectiondivider_label_widget.dart';
import 'package:jp_optical/Widgets/productItem_widget.dart';
import 'package:jp_optical/Widgets/redirect_uri.dart';
import 'package:jp_optical/api/api_service.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/constants/endpoints.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:jp_optical/presentation/cart_screen.dart';
import 'package:jp_optical/presentation/cloth_cateogry_list_screen.dart';
import 'package:jp_optical/presentation/home_screen_new.dart';
import 'package:jp_optical/presentation/my_navigation_drawer.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Productlistscreen extends StatefulWidget {
  final String routeFrom, firebaeCollectionName;

  const Productlistscreen({
    super.key,
    required this.routeFrom,
    required this.firebaeCollectionName,
  });

  @override
  State<Productlistscreen> createState() => _ProductlistscreenState();
}

class _ProductlistscreenState extends State<Productlistscreen> {
  late Future<List<ProductItemFirebaseModel>> productList = Future.value([]);
  String productListData = '', updatedCollectionName = '';
  final _scrollController = ScrollController();
  List<ProductItemFirebaseModel> _products = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  bool isMenTabSelected = true;
  bool isWomenTabSelected = false;
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

  void navigateToCart() {
    setState(() {
      dismissCartScreen = true;
    });
  }

  _handleBagAndWatchNavigation(String action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Productlistscreen(
          routeFrom: action == Endpoints.menBagProductList ? 'Bag' : 'Watch',
          firebaeCollectionName: action,
        ),
      ),
    );
  }

  void navigateToCategoryListScreen(String collectionName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ClothCateogryListScreen(
                firebaeCollectionName: collectionName,
              )),
    );
  }

  void handleNavigation(String firebaeCollectionName, String routeFrom) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Productlistscreen(
          routeFrom: routeFrom,
          firebaeCollectionName: firebaeCollectionName,
        ),
      ),
    );
  }

  void handleNavigationDrawerClick(String action) {
    setState(() {
      switch (action) {
        case 'Home':
          showNavigationDrawer = false;
          _navigateToHomeScreen();
          break;
        case 'Close':
          showNavigationDrawer = false;
          break;
        case 'Men Optical':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.menOpticalProductList, action);
          break;
        case 'Women Optical':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.womenOpticalProductList, action);
          break;
        case 'Men cloths':
          showNavigationDrawer = false;
          navigateToCategoryListScreen(Endpoints.menClothCategoryList);
          break;
        case 'Bags - women, men':
          showNavigationDrawer = false;
          _handleBagAndWatchNavigation(Endpoints.menBagProductList);
          break;
        case 'Perfumes':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.perfumeProductList, action);
          break;
        case 'Watches - women, men':
          showNavigationDrawer = false;
          _handleBagAndWatchNavigation(Endpoints.menWatchProductList);
          break;
        case 'Belt':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.beltProductList, action);
          break;
        case 'Shoe':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.shoeProductList, action);
          break;
        case 'Caps':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.capProductList, action);
          break;
        case 'Wallets':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.walletProductList, action);
          break;
        case 'Other Accessories':
          showNavigationDrawer = false;
          handleNavigation(Endpoints.otherAccessoriesProductList, action);
          break;
        default:
          showNavigationDrawer = false;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts(widget.firebaeCollectionName);
    _scrollController.addListener(() {
      if (!_isLoading &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _fetchProducts(updatedCollectionName != ''
            ? updatedCollectionName
            : widget.firebaeCollectionName);
      }
    });
  }

  Future<void> _fetchProducts(String collectionName) async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result = await ApiService()
        .fetchProductListFromFirebase1(
            collectionName: collectionName, lastDoc: _lastDoc, limit: 10);
    List<ProductItemFirebaseModel> newProducts = result['products'];
    DocumentSnapshot? lastDocument = result['lastDocument'];

    setState(() {
      _products.addAll(newProducts);
      _lastDoc = lastDocument;
      _isLoading = false;
      _hasMore = newProducts.length == 10;
    });
  }

  Future<void> handleClickOnWhatsAppNumber(Map<String, dynamic> data) async {
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
      transitionDuration: const Duration(milliseconds: 300),
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

  Widget menButtonWidget(bool tabletView) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.only(top: 5, bottom: 5),
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
    );
  }

  Widget womenButtonWidget(bool tabletView) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.only(top: 5, bottom: 5),
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
    );
  }

  _navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreenNew()),
      (route) => false, // Remove all routes
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var mobileView = screenSize.width < 600;
    var tabletView = screenSize.width > 600;
    var mediumTabletView = screenSize.width > 820;
    var desktopView = screenSize.width > 1300;

    return WillPopScope(
        onWillPop: () async {
          _navigateToHomeScreen();
          return false;
        },
        child: Scaffold(
            body: !showNavigationDrawer
                ? Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/app_bg.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Column(
                        children: [
                          Header(
                              onClickHamburger: handleOnClickHamburger,
                              showCart: true,
                              showBackArrow: true,
                              routeFromHome: false),
                          ['Bag', 'Watch'].contains(widget.routeFrom)
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (!isMenTabSelected) {
                                              updatedCollectionName =
                                                  widget.firebaeCollectionName ==
                                                          Endpoints
                                                              .menBagProductList
                                                      ? Endpoints
                                                          .menBagProductList
                                                      : Endpoints
                                                          .menWatchProductList;
                                              _products.clear();
                                              _lastDoc = null;
                                              _isLoading = false;
                                              _hasMore = true;
                                              _fetchProducts(
                                                  widget.firebaeCollectionName ==
                                                          Endpoints
                                                              .menBagProductList
                                                      ? Endpoints
                                                          .menBagProductList
                                                      : Endpoints
                                                          .menWatchProductList);
                                              isMenTabSelected = true;
                                              isWomenTabSelected = false;
                                            }
                                          });
                                        },
                                        child: menButtonWidget(tabletView),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            if (!isWomenTabSelected) {
                                              updatedCollectionName =
                                                  widget.firebaeCollectionName ==
                                                          Endpoints
                                                              .menBagProductList
                                                      ? Endpoints
                                                          .womenBagProductList
                                                      : Endpoints
                                                          .womenWatchProductList;
                                              _products.clear();
                                              _lastDoc = null;
                                              _isLoading = false;
                                              _hasMore = true;
                                              _fetchProducts(
                                                  widget.firebaeCollectionName ==
                                                          Endpoints
                                                              .menBagProductList
                                                      ? Endpoints
                                                          .womenBagProductList
                                                      : Endpoints
                                                          .womenWatchProductList);
                                              isMenTabSelected = false;
                                              isWomenTabSelected = true;
                                            }
                                          });
                                        },
                                        child: womenButtonWidget(tabletView),
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          const SizedBox(height: 10),
                          MenWomenSectionDividerLabelWidget(
                            label: '${widget.routeFrom} ',
                            label2: 'Section',
                            margin: const EdgeInsets.only(left: 50),
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            tabletView: tabletView,
                            routeFromHome: false,
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: dismissCartScreen
                                  ? NeverScrollableScrollPhysics()
                                  : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(
                                      left: tabletView ? 40 : 10,
                                      right: tabletView ? 40 : 10,
                                    ),
                                    child: _products.isEmpty
                                        ? _isLoading
                                            ? const Center(
                                                child: CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            AppColors
                                                                .cGreenColor)))
                                            : const Center(
                                                child: Text('No data found'))
                                        : ResponsiveGridList(
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
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                            ),
                                            children: List.generate(
                                              _products.length +
                                                  (_hasMore ? 1 : 0),
                                              (index) {
                                                if (index == _products.length) {
                                                  return const Center(
                                                      child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  AppColors
                                                                      .cGreenColor)));
                                                }
                                                return ProductItemWidget(
                                                  tabletView: tabletView,
                                                  mediumTabletView:
                                                      mediumTabletView,
                                                  desktopView: desktopView,
                                                  isHorizontalList: false,
                                                  bestSellerFirebaseList:
                                                      _products[index],
                                                  onClickCallBack: handleClick,
                                                  routeFromHomeScreen: false,
                                                );
                                              },
                                            ),
                                          ),
                                  ),
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
                              child:
                                  CartScreen(onCloseCallBack: handleCartScreen),
                            )
                          : Container(),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(10),
                    child: MyNavigationdrawer(
                        onClickCallBack: handleNavigationDrawerClick))));
  }
}
