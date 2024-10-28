class FrameCategory {
  final String categoryId;
  final String categoryName;

  FrameCategory({
    required this.categoryId,
    required this.categoryName,
  });

  factory FrameCategory.fromJson(Map<String, dynamic> json) {
    return FrameCategory(
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'] ?? '',
    );
  }
}
