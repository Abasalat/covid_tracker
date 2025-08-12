import 'dart:convert';

import 'package:covid_tracker/Model/world_state_model.dart';
import 'package:covid_tracker/Services/Utilities/app_url.dart';
import 'package:http/http.dart' as http;

class StateServies {
  Future<WorldStateModel> fetchWorldStateRecords() async {
    final response = await http.get(Uri.parse(AppUrl.worldStatesApi));

    if (response.statusCode == 200) {
      print('Response data: ${response.body}');
      var data = jsonDecode(response.body);
      return WorldStateModel.fromJson(data);
    } else {
      throw Exception('Failed to load the data');
    }
  }
}
