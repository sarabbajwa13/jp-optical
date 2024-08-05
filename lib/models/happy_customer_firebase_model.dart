import 'package:cloud_firestore/cloud_firestore.dart';

class HappyCustomerFirabaseModel { 
  final String? thumbnailUrl;
  final String? videoUrl;
  final Timestamp? createdBy;

  HappyCustomerFirabaseModel({ 
    this.thumbnailUrl,
    this.videoUrl,
    this.createdBy,
  });

  factory HappyCustomerFirabaseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HappyCustomerFirabaseModel( 
      thumbnailUrl: data.containsKey('thumbnailUrl') ? data['thumbnailUrl'] as String? : null,
      videoUrl: data.containsKey('videoUrl') ? data['videoUrl'] as String? : null,
      createdBy: data['createdBy'] is Timestamp ? data['createdBy'] as Timestamp? : null,
    );
  }
}
