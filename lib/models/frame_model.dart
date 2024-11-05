// frame_model.dart
class FrameModel {
  final String categoryId;
  final String wedFrameId;
  final String frameImage;
  final String type; // Replaced description with type

  FrameModel({
    required this.categoryId,
    required this.wedFrameId,
    required this.frameImage,
    required this.type, // Initialize type
  });

  // Factory constructor to create an instance from JSON
  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      categoryId: json['cat_id'] ?? '',
      wedFrameId: json['wed_frame_id'] ?? '',
      frameImage: json['frame_image'] ?? '',
      type: json['type'] ?? '', // Parse type from JSON
    );
  }

  // CopyWith method to update specific fields
  FrameModel copyWith({
    String? categoryId,
    String? wedFrameId,
    String? frameImage,
    String? type,
  }) {
    return FrameModel(
      categoryId: categoryId ?? this.categoryId,
      wedFrameId: wedFrameId ?? this.wedFrameId,
      frameImage: frameImage ?? this.frameImage,
      type: type ?? this.type, // Allow updating type
    );
  }

  // Method to convert FrameModel instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'cat_id': categoryId,
      'wed_frame_id': wedFrameId,
      'frame_image': frameImage,
      'type': type, // Include type in JSON
    };
  }
}
