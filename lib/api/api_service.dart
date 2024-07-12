import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:jp_optical/constants/endpoints.dart';
import 'package:jp_optical/models/happy_customer_model.dart';
import 'package:jp_optical/models/happy_customer_firebase_model.dart';
import 'package:jp_optical/models/product_category_model.dart';
import 'package:jp_optical/models/product_item_firebase_model.dart';
 

class ApiService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String apiUrl = 'http://localhost:3000/api/HappyCustomer';

  Future<List<HappyCustomerModel>> fetchHappyCustomerData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Decode the JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      // Check if the response indicates success
      if (jsonResponse['success'] == true) {
        // Extract the data array
        List<dynamic> dataList = jsonResponse['data'];
        
        // Convert the list of maps into a list of HappyCustomerModel
        return dataList.map((json) => HappyCustomerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load happy customers: ${jsonResponse['message']}');
      }
    } else {
      throw Exception('Failed to load happy customers');
    }
  }

   Future<List<HappyCustomerFirabaseModel>> fetchHappyCustomerListFromFirebase() async {
    QuerySnapshot querySnapshot = await _firestore.collection(Endpoints.happyCustomerList).get();
    return querySnapshot.docs
        .map((doc) => HappyCustomerFirabaseModel.fromDocument(doc))
        .toList();
  }
  Future<List<ProductItemFirebaseModel>> fetchBestSellersListFromFirebase() async {
    QuerySnapshot querySnapshot = await _firestore.collection(Endpoints.bestSellersList).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }
  Future<List<HappyCustomerFirabaseModel>> fetchReadyToOrderListFromFirebase() async {
    QuerySnapshot querySnapshot = await _firestore.collection(Endpoints.readyToOrderList).get();
    return querySnapshot.docs
        .map((doc) => HappyCustomerFirabaseModel.fromDocument(doc))
        .toList();
  }
   Future<List<ProductItemFirebaseModel>> fetchMenProductListFromFirebase() async {
    QuerySnapshot querySnapshot = await _firestore.collection(Endpoints.menOpticalProductList).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }
  Future<List<ProductItemFirebaseModel>> fetchwomenProductListFromFirebase() async {
    QuerySnapshot querySnapshot = await _firestore.collection(Endpoints.womenOpticalProductList).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }
  Future<List<HappyCustomerFirabaseModel>> fetchAboutShopFirebaseVideoFromFirebase() async {
    QuerySnapshot querySnapshot = await _firestore.collection(Endpoints.aboutShopVideo).get();
    return querySnapshot.docs
        .map((doc) => HappyCustomerFirabaseModel.fromDocument(doc))
        .toList();
  }
   Future<List<ProductCategoryFirebaseModel>> fetchMenClothCategoryListFromFirebase(String collectionName) async {
    QuerySnapshot querySnapshot = await _firestore.collection(collectionName).get();
    return querySnapshot.docs
        .map((doc) => ProductCategoryFirebaseModel.fromDocument(doc))
        .toList();
  }

   Future<List<ProductItemFirebaseModel>> fetchMenJacektListFromFirebase(String collectionName) async {
    QuerySnapshot querySnapshot = await _firestore.collection(collectionName).get();
    return querySnapshot.docs
        .map((doc) => ProductItemFirebaseModel.fromDocument(doc))
        .toList();
  }
}
