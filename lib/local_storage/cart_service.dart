import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
import 'package:hive/hive.dart';

class CartService extends ChangeNotifier {
  static const _cartKey = 'cart_items';
  static final Box cartBox = Hive.box('cartBox');
  List<ProductItemFirebaseModel> _cartItems = [];

  // Getter to access cart items
  List<ProductItemFirebaseModel> get cartItems => _cartItems;

  bool get isEmptyCart => _cartItems.isEmpty;

  Future<void> loadCartItems() async {
    try {
      final itemsJson = cartBox.get(_cartKey);
      debugPrint('sarab Loading items from local storage: $itemsJson');
      if (itemsJson != null) {
        final List<dynamic> itemsList = jsonDecode(itemsJson);
        _cartItems = itemsList.map((item) => ProductItemFirebaseModel.fromMap(Map<String, dynamic>.from(item))).toList();
        notifyListeners(); // Notify listeners after loading items
      }
    } catch (e) {
      debugPrint('sarab Error loading items: $e');
    }
  }

  Future<void> saveCartItems(List<ProductItemFirebaseModel> items) async {
    try {
      final itemsJson = jsonEncode(items.map((item) => item.toMap()).toList());
      debugPrint('sarab Saving items to local storage: $itemsJson'); // Debugging
      await cartBox.put(_cartKey, itemsJson);
      _cartItems = items; // Update the in-memory list
      notifyListeners(); // Notify listeners after saving items
      debugPrint('sarab Items successfully saved'); // Debugging
    } catch (e) {
      debugPrint('sarab Error saving items: $e'); // Debugging
    }
  }

  void addToCart(ProductItemFirebaseModel item, String? selectedSize) async {
    item.selectedSize = selectedSize; 
    final existingItemIndex = _cartItems.indexWhere((cartItem) => cartItem.createdBy == item.createdBy && cartItem.selectedSize == selectedSize);

    if (existingItemIndex == -1) {
      _cartItems.add(item);
      await saveCartItems(_cartItems);
      debugPrint('Item added to cart: ${item.toMap()}');
    } else {
      debugPrint('Item with productId ${item.createdBy} and size $selectedSize already exists in cart');
    }
    notifyListeners();
  }

  void removeFromCart(ProductItemFirebaseModel item) async {
    _cartItems.removeWhere((cartItem) => cartItem.createdBy == item.createdBy && cartItem.selectedSize == item.selectedSize);
    await saveCartItems(_cartItems);
    notifyListeners(); // Notify listeners to update UI
  }
}
