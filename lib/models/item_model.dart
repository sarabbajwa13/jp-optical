class Item {
  final String title;
  final String callback;
  final String imageUrl;

  Item({
    required this.title,
    required this.callback,
    required this.imageUrl,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      title: json['title'] ?? '',
      callback: json['callback'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
