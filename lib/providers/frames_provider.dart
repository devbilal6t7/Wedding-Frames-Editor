import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/frame_model.dart';

class FramesProvider with ChangeNotifier {
  final Map<String, List<FrameModel>> _categoryFrames = {};

  List<FrameModel> getFrames(String categoryId) {
    return _categoryFrames[categoryId] ?? [];
  }

  Future<void> fetchFrames(String categoryId) async {
    final url = Uri.parse("https://digitalprimeagency.com/zoncoapps/weddingframeseditor/Response.php");

    try {
      final response = await http.post(
        url,
        body: {
          'cat_id': categoryId,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> framesData = data['wedlist'] ?? [];

        // Parse each frame and store in map based on categoryId
        _categoryFrames[categoryId] = framesData.map((item) => FrameModel.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception("Failed to load frames");
      }
    } catch (error) {
      throw error;
    }
  }
}
