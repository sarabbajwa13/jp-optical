import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductItemFirebaseModel {
  final String productId;
  final String productImage;
  final String productTitle;
  final String? productDesc;
  final Timestamp createdBy;
  List<String>? size; 
  int quantity;
  String? selectedSize;

  ProductItemFirebaseModel({
    required this.productId,
    required this.productImage,
    required this.productTitle,
    this.productDesc,
    required this.createdBy,
    this.size,  
    this.quantity = 1,
    this.selectedSize,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productImage': productImage,
      'productTitle': productTitle,
      'createdBy': createdBy.toDate().toIso8601String(),
      'size': size ?? [],  
      'quantity': quantity,
      'selectedSize': selectedSize,  // Add this line
    };
  }

  factory ProductItemFirebaseModel.fromMap(Map<String, dynamic> map) {
    return ProductItemFirebaseModel(
      productId: map['productId'],
      productImage: map['productImage'],
      productTitle: map['productTitle'],
      createdBy: Timestamp.fromDate(DateTime.parse(map['createdBy'])),
      size: map['size'] != null 
          ? List<String>.from(map['size']) 
          : null, 
      quantity: map['quantity'] ?? 1,
      selectedSize: map['selectedSize'],  // Add this line
    );
  }

  factory ProductItemFirebaseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;  
    return ProductItemFirebaseModel(
      productId: data['productId'] ?? '',
      productImage: data['productImage'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productDesc: data['productDesc'] ?? '',
      createdBy: data['createdBy'] as Timestamp,
      size: data.containsKey('size') && data['size'] != null
          ? List<String>.from(data['size'])
          : null,  
      quantity: data['quantity'] ?? 1,
      selectedSize: data['selectedSize'],  // Add this line
    );
  }

  String toJson() => jsonEncode(toMap());
}
