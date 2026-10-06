import 'package:http/http.dart' as http;
import 'ticket.dart';
import 'dart:convert';
import 'env.dart';

class Apiservices {
  // Add your API service methods here

  Future<Ticket> requestActivity(String Depart, String Arrive) async {
    if (Env.aviationstackApiKey.isEmpty) {
      throw Exception('Missing AVIATIONSTACK_API_KEY: run with --dart-define-from-file=env.json');
    }
    String url = 'https://api.aviationstack.com/v1/flights?access_key=${Env.aviationstackApiKey}&dep_iata=$Depart&arr_iata=$Arrive&limit=15';
    try {
      return await http
        .get(Uri.parse(url))
        .then((value) {
          if (value.statusCode == 200) {
            // If the server returns an OK response, parse the JSON
            return processResponse(value.body);
          } else {
            // If the server did not return a 200 OK response, throw an exception
            throw Exception('Failed to load');
          } 
        })
        .catchError((error) {
          // Handle any errors that occur during the request
          throw Exception('Failed to request activity api');
        });
    } catch (e) {
      // Handle any exceptions that occur during the request
      throw Exception('Failed to get activity: $e');
    }    
  }

  Ticket processResponse(String responseBody) {
    try {
      final jsonData = jsonDecode(responseBody);
      
      // ตรวจสอบโครงสร้าง JSON
      if (jsonData == null) {
        throw Exception('Invalid JSON response: null data');
      }
      
      // ตรวจสอบ data field
      if (jsonData['data'] == null || jsonData['data'] is! List) {
        print('⚠️ Warning: No flight data found or invalid data format');
        // สร้าง empty ticket แทน error
        return Ticket(
          pagination: jsonData['pagination'] != null 
              ? Pagination.fromJson(jsonData['pagination']) 
              : null,
          data: [],
        );
      }
      
      print('✅ API Response valid, found ${jsonData['data'].length} flights');
      return Ticket.fromJson(jsonData);
    } catch (e) {
      print('❌ JSON Parse Error: $e');
      throw Exception('Failed to parse flight data: $e');
    }
  }
}
