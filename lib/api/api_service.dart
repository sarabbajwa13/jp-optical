import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:jp_optical/constants/endpoints.dart';
import 'package:jp_optical/models/banner_carousel_model.dart'; 
import 'package:jp_optical/models/happy_customer_firebase_model.dart';
import 'package:jp_optical/models/product_category_model.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  Future<List<HappyCustomerFirabaseModel>>
      fetchHappyCustomerListFromFirebase() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(Endpoints.happyCustomerList).get();
    return querySnapshot.docs
        .map((doc) => HappyCustomerFirabaseModel.fromDocument(doc))
        .toList();
  }

  Future<List<ProductItemFirebaseModel>>
      fetchBestSellersListFromFirebase() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(Endpoints.bestSellersList).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }

  // Future<List<HappyCustomerFirabaseModel>>
  //     fetchReadyToOrderListFromFirebase() async {
  //   QuerySnapshot querySnapshot =
  //       await _firestore.collection(Endpoints.readyToOrderList).get();
  //   return querySnapshot.docs
  //       .map((doc) => HappyCustomerFirabaseModel.fromDocument(doc))
  //       .toList();
  // }

  Future<List<ProductItemFirebaseModel>>
      fetchMenOpticalProductListFromFirebase() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(Endpoints.menOpticalProductList).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }

  Future<List<ProductItemFirebaseModel>>
      fetchWomenOpticalProductListFromFirebase() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(Endpoints.womenOpticalProductList).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }

  Future<List<ProductCategoryFirebaseModel>>
      fetchMenClothCategoryListFromFirebase(String collectionName) async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(collectionName).get();
    return querySnapshot.docs
        .map((doc) => ProductCategoryFirebaseModel.fromDocument(doc))
        .toList();
  }

  Future<List<ProductItemFirebaseModel>> fetchProductListFromFirebase(
      String collectionName) async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(collectionName).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }

  Future<Map<String, dynamic>> fetchProductListFromFirebase1({required String collectionName, DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _firestore
        .collection(collectionName)
        .orderBy('createdBy', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<ProductItemFirebaseModel> products = querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
    DocumentSnapshot? lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

    return {
      'products': products,
      'lastDocument': lastDocument,
    };
  }

Future<Map<String, dynamic>> fetchReadyToOrderListFromFirebase({required String collectionName, DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _firestore
        .collection(collectionName)
        .orderBy('createdBy', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    QuerySnapshot querySnapshot = await query.get();
    List<HappyCustomerFirabaseModel> products = querySnapshot.docs
        .map((doc) => HappyCustomerFirabaseModel.fromDocument(doc))
        .toList();
    DocumentSnapshot? lastDocument = querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;

    return {
      'products': products,
      'lastDocument': lastDocument,
    };
  }

  Future<List<BannerCarouselModel>>
      fetchBannerCarouselListFromFirebase() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(Endpoints.bannerCarouselList).get();
    return querySnapshot.docs
        .map((doc) => BannerCarouselModel.fromDocument(doc))
        .toList();
  }

  Future<List<BannerCarouselModel>>
      fetchBannerBelowBestSellerFromFirebase() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(Endpoints.bannerBelowBestSeller).get();
    return querySnapshot.docs
        .map((doc) => BannerCarouselModel.fromDocument(doc))
        .toList();
  }
}
