import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jp_optical/VideoData.dart';
import 'package:jp_optical/Widgets/MenWomenSectiondivider_label_widget.dart';
import 'package:jp_optical/Widgets/custom_dialog.dart';
import 'package:jp_optical/Widgets/login_screen.dart';
import 'package:jp_optical/Widgets/productItem_widget.dart';
import 'package:jp_optical/Widgets/redirect_uri.dart';
import 'package:jp_optical/api/api_service.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/Widgets/banner_widget.dart';
import 'package:jp_optical/Widgets/header.dart';
import 'package:jp_optical/constants/endpoints.dart';
import 'package:jp_optical/constants/redirection_string.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:jp_optical/models/happy_customer_model.dart';
import 'package:jp_optical/models/happy_customer_firebase_model.dart';
import 'package:jp_optical/presentation/cart_screen.dart';
import 'package:jp_optical/presentation/cloth_list_screen.dart';
import 'package:jp_optical/presentation/my_navigation_drawer.dart';
import 'package:jp_optical/presentation/product_list_screen.dart';
import 'package:jp_optical/presentation/video_player_screen.dart';
import 'package:outlined_text/outlined_text.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/cupertino.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  late Future<List<HappyCustomerModel>> happyCustomerData = Future.value([]);
  List<HappyCustomerModel> happyCustomerList = [];

  Future<void> fetchData() async {
    try {
      // Perform the asynchronous work outside of setState
      final List<HappyCustomerModel> data =
          await ApiService().fetchHappyCustomerData();

      // Use setState to update the state after the asynchronous work is done
      setState(() {
        happyCustomerData = Future.value(data);
        happyCustomerList = data;
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  late Future<List<HappyCustomerFirabaseModel>> happyCustomerFirebaseList;
  late Future<List<ProductItemFirebaseModel>> bestSellerFirebaseList;
  late Future<List<HappyCustomerFirabaseModel>> readyToOrderFirebaseList;
  late Future<List<ProductItemFirebaseModel>> menProductFirebaseList;
  late Future<List<ProductItemFirebaseModel>> womenProductFirebaseList;
  late Future<List<HappyCustomerFirabaseModel>> aboutShopFirebaseVideo;

  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    //upload data on firestore
    // FirebaseFirestore.instance.collection(Endpoints.womenOpticalProductList).add({
    //   'productId': 'QS234WW',
    //   'productTitle':'Men Glass New Trendy Stylish',
    //   'productImage':'https://images.pexels.com/photos/947885/pexels-photo-947885.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    //   'createdBy': Timestamp.now(),
    // }).then((value) {
    //   print("Document successfully written!");
    // }).catchError((error) {
    //   print("Error writing document: $error");
    // });

    //  FirebaseFirestore.instance.collection(Endpoints.menOpticalProductList).add({
    //   'productId': 'JH757GG',
    //   'productTitle':'Women Glass New Trendy Stylish',
    //   'productImage':'https://images.pexels.com/photos/131018/pexels-photo-131018.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
    //   'createdBy': Timestamp.now(),
    // }).then((value) {
    //   print("Document successfully written!");
    // }).catchError((error) {
    //   print("Error writing document: $error");
    // });

    happyCustomerFirebaseList =
        ApiService().fetchHappyCustomerListFromFirebase();
    bestSellerFirebaseList = ApiService().fetchBestSellersListFromFirebase();
    readyToOrderFirebaseList = ApiService().fetchReadyToOrderListFromFirebase();
    menProductFirebaseList = ApiService().fetchMenProductListFromFirebase();
    womenProductFirebaseList = ApiService().fetchwomenProductListFromFirebase();
    aboutShopFirebaseVideo =
        ApiService().fetchAboutShopFirebaseVideoFromFirebase();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (!_isUserScrolling) {
        if (_scrollController.hasClients) {
          final maxScrollExtent = _scrollController.position.maxScrollExtent;
          final currentScrollPosition = _scrollController.position.pixels;
          final nextScrollPosition = currentScrollPosition + 300.0;

          if (currentScrollPosition < maxScrollExtent) {
            _scrollController.animateTo(
              nextScrollPosition,
              duration: Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          } else {
            _scrollController.jumpTo(0); // Scroll back to start
          }
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
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

  void handleNavigation(String viewMoreFor) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Productlistscreen(
                routeFrom: viewMoreFor,
                productList: viewMoreFor == 'Men'
                    ? menProductFirebaseList
                    : viewMoreFor == 'Women'
                        ? womenProductFirebaseList
                        : bestSellerFirebaseList,
              )),
    );
  }

  void handleNavigationDrawerClick(String action) {
    setState(() {
      switch (action) {
        case 'Close':
          showNavigationDrawer = false;
          break;
        case 'Men':
          showNavigationDrawer = false;
          handleNavigation(action);
          break;
        case 'Women':
          showNavigationDrawer = false;
          handleNavigation(action);
          break;
        case 'Cart':
          showNavigationDrawer = false;
          dismissCartScreen = true;

          break;
        default:
          showNavigationDrawer = false;
      }
    });
  }

  void handleCartScreen(String action) {
    setState(() {
      dismissCartScreen = false;
    });
  }

  void navigateToVideoPlayerScreen(String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(videoUrl: videoUrl)),
    );
  }

  void handleClickOnWhatsAppNumber(Map<String, dynamic> data) {
    String action = data['action'];
    switch (action) {
      case 'close':
        Navigator.of(context).pop();
        break;
      default:
        final itemsJson = jsonEncode([data]);
        redirectUri(action, 'orderThroghWhatsApp', itemsJson);
        Navigator.of(context).pop();
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

  _handleClickOnClothSection(String action) {
    navigateToClothListScreen(Endpoints.menClothCategoryList);
  }

  _handleClickOnOpticalSection(String action) {
    handleNavigation(action);
  }

  void navigateToClothListScreen(String collectionName) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ClothListScreen(
                firebaeCollectionName: collectionName,
              )),
    );
  }

  Widget playIconWidget(bool desktopView) {
    return Container(
        width: desktopView ? 60 : 30,
        height: desktopView ? 60 : 30,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(width: 2, color: Colors.black)),
        child: Icon(
          Icons.play_arrow,
          color: Colors.black,
          size: desktopView ? 50 : 20,
        ));
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var mobileView = screenSize.width < 600;
    var tabletView = screenSize.width > 600;
    var mediumTabletView = screenSize.width > 820;
    var desktopView = screenSize.width > 1300;
    return Scaffold(
        body: !showNavigationDrawer
            ? Stack(alignment: Alignment.topRight, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Header(
                      onClickHamburger: handleOnClickHamburger,
                      showCart: mobileView ? false : true,
                      showBackArrow: false,
                      routeFromHome: true),
                  Expanded(
                      child: SingleChildScrollView(
                          physics: dismissCartScreen
                              ? NeverScrollableScrollPhysics()
                              : null,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TopBannerBelowHeader(
                                    tabletView: tabletView,
                                    desktopView: desktopView,
                                    mediumTabletView: mediumTabletView,
                                    handleGetDetailsClick: handleClick),
                                MarqueeWidgetbelowTopBanner(
                                    tabletView: tabletView),
                                HappyCustomerDividerAndLabel(
                                    tabletView: tabletView,
                                    desktopView: desktopView),
                                FutureBuilder<List<HappyCustomerFirabaseModel>>(
                                    future: happyCustomerFirebaseList,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Shimmer.fromColors(
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
                                            ));
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text('No data found'));
                                      } else {
                                        return HappyCustomerVideoAndGridWidget(
                                            tabletView: tabletView,
                                            desktopView: desktopView,
                                            happyCustomerData:
                                                snapshot.data ?? [],
                                            onClickVideo:
                                                navigateToVideoPlayerScreen,
                                            playIconWidget:
                                                playIconWidget(false));
                                      }
                                    }),
                                tabletView
                                    ? Container()
                                    : const SizedBox(height: 20),
                                CategoryLabel(tabletView: tabletView),
                                MenWomenContainerBelowCategory(
                                  tabletView: tabletView,
                                  desktopView: desktopView,
                                  onClickCallBack: _handleClickOnOpticalSection,
                                ),
                                const SizedBox(height: 20),
                                MenClothBanner(
                                  tabletView: tabletView,
                                  desktopView: desktopView,
                                  onClickCallBack: _handleClickOnClothSection,
                                ),
                                const SizedBox(height: 20),
                                BestSellersLabel(tabletView: tabletView),
                                SizedBox(height: tabletView ? 50 : 20),
                                GestureDetector(
                                    onPanDown: (_) {
                                      _isUserScrolling = true;
                                      _stopAutoScroll();
                                    },
                                    onPanEnd: (_) {
                                      Future.delayed(const Duration(seconds: 3), () {
                                        if (!_isUserScrolling) {
                                          _isUserScrolling = false;
                                          _startAutoScroll();
                                        }
                                      });
                                    },
                                    child: Container(
                                      height: desktopView ? 590 : 450,
                                      margin: EdgeInsets.only(
                                          left: tabletView ? 50 : 10,
                                          right: tabletView ? 50 : 10),
                                      child: FutureBuilder<
                                              List<ProductItemFirebaseModel>>(
                                          future: bestSellerFirebaseList,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return ListView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  children: List.generate(
                                                      7,
                                                      (index) =>
                                                          Shimmer.fromColors(
                                                              baseColor: Colors
                                                                  .grey[300]!,
                                                              highlightColor:
                                                                  Colors.grey[
                                                                      100]!,
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
                                                                color: Colors
                                                                    .grey[300]!,
                                                              ))));
                                            } else if (snapshot.hasError) {
                                              return Center();
                                            } else if (!snapshot.hasData ||
                                                snapshot.data!.isEmpty) {
                                              return Center();
                                            } else {
                                              return ListView.builder(
                                                controller: _scrollController,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: snapshot.data!
                                                    .length, // Increase the item count by 1
                                                itemBuilder: (context, index) {
                                                  // Check if the current index is 50
                                                  if (index == 9) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          // Handle the click event for the custom widget
                                                          print('sarab wah');
                                                        },
                                                        child: Center(
                                                            child:
                                                                GestureDetector(
                                                          onTap: () => {
                                                            handleNavigation(
                                                                'Best Seller')
                                                          },
                                                          child: MouseRegion(
                                                            cursor:
                                                                SystemMouseCursors
                                                                    .click,
                                                            child: Container(
                                                              height:
                                                                  desktopView
                                                                      ? 100
                                                                      : 50,
                                                              width: desktopView
                                                                  ? 150
                                                                  : 100,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                  color: Colors
                                                                      .white,
                                                                  border: Border.all(
                                                                      width: 1,
                                                                      color: Colors
                                                                          .grey)),
                                                              child: Text(
                                                                'View more >',
                                                                style: GoogleFonts.outfit(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        desktopView
                                                                            ? 20
                                                                            : 15,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                            ),
                                                          ),
                                                        )));
                                                  } else {
                                                    int adjustedIndex =
                                                        index > 50
                                                            ? index - 1
                                                            : index;
                                                    return ProductItemWidget(
                                                      tabletView: tabletView,
                                                      mediumTabletView:
                                                          mediumTabletView,
                                                      desktopView: desktopView,
                                                      isHorizontalList: true,
                                                      bestSellerFirebaseList:
                                                          snapshot.data![
                                                              adjustedIndex],
                                                      onClickCallBack:
                                                          handleClick,
                                                      routeFromHomeScreen: true,
                                                    );
                                                  }
                                                },
                                              );
                                            }
                                          }),
                                    )),
                                SizedBox(height: 30),
                                BannerWidget(
                                    tabletView: tabletView,
                                    desktopView: desktopView),
                                SizedBox(height: tabletView ? 50 : 20),
                                ReadyToOrderDividerAndLabel(
                                    tabletView: tabletView),
                                SizedBox(height: tabletView ? 50 : 0),
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    // glassLabelImage(),
                                    Container(
                                        margin: EdgeInsets.only(
                                            right: tabletView ? 60 : 10,
                                            left: tabletView ? 60 : 10),
                                        width: double.infinity,
                                        child: FutureBuilder<
                                                List<
                                                    HappyCustomerFirabaseModel>>(
                                            future: readyToOrderFirebaseList,
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Shimmer.fromColors(
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
                                                    ));
                                              } else if (snapshot.hasError) {
                                                return Center();
                                              } else if (!snapshot.hasData ||
                                                  snapshot.data!.isEmpty) {
                                                return Center();
                                              } else {
                                                return ReadyToOrderListWidget(
                                                  videoWidth:
                                                      tabletView ? 296 : 188,
                                                  videoHeight:
                                                      tabletView ? 573 : 283,
                                                  happyCustomerData:
                                                      snapshot.data ?? [],
                                                  onClickVideo:
                                                      navigateToVideoPlayerScreen,
                                                  desktopView: desktopView,
                                                );
                                              }
                                            }))
                                  ],
                                ),
                                SizedBox(height: tabletView ? 40 : 20),
                                MenWomenSectionDividerLabelWidget(
                                  label: 'Men',
                                  label2: 'Section',
                                  margin: EdgeInsets.only(left: 50),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  tabletView: tabletView,
                                ),
                                FutureBuilder<List<ProductItemFirebaseModel>>(
                                    future: menProductFirebaseList,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Shimmer.fromColors(
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
                                            ));
                                      } else if (snapshot.hasError) {
                                        return Center();
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Center();
                                      } else {
                                        return MenSectionGridWidget(
                                            tabletView: tabletView,
                                            mediumTabletView: mediumTabletView,
                                            desktopView: desktopView,
                                            productFirebaseList:
                                                snapshot.data ?? [],
                                            handleClick: handleClick);
                                      }
                                    }),
                                SizedBox(height: tabletView ? 40 : 20),
                                MenSectionViewMore(
                                  viewMoreFor: 'Men',
                                  tabletView: tabletView,
                                  onViewMoreClick: handleNavigation,
                                ),
                                const SizedBox(height: 60),
                                BuyBrandedSunglassesBanner(
                                    tabletView: tabletView),
                                const SizedBox(height: 20),
                                MenWomenSectionDividerLabelWidget(
                                    label: 'Women',
                                    label2: 'Section',
                                    margin: EdgeInsets.only(right: 50),
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    tabletView: tabletView),
                                FutureBuilder<List<ProductItemFirebaseModel>>(
                                    future: womenProductFirebaseList,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Shimmer.fromColors(
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
                                            ));
                                      } else if (snapshot.hasError) {
                                        return Center();
                                      } else if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return Center();
                                      } else {
                                        return MenSectionGridWidget(
                                            tabletView: tabletView,
                                            mediumTabletView: mediumTabletView,
                                            desktopView: desktopView,
                                            productFirebaseList:
                                                snapshot.data ?? [],
                                            handleClick: handleClick);
                                      }
                                    }),
                                SizedBox(height: tabletView ? 40 : 20),
                                MenSectionViewMore(
                                  viewMoreFor: 'Women',
                                  tabletView: tabletView,
                                  onViewMoreClick: handleNavigation,
                                ),
                                const SizedBox(height: 20),
                                AboutJpOpticalWidget(
                                    tabletView: tabletView,
                                    mediumTabletView: mediumTabletView,
                                    mobileView: mobileView,
                                    desktopView: desktopView,
                                    happyCustomerFirebaseList:
                                        aboutShopFirebaseVideo,
                                    onClickVideo: navigateToVideoPlayerScreen,
                                    playIconWidget:
                                        playIconWidget(desktopView)),
                                SizedBox(height: tabletView ? 80 : 30),
                                StoreLocationMapWidget(
                                    tabletView: tabletView,
                                    desktopView: desktopView),
                                const SizedBox(height: 60),
                                const Footer(),
                                const SizedBox(height: 20),
                              ])))
                ]),
                dismissCartScreen
                    ? Container(
                        margin: EdgeInsets.only(top: mobileView ? 0 : 70),
                        width: mobileView ? double.infinity : 700,
                        height: mobileView ? double.infinity : 700,
                        child: CartScreen(onCloseCallBack: handleCartScreen),
                      )
                    : Container()
              ])
            : Padding(
                padding: const EdgeInsets.all(10),
                child: MyNavigationdrawer(
                    onClickCallBack: handleNavigationDrawerClick)));
  }
}

class TopBannerBelowHeader extends StatefulWidget {
  final bool tabletView, desktopView, mediumTabletView;
  final ValueChanged<Map<String, dynamic>> handleGetDetailsClick;

  const TopBannerBelowHeader(
      {Key? key,
      required this.tabletView,
      required this.desktopView,
      required this.mediumTabletView,
      required this.handleGetDetailsClick})
      : super(key: key);

  @override
  State<TopBannerBelowHeader> createState() => _TopBannerBelowHeaderState();
}

class _TopBannerBelowHeaderState extends State<TopBannerBelowHeader> {
  @override
  Widget build(BuildContext context) {
    var imageFirst = widget.tabletView
        ? 'assets/images/header_banner_first_image.png'
        : 'assets/images/header_banner_first_image_landscape.png';
    var imageSecond = widget.tabletView
        ? 'assets/images/header_banner_second_image.png'
        : 'assets/images/header_banner_second_image_landscape.png';
    var imageThird = widget.tabletView
        ? 'assets/images/header_banner_third_image.png'
        : 'assets/images/header_banner_third_image_landscape.png';
    var imageFouth = widget.tabletView
        ? 'assets/images/header_banner_forth_image.png'
        : 'assets/images/header_banner_forth_image_landscape.png';

    var topHeaderWidgetForLandscape = <Widget>[
      Expanded(
          child: Image.asset(
        imageFirst,
        fit: BoxFit.fitHeight,
      )),
      Expanded(
          child: Image.asset(
        imageSecond,
        fit: BoxFit.fitHeight,
      )),
      Expanded(
          child: Image.asset(
        imageThird,
        fit: BoxFit.fitHeight,
      )),
      Expanded(
          child: Image.asset(
        imageFouth,
        fit: BoxFit.fitHeight,
      )),
      const SizedBox(
        width: 40,
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 32,
              ),
              children: const <TextSpan>[
                TextSpan(text: 'GET YOUR CLEAR \nVISION '),
                TextSpan(
                  text: 'EYEGLASSES NOW',
                  style: TextStyle(
                    color: AppColors.cGreenColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
            width: 387,
            child: Text(
                "Explore our exclusive collection of sunglasses designed to elevate your look and protect your eyes. From timeless classics to trendy styles, discover sunglasses that suit every face shape and personality."
                    .toUpperCase(),
                style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    fontSize: 18))),
        const SizedBox(
          height: 50,
        ),
        ElevatedButton(
          onPressed: () => {
            widget.handleGetDetailsClick({
              'action': 'get details',
              'productId': null,
              'productTitle': null,
              'productImage': null,
            })
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.only(
                left: widget.tabletView ? 40 : 5,
                right: widget.tabletView ? 40 : 5,
                top: widget.tabletView ? 20 : 5,
                bottom: widget.tabletView ? 20 : 5),
            backgroundColor: AppColors.cGreenColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0.0),
            ),
          ),
          child: Text(
            'Get Details',
            style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: widget.tabletView ? 20 : 16,
                color: Colors.white),
          ),
        )
      ]),
      const SizedBox(
        width: 40,
      ),
    ];
    var topHeaderWidgetForPortrait = <Widget>[
      Container(
          margin: EdgeInsets.only(right: 60),
          child: Image.asset(
            imageFirst,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          )),
      Container(
          margin: EdgeInsets.only(left: 60),
          child: Image.asset(
            imageSecond,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          )),
      Container(
          margin: EdgeInsets.only(right: 60),
          child: Image.asset(
            imageThird,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          )),
      Container(
          margin: EdgeInsets.only(left: 60),
          child: Image.asset(
            imageFouth,
            width: double.infinity,
            fit: BoxFit.fitWidth,
          )),
      const SizedBox(
        width: 40,
      ),
      Container(
          margin: EdgeInsets.all(widget.tabletView ? 0 : 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: widget.tabletView ? 32 : 20,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'GET YOUR CLEAR \nVISION '),
                    TextSpan(
                      text: 'EYEGLASSES NOW',
                      style: TextStyle(
                        color: AppColors.cGreenColor,
                        fontWeight: FontWeight.w500,
                        fontSize: widget.tabletView ? 32 : 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
                width: 387,
                child: Text(
                    "Explore our exclusive collection of sunglasses designed to elevate your look and protect your eyes. From timeless classics to trendy styles, discover sunglasses that suit every face shape and personality."
                        .toUpperCase(),
                    style: GoogleFonts.outfit(
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        fontSize: widget.tabletView ? 18 : 14))),
            const SizedBox(
              height: 50,
            ),
            Container(
                alignment:
                    widget.tabletView ? Alignment.centerLeft : Alignment.center,
                child: ElevatedButton(
                  onPressed: () => {
                    widget.handleGetDetailsClick({
                      'action': 'get details',
                      'productId': null,
                      'productTitle': null,
                      'productImage': null,
                    })
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.only(
                        left: widget.tabletView ? 40 : 20,
                        right: widget.tabletView ? 40 : 20,
                        top: widget.tabletView ? 20 : 10,
                        bottom: widget.tabletView ? 20 : 10),
                    backgroundColor: AppColors.cGreenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  child: Text(
                    'Get Details',
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: widget.tabletView ? 20 : 16,
                        color: Colors.white),
                  ),
                ))
          ])),
      const SizedBox(
        height: 20,
      ),
    ];

    return Container(
        color: AppColors.blackColor,
        child: Column(children: [
          Container(
              padding: EdgeInsets.all(widget.tabletView ? 10.0 : 10.0),
              child: Row(
                  mainAxisAlignment: widget.tabletView
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    OutlinedText(
                      text: Text('EVERY',
                          style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: widget.desktopView
                                  ? 90
                                  : widget.tabletView
                                      ? 40
                                      : 20,
                              fontWeight: FontWeight.w600)),
                      strokes: [
                        OutlinedTextStroke(color: Colors.grey, width: 1),
                      ],
                    ),
                    SizedBox(width: widget.tabletView ? 15 : 5),
                    OutlinedText(
                      text: Text('MOOD',
                          style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: widget.desktopView
                                  ? 90
                                  : widget.tabletView
                                      ? 40
                                      : 20,
                              fontWeight: FontWeight.w600)),
                      strokes: [
                        OutlinedTextStroke(
                            color: AppColors.cGreenColor, width: 1),
                      ],
                    ),
                    SizedBox(width: widget.tabletView ? 15 : 5),
                    OutlinedText(
                      text: Text('HAS',
                          style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: widget.desktopView
                                  ? 90
                                  : widget.tabletView
                                      ? 40
                                      : 20,
                              fontWeight: FontWeight.w600)),
                      strokes: [
                        OutlinedTextStroke(color: Colors.grey, width: 1),
                      ],
                    ),
                    SizedBox(width: widget.tabletView ? 15 : 5),
                    OutlinedText(
                      text: Text('A',
                          style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: widget.desktopView
                                  ? 90
                                  : widget.tabletView
                                      ? 40
                                      : 20,
                              fontWeight: FontWeight.w600)),
                      strokes: [
                        OutlinedTextStroke(color: Colors.grey, width: 1),
                      ],
                    ),
                    SizedBox(width: widget.tabletView ? 15 : 5),
                    OutlinedText(
                      text: Text('FRAME',
                          style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: widget.desktopView
                                  ? 90
                                  : widget.tabletView
                                      ? 40
                                      : 20,
                              fontWeight: FontWeight.w600)),
                      strokes: [
                        OutlinedTextStroke(
                            color: AppColors.cGreenColor, width: 1),
                      ],
                    ),
                  ])),
          Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                  top: widget.desktopView
                      ? 0
                      : widget.tabletView
                          ? 20
                          : 0),
              padding: EdgeInsets.only(
                  bottom: widget.desktopView
                      ? 0
                      : widget.tabletView
                          ? 50
                          : 0),
              child: widget.tabletView
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: topHeaderWidgetForLandscape)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: topHeaderWidgetForPortrait)),
        ]));
  }
}

class MarqueeWidgetbelowTopBanner extends StatelessWidget {
  final bool tabletView;

  const MarqueeWidgetbelowTopBanner({Key? key, required this.tabletView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: tabletView ? 45 : 40,
        color: AppColors.cGreenColor,
        child: Text(
          "Trending Frame   *   Best Deals   *   Offers You Can't Regret",
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w300,
              fontSize: tabletView ? 25 : 13,
              color: Colors.white),
        ));
  }
}

class HappyCustomerDividerAndLabel extends StatelessWidget {
  final bool tabletView, desktopView;

  const HappyCustomerDividerAndLabel(
      {Key? key, required this.tabletView, required this.desktopView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: tabletView ? 50 : 20),
        child: Row(
          mainAxisAlignment:
              tabletView ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            tabletView
                ? Container(
                    width: desktopView ? 600 : 200,
                    height: 3,
                    color: Colors.black.withOpacity(0.2),
                  )
                : Container(),
            tabletView
                ? const SizedBox(
                    width: 20,
                  )
                : Container(),
            Text(
              'Happy Customer',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: tabletView ? 32 : 20,
                  color: AppColors.cGreenColor),
            ),
          ],
        ));
  }
}

class HappyCustomerVideoAndGridWidget extends StatefulWidget {
  final bool tabletView, desktopView;
  final List<HappyCustomerFirabaseModel> happyCustomerData;
  final ValueChanged<String> onClickVideo;
  final Widget playIconWidget;

  const HappyCustomerVideoAndGridWidget(
      {Key? key,
      required this.tabletView,
      required this.desktopView,
      required this.happyCustomerData,
      required this.onClickVideo,
      required this.playIconWidget})
      : super(key: key);

  @override
  State<HappyCustomerVideoAndGridWidget> createState() =>
      _HappyCustomerVideoAndGridWidgetState();
}

class _HappyCustomerVideoAndGridWidgetState
    extends State<HappyCustomerVideoAndGridWidget> {
  // late VideoPlayerController _controllers;

  // String currentVideoUrl =
  //     'https://videos.pexels.com/video-files/4812205/4812205-hd_1080_1920_30fps.mp4';

  List<VideoData> videoDataList = [];

  Future<void> _updateVideoUrl(String videoUrl, bool videoChanged) async {
    if (widget.happyCustomerData.isNotEmpty) {
      if (videoChanged) widget.onClickVideo(videoUrl);
    }
  }

  @override
  void initState() {
    super.initState();
    // _controllers =
    //     VideoPlayerController.network(widget.happyCustomerData[0].videoUrl);
    // _controllers.addListener(() {
    //   setState(() {});
    // });
    // _controllers.initialize().then((_) {
    //   setState(() {
    //     _controllerInitialized = true;
    //   });
    // });
    // }
    // _initializeVideoDataList();
    // _updateVideoUrl(currentVideoUrl, false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  //   _playVideo(String videoUrl) {
  //    navigateToVideoPlayerScreen(videoUrl);
  //   // setState(() {
  //   //   if (_controllers.value.isPlaying) {
  //   //     _controllers.pause();
  //   //     _controllers.seekTo(Duration.zero);
  //   //   } else {
  //   //     _controllers.play();
  //   //   }
  //   // });
  // }

  static const gridImageHeight = 108.0;

  Widget imageContainer(String videoUrl, String thumbnailUrl) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _updateVideoUrl(videoUrl, true);
        });
      },
      child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            margin: const EdgeInsets.all(8),
            width: double.infinity,
            height: double.infinity,
            child: Stack(alignment: Alignment.center, children: [
              Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading image: $error');
                  return Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error, color: Colors.red),
                  );
                },
              ),
              widget.playIconWidget
            ]),
          )),
    );
  }

  Widget buildGrid(final List<HappyCustomerFirabaseModel> videoDataList) {
    return ResponsiveGridList(
        horizontalGridSpacing: 0,
        verticalGridSpacing: 0,
        horizontalGridMargin: 0,
        verticalGridMargin: 0,
        minItemWidth: 1,
        minItemsPerRow: 1,
        maxItemsPerRow: 6,
        listViewBuilderOptions: ListViewBuilderOptions(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
        children: List.generate(
            videoDataList.length >= 18 ? 18 : videoDataList.length,
            (index) => imageContainer(
                  videoDataList[index].videoUrl,
                  videoDataList[index].thumbnailUrl,
                )));
  }

  bool _controllerInitialized = false;

  @override
  Widget build(BuildContext context) {
    return widget.desktopView
        ? Container(
            width: double.infinity,
            margin:
                const EdgeInsets.only(left: 60, right: 60, top: 40, bottom: 40),
            height: widget.desktopView
                ? 650
                : widget.tabletView
                    ? 300
                    : 620,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () => {
                          widget.onClickVideo(
                              widget.happyCustomerData[0].videoUrl)
                        },
                    child: Stack(alignment: Alignment.center, children: [
                      MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            margin: EdgeInsets.only(top: 10),
                            width: widget.desktopView
                                ? 365
                                : widget.tabletView
                                    ? 165
                                    : 365,
                            height: widget.desktopView
                                ? 650
                                : widget.tabletView
                                    ? 500
                                    : 620,
                            child: Image.network(
                              widget.happyCustomerData[0].thumbnailUrl,
                              fit: BoxFit.fill,
                            ),
                          )),
                      MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      width: 2, color: Colors.black)),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 50,
                              )))
                    ])),
                const SizedBox(width: 40),
                Expanded(
                  child: SizedBox(
                    height: 650,
                    child: buildGrid(widget.happyCustomerData),
                  ),
                ),
              ],
            ),
          )
        : Container(
            margin: EdgeInsets.only(right: 10, left: 10),
            width: double.infinity,
            child: ReadyToOrderListWidget(
                videoWidth: 188,
                videoHeight: 283,
                happyCustomerData: widget.happyCustomerData,
                onClickVideo: widget.onClickVideo,
                desktopView: widget.desktopView));
  }
}

class CategoryLabel extends StatelessWidget {
  final bool tabletView;

  const CategoryLabel({Key? key, required this.tabletView}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Category',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: tabletView ? 32 : 20,
              color: AppColors.cGreenColor),
        ),
      ],
    );
  }
}

class MenWomenContainerBelowCategory extends StatelessWidget {
  final bool tabletView, desktopView;
  final ValueChanged<String> onClickCallBack;

  const MenWomenContainerBelowCategory(
      {Key? key,
      required this.tabletView,
      required this.desktopView,
      required this.onClickCallBack})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            left: tabletView ? 60 : 10,
            right: tabletView ? 60 : 10,
            top: tabletView ? 40 : 20,
            bottom: tabletView ? 40 : 20),
        child: Row(children: [
          Expanded(
              child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => {onClickCallBack('Men')},
                      child: Stack(alignment: Alignment.bottomLeft, children: [
                        Container(
                            height: desktopView
                                ? 350
                                : tabletView
                                    ? 250
                                    : 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/men_banner.png',
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ))),
                        Container(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 5, bottom: 5),
                          decoration: const BoxDecoration(
                              color: AppColors.cGreenColor,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(8),
                                  bottomLeft: Radius.circular(8))),
                          child: Text(
                            'Men',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: tabletView ? 30 : 14,
                                color: Colors.white),
                          ),
                        )
                      ])))),
          const SizedBox(
            width: 30,
          ),
          Expanded(
              child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () => {onClickCallBack('Women')},
                child: Stack(alignment: Alignment.bottomLeft, children: [
                  Container(
                      height: desktopView
                          ? 350
                          : tabletView
                              ? 250
                              : 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/women_banner.png',
                            width: double.infinity,
                            fit: BoxFit.fill,
                          ))),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 5, bottom: 5),
                    decoration: const BoxDecoration(
                        color: AppColors.cGreenColor,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomLeft: Radius.circular(8))),
                    child: Text(
                      'Women',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: tabletView ? 30 : 14,
                          color: Colors.white),
                    ),
                  )
                ])),
          ))
        ]));
  }
}

class MenClothBanner extends StatelessWidget {
  final bool tabletView, desktopView;
  final ValueChanged<String> onClickCallBack;

  const MenClothBanner(
      {Key? key,
      required this.tabletView,
      required this.desktopView,
      required this.onClickCallBack})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            left: tabletView ? 60 : 10,
            right: tabletView ? 60 : 10,
            top: tabletView ? 40 : 20,
            bottom: tabletView ? 40 : 20),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () => {onClickCallBack('Clothing and accessories')},
                child: Stack(alignment: Alignment.bottomRight, children: [
                  Container(
                      height: desktopView
                          ? 500
                          : tabletView
                              ? 450
                              : 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/men_cloth_banner.jpg',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ))),
                  Container(
                    padding: EdgeInsets.only(
                        left: desktopView ? 30 : 10,
                        right: desktopView ? 30 : 10,
                        top: 5,
                        bottom: 5),
                    decoration: const BoxDecoration(
                        color: AppColors.cGreenColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8))),
                    child: Text(
                      'Men wear & Accessories',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: tabletView ? 30 : 14,
                          color: Colors.white),
                    ),
                  )
                ]))));
  }
}

class BestSellersLabel extends StatelessWidget {
  final bool tabletView;

  const BestSellersLabel({Key? key, required this.tabletView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.outfit(
                  color: AppColors.cGreenColor,
                  fontWeight: FontWeight.w600,
                  fontSize: tabletView ? 32 : 20,
                  height: 1.2),
              children: <TextSpan>[
                TextSpan(text: 'Best '),
                TextSpan(
                  text: 'Sellers',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: tabletView ? 32 : 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: tabletView ? 20 : 5,
          ),
          Container(
            margin: EdgeInsets.only(top: 18),
            color: AppColors.cGreenColor,
            width: 1,
            height: tabletView ? 50 : 30,
          )
        ],
      ),
      Container(
        width: tabletView ? 170 : 90,
        margin: EdgeInsets.only(bottom: 8, left: tabletView ? 40 : 40),
        height: 1,
        color: AppColors.cGreenColor,
      ),
    ]);
  }
}

class ReadyToOrderDividerAndLabel extends StatelessWidget {
  final bool tabletView;

  const ReadyToOrderDividerAndLabel({Key? key, required this.tabletView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: tabletView ? 50 : 30,
        margin: const EdgeInsets.only(top: 0),
        child: Row(
          children: [
            Expanded(
                child: Container(
              width: double.infinity,
              height: tabletView ? 3 : 2,
              color: Colors.black.withOpacity(0.2),
            )),
            const SizedBox(
              width: 10,
            ),
            RichText(
              text: TextSpan(
                style: GoogleFonts.outfit(
                    color: AppColors.cGreenColor,
                    fontWeight: FontWeight.w600,
                    fontSize: tabletView ? 32 : 10,
                    height: 1.2),
                children: <TextSpan>[
                  TextSpan(text: 'Ready To '),
                  TextSpan(
                    text: 'Order',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: tabletView ? 48 : 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Container(
              margin: EdgeInsets.only(top: tabletView ? 40 : 10),
              width: double.infinity,
              height: tabletView ? 3 : 2,
              color: Colors.black.withOpacity(0.2),
            )),
          ],
        ));
  }
}

class ReadyToOrderListWidget extends StatefulWidget {
  final double videoWidth;
  final double videoHeight;
  final List<HappyCustomerFirabaseModel> happyCustomerData;
  final ValueChanged<String> onClickVideo;
  final bool desktopView;
  const ReadyToOrderListWidget(
      {super.key,
      required this.videoHeight,
      required this.videoWidth,
      required this.happyCustomerData,
      required this.onClickVideo,
      required this.desktopView});

  @override
  State<ReadyToOrderListWidget> createState() => _ReadyToOrderListWidgetState();
}

class _ReadyToOrderListWidgetState extends State<ReadyToOrderListWidget> {
  List<HappyCustomerModel> fetchList = [];
  late List<VideoPlayerController> _controllers = [];
  late ScrollController _scrollController;
  late int _currentlyPlayingIndex = -1;

  void fetchHappyCustomerData() {
    setState(() {
      List<String> videoUrls =
          widget.happyCustomerData.map((e) => e.videoUrl).toList();
      _controllers =
          videoUrls.map((url) => VideoPlayerController.network(url)).toList();
      for (var controller in _controllers) {
        controller.addListener(() {
          setState(() {});
        });
        controller.initialize().then((_) {
          setState(() {});
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchHappyCustomerData();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void scrollLeft() {
    double targetOffset =
        _scrollController.offset - MediaQuery.of(context).size.width;
    targetOffset =
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    double targetOffset =
        _scrollController.offset + MediaQuery.of(context).size.width;

    targetOffset =
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void playVideo(int index) {
    if (index == _currentlyPlayingIndex) {
      if (_controllers[index].value.isPlaying) {
        _controllers[index].pause();
        _controllers[index].seekTo(Duration.zero);
      } else {
        _controllers[index].play();
      }
    } else {
      if (_currentlyPlayingIndex != -1) {
        _controllers[_currentlyPlayingIndex].pause();
        _controllers[_currentlyPlayingIndex].seekTo(Duration.zero);
      }
      _controllers[index].play();
      setState(() {
        _currentlyPlayingIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.videoWidth,
      height: widget.videoHeight,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.happyCustomerData.length,
        itemBuilder: (context, index) {
          var controller = _controllers[index];
          double aspectRatio = controller.value.aspectRatio;
          double containerHeight = 350;
          if (aspectRatio != null && aspectRatio > 0) {
            containerHeight = 400.0 / aspectRatio;
          }

          return GestureDetector(
              onTap: () => {
                    widget
                        .onClickVideo(widget.happyCustomerData[index].videoUrl),
                  },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Stack(alignment: Alignment.center, children: [
                  Container(
                    width: widget.videoWidth == 188 ? 160 : 350,
                    height: containerHeight,
                    margin: EdgeInsets.fromLTRB(
                      0,
                      20,
                      index == widget.happyCustomerData.length - 1 ? 0 : 10,
                      0,
                    ),
                    child: Image.network(
                        widget.happyCustomerData[index].thumbnailUrl,
                        fit: BoxFit.fill),
                  ),
                  Container(
                      width: widget.desktopView ? 60 : 35,
                      height: widget.desktopView ? 60 : 35,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(width: 2, color: Colors.black)),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: widget.desktopView ? 50 : 25,
                      ))
                ]),
              ));
        },
      ),
    );
  }
}

class MenSectionGridWidget extends StatelessWidget {
  final bool tabletView, mediumTabletView, desktopView;
  final List<ProductItemFirebaseModel> productFirebaseList;
  final ValueChanged<Map<String, dynamic>> handleClick;

  const MenSectionGridWidget(
      {Key? key,
      required this.tabletView,
      required this.mediumTabletView,
      required this.desktopView,
      required this.productFirebaseList,
      required this.handleClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        //  height: desktopView ? 1000 : null,
        margin: EdgeInsets.only(
            left: tabletView ? 40 : 10, right: tabletView ? 40 : 10),
        child: ResponsiveGridList(
          horizontalGridSpacing: 5,
          verticalGridSpacing: 5,
          horizontalGridMargin: 5,
          verticalGridMargin: 5,
          minItemWidth: 100,
          minItemsPerRow: 1,
          maxItemsPerRow: desktopView ? 2 : 1,
          listViewBuilderOptions: ListViewBuilderOptions(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          ),
          children: List.generate(
              desktopView ? 4 : 2,
              (index) => ProductItemWidget(
                    tabletView: tabletView,
                    mediumTabletView: mediumTabletView,
                    desktopView: desktopView,
                    isHorizontalList: false,
                    bestSellerFirebaseList: productFirebaseList[index],
                    onClickCallBack: handleClick,
                    routeFromHomeScreen: true,
                  )),
        ));
  }
}

class MenSectionViewMore extends StatelessWidget {
  final String viewMoreFor;
  final bool tabletView;
  final ValueChanged<String> onViewMoreClick;

  const MenSectionViewMore(
      {Key? key,
      required this.viewMoreFor,
      required this.tabletView,
      required this.onViewMoreClick})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            left: tabletView ? 100 : 30, right: tabletView ? 100 : 30),
        alignment: Alignment.center,
        child: ElevatedButton(
            onPressed: () {
              onViewMoreClick(viewMoreFor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cGreenColor,
              side: const BorderSide(color: AppColors.cGreenColor, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Padding(
                padding: EdgeInsets.only(
                    left: tabletView ? 110 : 50,
                    right: tabletView ? 110 : 50,
                    top: 5,
                    bottom: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('View More',
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: tabletView ? 20 : 16)),
                    // const SizedBox(width: 10),
                    // Icon(
                    //   Icons.arrow_drop_down,
                    //   color: Colors.white,
                    //   size: 30,
                    // )
                  ],
                ))));
  }
}

class BuyBrandedSunglassesBanner extends StatelessWidget {
  final bool tabletView;

  const BuyBrandedSunglassesBanner({Key? key, required this.tabletView})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Image.asset(
          'assets/images/buy_branded_sunglasses_banner.png',
          width: double.infinity,
          height: tabletView ? 800 : 212,
          fit: BoxFit.contain,
        ));
  }
}

class AboutJpOpticalWidget extends StatefulWidget {
  final bool tabletView, mediumTabletView, mobileView, desktopView;
  final ValueChanged<String> onClickVideo;
  final Future<List<HappyCustomerFirabaseModel>> happyCustomerFirebaseList;
  final Widget playIconWidget;
  const AboutJpOpticalWidget(
      {Key? key,
      required this.tabletView,
      required this.mediumTabletView,
      required this.mobileView,
      required this.desktopView,
      required this.onClickVideo,
      required this.happyCustomerFirebaseList,
      required this.playIconWidget})
      : super(key: key);

  @override
  State<AboutJpOpticalWidget> createState() => _AboutJpOpticalWidgetState();
}

class _AboutJpOpticalWidgetState extends State<AboutJpOpticalWidget> {
  bool comingFirstTime = true;
  late VideoPlayerController _controllers;
  bool _controllerInitialized = false;
  String currentVideoUrl =
      'https://firebasestorage.googleapis.com/v0/b/rj-brothers-e9d57.appspot.com/o/4752391-sd_356_640_25fps.mp4?alt=media&token=9ca6006b-a6bf-43b6-9ec1-0a70d8c9f250';
  String thumbnailUrl =
      'https://firebasestorage.googleapis.com/v0/b/rj-brothers-e9d57.appspot.com/o/pexels-nitin-creative-249210.jpg?alt=media&token=44291861-c402-49b0-9a34-0aaca3fc35e4';

  // void _updateVideoUrl(String videoUrl, bool videoChanged) {
  //   setState(() {
  //     currentVideoUrl = videoUrl;
  //     _controllers = VideoPlayerController.network(currentVideoUrl);

  //     _controllers.addListener(() {
  //       setState(() {});
  //     });
  //     _controllers.initialize().then((_) {
  //       setState(() {
  //         if (videoChanged) _controllers.play();
  //       });
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    if (!_controllerInitialized) {
      // _controllers = VideoPlayerController.network(
      //     snapshot.data![0].videoUrl);
      _controllers = VideoPlayerController.network(currentVideoUrl);
      _controllers.addListener(() {
        setState(() {});
      });
      _controllers.initialize().then((_) {
        setState(() {
          _controllerInitialized = true;
        });
      });
    }
    // _updateVideoUrl(currentVideoUrl, false);
  }

  @override
  void dispose() {
    _controllers.dispose();

    super.dispose();
  }

  void _playVideo() {
    setState(() {
      if (_controllers.value.isPlaying) {
        _controllers.pause();
        _controllers.seekTo(Duration.zero);
      } else {
        _controllers.play();
      }
    });
  }

  final FlickManager flickManager = FlickManager(
    videoPlayerController: VideoPlayerController.network(
      'https://firebasestorage.googleapis.com/v0/b/rj-brothers-e9d57.appspot.com/o/4752391-sd_356_640_25fps.mp4?alt=media&token=9ca6006b-a6bf-43b6-9ec1-0a70d8c9f250',
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, AppColors.cGreenColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
          top: widget.tabletView ? 40 : 20,
          bottom: widget.tabletView ? 40 : 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder<List<HappyCustomerFirabaseModel>>(
              future: widget.happyCustomerFirebaseList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: widget.desktopView
                            ? 320
                            : widget.tabletView
                                ? 250
                                : 188,
                        height: widget.tabletView ? 400 : 283,
                        color: Colors.grey[300]!,
                      ));
                } else if (snapshot.hasError) {
                  return Center(
                      child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey,
                    width: widget.desktopView
                        ? 320
                        : widget.tabletView
                            ? 250
                            : 188,
                    height: widget.tabletView ? 400 : 283,
                    child: Text(
                      'Something went wrong...',
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                  ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Container(
                    alignment: Alignment.center,
                    color: Colors.grey,
                    width: widget.desktopView
                        ? 320
                        : widget.tabletView
                            ? 250
                            : 188,
                    height: widget.tabletView ? 400 : 283,
                    child: Text(
                      'No data found!',
                      style: GoogleFonts.outfit(color: Colors.white),
                    ),
                  ));
                } else {
                  return GestureDetector(
                      onTap: () =>
                          {widget.onClickVideo(snapshot.data![0].videoUrl)},
                      child: Stack(alignment: Alignment.center, children: [
                        Container(
                          margin: EdgeInsets.only(
                              left: widget.desktopView ? 60 : 10),
                          width: widget.desktopView
                              ? 320
                              : widget.tabletView
                                  ? 250
                                  : 180,
                          height: widget.tabletView ? 400 : 283,
                          child: Image.network(
                            snapshot.data![0].thumbnailUrl,
                            fit: BoxFit.fill,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(
                                left: widget.desktopView ? 60 : 10),
                            child: widget.playIconWidget)
                      ]));
                }
              }),
          SizedBox(
            width: widget.desktopView
                ? 80
                : widget.tabletView
                    ? 30
                    : 10,
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About JP Optical',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: widget.desktopView
                                ? 32
                                : widget.tabletView
                                    ? 18
                                    : 12,
                            color: Colors.black),
                      ),
                      Container(
                        width: widget.tabletView ? 150 : 80,
                        height: widget.tabletView ? 5 : 2,
                        color: AppColors.cGreenColor,
                      )
                    ],
                  ),
                  SizedBox(
                      width: widget.desktopView
                          ? 40
                          : widget.tabletView
                              ? 20
                              : 10),
                  SvgPicture.asset(
                    'assets/images/sunglass_image_blue.svg',
                    semanticsLabel: 'Sungalass',
                    width: widget.tabletView ? 60 : 30,
                    height: widget.tabletView ? 60 : 30,
                    // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  )
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              Text(
                'At JP OPTICAL, we are dedicated to providing you with the highest quality optical products and watches. Our mission is to help you see better and look great. With years of experience in the optical and watch industry, we pride ourselves on offering exceptional customer service and a wide range of products to suit every style and need.',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w400,
                    fontSize: widget.tabletView ? 16 : 12,
                    color: Colors.black),
              )
            ],
          )),
          SizedBox(
            width: widget.tabletView ? 80 : 10,
          ),
        ],
      ),
    );
  }
}

class StoreLocationMapWidget extends StatelessWidget {
  final bool tabletView, desktopView;

  const StoreLocationMapWidget(
      {Key? key, required this.tabletView, required this.desktopView})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var landscapeWidget = <Widget>[
      Expanded(
          child: Container(
              height: desktopView
                  ? 478
                  : tabletView
                      ? 250
                      : 278,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 60),
                    child: Text(
                      'Store location',
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontSize: desktopView ? 32 : 20,
                          color: AppColors.cGreenColor),
                    ),
                  ),
                  Container(
                    width: 180,
                    height: 2,
                    color: Colors.black.withOpacity(0.2),
                  ),
                  Container(
                      margin: const EdgeInsets.all(20),
                      child: Text(
                        'We invite you to visit our store to experience our exceptional service and explore our extensive collection of optical products and watches. Located conveniently in Mohali, our shop is easily accessible and offers a welcoming atmosphere for all your eyewear and timepiece needs.',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            fontSize: desktopView
                                ? 16
                                : tabletView
                                    ? 8
                                    : 12,
                            color: Colors.black),
                      )),
                  Expanded(child: Container()),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    ElevatedButton(
                        onPressed: () => {redirectUri('', 'get direction', '')},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                              top: 15, bottom: 15, left: 40, right: 40),
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: AppColors.cGreenColor, width: 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(55.0),
                          ),
                        ),
                        child: Text('Get Direction',
                            style: GoogleFonts.outfit(
                                color: AppColors.cGreenColor,
                                fontWeight: FontWeight.w600,
                                fontSize: desktopView ? 20 : 10)))
                  ]),
                ],
              ))),
      const SizedBox(
        width: 10,
      ),
      Expanded(
          child: Container(
              height: desktopView ? 478 : 287,
              child: Image.asset(
                'assets/images/shop_image.png',
                fit: BoxFit.fill,
              ))),
      const SizedBox(
        width: 15,
      ),
      Expanded(
          child: Container(
              height: desktopView ? 478 : 287,
              child: Image.asset(
                'assets/images/map_image.png',
                fit: BoxFit.fill,
              ))),
      const SizedBox(
        width: 20,
      ),
    ];
    var portraitWidget = <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 30),
            child: Text(
              'Store location',
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.cGreenColor),
            ),
          ),
          Container(
            width: 150,
            height: 1,
            color: Colors.black.withOpacity(0.2),
          ),
          Container(
              margin: const EdgeInsets.all(20),
              child: Text(
                'We invite you to visit our store to experience our exceptional service and explore our extensive collection of optical products and watches. Located conveniently in Mohali, our shop is easily accessible and offers a welcoming atmosphere for all your eyewear and timepiece needs.',
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Colors.black),
              )),
        ],
      ),
      const SizedBox(
        width: 10,
      ),
      Container(
          margin: EdgeInsets.all(15),
          width: double.infinity,
          height: 205,
          child: Image.asset(
            'assets/images/shop_image.png',
            fit: BoxFit.fill,
          )),
      const SizedBox(
        width: 10,
      ),
      Container(
          width: double.infinity,
          margin: EdgeInsets.all(15),
          height: 205,
          child: Image.asset(
            'assets/images/map_image.png',
            fit: BoxFit.fill,
          )),
      const SizedBox(
        width: 40,
      ),
      ElevatedButton(
          onPressed: () {
            redirectUri('', 'get direction', '');
          },
          style: ElevatedButton.styleFrom(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
            backgroundColor: Colors.white,
            side: const BorderSide(color: AppColors.cGreenColor, width: 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(55.0),
            ),
          ),
          child: Text('Get Direction',
              style: GoogleFonts.outfit(
                  color: AppColors.cGreenColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 18))),
    ];

    return Container(
        width: double.infinity,
        margin: EdgeInsets.only(
            right: desktopView
                ? 50
                : tabletView
                    ? 10
                    : 0),
        child: tabletView
            ? Row(children: landscapeWidget)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: portraitWidget));
  }
}

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/whatsapp_icon.svg',
                  height: 20,
                  width: 20,
                ),
                onPressed: () => redirectUri('', 'normalWhatsAppContact', ''),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/instagram_icon.svg',
                  height: 20,
                  width: 20,
                ),
                onPressed: () => redirectUri('', 'instagram', ''),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/facebook_icon.svg',
                  height: 20,
                  width: 20,
                ),
                onPressed: () => redirectUri('', 'facebook', ''),
              ),
              IconButton(
                icon: SvgPicture.asset(
                  'assets/icons/youtube_icon.svg',
                  height: 20,
                  width: 20,
                ),
                onPressed: () => redirectUri('', 'youtube', ''),
              ),
            ],
          ),
          Text('© ${DateTime.now().year} JP Optical. All rights reserved.',
              style: GoogleFonts.outfit(
                color: Colors.grey[700],
                fontSize: 14,
              ))
        ]));
  }
}
