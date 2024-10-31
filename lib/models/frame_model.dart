// frame_model.dart
class FrameModel {
  final String categoryId;
  final String wedFrameId;
  final String frameImage;

  FrameModel({
    required this.categoryId,
    required this.wedFrameId,
    required this.frameImage,
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      categoryId: json['cat_id'] ?? '',
      wedFrameId: json['wed_frame_id'] ?? '',
      frameImage: json['frame_image'] ?? '',
    );
  }
  FrameModel copyWith({String? frameImage}) {
    return FrameModel(
      frameImage: frameImage ?? this.frameImage,
      categoryId: '',
      wedFrameId: '',
      // Copy other fields as needed
    );
  }
}
