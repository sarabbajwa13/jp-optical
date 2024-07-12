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

    Widget cartIcon(CartService cartService){
       final isEmptyCart = cartService.isEmptyCart;
      return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SvgPicture.asset(
        isEmptyCart ? 'assets/icons/empty_cart_icon.svg' : 'assets/icons/not_empty_cart_icon.svg',
        semanticsLabel: 'Cart',
        width: isEmptyCart ? 25 : 30,
        height: isEmptyCart ? 25 : 30,
colorFilter: isEmptyCart ? const ColorFilter.mode(Colors.white, BlendMode.srcIn) : null,
      ));
    }

  Widget hamburgerWidget(BuildContext cart) {
    return (Container( 
      decoration: BoxDecoration(
          color: AppColors.cGreenColor, borderRadius: BorderRadius.circular(2)),
      child: const Icon(
        Icons.menu,
        color: Colors.white,
        size: 30,
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
    return Consumer<CartService>(
      builder: (context, cartService, child) {
        return Column(children: [
      Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal:  widget.routeFromHome ? 20 : 5, vertical: widget.routeFromHome  ? 20 : tabletView ? 20 : 5),
          color: AppColors.blackColor,
          child: Stack(
            alignment: tabletView ? Alignment.center : Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // tabletView
                  //     ? ElevatedButton(
                  //         onPressed: () {
                  //           redirectUri('', 'normalWhatsAppContact', '');
                  //         },
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.transparent,
                  //           side: const BorderSide(
                  //               color: AppColors.cGreenColor, width: 1.0),
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(55.0),
                  //           ),
                  //         ),
                  //         child: Text('Get Direction',
                  //             style: GoogleFonts.outfit(
                  //                 color: Colors.white,
                  //                 fontWeight: FontWeight.w400,
                  //                 fontSize: 20)))
                  //     : Container(),
                  const SizedBox(width: 20),
                  widget.showCart
                      ? GestureDetector(
                          onTap: () => {widget.onClickHamburger('show_cart')},
                          child:  
                          cartIcon(cartService))
                      : GestureDetector(
                          onTap: () => {widget.onClickHamburger('show_drawer')},
                          child: hamburgerWidget(context)),
                          widget.showCart ? const SizedBox(width: 10) : Container(),
                ],
              ),
              widget.showBackArrow
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [backArrowWidget(context)])
                  : Container(),
              Text('RJ Brothers',
                  style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: tabletView ? 32 : 20)),
            ],
          )),
      Container(
          color: Colors.black.withOpacity(0.8),
          width: double.infinity,
          height: 1)
    ]);});
  }
}
