import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:jp_optical/Widgets/custom_dialog.dart';
import 'package:jp_optical/Widgets/redirect_uri.dart';
import 'package:jp_optical/colors/app_color.dart';
import 'package:jp_optical/local_storage/cart_service.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  final ValueChanged<String> onCloseCallBack;
  const CartScreen({super.key, required this.onCloseCallBack});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<ProductItemFirebaseModel> _cartItems = [];
  @override
  void initState() {
    super.initState();
    debugPrint('sarab ji ');
    _loadCartItems();
  }

  void _loadCartItems() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final cartService = Provider.of<CartService>(context, listen: false);
      await cartService.loadCartItems(); // Load items and notify listeners
      setState(() {
        _cartItems = cartService.cartItems; // Access items from CartService
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading cart items: $e');
    }
  }

  // void addItemToCart(ProductItemFirebaseModel item) async {
  //   try {
  //     final currentCartItems = await CartService.loadCartItems();
  //     final existingItemIndex = currentCartItems
  //         .indexWhere((cartItem) => cartItem.productId == item.productId);

  //     if (existingItemIndex == -1) {
  //       // Item does not exist, add it to the cart
  //       currentCartItems.add(item);
  //       await CartService.saveCartItems(currentCartItems);
  //       debugPrint('Item added to cart: ${item.toMap()}');
  //     } else {
  //       debugPrint(
  //           'Item with productId ${item.productId} already exists in cart');
  //     }

  //     // Print cart items after adding
  //     final updatedCartItems = await CartService.loadCartItems();
  //     debugPrint(
  //         'Cart items after adding: ${updatedCartItems.map((item) => item.toMap()).toList()}');
  //   } catch (e) {
  //     debugPrint('Error adding item to cart: $e');
  //   }
  // }

  void _updateQuantity(ProductItemFirebaseModel item, int change) async {
    setState(() {
      item.quantity += change;
      if (item.quantity < 1) {
        item.quantity = 1;
      }
    });
    Provider.of<CartService>(context, listen: false).saveCartItems(_cartItems);
    // await CartService.saveCartItems(_cartItems);
  }

  void _removeItem(ProductItemFirebaseModel item) async {
    setState(() {
      _cartItems.remove(item);
    });
    Provider.of<CartService>(context, listen: false).saveCartItems(_cartItems);
    // await CartService.saveCartItems(_cartItems);
  }

  void _clearCart() async {
    setState(() {
      _cartItems.clear();
    });
    Provider.of<CartService>(context, listen: false).saveCartItems(_cartItems);
  }

  Future<void> handleClickOnWhatsAppNumber(Map<String, dynamic> data) async {
    String action = data['action'];
    switch (action) {
      case 'close':
        Navigator.of(context).pop();
        break;
      default:
        Navigator.of(context).pop();
        final cartService = Provider.of<CartService>(context, listen: false);
        await cartService.loadCartItems();
        final items = cartService.cartItems;
        final itemsJson =
            jsonEncode(items.map((item) => item.toMap()).toList());

        redirectUri(action, 'orderThroghWhatsApp', itemsJson);
        setState(() {
          _clearCart();
          widget.onCloseCallBack('desktopView');
        });
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
          onConfirm: handleClickOnWhatsAppNumber,
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

  void _printStoredData() async {
    try {
      showAnimatedDialog(context, {}, '');
    } catch (e) {
      print('Error printing stored data: $e');
    }
  }

  bool _isLoading = true;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var mobileView = screenSize.width < 600;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              border: Border.all(
                  color: mobileView
                      ? Colors.transparent
                      : Colors.black.withOpacity(0.3),
                  width: mobileView ? 0 : 2)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'YOUR CART (${_cartItems.length})',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => {widget.onCloseCallBack('desktopView')},
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 30,
                        ),
                      )),
                ],
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.black.withOpacity(0.2),
                width: double.infinity,
                height: 1,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? Expanded(
                      child: Center(),
                    )
                  : _cartItems.isNotEmpty
                      ? Expanded(
                          child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context)
                                  .copyWith(scrollbars: false),
                              child: ListView.builder(
                                itemCount: _cartItems
                                    .length, // Number of items you want
                                itemBuilder: (context, index) {
                                  final item = _cartItems[index];
                                  return cartItemWidget(context, item,
                                      _updateQuantity, _removeItem);
                                },
                              )),
                        )
                      : Expanded(
                          child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'Cart is empty...',
                            style: GoogleFonts.outfit(
                                color: Colors.grey, fontSize: 20),
                          ),
                        )),
              _cartItems.isNotEmpty
                  ? footerWidget(context, _printStoredData)
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}

Widget cartItemWidget(
    BuildContext context,
    ProductItemFirebaseModel item,
    Function(ProductItemFirebaseModel, int) updateQuantity,
    Function(ProductItemFirebaseModel) removeItem) {
  return Container(
      margin: const EdgeInsets.only(top: 20),
      child: Column(children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              child: Image.network(
                item.productImage,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 65,
                    child: Text(item.productTitle,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.black,
                        )),
                  ),
                  SizedBox(height: 15),
                   Text(item.selectedSize != null ? 'Size: ${item.selectedSize.toString()}' : '',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.black,
                        )),
                   
                  SizedBox(height: 15),
                  Row(
                    children: [
                      MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                              onTap: () => {updateQuantity(item, -1)},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  '-',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ))),
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: Colors.black.withOpacity(0.2),
                                width: 1.0),
                            bottom: BorderSide(
                                color: Colors.black.withOpacity(0.2),
                                width: 1.0),
                          ),
                        ),
                        child: Text(
                          '${item.quantity}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                              onTap: () => {updateQuantity(item, 1)},
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black.withOpacity(0.2),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  '+',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ))),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                        onTap: () => {removeItem(item)},
                        child: Text(
                          'Remove',
                          style: GoogleFonts.outfit(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        )))
              ],
            )
          ],
        ),
        const SizedBox(height: 30),
        Container(
          margin: const EdgeInsets.only(left: 40, right: 40),
          color: Colors.black.withOpacity(0.2),
          height: 1,
          width: double.infinity,
        ),
      ]));
}

Widget footerWidget(BuildContext context, Function() onPressed) {
  return Container(
    width: double.infinity,
    margin: EdgeInsets.only(top: 20, bottom: 5),
    child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.only(top: 20, bottom: 20),
          backgroundColor: AppColors.cGreenColor,
          side: const BorderSide(color: AppColors.cGreenColor, width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text('Get Details',
            style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12))),
  );
}
