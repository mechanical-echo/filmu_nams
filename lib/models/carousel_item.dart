class CarouselItemModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;

  CarouselItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
  });

  factory CarouselItemModel.fromMap(Map<String, dynamic> map) {
    return CarouselItemModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['image-url'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image-url': imageUrl,
      'description': description,
    };
  }
}
