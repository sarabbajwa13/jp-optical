import 'package:cloud_firestore/cloud_firestore.dart';

class BannerCarouselModel {
  final String banner;

  BannerCarouselModel({
    required this.banner,
  });

  Map<String, dynamic> toMap() {
    return {
      'banner': banner,
    };
  }

  factory BannerCarouselModel.fromMap(Map<String, dynamic> map) {
    return BannerCarouselModel(banner: map['banner']);
  }

  factory BannerCarouselModel.fromDocument(DocumentSnapshot doc) {
    return BannerCarouselModel(banner: doc['banner']);
  }
}
