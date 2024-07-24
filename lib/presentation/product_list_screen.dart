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
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Productlistscreen extends StatefulWidget {
  final String routeFrom, firebaeCollectionName;

  const Productlistscreen(
      {super.key,
      required this.routeFrom,
      required this.firebaeCollectionName,
      });

  @override
  State<Productlistscreen> createState() => _ProductlistscreenState();
}

class _ProductlistscreenState extends State<Productlistscreen> {
  late Future<List<ProductItemFirebaseModel>> productList = Future.value([]);
  String productListData = '';
  final _scrollController = ScrollController();
  List<ProductItemFirebaseModel> _products = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  bool isMenTabSelected = true;
  bool isWomenTabSelected = false;

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
    _fetchProducts(widget.firebaeCollectionName);
    _scrollController.addListener(() {
      if (!_isLoading &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _fetchProducts(widget.firebaeCollectionName);
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
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
      ),
    );
  }

  Widget womenButtonWidget(bool tabletView) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
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
      body: Stack(
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
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (!isMenTabSelected) {
                                  _products.clear();
                                  _lastDoc = null;
                                  _isLoading = false;
                                  _hasMore = true;
                                  _fetchProducts(widget.firebaeCollectionName ==
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
                                  _products.clear();
                                  _lastDoc = null;
                                  _isLoading = false;
                                  _hasMore = true;
                                  _fetchProducts(widget.firebaeCollectionName ==
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
                  physics:
                      dismissCartScreen ? NeverScrollableScrollPhysics() : null,
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
                                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.cGreenColor)))
                                : const Center(child: Text('No data found'))
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
                                listViewBuilderOptions: ListViewBuilderOptions(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                ),
                                children: List.generate(
                                  _products.length + (_hasMore ? 1 : 0),
                                  (index) {
                                    if (index == _products.length) {
                                      return const Center(
                                          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.cGreenColor)));
                                    }
                                    return ProductItemWidget(
                                      tabletView: tabletView,
                                      mediumTabletView: mediumTabletView,
                                      desktopView: desktopView,
                                      isHorizontalList: false,
                                      bestSellerFirebaseList: _products[index],
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
                  child: CartScreen(onCloseCallBack: handleCartScreen),
                )
              : Container(),
        ],
      ),
    );
  }
}
