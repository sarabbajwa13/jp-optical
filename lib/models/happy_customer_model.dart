class HappyCustomerModel {
  final String id;
  final String thumbnailUrl;
  final String videoUrl;

  HappyCustomerModel({
    required this.id,
    required this.thumbnailUrl,
    required this.videoUrl,
  });

  factory HappyCustomerModel.fromJson(Map<String, dynamic> json) {
    return HappyCustomerModel(
      id: json['_id'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
    };
  }

  @override
  String toString() {
    return 'HappyCustomerModel{id: $id, thumbnailUrl: $thumbnailUrl, videoUrl: $videoUrl}';
  }
}
