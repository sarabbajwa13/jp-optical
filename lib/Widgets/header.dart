import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/Widgets/redirect_uri.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/local_storage/cart_service.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  final bool showBackArrow;
  final ValueChanged<String> onClickHamburger;
  final bool showCart;
  final routeFromHome;
  const Header(
      {super.key,
      required this.onClickHamburger,
      required this.showCart,
      required this.showBackArrow,
      required this.routeFromHome});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() async {
    await Provider.of<CartService>(context, listen: false).loadCartItems();
  }

  Widget cartIcon(CartService cartService, bool tabletView) {
    final isEmptyCart = cartService.isEmptyCart;
    return Image.asset(
      isEmptyCart
          ? 'assets/icons/empty_cart_icon.png'
          : 'assets/icons/not_empty_cart_icon.png',
      width: isEmptyCart & tabletView
          ? 40
          : !isEmptyCart & tabletView
              ? 40
              : 30,
      height: isEmptyCart & tabletView
          ? 40
          : !isEmptyCart & tabletView
              ? 40
              : 30,
      color: isEmptyCart ? Colors.white : null,
      colorBlendMode: isEmptyCart ? BlendMode.srcIn : null,
    );
  }

  Widget hamburgerWidget(BuildContext cart, bool tabletView) {
    return (Container(
      decoration: BoxDecoration(
          color: AppColors.cGreenColor, borderRadius: BorderRadius.circular(2)),
      child: Icon(
        Icons.menu,
        color: Colors.white,
        size: tabletView ? 40 : 30,
      ),
    ));
  }

  Widget backArrowWidget(BuildContext cart) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
      onPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var tabletView = screenSize.width > 600;
    return Consumer<CartService>(builder: (context, cartService, child) {
      return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: widget.routeFromHome && tabletView ? 20 : 10),
          color: AppColors.blackColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                  onTap: () => {widget.onClickHamburger('show_drawer')},
                  child: hamburgerWidget(context, tabletView)),
              Expanded(
                  child: Container(
                      margin: EdgeInsets.only(left: tabletView ? 0 : 35),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: tabletView ? 13 : 10),
                            child: SvgPicture.asset(
                              'assets/images/glass_icon_header.svg',
                              width: tabletView ? null : 40,
                            ),
                          ),
                          SizedBox(width: tabletView ? 10 : 5),
                          SizedBox(
                              width: 170,
                              child: Stack(
                                alignment: Alignment.centerRight,
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      child: Text('JP Opticals',
                                          style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: tabletView ? 23 : 18))),
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: tabletView ? 40 : 35,
                                          right: tabletView ? 10 : 45),
                                      child: Text('By RJ Brothers',
                                          style: GoogleFonts.allura(
                                              color: AppColors.cGreenColor,
                                              fontWeight: FontWeight.normal,
                                              fontSize: tabletView ? 18 : 15))),
                                ],
                              ))
                        ],
                      ))),
              InkWell(
                  onTap: () => {widget.onClickHamburger('show_cart')},
                  child: cartIcon(cartService, tabletView)),
            ],
          ));
    });
  }
}
