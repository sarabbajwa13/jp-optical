import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jp_optical/Widgets/image_viewer.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/local_storage/cart_service.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:provider/provider.dart';

class ProductItemWidget extends StatefulWidget {
  final bool tabletView,
      mediumTabletView,
      desktopView,
      isHorizontalList,
      routeFromHomeScreen;
  final ProductItemFirebaseModel bestSellerFirebaseList;
  final ValueChanged<Map<String, dynamic>> onClickCallBack;

  const ProductItemWidget(
      {Key? key,
      required this.tabletView,
      required this.mediumTabletView,
      required this.desktopView,
      required this.isHorizontalList,
      required this.bestSellerFirebaseList,
      required this.onClickCallBack,
      required this.routeFromHomeScreen})
      : super(key: key);

  @override
  State<ProductItemWidget> createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends State<ProductItemWidget> {
  String? selectedSize;

  void _showSizeAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Size not selected"),
          content: Text("Please select a size before proceeding."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget elevatedBtnWidget(Color bgColor, Color txtColor, String label) {
      return ElevatedButton(
        onPressed: () {
          if (selectedSize == null &&
              widget.bestSellerFirebaseList.size != null) {
            _showSizeAlertDialog(context);
            return;
          }
          if (label == 'Add to cart') {
            Provider.of<CartService>(context, listen: false)
                .addToCart(widget.bestSellerFirebaseList, selectedSize);
            widget.onClickCallBack({
              'action': 'cart',
              'productId': widget.bestSellerFirebaseList.productId,
              'productTitle': widget.bestSellerFirebaseList.productTitle,
              'productImage': widget.bestSellerFirebaseList.productImage,
              'productSize': selectedSize,
              'createdBy': widget.bestSellerFirebaseList.createdBy,
            });
          } else {
            widget.onClickCallBack({
              'action': 'get details',
              'productId': widget.bestSellerFirebaseList.productId,
              'productTitle': widget.bestSellerFirebaseList.productTitle,
              'productImage': widget.bestSellerFirebaseList.productImage,
              'productSize': selectedSize ?? '',
              'createdBy': widget.bestSellerFirebaseList.createdBy,
            });
          }
        },
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: widget.desktopView ? 30 : 5,
              right: widget.desktopView ? 30 : 5,
              top: widget.desktopView ? 20 : 0,
              bottom: widget.desktopView ? 20 : 0),
          backgroundColor: bgColor,
          side: BorderSide(
            color: AppColors.cGreenColor,
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        child: Text(
          textAlign: TextAlign.center,
          maxLines: 1,
          label,
          style: GoogleFonts.outfit(
            color: txtColor,
            fontWeight: FontWeight.w600,
            fontSize: widget.desktopView
                ? 20
                : widget.tabletView
                    ? 18
                    : 12,
          ),
        ),
      );
    }

    var buttonWidget = <Widget>[
      Container(
          width: widget.desktopView || widget.tabletView
              ? null
              : MediaQuery.of(context).size.width,
          child: widget.tabletView
              ? Expanded(
                  child: elevatedBtnWidget(
                      AppColors.cGreenColor, Colors.white, 'Get details'))
              : elevatedBtnWidget(
                  AppColors.cGreenColor, Colors.white, 'Get details')),
      SizedBox(
        height: 10,
        width: widget.desktopView
            ? 20
            : widget.tabletView
                ? 10
                : 0,
      ),
      Container(
          width: widget.desktopView || widget.tabletView
              ? null
              : MediaQuery.of(context).size.width,
          child: widget.tabletView
              ? Expanded(
                  child: elevatedBtnWidget(
                      Colors.white, AppColors.cGreenColor, 'Add to cart'))
              : elevatedBtnWidget(
                  Colors.white, AppColors.cGreenColor, 'Add to cart'))
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          width: widget.desktopView && !widget.isHorizontalList
              ? null
              : widget.desktopView && widget.isHorizontalList
                  ? 500
                  : (widget.isHorizontalList && !widget.desktopView)
                      ? 300
                      : double.infinity,
          margin: EdgeInsets.all(widget.tabletView ? 10 : 5),
          padding: EdgeInsets.all(widget.desktopView ? 20 : 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            border: Border.all(
              color: Colors.black.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  widget.bestSellerFirebaseList.productId.isNotEmpty
                      ? Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.cGreenColor.withOpacity(0.2),
                          ),
                          child: Text(
                            widget.bestSellerFirebaseList.productId,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: widget.tabletView ? 20 : 12,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => {
                      widget.onClickCallBack({
                        'action': 'imageUrl',
                        'imageUrl': widget.bestSellerFirebaseList.productImage
                      })
                    },
                    child: Container(
                      width: widget.desktopView
                          ? 420
                          : widget.isHorizontalList
                              ? 300
                              : null,
                      height: widget.desktopView
                          ? 300
                          : widget.isHorizontalList
                              ? 250
                              : null,
                      margin:
                          EdgeInsets.only(top: widget.desktopView ? 30 : 10),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/loading.gif',
                        image: widget.bestSellerFirebaseList.productImage,
                        fit: BoxFit.fill,
                        fadeInDuration: Duration(milliseconds: 300),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      widget.bestSellerFirebaseList.productTitle,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        fontSize: widget.tabletView ? 16 : 12,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  widget.bestSellerFirebaseList.productDesc!.isNotEmpty
                      ? Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            maxLines: 4,
                            textAlign: TextAlign.start,
                            widget.bestSellerFirebaseList.productDesc!,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.normal,
                              fontSize: widget.tabletView ? 16 : 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : Container(),
                  widget.bestSellerFirebaseList.size != null
                      ? Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          height: 60,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    widget.bestSellerFirebaseList.size!.length,
                                itemBuilder: (context, index) {
                                  final size = widget
                                      .bestSellerFirebaseList.size![index];
                                  final isSelected = size == selectedSize;

                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedSize = size;
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10),
                                      height: 40,
                                      width: 40,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.cGreenColor
                                              : Colors.grey,
                                          width: 2.0,
                                        ),
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppColors.cGreenColor
                                                .withOpacity(0.2)
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        size.toString(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ))
                            ],
                          ),
                        )
                      : const Center(),
                  widget.desktopView || widget.tabletView
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: buttonWidget)
                      : Column(
                          mainAxisSize: MainAxisSize.max,
                          children: buttonWidget),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
