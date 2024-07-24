import 'package:cloud_firestore/cloud_firestore.dart';

class HappyCustomerFirabaseModel { 
  final String thumbnailUrl;
  final String videoUrl;
  final Timestamp createdBy;

  HappyCustomerFirabaseModel({ 
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.createdBy,
  });

  factory HappyCustomerFirabaseModel.fromDocument(DocumentSnapshot doc) {
    return HappyCustomerFirabaseModel( 
      thumbnailUrl: doc['thumbnailUrl'],
      videoUrl: doc['videoUrl'],
      createdBy: doc['createdBy'] as Timestamp,
    );
  }
}
