import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCategoryFirebaseModel {
  final String productImage;
  final String productTitle; 
  final String productListName; 
  

  ProductCategoryFirebaseModel({ 
    required this.productImage,
    required this.productTitle,
    required this.productListName
  });

  Map<String, dynamic> toMap() {
    return { 
      'productImage': productImage,
      'productTitle': productTitle,
      'productListName': productListName,
    };
  }

  factory ProductCategoryFirebaseModel.fromMap(Map<String, dynamic> map) {
    return ProductCategoryFirebaseModel( 
      productImage: map['productImage'],
      productTitle: map['productTitle'],
      productListName: map['productListName'],
    );
  }

  factory ProductCategoryFirebaseModel.fromDocument(DocumentSnapshot doc) {
    return ProductCategoryFirebaseModel( 
      productImage: doc['productImage'],
      productTitle: doc['productTitle'],
      productListName: doc['productListName'],
    );
  }
}
