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
import 'package:jp_optical/presentation/home_screen_new.dart';
import 'package:jp_optical/presentation/my_navigation_drawer.dart';
import 'package:jp_optical/presentation/product_list_screen.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:shimmer/shimmer.dart';

class ClothCateogryListScreen extends StatefulWidget {
  final String firebaeCollectionName;
  const ClothCateogryListScreen(
      {super.key, required this.firebaeCollectionName});

  @override
  State<ClothCateogryListScreen> createState() =>
      _ClothCateogryListScreenState();
}

class _ClothCateogryListScreenState extends State<ClothCateogryListScreen> {
  late Future<List<ProductCategoryFirebaseModel>> categoryListFromFirebase;
  late Future<List<ProductItemFirebaseModel>> productList = Future.value([]);
  String productListData = '', updatedCollectionName = '';
  String? selectedCategory;
  final _scrollController = ScrollController();
  List<ProductItemFirebaseModel> _products = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  @override
  void initState() {
    super.initState();

    categoryListFromFirebase = ApiService()
        .fetchMenClothCategoryListFromFirebase(widget.firebaeCollectionName);
    _initializeProductList();

    //  _fetchProducts(widget.firebaeCollectionName);
    _scrollController.addListener(() {
      if (!_isLoading &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _fetchProducts(updatedCollectionName);
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

  void _refreshProducts(String collectionName) {
    setState(() {
      _lastDoc = null;
      _products.clear();
    });
    _fetchProducts(collectionName);
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
        await _fetchProducts(collectionName);
      }
    } catch (e) {
      debugPrint('Error initializing product list: $e');
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

  void previewImage(String imageUrl) {
    showImageViewer(
      context,
      Image.network(imageUrl).image,
      useSafeArea: true,
      swipeDismissible: true,
      doubleTapZoomable: true,
    );
  }

  _navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomeScreenNew()),
      (route) => false,
    );
  }

  void handleClick(Map<String, dynamic> data) {
    String action = data['action'];
    switch (action) {
      case 'Home':
        showNavigationDrawer = false;
        _navigateToHomeScreen();
        break;
      case 'cart':
        if (!dismissCartScreen) {
          setState(() {
            updateCartIcon = true;
          });
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

  bool showNavigationDrawer = false,
      dismissCartScreen = false,
      updateCartIcon = false;
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
    return WillPopScope(
        onWillPop: () async {
          // _navigateToHomeScreen();
          if (dismissCartScreen) {
            setState(() {
              dismissCartScreen = false;
            });
            return false;
          } else {
            Navigator.of(context).pop();
            return true;
          }
        },
        child: SafeArea(
            child: Scaffold(
                body: !showNavigationDrawer
                    ? Stack(alignment: Alignment.topRight, children: [
                        Column(
                          children: [
                            updateCartIcon
                                ? Header(
                                    onClickHamburger: handleOnClickHamburger,
                                    showCart: true,
                                    showBackArrow: true,
                                    routeFromHome: false)
                                : Header(
                                    onClickHamburger: handleOnClickHamburger,
                                    showCart: true,
                                    showBackArrow: true,
                                    routeFromHome: false),
                            Container(
                                height: 60,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: FutureBuilder<
                                        List<ProductCategoryFirebaseModel>>(
                                    future: categoryListFromFirebase,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: List.generate(
                                                7,
                                                (index) => Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
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
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Center();
                                      } else {
                                        return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: snapshot.data!.length,
                                            itemBuilder: (context, index) {
                                              final category =
                                                  snapshot.data![index];
                                              final isSelected =
                                                  selectedCategory ==
                                                      category.productListName;

                                              return InkWell(
                                                  splashColor: Colors
                                                      .transparent, // Removes the splash color
                                                  highlightColor: Colors
                                                      .transparent, // Removes the highlight color
                                                  radius:
                                                      0, // Optionally adjust the radius if needed

                                                  onTap: () => {
                                                        if (!isSelected)
                                                          {
                                                            setState(() {
                                                              selectedCategory =
                                                                  category
                                                                      .productListName;
                                                              updatedCollectionName =
                                                                  category
                                                                      .productListName;
                                                              _products.clear();
                                                              _lastDoc = null;
                                                              _isLoading =
                                                                  false;
                                                              _hasMore = true;
                                                            }),
                                                            _fetchProducts(category
                                                                .productListName)
                                                          }
                                                      },
                                                  child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 20,
                                                          right: index ==
                                                                  snapshot.data!
                                                                          .length -
                                                                      1
                                                              ? 20
                                                              : 0),
                                                      padding: EdgeInsets.only(
                                                          left: desktopView
                                                              ? 25
                                                              : 15,
                                                          right: desktopView
                                                              ? 25
                                                              : 15,
                                                          top: 5,
                                                          bottom: 5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  50),
                                                          border: Border.all(
                                                              width: isSelected
                                                                  ? 2.5
                                                                  : 1,
                                                              color: isSelected
                                                                  ? AppColors
                                                                      .cGreenColor
                                                                  : Colors.grey),
                                                          color: Colors.white),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.network(
                                                            snapshot
                                                                .data![index]
                                                                .productImage,
                                                            width: 35,
                                                            height: 50,
                                                            fit: BoxFit.fill,
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            snapshot
                                                                .data![index]
                                                                .productTitle,
                                                            style: GoogleFonts
                                                                .outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .black),
                                                          ),
                                                        ],
                                                      )));
                                            });
                                      }
                                    })),
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
                                                  if (index ==
                                                      _products.length) {
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
                                                    onClickCallBack:
                                                        handleClick,
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
                                margin:
                                    EdgeInsets.only(top: mobileView ? 0 : 70),
                                width: mobileView ? double.infinity : 700,
                                height: mobileView ? double.infinity : 700,
                                child: CartScreen(
                                    onCloseCallBack: handleCartScreen),
                              )
                            : Container(),
                      ])
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: MyNavigationdrawer(
                            selectedTab: 'Men cloths',
                            onClickCallBack: handleNavigationDrawerClick)))));
  }
}
