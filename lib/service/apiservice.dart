import 'dart:convert';

import 'package:cook_ease/model/ResRecipe.dart';
import 'package:http/http.dart' as http;

class Apiservice {
  final baseurl="https://dummyjson.com";

  Future<List<Recipes>?> fetchrecipes() async {
    Uri url=Uri.parse("$baseurl/recipes");
    try{
      var response=await http.get(url);
      if(response.statusCode==200){
        var json=jsonDecode(response.body);
        var resRecipe=ResRecipe.fromJson(json);
        return resRecipe.recipes;
      }
    }catch(e){
      print(e);
    }
  }
}