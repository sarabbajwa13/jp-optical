import 'package:flutter/material.dart';

class AddToCartProductModel {
  final String productId;
  final String productImage;
  final String productTitle;

  AddToCartProductModel({
    required this.productId,
    required this.productImage,
    required this.productTitle
  });

  // Convert a Product instance to a map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productImage': productImage,
      'productTitle': productTitle
    };
  }

  // Convert a map to a Product instance
  factory AddToCartProductModel.fromMap(Map<String, dynamic> map) {
    return AddToCartProductModel(
      productId: map['productId'] ?? '',
      productImage: map['productImage'] ?? '',
      productTitle: map['productTitle'] ?? ''
    );
  }
}
