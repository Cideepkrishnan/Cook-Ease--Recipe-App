import 'dart:convert';

import 'package:cook_ease/model/ResRecipe.dart';
import 'package:http/http.dart' as http;

class Apiservice {
  final baseurl = "https://dummyjson.com";

  Future<List<Recipes>> fetchrecipes() async {
    Uri url = Uri.parse("$baseurl/recipes?limit=0");
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        var resRecipe = ResRecipe.fromJson(json);
        return resRecipe.recipes ?? [];
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load recipes: $e');
    }
  }
}