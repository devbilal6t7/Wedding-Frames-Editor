import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/frame_category_model.dart';

class CategoryProvider with ChangeNotifier {
  List<FrameCategory> _categories = [];

  List<FrameCategory> get categories => _categories;

  Future<void> fetchCategories() async {
    final url = Uri.parse("https://digitalprimeagency.com/zoncoapps/weddingframeseditor/AllCategory.php");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Access the list under "categoryList"
        final List<dynamic> categoriesData = data['categoryList'] ?? [];

        // Parse each category
        _categories = categoriesData.map((item) => FrameCategory.fromJson(item)).toList();
        notifyListeners();
      } else {
        throw Exception("Failed to load categories");
      }
    } catch (error) {
      throw error;
    }
  }
}
