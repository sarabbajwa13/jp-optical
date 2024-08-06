import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jp_optical/Widgets/MenWomenSectiondivider_label_widget.dart';
import 'package:jp_optical/Widgets/custom_dialog.dart';
import 'package:jp_optical/Widgets/image_carousel_slider.dart';
import 'package:jp_optical/Widgets/productItem_widget.dart';
import 'package:jp_optical/Widgets/redirect_uri.dart';
import 'package:jp_optical/api/api_service.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/Widgets/banner_widget.dart';
import 'package:jp_optical/Widgets/header.dart';
import 'package:jp_optical/constants/endpoints.dart';
import 'package:jp_optical/models/banner_carousel_model.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:jp_optical/models/happy_customer_firebase_model.dart';
import 'package:jp_optical/presentation/cart_screen.dart';
import 'package:jp_optical/presentation/cloth_cateogry_list_screen.dart';
import 'package:jp_optical/presentation/my_navigation_drawer.dart';
import 'package:jp_optical/presentation/product_list_screen.dart';
import 'package:jp_optical/presentation/video_player_screen.dart';
import 'package:outlined_text/outlined_text.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:video_player/video_player.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  late Future<List<HappyCustomerFirabaseModel>> happyCustomerFirebaseList;
  late Future<List<ProductItemFirebaseModel>> bestSellerFirebaseList;
  late Future<List<HappyCustomerFirabaseModel>> readyToOrderFirebaseList;
  late Future<List<ProductItemFirebaseModel>> menOpticalProductFirebaseList;
  late Future<List<ProductItemFirebaseModel>> womenOpticalProductFirebaseList;
  late Future<List<BannerCarouselModel>> bannerCarouselFirebaseList;
  late Future<List<BannerCarouselModel>> bannerBelowBestSeller;

  final ScrollController _scrollController = ScrollController();
  Timer? _autoScrollTimer;
  bool _isUserScrolling = false;
  final _readyToOrderScrollController = ScrollController();
  List<HappyCustomerFirabaseModel> _readyToOrderFirebaseList = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false, isFirstTime = true;
  bool _hasMore = true;
  late List<FlickManager> flickManagers;
  @override
  void initState() {
    super.initState();

    _startAutoScroll();
    _readyToOrderScrollController.addListener(() {
      if (!_isLoading &&
          _readyToOrderScrollController.offset ==
              _readyToOrderScrollController.position.maxScrollExtent) {
        _fetchProducts(Endpoints.readyToOrderList);
      }
    });
    //upload data on firestore
    // FirebaseFirestore.instance.collection('menOpticalProductList').add({
    //   'productTitle':'Men Jacket new',
    //   'productImage':'https://images.vexels.com/media/users/3/234039/isolated/preview/0bb83cedf3679102fae76c6bbb940ccb-denim-jean-jacket.png',
    //   'createdBy': FieldValue.serverTimestamp(),
    // }).then((value) {
    //   debugPrint("Document successfully written!");
    // }).catchError((error) {
    //   debugPrint("Error writing document: $error");
    // });

    // FirebaseFirestore.instance.collection(Endpoints.happyCustomerList).add({
    //   'videoUrl':'https://firebasestorage.googleapis.com/v0/b/rj-brothers-e9d57.appspot.com/o/review6.mp4?alt=media&token=07ca0121-c6c3-4e36-8ba1-373dfa572b75',
    //   'createdBy': FieldValue.serverTimestamp(),
    // }).then((value) {
    //   debugPrint("Document successfully written!");
    // }).catchError((error) {
    //   debugPrint("Error writing document: $error");
    // });

    happyCustomerFirebaseList =
        ApiService().fetchHappyCustomerListFromFirebase();
    bestSellerFirebaseList = ApiService().fetchBestSellersListFromFirebase();
    // readyToOrderFirebaseList = ApiService().fetchReadyToOrderListFromFirebase();
    menOpticalProductFirebaseList =
        ApiService().fetchMenOpticalProductListFromFirebase();
    womenOpticalProductFirebaseList =
        ApiService().fetchWomenOpticalProductListFromFirebase();
    bannerCarouselFirebaseList =
        ApiService().fetchBannerCarouselListFromFirebase();
    bannerBelowBestSeller =
        ApiService().fetchBannerBelowBestSellerFromFirebase();
    fetchBannerData();
    _fetchProducts(Endpoints.readyToOrderList);
  }

  Future<void> _fetchProducts(String collectionName) async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> result = await ApiService()
          .fetchReadyToOrderListFromFirebase(
              collectionName: collectionName, lastDoc: _lastDoc, limit: 10);

      if (result.containsKey('products') &&
          result.containsKey('lastDocument')) {
        List<HappyCustomerFirabaseModel> newProducts = result['products'];
        DocumentSnapshot? lastDocument = result['lastDocument'];

        setState(() {
          _readyToOrderFirebaseList.addAll(newProducts);
          _lastDoc = lastDocument;
          _isLoading = false;
          _hasMore = newProducts.length == 10;
          isFirstTime = false;

          flickManagers = _readyToOrderFirebaseList.map((data) {
            final videoController =
                VideoPlayerController.network(data.videoUrl ?? '');
            return FlickManager(
              videoPlayerController: videoController
                ..initialize().then((_) {
                  videoController.pause();
                  // Play and then pause the video after a delay
                  // for (int i = 0; i < flickManagers.length; i++) {
                  //   _playAndPauseVideo(i);
                  // }
                }),
            );
          }).toList();
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playAndPauseVideo(int index) {
    flickManagers[index].flickVideoManager?.videoPlayerController?.play();

    // Delay and then pause the video
    Future.delayed(Duration(milliseconds: 100), () {
      flickManagers[index].flickVideoManager?.videoPlayerController?.pause();
    });
  }

  String bannerImageUrl = '', bannerImageUrl2 = '';
  void fetchBannerData() {
    bannerBelowBestSeller =
        ApiService().fetchBannerBelowBestSellerFromFirebase();
    bannerBelowBestSeller.then((data) {
      if (data.isNotEmpty) {
        setState(() {
          if (data.length > 1) {
            bannerImageUrl = data[0].banner;
            bannerImageUrl2 = data[1].banner;
          } else if (data.length == 1) {
            bannerImageUrl = data[0].banner;
            bannerImageUrl2 = '';
          } else {
            bannerImageUrl = '';
            bannerImageUrl2 = '';
          }
        });
      }
    }).catchError((error) {
      debugPrint('Error fetching banner data: $error');
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isUserScrolling) {
        if (_scrollController.hasClients) {
          final maxScrollExtent = _scrollController.position.maxScrollExtent;
          final currentScrollPosition = _scrollController.position.pixels;
          final nextScrollPosition = currentScrollPosition + 300.0;

          if (currentScrollPosition < maxScrollExtent) {
            _scrollController.animateTo(
              nextScrollPosition,
              duration: Duration(milliseconds: 400),
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
    _readyToOrderScrollController.dispose();
    for (var flickManager in flickManagers) {
      flickManager.dispose();
    }
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

  void handleCartScreen(String action) {
    setState(() {
      dismissCartScreen = false;
    });
  }

  void navigateToVideoPlayerScreen(Map<String, dynamic> data) {
    if (data['videoUrl'].isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                VideoPlayerScreen(videoUrl: data['videoUrl'])),
      );
    } else {
      previewImage(data['thumbnailUrl']);
    }
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

  void handleClickOnFooterWhatsApp(Map<String, dynamic> data) {
    if (!dismissCartScreen) {
      showAnimatedDialog(context, data, 'Get details');
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
      case 'imageUrl':
        previewImage(data['imageUrl']);
        break;
      default:
        if (!dismissCartScreen) {
          showAnimatedDialog(context, data, 'Get details');
        }
    }
  }

  _handleClickOnClothSection(String action) {
    navigateToCategoryListScreen(Endpoints.menClothCategoryList);
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

  _handleClickOnOpticalSection(String action) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Productlistscreen(
          routeFrom: action == 'Men' ? 'Men Optical' : 'Women Optical',
          firebaeCollectionName: action == 'Men'
              ? Endpoints.menOpticalProductList
              : Endpoints.womenOpticalProductList,
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

  void previewImage(String imageUrl) {
    showImageViewer(
      context,
      Image.network(imageUrl).image,
      useSafeArea: true,
      swipeDismissible: true,
      doubleTapZoomable: true,
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
        body: !showNavigationDrawer
            ? Stack(alignment: Alignment.topRight, children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/app_bg.png',
                    fit: BoxFit.cover,
                  ),
                ),
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
                                // TopBannerBelowHeader(
                                //     tabletView: tabletView,
                                //     desktopView: desktopView,
                                //     mediumTabletView: mediumTabletView,
                                //     handleGetDetailsClick: handleClick),
                                FutureBuilder<List<BannerCarouselModel>>(
                                  future: bannerCarouselFirebaseList,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Shimmer.fromColors(
                                          baseColor: Colors.grey[300]!,
                                          highlightColor: Colors.grey[100]!,
                                          child: Container(
                                            height: desktopView
                                                ? 500
                                                : tabletView
                                                    ? 300
                                                    : 200,
                                            width: double.infinity,
                                            color: Colors.grey[300]!,
                                          ));
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const Center(
                                          child: Text('No data available'));
                                    } else {
                                      List<String> imageUrls = snapshot.data!
                                          .map((model) => model.banner)
                                          .toList();
                                      return Container(
                                        child: ImageCarouselSlider(
                                          items: imageUrls,
                                          imageHeight: desktopView ? 500 : 200,
                                          dotColor: Colors.black,
                                        ),
                                      );
                                    }
                                  },
                                ),

                                MarqueeWidgetbelowTopBanner(
                                    tabletView: tabletView),
                                const SizedBox(height: 20),
                                ReadyToOrderDividerAndLabel(
                                    tabletView: tabletView),
                                SizedBox(height: tabletView ? 50 : 20),

                                Container(
                                  margin: EdgeInsets.only(
                                    right: tabletView ? 60 : 10,
                                    left: tabletView ? 60 : 10,
                                  ),
                                  width: double.infinity,
                                  child: Container(
                                    height: desktopView ? 550 : 300,
                                    child: SingleChildScrollView(
                                      controller: _readyToOrderScrollController,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: _readyToOrderFirebaseList
                                                .isNotEmpty
                                            ? List.generate(
                                                _readyToOrderFirebaseList
                                                        .length +
                                                    (_hasMore ? 1 : 0),
                                                (index) {
                                                  if (index ==
                                                      _readyToOrderFirebaseList
                                                          .length) {
                                                    return isFirstTime
                                                        ? Shimmer.fromColors(
                                                            baseColor: Colors
                                                                .grey[300]!,
                                                            highlightColor:
                                                                Colors
                                                                    .grey[100]!,
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
                                                                      : 320,
                                                              color: Colors
                                                                  .grey[300]!,
                                                            ),
                                                          )
                                                        : Container();
                                                  }
                                                  return Container(
                                                    width:
                                                        desktopView ? 288 : 180,
                                                    height: double.infinity,
                                                    child: InkWell(
                                                      onTap: () => {
                                                        navigateToVideoPlayerScreen({
                                                          'videoUrl':
                                                              _readyToOrderFirebaseList[
                                                                      index]
                                                                  .videoUrl!,
                                                          'thumbnailUrl':
                                                              _readyToOrderFirebaseList[
                                                                      index]
                                                                  .thumbnailUrl,
                                                        })
                                                      },
                                                      child: Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Container(
                                                            height:
                                                                double.infinity,
                                                            margin: EdgeInsets
                                                                .fromLTRB(
                                                              0,
                                                              0,
                                                              index ==
                                                                      _readyToOrderFirebaseList
                                                                              .length -
                                                                          1
                                                                  ? 0
                                                                  : 10,
                                                              0,
                                                            ),
                                                            child:
                                                                FlickVideoPlayer(
                                                              flickManager:
                                                                  flickManagers[
                                                                      index],
                                                              flickVideoWithControls:
                                                                  const FlickVideoWithControls(
                                                                videoFit:
                                                                    BoxFit.fill,
                                                                playerLoadingFallback:
                                                                    Center(),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: desktopView
                                                                ? 60
                                                                : 35,
                                                            height: desktopView
                                                                ? 60
                                                                : 35,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          50),
                                                              border: Border.all(
                                                                  width: 2,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            child: Icon(
                                                              Icons.play_arrow,
                                                              color:
                                                                  Colors.black,
                                                              size: desktopView
                                                                  ? 50
                                                                  : 25,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : [
                                                Center(
                                                    child: Shimmer.fromColors(
                                                  baseColor: Colors.grey[300]!,
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
                                                            : 320,
                                                    color: Colors.grey[300]!,
                                                  ),
                                                ))
                                              ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: desktopView ? 40 : 20),
                                CategoryLabel(
                                  tabletView: tabletView,
                                  label: 'Opticals',
                                ),
                                MenWomenContainerBelowCategory(
                                  tabletView: tabletView,
                                  desktopView: desktopView,
                                  onClickCallBack: _handleClickOnOpticalSection,
                                ),

                                CategoryLabel(
                                  tabletView: tabletView,
                                  label:
                                      'Also Try out our Clothing and Accessory',
                                ),

                                MenClothBanner(
                                  tabletView: tabletView,
                                  desktopView: desktopView,
                                  onClickCallBack: _handleClickOnClothSection,
                                ),
                                const SizedBox(height: 20),
                                BestSellersLabel(tabletView: tabletView),
                                SizedBox(height: tabletView ? 50 : 20),
                                NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification scrollInfo) {
                                      if (scrollInfo
                                          is ScrollStartNotification) {
                                        _isUserScrolling = true;
                                        _stopAutoScroll();
                                      } else if (scrollInfo
                                          is ScrollEndNotification) {
                                        Future.delayed(
                                            const Duration(seconds: 3), () {
                                          if (_isUserScrolling) {
                                            _isUserScrolling = false;
                                            _startAutoScroll();
                                          }
                                        });
                                      }
                                      return true;
                                    },
                                    child: Container(
                                      height: desktopView ? 640 : 470,
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
                                                itemCount:
                                                    snapshot.data!.length >= 16
                                                        ? 16
                                                        : snapshot.data!.length,
                                                itemBuilder: (context, index) {
                                                  // Check if the current index is 50
                                                  if (index == 15) {
                                                    return Center(
                                                        child: InkWell(
                                                      onTap: () => {
                                                        handleNavigation(
                                                            Endpoints
                                                                .bestSellersList,
                                                            'Best Seller')
                                                      },
                                                      child: Container(
                                                        height: desktopView
                                                            ? 100
                                                            : 50,
                                                        width: desktopView
                                                            ? 150
                                                            : 100,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors
                                                                    .grey)),
                                                        child: Text(
                                                          'View more >',
                                                          style: GoogleFonts
                                                              .outfit(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      desktopView
                                                                          ? 20
                                                                          : 12,
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ),
                                                    ));
                                                  } else {
                                                    return ProductItemWidget(
                                                      tabletView: tabletView,
                                                      mediumTabletView:
                                                          mediumTabletView,
                                                      desktopView: desktopView,
                                                      isHorizontalList: true,
                                                      bestSellerFirebaseList:
                                                          snapshot.data![index],
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
                                SizedBox(height: desktopView ? 30 : 0),

                                bannerImageUrl2.isEmpty
                                    ? Container()
                                    : BannerWidget(
                                        tabletView: tabletView,
                                        desktopView: desktopView,
                                        imageUrl: bannerImageUrl2,
                                      ),
                                SizedBox(height: 30),
                                bannerImageUrl.isEmpty
                                    ? Container()
                                    : BannerWidget(
                                        tabletView: tabletView,
                                        desktopView: desktopView,
                                        imageUrl: bannerImageUrl,
                                      ),
                                SizedBox(height: tabletView ? 50 : 20),
                                HappyCustomerDividerAndLabel(
                                    tabletView: tabletView,
                                    desktopView: desktopView),
                                SizedBox(height: tabletView ? 50 : 20),
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

                                SizedBox(height: tabletView ? 40 : 20),
                                MenWomenSectionDividerLabelWidget(
                                  label: 'Men',
                                  label2: 'Section',
                                  margin: EdgeInsets.only(left: 50),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  tabletView: tabletView,
                                  routeFromHome: true,
                                ),
                                FutureBuilder<List<ProductItemFirebaseModel>>(
                                    future: menOpticalProductFirebaseList,
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
                                CategoryLabel(
                                  tabletView: tabletView,
                                  label: 'Brands we offer',
                                ),
                                BuyBrandedSunglassesBanner(
                                    tabletView: tabletView),
                                const SizedBox(height: 20),
                                MenWomenSectionDividerLabelWidget(
                                  label: 'Women',
                                  label2: 'Section',
                                  margin: EdgeInsets.only(right: 50),
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  tabletView: tabletView,
                                  routeFromHome: true,
                                ),
                                FutureBuilder<List<ProductItemFirebaseModel>>(
                                    future: womenOpticalProductFirebaseList,
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
                                    onClickVideo: navigateToVideoPlayerScreen,
                                    playIconWidget:
                                        playIconWidget(desktopView)),
                                SizedBox(height: tabletView ? 80 : 30),
                                // StoreLocationMapWidget(
                                //     tabletView: tabletView,
                                //     desktopView: desktopView),
                                const SizedBox(height: 60),
                                Footer(
                                    onClickCallBack:
                                        handleClickOnFooterWhatsApp),
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
              'Happy Customers',
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
  final ValueChanged<Map<String, dynamic>> onClickVideo;
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
  Future<void> _updateVideoUrl(
      String videoUrl, String thumbnailUrl, bool videoChanged) async {
    if (widget.happyCustomerData.isNotEmpty) {
      if (videoChanged) {
        widget
            .onClickVideo({'videoUrl': videoUrl, 'thumbnailUrl': thumbnailUrl});
      }
    }
  }

  late List<FlickManager> flickManagers;
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    flickManagers = widget.happyCustomerData.map((data) {
      // Create the VideoPlayerController
      final videoController =
          VideoPlayerController.network(data.videoUrl ?? '');

      // Create the FlickManager with the videoController
      final flickManager = FlickManager(
          videoPlayerController: videoController
            ..initialize().then((_) {
              videoController.pause();
              // for (int i = 0; i < flickManagers.length; i++) {
              //   _playAndPauseVideo(i);
              // }
              videoController.addListener(_onVideoPlayerChanged);
            }));

      return flickManager;
    }).toList();
  }

  void _playAndPauseVideo(int index) {
    flickManagers[index].flickVideoManager?.videoPlayerController?.play();

    // Delay and then pause the video
    Future.delayed(Duration(milliseconds: 100), () {
      flickManagers[index].flickVideoManager?.videoPlayerController?.pause();
    });
  }

  void _onVideoPlayerChanged() {
    final controller = flickManager.flickVideoManager?.videoPlayerController;
    if (controller != null) {
      if (controller.value.hasError) {
        debugPrint("Video player error: ${controller.value.errorDescription}");
      }
    }
  }

  @override
  void dispose() {
    for (var flickManager in flickManagers) {
      flickManager.dispose();
    }
    super.dispose();
  }

  Widget imageContainer(String videoUrl, String thumbnailUrl, int index) {
    return InkWell(
      onTap: () {
        setState(() {
          _updateVideoUrl(videoUrl, thumbnailUrl, true);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        height: double.infinity,
        child: Stack(alignment: Alignment.center, children: [
          Container(
              width: double.infinity,
              height: 250,
              child: videoUrl.isNotEmpty
                  ? FlickVideoPlayer(
                      flickManager: flickManagers[index],
                      flickVideoWithControls: const FlickVideoWithControls(
                        videoFit: BoxFit.fill,
                      ),
                    )
                  : Image.network(
                      thumbnailUrl,
                      fit: BoxFit.fill,
                    )),
          videoUrl.isNotEmpty ? widget.playIconWidget : Container(),
          videoUrl.isEmpty
              ? Container(
                  padding: const EdgeInsets.only(
                      left: 10, right: 10, top: 5, bottom: 5),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.8),
                      border:
                          Border.all(width: 1, color: AppColors.cGreenColor)),
                  child: Text(
                    'View image',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: AppColors.cGreenColor,
                        fontWeight: FontWeight.bold),
                  ))
              : Container(),
        ]),
      ),
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
          // physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
        ),
        children: List.generate(
            videoDataList.length >= 18 ? 18 : videoDataList.length,
            (index) => imageContainer(videoDataList[index].videoUrl ?? '',
                videoDataList[index].thumbnailUrl ?? '', index)));
  }

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
                InkWell(
                    onTap: () => {
                          widget.onClickVideo({
                            'videoUrl': widget.happyCustomerData[0].videoUrl,
                            'thumbnailUrl':
                                widget.happyCustomerData[0].thumbnailUrl
                          })
                        },
                    child: Stack(alignment: Alignment.center, children: [
                      Container(
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
                          widget.happyCustomerData[0].thumbnailUrl!,
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border:
                                  Border.all(width: 2, color: Colors.black)),
                          child: widget.happyCustomerData[0].videoUrl!.isEmpty
                              ? Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white.withOpacity(0.8),
                                      border: Border.all(
                                          width: 1,
                                          color: AppColors.cGreenColor)),
                                  child: Text(
                                    'View image',
                                    style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: AppColors.cGreenColor,
                                        fontWeight: FontWeight.bold),
                                  ))
                              : const Icon(
                                  Icons.play_arrow,
                                  color: Colors.black,
                                  size: 50,
                                ))
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
            margin: const EdgeInsets.only(right: 10, left: 10),
            width: double.infinity,
            height: widget.desktopView ? 550 : 300,
            child: ReadyToOrderListWidget(
                videoWidth: 188,
                videoHeight: widget.desktopView ? 550 : 300,
                happyCustomerData: widget.happyCustomerData,
                onClickVideo: widget.onClickVideo,
                desktopView: widget.desktopView));
  }
}

class CategoryLabel extends StatelessWidget {
  final bool tabletView;
  final String label;

  const CategoryLabel({Key? key, required this.tabletView, required this.label})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: tabletView
                  ? 32
                  : label == 'Opticals'
                      ? 20
                      : label == 'Brands we offer'
                          ? 20
                          : 15,
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
              child: InkWell(
                  onTap: () => {onClickCallBack('Men')},
                  child: Stack(alignment: Alignment.bottomRight, children: [
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
                              'assets/images/men_banner.jpeg',
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ))),
                    Container(
                      padding: EdgeInsets.only(
                          left: desktopView ? 40 : 20,
                          right: desktopView ? 40 : 20,
                          top: 5,
                          bottom: 5),
                      decoration: const BoxDecoration(
                          color: AppColors.cGreenColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8))),
                      child: Text(
                        'Men',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: tabletView ? 30 : 14,
                            color: Colors.white),
                      ),
                    )
                  ]))),
          SizedBox(
            width: desktopView ? 30 : 10,
          ),
          Expanded(
            child: InkWell(
                onTap: () => {onClickCallBack('Women')},
                child: Stack(alignment: Alignment.bottomRight, children: [
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
                            topLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8))),
                    child: Text(
                      'Women',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: tabletView ? 30 : 14,
                          color: Colors.white),
                    ),
                  )
                ])),
          )
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
        child: InkWell(
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
                        'assets/images/men_cloth_banner.png',
                        width: double.infinity,
                        fit: BoxFit.fitHeight,
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
            ])));
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
                const TextSpan(text: 'Best '),
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
            margin: const EdgeInsets.only(top: 18),
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
                    fontSize: tabletView ? 32 : 12,
                    height: 1.2),
                children: <TextSpan>[
                  const TextSpan(text: 'Powered '),
                  TextSpan(
                    text: 'Sunglasses',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: tabletView ? 40 : 14,
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
  final ValueChanged<Map<String, dynamic>> onClickVideo;
  final bool desktopView;

  const ReadyToOrderListWidget({
    Key? key,
    required this.videoHeight,
    required this.videoWidth,
    required this.happyCustomerData,
    required this.onClickVideo,
    required this.desktopView,
  }) : super(key: key);

  @override
  State<ReadyToOrderListWidget> createState() => _ReadyToOrderListWidgetState();
}

class _ReadyToOrderListWidgetState extends State<ReadyToOrderListWidget> {
  late List<FlickManager> flickManagers;
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    flickManagers = widget.happyCustomerData.map((data) {
      // Create the VideoPlayerController
      final videoController =
          VideoPlayerController.network(data.videoUrl ?? '');

      // Create the FlickManager with the videoController
      final flickManager = FlickManager(
          videoPlayerController: videoController
            ..initialize().then((_) {
              // for (int i = 0; i < flickManagers.length; i++) {
              //   _playAndPauseVideo(i);
              // }
              videoController.addListener(_onVideoPlayerChanged);
            }));

      return flickManager;
    }).toList();
  }

  void _playAndPauseVideo(int index) {
    flickManagers[index].flickVideoManager?.videoPlayerController?.play();

    // Delay and then pause the video
    Future.delayed(Duration(milliseconds: 100), () {
      flickManagers[index].flickVideoManager?.videoPlayerController?.pause();
    });
  }

  void _onVideoPlayerChanged() {
    final controller = flickManager.flickVideoManager?.videoPlayerController;
    if (controller != null) {
      if (controller.value.hasError) {
        debugPrint("Video player error: ${controller.value.errorDescription}");
      }
    }
  }

  @override
  void dispose() {
    for (var flickManager in flickManagers) {
      flickManager.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.videoWidth,
      height: widget.videoHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.happyCustomerData.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => widget.onClickVideo({
              'videoUrl': widget.happyCustomerData[index].videoUrl ?? '',
              'thumbnailUrl': widget.happyCustomerData[index].thumbnailUrl,
            }),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: widget.desktopView ? 288 : 180,
                  height: widget.desktopView ? 550 : 300,
                  margin: EdgeInsets.fromLTRB(
                    0,
                    0,
                    index == widget.happyCustomerData.length - 1 ? 0 : 10,
                    0,
                  ),
                  child: widget.happyCustomerData[index].videoUrl != null
                      ? FlickVideoPlayer(
                          flickManager: flickManagers[index],
                          flickVideoWithControls: const FlickVideoWithControls(
                            videoFit: BoxFit.fill,
                            playerLoadingFallback: Center(),
                          ),
                        )
                      : Image.network(
                          widget.happyCustomerData[index].thumbnailUrl!,
                          fit: BoxFit.fill,
                        ),
                ),
                widget.happyCustomerData[index].videoUrl == null
                    ? Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 10, top: 10),
                        width: 100,
                        height: 30,
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, top: 5, bottom: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.8),
                            border: Border.all(
                                width: 1, color: AppColors.cGreenColor)),
                        child: Text(
                          textAlign: TextAlign.center,
                          'View image',
                          style: GoogleFonts.outfit(
                              color: AppColors.cGreenColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(
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
                        ),
                      ),
              ],
            ),
          );
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
        margin: EdgeInsets.only(
            left: tabletView ? 40 : 10, right: tabletView ? 40 : 10),
        child: ResponsiveGridList(
          horizontalGridSpacing: 5,
          verticalGridSpacing: 5,
          horizontalGridMargin: 5,
          verticalGridMargin: 5,
          minItemWidth: 100,
          minItemsPerRow: 1,
          maxItemsPerRow: tabletView ? 2 : 1,
          listViewBuilderOptions: ListViewBuilderOptions(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
          ),
          children: List.generate(
              productFirebaseList.length > 4 ? 4 : productFirebaseList.length,
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
  final void Function(String, String) onViewMoreClick;

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
              String firebaseCollectionName = viewMoreFor == 'Men'
                  ? Endpoints.menOpticalProductList
                  : Endpoints.womenOpticalProductList;
              onViewMoreClick(firebaseCollectionName,
                  viewMoreFor == 'Men' ? 'Men Optical' : 'Women Optical');
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
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Image.asset(
          'assets/images/buy_branded_sunglasses_banner.png',
          width: double.infinity,
          height: tabletView ? 650 : 180,
          fit: BoxFit.fill,
        ));
  }
}

class AboutJpOpticalWidget extends StatefulWidget {
  final bool tabletView, mediumTabletView, mobileView, desktopView;
  final ValueChanged<Map<String, dynamic>> onClickVideo;
  final Widget playIconWidget;
  const AboutJpOpticalWidget(
      {Key? key,
      required this.tabletView,
      required this.mediumTabletView,
      required this.mobileView,
      required this.desktopView,
      required this.onClickVideo,
      required this.playIconWidget})
      : super(key: key);

  @override
  State<AboutJpOpticalWidget> createState() => _AboutJpOpticalWidgetState();
}

class _AboutJpOpticalWidgetState extends State<AboutJpOpticalWidget> {
  bool comingFirstTime = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
          bottom: widget.tabletView ? 40 : 20,
          right: 20,
          left: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // FutureBuilder<List<HappyCustomerFirabaseModel>>(
          //     future: widget.happyCustomerFirebaseList,
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.waiting) {
          //         return Shimmer.fromColors(
          //             baseColor: Colors.grey[300]!,
          //             highlightColor: Colors.grey[100]!,
          //             child: Container(
          //               width: widget.desktopView
          //                   ? 320
          //                   : widget.tabletView
          //                       ? 250
          //                       : 188,
          //               height: widget.tabletView ? 400 : 283,
          //               color: Colors.grey[300]!,
          //             ));
          //       } else if (snapshot.hasError) {
          //         return Center(
          //             child: Container(
          //           alignment: Alignment.center,
          //           color: Colors.grey,
          //           width: widget.desktopView
          //               ? 320
          //               : widget.tabletView
          //                   ? 250
          //                   : 188,
          //           height: widget.tabletView ? 400 : 283,
          //           child: Text(
          //             'Something went wrong...',
          //             style: GoogleFonts.outfit(color: Colors.white),
          //           ),
          //         ));
          //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          //         return Center(
          //             child: Container(
          //           alignment: Alignment.center,
          //           color: Colors.grey,
          //           width: widget.desktopView
          //               ? 320
          //               : widget.tabletView
          //                   ? 250
          //                   : 188,
          //           height: widget.tabletView ? 400 : 283,
          //           child: Text(
          //             'No data found!',
          //             style: GoogleFonts.outfit(color: Colors.white),
          //           ),
          //         ));
          //       } else {
          //         return InkWell(
          //             onTap: () =>
          //                 {widget.onClickVideo(snapshot.data![0].videoUrl)},
          //             child: Stack(alignment: Alignment.center, children: [
          //               Container(
          //                 margin: EdgeInsets.only(
          //                     left: widget.desktopView ? 60 : 10),
          //                 width: widget.desktopView
          //                     ? 320
          //                     : widget.tabletView
          //                         ? 250
          //                         : 180,
          //                 height: widget.tabletView ? 400 : 283,
          //                 child: Image.network(
          //                   snapshot.data![0].thumbnailUrl,
          //                   fit: BoxFit.fill,
          //                 ),
          //               ),
          //               Container(
          //                   margin: EdgeInsets.only(
          //                       left: widget.desktopView ? 60 : 10),
          //                   child: widget.playIconWidget)
          //             ]));
          //       }
          //     }),
          // SizedBox(
          //   width: widget.desktopView
          //       ? 80
          //       : widget.tabletView
          //           ? 30
          //           : 10,
          // ),
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
                        'About JP Opticals',
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
                  SvgPicture.asset('assets/images/sunglass_image_blue.svg',
                      semanticsLabel: 'Sungalass',
                      width: widget.tabletView ? 60 : 30,
                      height: widget.tabletView ? 60 : 30)
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                  width: double.infinity,
                  child: Text(
                    "At JP OPTICALS, we are dedicated to providing you with the highest quality optical products, watches, men's clothing, and accessories. Our mission is to help you see better and look great. With years of experience in the optical, watch, and fashion industry, we pride ourselves on offering exceptional customer service and a wide range of products to suit every style and need. Whether you're looking for the perfect pair of glasses, a stylish watch, or the latest in men's fashion, JP OPTICALS has you covered.",
                    style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w400,
                        fontSize: widget.tabletView ? 16 : 12,
                        color: Colors.black),
                  ))
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
  final ValueChanged<Map<String, dynamic>> onClickCallBack;
  const Footer({Key? key, required this.onClickCallBack}) : super(key: key);

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
                onPressed: () => onClickCallBack({
                  'action': 'close',
                }),
              ),
              IconButton(
                icon: Image.asset(
                  'assets/icons/instagram_icon.png',
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
              // IconButton(
              //   icon: Image.asset(
              //     'assets/icons/snapchat.png',
              //     height: 20,
              //     width: 20,
              //   ),
              //   onPressed: () => redirectUri('', 'snapchat', ''),
              // ),
              // IconButton(
              //   icon: SvgPicture.asset(
              //     'assets/icons/youtube_icon.svg',
              //     height: 20,
              //     width: 20,
              //   ),
              //   onPressed: () => redirectUri('', 'youtube', ''),
              // ),
            ],
          ),
          Text('© ${DateTime.now().year} JP Opticals. All rights reserved.',
              style: GoogleFonts.outfit(
                color: Colors.grey[700],
                fontSize: 10,
              ))
        ]));
  }
}
