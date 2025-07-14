import 'dart:convert';
import 'dart:io';
import 'package:artist/config/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../../keys.dart';
import '../../view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_exhibition_seat_booking_screen.dart';
import '../../view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_list_exhibition_screen.dart';
import '../../view/artist_side/artist_home_page/artist_home_screen.dart';
import '../../view/user_side/home_screen/home_screen.dart';
import '../../view/user_side/home_screen/search_screen.dart';
import '../models/artist_art_model.dart';
import '../models/artist_model.dart';
import '../models/auction_art_model.dart';
import '../models/category_model.dart';
import '../models/country_state_city_model.dart';
import '../models/customer_modell.dart';
import '../models/faq_model.dart';
import '../models/gallery_model.dart';
import '../models/order_response_model.dart';
import '../models/privacy_policy_model.dart';
import '../models/upload_art_model/addtional__title_model.dart';
import '../models/upload_art_model/art_review_model.dart';
import '../models/upload_art_model/category_select_model.dart';
import '../models/upload_art_model/portal_percentage_model.dart';
import '../models/user_side/all_artist_story_model.dart';
import '../models/user_side/art_reply_model.dart';
import '../models/user_side/cart_model.dart';
import '../models/user_side/customer_all_art_model.dart';
import '../models/user_side/customer_exhibitions_model.dart';
import '../models/user_side/donation_page_content_model.dart';
import '../models/user_side/single_art_model.dart';
import '../models/user_side/single_exhibitions_model.dart';
import '../models/user_side/wishlist_model.dart';
import 'base_url.dart';

class ApiService {
  static String baseUrl = "https://api.miramonet.com/api";
  // static String baseUrl = "https://artist.genixbit.com/api/";

  // static Future<String?> _getToken() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('UserToken');
  // }
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('UserToken');
  }

  // static Future<String?> _getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString('ApiToken');
  // }

  // Future<String> getDeviceIP() async {
  //   try {
  //     final List<InternetAddress> addresses = await InternetAddress.lookup('google.com');
  //     return addresses.isNotEmpty ? addresses.first.address : 'Unknown';
  //   } catch (e) {
  //     return 'Failed to get IP';
  //   }
  // }

  //1. Register User API
  Future<Map<String, dynamic>> registerUser(
      {required String name,
      required String email,
      required String password,
      required String role,
      String? artistName,
      required String mobile,
      required String deviceIP,
      required String token}) async {
    final url = Uri.parse('${baseUrl}/register_customer');
    // String deviceIP = await getDeviceIP();
    // print("deviceIP : $deviceIP");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': name,
        'artist_name': artistName,
        'email': email,
        'password': password,
        'role': role,
        'mobile': mobile,
        'fcm_token': token,
        'ip': deviceIP,
      }),
    );

    print(response.body);
    final responseBody = json.decode(response.body);
    showToast(message: responseBody['message']);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  //2. Login User API
  Future<Map<String, dynamic>> loginUser(
      {required String email,
      required String password,
      required String token}) async {
    final url = Uri.parse('${baseUrl}/login_customer');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'fcm_token': token,
        }),
      );

      print(response.body);
      print(response.statusCode);
      final responseBody = json.decode(response.body);
      // showToast(message: responseBody['message']);
      // showToast(message: "Failed to Login user");
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['status'] == true) {
        } else {
          showToast(message: responseBody['message']);
        }
        return json.decode(response.body);
      } else {
        showToast(message: "Failed to Login user");
        throw Exception('Failed to Login user: ${response.body}');
      }
    } catch (e) {
      showToast(message: "Failed to Login user");
      return {'status': false, 'message': 'An error occurred: $e'};
    }
  }

  //3. user_side and seller_side
  // Future<CustomerData> getCustomerData(String customerUniqueId) async {
  //   final url = Uri.parse('$baseUrl/customer_data');
  //   String? token = await _getToken();
  //   print("customerUniqueId: $customerUniqueId");
  //   print("token : $token");
  //
  //   if (token == null) {
  //     throw Exception('Authorization token is missing');
  //   }
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //     body: json.encode({
  //       'customer_unique_id': customerUniqueId,
  //     }),
  //   );
  //
  //   print(response.body);
  //   print(response.statusCode);
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     // Check if the response is successful
  //     if (responseData['status'] == true) {
  //       // Parse and return the customer data
  //       return CustomerData.fromJson(responseData['customer_data']);
  //     } else {
  //       throw Exception('Error: ${responseData['message']}');
  //     }
  //   } else {
  //     throw Exception('Failed to load customer data: ${response.body}');
  //   }
  // }
  Future<CustomerData> getCustomerData(String customerUniqueId) async {
    try {
      final url = Uri.parse('$baseUrl/customer_data');
      String? token = await _getToken();

      print("customerUniqueId: $customerUniqueId");
      print("Retrieved token: ($token)");

      if (token == null || token.isEmpty) {
        throw Exception('Authorization token is missing or empty');
      }

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.trim()}',
          'Accept': 'application/json, text/plain, */*',
          'Origin': 'https://www.miramonet.com',
          'Referer': 'https://www.miramonet.com/',
          'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',
          'DNT': '1',
        },
        body: json.encode({
          'customer_unique_id': customerUniqueId,
        }),
      );


      print('Response body: ${response.body}');
      print('Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return CustomerData.fromJson(responseData['customer_data']);
        } else {
          throw Exception('API error: ${responseData['message']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Exception caught in getCustomerData: $e');
      throw Exception('Something went wrong while fetching customer data.');
    }
  }

  // Future<CustomerData> getCustomerData(String customerUniqueId) async {
  //   final url = Uri.parse('${baseUrl}/customer_data');
  //   String? token = await _getToken();
  //
  //   print("customerUniqueId: $customerUniqueId");
  //   print("Retrieved token: ($token)");
  //
  //   if (token == null || token.isEmpty) {
  //     throw Exception('Authorization token is missing or empty');
  //   }
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //     body: json.encode({
  //       'customer_unique_id': customerUniqueId,
  //     }),
  //   );
  //
  //   print('Response body: ${response.body}');
  //   print('Status code: ${response.statusCode}');
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     if (responseData['status'] == true) {
  //       return CustomerData.fromJson(responseData['customer_data']);
  //     } else {
  //       throw Exception('API error: ${responseData['message']}');
  //     }
  //   } else {
  //     throw Exception('HTTP error: ${response.statusCode} - ${response.body}');
  //   }
  // }

  // Future<CustomerData> getCustomerData(String customerUniqueId) async {
  //   final url = Uri.parse('${baseUrl}/customer_data');
  //   String? token = await _getToken();
  //
  //   print("customerUniqueId: $customerUniqueId");
  //   print("token : ($token)");
  //
  //   if (token == null || token.isEmpty) {
  //     throw Exception('Authorization token is missing or empty');
  //   }
  //   String token1 = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2FwaS5taXJhbW9uZXQuY29tL2FwaS9sb2dpbl9jdXN0b21lciIsImlhdCI6MTc0NDY5ODYwOSwiZXhwIjoxNzQ5ODgyNjA5LCJuYmYiOjE3NDQ2OTg2MDksImp0aSI6IlQxVFVkQ3pwaGtjOVNjaEQiLCJzdWIiOiIxOSIsInBydiI6IjFkMGEwMjBhY2Y1YzRiNmM0OTc5ODlkZjFhYmYwZmJkNGU4YzhkNjMifQ.3exsUeNMFQAQbZ2tjw5XQ2oDsaf98TmByWtK9rR1BdM';
  //   String token2 = token;
  //
  //   if (token1 == token2) {
  //     print("Tokens are equal");
  //   } else {
  //     print("Tokens are different");
  //   }
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $token',
  //     },
  //     body: json.encode({
  //       'customer_unique_id': customerUniqueId,
  //     }),
  //   );
  //
  //   print(response.body);
  //   print(response.statusCode);
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     if (responseData['status'] == true) {
  //       return CustomerData.fromJson(responseData['customer_data']);
  //     } else {
  //       throw Exception('Error: ${responseData['message']}');
  //     }
  //   } else {
  //     throw Exception('Failed to load customer data: ${response.body}');
  //   }
  // }

  //4. user_side and seller_side
  Future<List<FAQItem>> fetchFAQs(String role) async {
    // Your API call here
    final url = Uri.parse('$baseUrl/get_faq');
    String? token = await _getToken();
    print(token);
    final Map<String, String>? headers =
        role == 'seller' ? {'Authorization': 'Bearer $token'} : null;

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final faqResponse = FAQResponse.fromJson(json.decode(response.body));
      return faqResponse.faqItems;
    } else {
      throw Exception('Failed to load FAQs');
    }
  }

  //5. user_side and seller_side
  Future<PrivacyPolicy> fetchPrivacyPolicy(String role) async {
    final url = Uri.parse('$serverUrl/get_policy_content');
    String? token = await _getToken();

    final Map<String, String>? headers =
        role == 'seller' ? {'Authorization': 'Bearer $token'} : null;

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return PrivacyPolicy.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load privacy policy');
    }
  }

  //6. seller_side
  Future<List<Exhibition>> fetchExhibitions() async {
    final url = Uri.parse('$baseUrl/exhibitions/upcoming');
    String? token = await _getToken();
    print(token);

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Exhibition.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load exhibitions');
    }
  }

  //7. seller_side
  Future<List<Booth>> fetchBoothDataApi(String exhibitionUniqueId) async {
    print("exhibitionUniqueId : $exhibitionUniqueId");
    final url = Uri.parse('$serverUrl/exhibition/booths');
    String? token = await _getToken();
    print(token);
    if (token == null) {
      throw Exception('Authorization token is missing');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "exhibition_unique_id": exhibitionUniqueId,
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);

        // Check if the 'data' key is present and contains a list of booths
        if (data['data'] != null) {
          var boothsList = data['data'] as List;
          List<Booth> booths = boothsList.map((boothJson) {
            return Booth.fromJson(boothJson);
          }).toList();
          return booths;
        } else {
          throw Exception('Booths data is missing from the response');
        }
      } catch (e) {
        print('Error parsing booth data: $e');
        throw Exception('Failed to load booth data');
      }
    } else {
      print('Failed to load booth data. Status code: ${response.statusCode}');
      throw Exception('Failed to load booth data');
    }
  }

  //8. user_side and seller_side
  static Future<List<Country>> getCountries() async {
    final response = await http
        .get(Uri.parse('$serverUrl/getAllCountries'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['allCountries'] as List)
          .map((country) => Country.fromJson(country))
          .toList();
    } else {
      throw Exception('Failed to load countries');
    }
  }

  //9. user_side and seller_side
  static Future<List<StateModel>> getStates(int countryId) async {
    final response = await http
        .get(Uri.parse('$serverUrl/getState/$countryId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['states'] as List)
          .map((state) => StateModel.fromJson(state))
          .toList();
    } else {
      throw Exception('Failed to load states');
    }
  }

  //10. user_side and seller_side
  static Future<List<City>> getCities(int stateId) async {
    final response = await http
        .get(Uri.parse('$serverUrl/getCity/$stateId'));
    print("city : $serverUrl/getCity/$stateId");
    print("city : ${response.statusCode}");
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['cities'] as List)
          .map((city) => City.fromJson(city))
          .toList();
    } else {
      throw Exception('Failed to load cities');
    }
  }

  //11. seller_side
  static Future<List<UploadCategory>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse("$serverUrl/get_category"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> categoryList = responseData['category'];

        return categoryList
            .map((categoryJson) => UploadCategory.fromJson(categoryJson))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  //12. seller_side
  static Future<Map<String, dynamic>> getPortalPercentages(String role) async {
    final response = await http.post(
      Uri.parse('$serverUrl/get_portal_percentage'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'role': role}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Return full response as a map
    } else {
      throw Exception('Failed to load portal percentages');
    }
  }

  // static Future<List<PortalPercentage>> getPortalPercentages(
  //     String role) async {
  //   final response = await http.post(
  //     Uri.parse('$serverUrl/get_portal_percentage'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode({
  //       'role': role,
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonData = json.decode(response.body)['data'];
  //     return jsonData.map((item) => PortalPercentage.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Failed to load portal percentages');
  //   }
  // }

  //13. seller_side
  Future<Map<String, dynamic>?> uploadArtDetails(
      Map<String, dynamic> payload) async {
    String? token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/artwork/add"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error occurred during upload: $e");
      return null; // Return null if there's an error
    }
  }

  //14. seller_side
  static Future<List<ArtResponse>> fetchArtData() async {
    try {
      final response = await http
          .get(Uri.parse("$serverUrl/get_art_data"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('status') &&
            responseData.containsKey('artData')) {
          final List<dynamic> artDataList = responseData['artData'];

          return [
            ArtResponse.fromJson(responseData)
          ]; // Wrap into a list of ArtResponse objects
        } else {
          throw Exception('Missing required keys in response data');
        }
      } else {
        throw Exception('Failed to load Art: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch Art: $e');
    }
  }

  static Future<Map<String, dynamic>> getArtData(String categoryId) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/get_art_data'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'category_id': categoryId}),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load art data');
    }
  }

  static Future<bool> submitArtData(
      String artUniqueId, List<Map<String, String>> data) async {
    final response = await http.post(
      Uri.parse('${baseUrl}/addArtAdditionalDetailsnew'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'art_unique_id': artUniqueId, 'data': data}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData["status"] == true;
    } else {
      return false;
    }
  }

  //15. seller_side
  Future<Map<String, dynamic>> addAdditionalDetails(
      String artUniqueId, String artDataId, String description) async {
    final url = Uri.parse('$baseUrl/artwork/add-details');
    String? token = await _getToken();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'art_unique_id': artUniqueId,
        'art_data_id': artDataId,
        'description': description,
      }),
    );

    print("response : ${response.body}");
    if (response.statusCode == 200) {
      print("response : ${response.body}");
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to add additional details');
    }
  }

  //16. seller_side
  Future<Map<String, dynamic>> uploadImage({
    required String artUniqueId,
    required String artType,
    required File image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/artwork/add-image'),
      );

      // Add fields
      request.fields['art_unique_id'] = artUniqueId;
      request.fields['art_type'] = artType;

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
      ));

      // Add headers
      String? token = await _getToken();
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = json.decode(responseData);
        return decodedData;
      } else {
        return {
          'status': false,
          'message':
              'Failed to upload image. Server responded with ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {
        'status': false,
        'message': 'An error occurred while uploading the image.',
      };
    }
  }

  //17. seller_side
  Future<Map<String, dynamic>> deleteImage(String artImageId) async {
    String? token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/artwork/delete_art_image'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'art_image_id': artImageId,
        }), // Encode the body as JSON
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      print('Error deleting image: $e');
      return {'status': false, 'message': 'Error deleting image.'};
    }
  }

  //18. seller_side
  Future<ArtReviewModel> fetchArtDetails(String artUniqueId) async {
    String? token = await _getToken();
    print(token);
    final response = await http.post(
      Uri.parse('$baseUrl/artwork/art_detail'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'art_unique_id': artUniqueId}),
    );

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == true) {
        return ArtReviewModel.fromJson(responseData['artallDetails']);
      } else {
        throw Exception('Failed to load art details');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  Future<AuctionArtModel> fetchArtDetailsAuction(String artUniqueId) async {
    String? token = await _getToken();
    print(token);

    final response = await http.post(
      Uri.parse('$baseUrl/get_single_auction_art'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'art_unique_id': artUniqueId}),
    );

    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['status'] == true && responseData.containsKey('art')) {
        return AuctionArtModel.fromJson(responseData['art']);
      } else {
        throw Exception('Art details not found');
      }
    } else {
      throw Exception('Failed to fetch data from API. Status Code: ${response.statusCode}');
    }
  }


  //19. seller_side
  Future<Map<String, dynamic>?> cancelArtwork(String artUniqueId) async {
    String? token = await _getToken();
    final url = '$serverUrl/artwork/cancel';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final payload = {'art_unique_id': artUniqueId};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to cancel artwork: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error cancelling artwork: $e');
      return null;
    }
  }

  //20. seller_side
  Future<List<ArtistArtModel>> fetchMyArtData(
      String CustomerUID, String role) async {
    String? token = await _getToken();
    final url = '$serverUrl/get_artist_all_art_deatils';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    print("CustomerUID : $CustomerUID");
    final payload = {'customer_unique_id': CustomerUID, "role": role};

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(payload),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['artdata'] != null) {
        List<dynamic> data = decodedResponse['artdata'];
        return data.map((json) => ArtistArtModel.fromJson(json)).toList();
      } else {
        throw Exception('No art data found in the response');
      }
      // List<dynamic> data = json.decode(response.body)['artdata'];
      // return data.map((json) => ArtistArtModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load art data');
    }
  }

//21. buyer_side
  Future<Map<String, dynamic>> fetchSingleArtistData(
      String customerUID, String role) async {
    print("customerUID:$customerUID");
    String? token = await _getToken();
    final url = '$serverUrl/get_artist_all_art_deatils';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    final payload = {'customer_unique_id': customerUID, 'role': role};

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load artist data');
    }
  }

  //22. user_side
  Future<List<DonationPageContent>> fetchDonationPageContent() async {
    final response = await http.get(Uri.parse('$baseUrl/get_donation_page'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> donationPageContentJson =
          json['donation_page_content'];
      return donationPageContentJson
          .map((content) => DonationPageContent.fromJson(content))
          .toList();
    } else {
      throw Exception('Failed to load donation page content');
    }
  }

  //23. user_side
  Future<Gallery> fetchGalleryData() async {
    final response = await http.get(Uri.parse('$baseUrl/get_gallary'));

    if (response.statusCode == 200) {
      return Gallery.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load gallery data');
    }
  }

  //24. user_side
  Future<List<ArtistModel>> fetchArtists() async {
    const speedLimitInBytes = 5000000 ~/ 8; // 1 Mbps in bytes per second

    final url = Uri.parse('$baseUrl/get_artist');
    String? token = await _getToken();
    print('Token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Assuming token is needed for authorization
        },
      );

      if (response.statusCode == 200) {
        // Simulate downloading data at a limited speed
        final totalSize = response.bodyBytes.length;
        int downloaded = 0;
        List<ArtistModel> artists = [];

        while (downloaded < totalSize) {
          // Ensure the chunk size does not exceed the remaining data
          final chunkEnd = (downloaded + speedLimitInBytes) > totalSize
              ? totalSize
              : downloaded + speedLimitInBytes;

          // Download the data in chunks based on the speed limit
          final chunk = response.bodyBytes.sublist(downloaded, chunkEnd);

          // Simulate download speed with a delay (adjust the milliseconds as needed)
          await Future.delayed(
              Duration(milliseconds: 100)); // Simulating download speed

          downloaded += chunk.length;

          // Process chunk here (e.g., parse JSON and store it)
          String chunkStr = String.fromCharCodes(chunk);
          final data = json.decode(chunkStr);

          if (data['status'] == true) {
            final List<dynamic> artistList = data['artist'];
            artists.addAll(
                artistList.map((json) => ArtistModel.fromJson(json)).toList());
          } else {
            throw Exception('Failed to load artists: status is not true');
          }
        }

        return artists;
      } else {
        throw Exception('Failed to load artists');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error fetching artists');
    }
  }
  // Future<List<ArtistModel>> fetchArtists() async {
  //   final response = await http.get(Uri.parse('$baseUrl/get_artist'));
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (data['status']) {
  //       List<dynamic> artistList = data['artist'];
  //       return artistList.map((json) => ArtistModel.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load artists');
  //     }
  //   } else {
  //     throw Exception('Failed to load artists');
  //   }
  // }

  //25. user_side
  Future<List<Category>> fetchCategories() async {
    const speedLimitInBytes = 5000000 ~/ 8; // 1 Mbps in bytes per second

    final url = Uri.parse('$baseUrl/get_category');
    String? token = await _getToken();
    print('Token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Simulate downloading data at a limited speed
        final totalSize = response.bodyBytes.length;
        int downloaded = 0;
        List<Category> categories = [];

        while (downloaded < totalSize) {
          // Ensure the chunk size does not exceed the remaining data
          final chunkEnd = (downloaded + speedLimitInBytes) > totalSize
              ? totalSize
              : downloaded + speedLimitInBytes;

          // Download the data in chunks based on the speed limit
          final chunk = response.bodyBytes.sublist(downloaded, chunkEnd);

          // Simulate download speed with a delay (adjust the milliseconds as needed)
          await Future.delayed(
              Duration(milliseconds: 100)); // Simulating download speed

          downloaded += chunk.length;

          // Process chunk here (e.g., parse JSON and store it)
          String chunkStr = String.fromCharCodes(chunk);
          final data = json.decode(chunkStr);

          if (data['status'] == true) {
            final List<dynamic> categoryList = data['category'];
            categories.addAll(
                categoryList.map((json) => Category.fromJson(json)).toList());
          } else {
            throw Exception('Failed to load categories: status is not true');
          }
        }

        return categories;
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error fetching categories');
    }
  }
  // Future<List<Category>> fetchCategories() async {
  //   final response = await http.get(Uri.parse('$baseUrl/get_category'));
  //
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     final categoryList = (data['category'] as List)
  //         .map((categoryData) => Category.fromJson(categoryData))
  //         .toList();
  //     return categoryList;
  //   } else {
  //     throw Exception('Failed to load categories');
  //   }
  // }

  //26. user_side
  Future<List<CustomerAllArtModel>> getAllArt() async {
    const speedLimitInBytes = 5000000 ~/ 8; // 1 Mbps in bytes per second

    final url = Uri.parse('$baseUrl/get_all_art');
    String? token = await _getToken();
    print('Token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Assuming token is needed for authorization
        },
      );

      if (response.statusCode == 200) {
        // Simulate downloading data at a limited speed
        final totalSize = response.bodyBytes.length;
        int downloaded = 0;
        List<CustomerAllArtModel> artList = [];

        while (downloaded < totalSize) {
          // Ensure the chunk size does not exceed the remaining data
          final chunkEnd = (downloaded + speedLimitInBytes) > totalSize
              ? totalSize
              : downloaded + speedLimitInBytes;

          // Download the data in chunks based on the speed limit
          final chunk = response.bodyBytes.sublist(downloaded, chunkEnd);

          // Simulate download speed with a delay
          await Future.delayed(Duration(
              milliseconds: 100)); // Adjust delay to simulate download speed

          downloaded += chunk.length;

          // Process chunk here (e.g., parse JSON and store it)
          String chunkStr = String.fromCharCodes(chunk);
          final data = json.decode(chunkStr);

          // Assuming the response has a similar structure to the exhibitions data
          if (data['status'] == true) {
            final List<dynamic> artData = data['artdata'];
            artList.addAll(artData
                .map((json) => CustomerAllArtModel.fromJson(json))
                .toList());
          } else {
            throw Exception('Failed to load art data: status is not true');
          }
        }

        return artList;
      } else {
        throw Exception('Failed to load art data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error fetching art data');
    }
  }
  // Future<List<CustomerAllArtModel>> getAllArt() async {
  //   final response = await http.get(Uri.parse('$baseUrl/get_all_art'));
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body)['artdata'];
  //     return data.map((e) => CustomerAllArtModel.fromJson(e)).toList();
  //   } else {
  //     throw Exception('Failed to load art data');
  //   }
  // }

  //27. user_side
  Future<List<CustomerAllArtModel>> getAllPrivateArt() async {
    const speedLimitInBytes = 1000000 ~/ 8; // 1 Mbps in bytes per second

    final url = Uri.parse('$baseUrl/get_all_private_art');
    String? token = await _getToken();
    print('Token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Assuming token is needed for authorization
        },
      );

      if (response.statusCode == 200) {
        // Simulate downloading data at a limited speed
        final totalSize = response.bodyBytes.length;
        int downloaded = 0;
        List<CustomerAllArtModel> artList = [];

        while (downloaded < totalSize) {
          // Ensure the chunk size does not exceed the remaining data
          final chunkEnd = (downloaded + speedLimitInBytes) > totalSize
              ? totalSize
              : downloaded + speedLimitInBytes;

          // Download the data in chunks based on the speed limit
          final chunk = response.bodyBytes.sublist(downloaded, chunkEnd);

          // Simulate download speed with a delay
          await Future.delayed(Duration(
              milliseconds: 100)); // Adjust delay to simulate download speed

          downloaded += chunk.length;

          // Process chunk here (e.g., parse JSON and store it)
          String chunkStr = String.fromCharCodes(chunk);
          final data = json.decode(chunkStr);

          if (data['status'] == true) {
            final List<dynamic> artData = data['artdata'];
            artList.addAll(artData
                .map((json) => CustomerAllArtModel.fromJson(json))
                .toList());
          } else {
            throw Exception('Failed to load art data: status is not true');
          }
        }

        return artList;
      } else {
        throw Exception('Failed to load art data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error fetching art data');
    }
  }
  // Future<List<CustomerAllArtModel>> getAllPrivateArt() async {
  //   final response = await http.get(Uri.parse('$baseUrl/get_all_private_art'));
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body)['artdata'];
  //     return data.map((e) => CustomerAllArtModel.fromJson(e)).toList();
  //   } else {
  //     throw Exception('Failed to load art data');
  //   }
  // }

  //28. user_side - seller_side
  Position? _currentPosition;

  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //
  //   _currentPosition = await Geolocator.getCurrentPosition();
  // }



  //29. user_side - seller_side
  // Future<void> editCustomerProfile({
  //   required String role,
  //   required String customerUniqueID,
  //   required String name,
  //   required String address,
  //   required String country,
  //   required String state,
  //   required String city,
  //   required String zipCode,
  //   required String intro,
  //   required String? imagePath,
  // }) async {
  //   await _getCurrentLocation();
  //   String? token = await _getToken();
  //   final String url = '$serverUrl/edit_customer_profile';
  //   final request = http.MultipartRequest('POST', Uri.parse(url));
  //
  //   request.headers['Authorization'] = 'Bearer $token';
  //
  //   if (imagePath != null) {
  //     request.files.add(
  //       await http.MultipartFile.fromPath(
  //         'customer_profile',
  //         imagePath,
  //       ),
  //     );
  //   }
  //
  //   request.fields['customer_unique_id'] = customerUniqueID;
  //   request.fields['name'] = name;
  //   request.fields['address'] = address;
  //   request.fields['country'] = country.toString();
  //   request.fields['state'] = state.toString();
  //   request.fields['city'] = city.toString();
  //   request.fields['zip_code'] = zipCode;
  //
  //   if (role == "seller") {
  //     request.fields['introduction'] = intro;
  //   }
  //   if (_currentPosition != null) {
  //     request.fields['longitude'] = _currentPosition!.longitude.toString();
  //     request.fields['latitude'] = _currentPosition!.latitude.toString();
  //   } else {
  //     request.fields['longitude'] = '12';
  //     request.fields['latitude'] = '32';
  //   }
  //
  //   try {
  //     final response = await request.send();
  //
  //     if (response.statusCode == 200) {
  //       final responseBody = await response.stream.bytesToString();
  //       final jsonResponse = json.decode(responseBody);
  //       print('Profile updated successfully: $jsonResponse');
  //     } else {
  //       final responseBody = await response.stream.bytesToString();
  //       print('Failed to update profile: $responseBody');
  //     }
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

  Future<void> editCustomerProfile({
    required String role,
    required String customerUniqueID,
    required String name,
    required String address,
    required String country,
    required String state,
    required String city,
    required String longitude,
    required String latitude,
    required String zipCode,
    required String intro,
    required String? imagePath,
  }) async {
    try {

      String? token = await _getToken();
      final String url =
          '$serverUrl/edit_customer_profile';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      request.headers['Authorization'] = 'Bearer $token';

      if (imagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('customer_profile', imagePath),
        );
      }

      request.fields['customer_unique_id'] = customerUniqueID;
      request.fields['name'] = name;
      request.fields['address'] = address;
      request.fields['country'] = country;
      request.fields['state'] = state;
      request.fields['city'] = city;
      request.fields['zip_code'] = zipCode;

      if (role == "seller") {
        request.fields['introduction'] = intro;
      }

      request.fields['longitude'] = longitude.toString();
      request.fields['latitude'] = latitude.toString();

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);
        print('Profile updated successfully: $jsonResponse');
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Failed to update profile: $responseBody');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  //30. user_side
  Future<List<Story>> fetchArtistStories() async {
    const speedLimitInBytes = 5000000 ~/ 8; // 1 Mbps in bytes per second

    final url = Uri.parse('$baseUrl/get_artist_art_story');
    String? token = await _getToken();
    print('Token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Assuming token is needed for authorization
        },
      );

      if (response.statusCode == 200) {
        // Simulate downloading data at a limited speed
        final totalSize = response.bodyBytes.length;
        int downloaded = 0;
        List<Story> stories = [];

        while (downloaded < totalSize) {
          // Ensure the chunk size does not exceed the remaining data
          final chunkEnd = (downloaded + speedLimitInBytes) > totalSize
              ? totalSize
              : downloaded + speedLimitInBytes;

          // Download the data in chunks based on the speed limit
          final chunk = response.bodyBytes.sublist(downloaded, chunkEnd);

          // Simulate download speed with a delay (adjust the milliseconds as needed)
          await Future.delayed(
              Duration(milliseconds: 100)); // Simulating download speed

          downloaded += chunk.length;

          // Process chunk here (e.g., parse JSON and store it)
          String chunkStr = String.fromCharCodes(chunk);
          final data = json.decode(chunkStr);

          if (data['status'] == true) {
            final List<dynamic> storyList = data['stories'];
            stories
                .addAll(storyList.map((json) => Story.fromJson(json)).toList());
          } else {
            throw Exception(
                'Failed to load artist stories: status is not true');
          }
        }

        return stories;
      } else {
        throw Exception('Failed to load artist stories');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error fetching artist stories');
    }
  }
  // Future<List<Story>> fetchArtistStories() async {
  //   final response = await http.get(Uri.parse('$baseUrl/get_artist_art_story'));
  //
  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonResponse = json.decode(response.body)['stories'];
  //     return jsonResponse.map((e) => Story.fromJson(e)).toList();
  //   } else {
  //     throw Exception('Failed to load artist stories');
  //   }
  // }

  //31. user_side
  Future<SingleArtModel> fetchSingleArtDetails(
    String artUniqueId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/get_single_art"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "art_unique_id": artUniqueId,
        }),
      );

      print(response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if 'status' is true and 'art' is not null
        if (jsonResponse['status'] == true && jsonResponse['art'] != null) {
          return SingleArtModel.fromJson(jsonResponse);
        } else {
          throw Exception('Failed to load art or art details are unavailable.');
        }
      } else {
        throw Exception(
            'Failed to load art. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handling network or parsing errors
      throw Exception('Error fetching art details: $e');
    }
  }

  //32. user_side
  Future<SingleArtModel> fetchSinglePrivateArtDetails(
    String artUniqueId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/get_single_private_art"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "art_unique_id": artUniqueId,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Check if 'status' is true and 'art' is not null
        if (jsonResponse['status'] == true && jsonResponse['art'] != null) {
          return SingleArtModel.fromJson(jsonResponse);
        } else {
          throw Exception('Failed to load art or art details are unavailable.');
        }
      } else {
        throw Exception(
            'Failed to load art. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handling network or parsing errors
      throw Exception('Error fetching art details: $e');
    }
  }

  //33. user_side
  Future<void> addToWishlist(
      String customerUniqueId, String artUniqueId) async {
    // Define the API endpoint
    final String url = "$baseUrl/add_wishlist";

    final Map<String, String> payload = {
      "customer_unique_id": customerUniqueId,
      "art_unique_id": artUniqueId,
    };
    String? token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(payload),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final String message = responseBody["message"];

      if (response.statusCode == 200) {
        showToast(message: message);
        print("body : ${response.body}");
        print('Added to wishlist successfully');
      } else {
        showToast(message: message);
        print('Failed to add to wishlist: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  //34. user_side
  Future<List<WishlistItem>> fetchWishlist(String customerUniqueId) async {
    final String url = "$baseUrl/get_wishlist";

    final Map<String, String> payload = {
      "customer_unique_id": customerUniqueId,
    };
    String? token = await _getToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      Wishlist wishlist = Wishlist.fromJson(jsonResponse);
      return wishlist.wishlistItems;
    } else {
      throw Exception('Failed to load wishlist');
    }
  }

  //35. user_side
  Future<void> deleteWishlistItem(String wishlistId) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/delete_wishlist'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({'wishlist_id': wishlistId}),
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final String message = responseBody["message"];

    if (response.statusCode == 200) {
      showToast(message: message);
      print("body : ${response.body}");
      print('Delete to wishlist successfully');
    } else {
      showToast(message: message);
      print('Failed to add to wishlist: ${response.body}');
    }
  }

  //36. user_side
  Future<Map<String, dynamic>> getArtDetails(String artUniqueId) async {
    final String endpoint = '$baseUrl/get_artist_single_art_story';

    try {
      final Map<String, String> payload = {
        "art_unique_id": artUniqueId,
      };
      String? token = await _getToken();
      final response = await http.post(
        Uri.parse(endpoint),
        body: json.encode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load art details');
      }
    } catch (e) {
      throw Exception('Error occurred while fetching art details: $e');
    }
  }

  //37. user_side
  Future<void> addToCart(String customerUniqueId, String artUniqueId) async {
    // Define the API endpoint
    final String url = "$baseUrl/add_cart";

    final Map<String, String> payload = {
      "customer_unique_id": customerUniqueId,
      "art_unique_id": artUniqueId,
    };
    String? token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token!.trim()}',
          'Accept': 'application/json'
        },
        body: json.encode(payload),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final String message = responseBody["message"];

      if (response.statusCode == 200) {
        showToast(message: message);
        print("body : ${response.body}");
        print('Added to Cart successfully');
      } else {
        showToast(message: message);
        print('Failed to add to wishlist: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  //38. user_side
  Future<CartModel> fetchCartData(String customerUniqueId) async {
    print("customerUniqueId : $customerUniqueId");
    String? token = await _getToken();
    print("token : $token");
    final response = await http.post(
      Uri.parse('$baseUrl/get_cart'),
      body: jsonEncode({
        'customer_unique_id': customerUniqueId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      return CartModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load art data');
    }
  }

  //39. user_side
  Future<void> deleteCartItem(String art_cart_id) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/delete_cart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({'art_cart_id': art_cart_id}),
    );

    final Map<String, dynamic> responseBody = json.decode(response.body);
    final String message = responseBody["message"];

    if (response.statusCode == 200) {
      showToast(message: message);
      print("body : ${response.body}");
      print('Delete to Cart successfully');
    } else {
      showToast(message: message);
      print('Failed to add to wishlist: ${response.body}');
    }
  }

  //40. user_side
  Future<List<CustomerAllArtModel>> fetchCategoryProducts(
      String categoryId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_category_product'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'category_id': categoryId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        List<CustomerAllArtModel> artDataList = (data['artdata'] as List)
            .map((artData) => CustomerAllArtModel.fromJson(artData))
            .toList();
        return artDataList;
      } else {
        throw Exception('Failed to load products');
      }
    } else {
      throw Exception('Failed to connect to the server');
    }
  }

  //41. user_side
  // Future<List<CustomerExhibitionsModel>> fetchExhibitionsForCustomer() async {
  //   final url = Uri.parse('$baseUrl/get_all_exhibition');
  //   String? token = await _getToken();
  //   print(token);
  //
  //   final response = await http.get(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print(response.body);
  //     final data = json.decode(response.body);
  //     if (data['status'] == true) {
  //       final List<dynamic> exhibitionList = data['exhibition'];
  //       return exhibitionList
  //           .map((json) => CustomerExhibitionsModel.fromJson(json))
  //           .toList();
  //     } else {
  //       throw Exception('Failed to load exhibitions: status is not true');
  //     }
  //   } else {
  //     throw Exception('Failed to load exhibitions');
  //   }
  // }

  Future<List<CustomerExhibitionsModel>> fetchExhibitionsForCustomer() async {
    const speedLimitInBytes = 5000000 ~/ 8;

    final url = Uri.parse('$baseUrl/get_all_exhibition');
    String? token = await _getToken();
    print('Token: $token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Simulate downloading data at a limited speed
        final totalSize = response.bodyBytes.length;
        int downloaded = 0;
        List<CustomerExhibitionsModel> exhibitions = [];

        while (downloaded < totalSize) {
          // Ensure the chunk size does not exceed the remaining data
          final chunkEnd = (downloaded + speedLimitInBytes) > totalSize
              ? totalSize
              : downloaded + speedLimitInBytes;

          // Download the data in chunks based on the speed limit
          final chunk = response.bodyBytes.sublist(downloaded, chunkEnd);

          // Simulate download speed with a delay (adjust the milliseconds as needed)
          await Future.delayed(
              Duration(milliseconds: 100)); // Simulating download speed

          downloaded += chunk.length;

          // Process chunk here (e.g., parse JSON and store it)
          String chunkStr = String.fromCharCodes(chunk);
          final data = json.decode(chunkStr);

          if (data['status'] == true) {
            final List<dynamic> exhibitionList = data['exhibition'];
            exhibitions.addAll(exhibitionList
                .map((json) => CustomerExhibitionsModel.fromJson(json))
                .toList());
          } else {
            throw Exception('Failed to load exhibitions: status is not true');
          }
        }

        return exhibitions;
      } else {
        throw Exception('Failed to load exhibitions');
      }
    } catch (e) {
      print('Error fetching data: $e');
      throw Exception('Error fetching exhibitions');
    }
  }

  //42. user_side
  Future<Map<String, dynamic>> fetchExhibitionDetails(
      String exhibitionUniqueId) async {
    final url = Uri.parse('$baseUrl/get_single_exhibition');
    print("exhibition_unique_id: $exhibitionUniqueId");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
          {'exhibition_unique_id': exhibitionUniqueId, "type": "customer"}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exhibition details');
    }
  }

  Future<Map<String, dynamic>> fetchExhibitionDetailsSeller(
      String exhibitionUniqueId) async {
    String? token = await _getToken();
    final url = Uri.parse('$baseUrl/get_single_exhibition_seller');
    print("exhibition_unique_id: $exhibitionUniqueId");

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'exhibition_unique_id': exhibitionUniqueId,
      }),
    );

    if (response.statusCode == 200) {
      // print(response.body);
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exhibition details');
    }
  }

  //43. user_side
  Future<Map<String, dynamic>> sendOTPexhibitionReg(
      String email, String exhibition_unique_id) async {
    final url = Uri.parse('$baseUrl/sendEmailOTPexhibtionReg');
    // final url = Uri.parse('$baseUrl/sendOTPexhibtionRegBypass');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
          {'email': email, 'exhibition_unique_id': exhibition_unique_id}),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // if (responseData['status'] == 'true') {
      print(response.body);
      showToast(message: responseData['message']);
      // showToast(message: responseData['otp']);
      return {
        'status': responseData['status'].toString(),
        'message': responseData['message'],
      };
      // } else {
      //   showToast(message: responseData['message']);
      //   throw Exception('Failed to send OTP: ${responseData['message']}');
      // }
    } else {
      showToast(message: responseData['message']);
      throw Exception('Failed to send OTP');
    }
  }

  //44.
  Future<void> send_otp(
    String mobileCode,
    String mobile,
  ) async {
    final url = Uri.parse('$baseUrl/send-otp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobileCode': mobileCode,
        'mobile': mobile,
      }),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseData['status'] == 'true') {
        showToast(message: responseData['otp']);
        // showToast(message: responseData['message']);
        return responseData['message'];
      } else {
        showToast(message: responseData['message']);
        throw Exception('Failed to send OTP: ${responseData['message']}');
      }
    } else {
      showToast(message: responseData['message']);
      throw Exception('Failed to send OTP');
    }
  }

  Future<Map<String, dynamic>> verifyOtpEmail(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verifyEmailOtp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);

      if (response.statusCode == 200) {
        showToast(message: responseData['message']);
        return {
          'status': responseData['status'].toString(),
          'message': responseData['message'],
        };
      } else {
        showToast(message: responseData['message']);
        return {
          'status': 'false',
          'message': 'Failed to verify OTP',
        };
      }
    } catch (e) {
      showToast(message: e.toString());
      return {
        'status': 'false',
        'message': 'Error verifying OTP: $e',
      };
    }
  }

  // Future<String> verifyOtpEmail(String email, String otp) async {
  //   final url = Uri.parse('$baseUrl/verifyEmailOtp');
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'email': email,
  //       'otp': otp,
  //     }),
  //   );
  //
  //   final Map<String, dynamic> responseData = json.decode(response.body);
  //   if (response.statusCode == 200) {
  //     if (responseData['status'] == 'true') {
  //       showToast(message: responseData['message']);
  //       return responseData['message'];
  //     } else {
  //       showToast(message: responseData['message']);
  //       throw Exception('Failed to verify OTP: ${responseData['message']}');
  //     }
  //   } else {
  //     showToast(message: responseData['message']);
  //     throw Exception('Failed to verify OTP');
  //   }
  // }

  //45. user_side
  Future<String> verifyOtp(String mobile, String otp) async {
    final url = Uri.parse('$baseUrl/verify-otp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile': mobile,
        'otp': otp,
      }),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseData['status'] == 'true') {
        showToast(message: responseData['message']);
        return responseData['message'];
      } else {
        showToast(message: responseData['message']);
        throw Exception('Failed to verify OTP: ${responseData['message']}');
      }
    } else {
      showToast(message: responseData['message']);
      throw Exception('Failed to verify OTP');
    }
  }

  //46. user_side
  Future<Map<String, dynamic>> registerCustomerExhibitions({
    required String name,
    required String email,
    required String mobile,
    String? selectedSheet,
    required String exhibitionUniqueId,
    required String address,
    required String role,
    required String customerUniqueId,
  }) async {
    print("name : $name");
    print("email : $email");
    print("mobile : $mobile");
    print("selectedSheet : $selectedSheet");
    print("exhibitionUniqueId : $exhibitionUniqueId");
    print("address : $address");
    print("customerUniqueId : $customerUniqueId");
    final url = Uri.parse('$baseUrl/exhibtion/customer_register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile,
          'booth_seat_id': selectedSheet,
          'exhibition_unique_id': exhibitionUniqueId,
          'address': address,
          'customer_unique_id': customerUniqueId,
          'role': role
          // 'customer',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response: $responseData');
        return json.decode(response.body);
      } else {
        print(
            'Failed to load exhibition details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load exhibition details');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> registerCustomerExhibitionsnew({
    required String name,
    required String email,
    required String mobile,
    required String exhibitionUniqueId,
    required String address,
    required String country,
    required String state,
    required String city,
    required String zip,
    required String role,
    required String customerUniqueId,
    required String purpose_booking,
    required String date,
    required String exhibition_time_slot_id,
    required String type,
    required String amount,
  }) async {
    print("name : $name");
    print("email : $email");
    print("mobile : $mobile");
    print("exhibitionUniqueId : $exhibitionUniqueId");
    print("address : $address");
    print("Country : $country");
    print("State : $state");
    print("city : $city");
    print("Zip : $zip");
    print("customerUniqueId : $customerUniqueId");
    print("role : $role");
    print("purpose_booking : $purpose_booking");
    print("date : $date");
    print("exhibition_time_slot_id : $exhibition_time_slot_id");
    print("type : $type");
    print("amount : $amount");
    final url = Uri.parse('$baseUrl/registerForExhibitionNew');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile,
          'exhibition_unique_id': exhibitionUniqueId,
          'address': address,
          'country': country,
          'state': state,
          'city': city,
          'zip_code': zip,
          'customer_unique_id': customerUniqueId,
          'role': role,
          'purpose_booking': purpose_booking,
          'date': date,
          'exhibition_time_slot_id': exhibition_time_slot_id,
          'type': type,
          'amount': amount
          // 'customer',
        }),
      );

      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response: $responseData');
        return json.decode(response.body);
      } else {
        print(
            'Failed to load exhibition details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load exhibition details');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  //47. user_side
  Future<void> moveToCart(String customerUniqueId, String art_unique_id) async {
    final String url = "$baseUrl/moveToCart";

    final Map<String, String> payload = {
      "customer_unique_id": customerUniqueId,
      "art_unique_id": art_unique_id,
    };
    String? token = await _getToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      print("Response Body: $responseBody");
      bool status = responseBody['status'].toString().toLowerCase() == 'true';

      if (status) {
      } else {
        showToast(message: responseBody['message']);
        if (responseBody.containsKey('message')) {
          print("Message: ${responseBody['message']}");
        }
      }
    } else {
      Map<String, dynamic> responseBody = json.decode(response.body);
      print('Failed to move to wishlist: ${responseBody['message']}');
    }
  }

  //48. user_side
  Future<Map<String, dynamic>> addPrivateSaleEnquiry({
    required String name,
    required String email,
    required String mobile,
    required String artUniqueId,
    required String artist_unique_id,
    required String message,
    required String customerUniqueId,
  }) async {
    print("name : $name");
    print("email : $email");
    print("mobile : $mobile");
    print("address : $message");
    print("artist_unique_id : $artist_unique_id");
    print("artUniqueId : $artUniqueId");
    print("customerUniqueId : $customerUniqueId");
    final url = Uri.parse('$baseUrl/private_enquiry_chat');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile,
          'message': message,
          'artist_unique_id': artist_unique_id,
          'customer_unique_id': customerUniqueId,
          'art_unique_id': artUniqueId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response: $responseData');
        return json.decode(response.body);
      } else {
        print(
            'Failed to load art details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load exhibition details');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  //49. user_side
  Future<Map<String, dynamic>> addSaleEnquiry({
    required String name,
    required String email,
    // required String mobile,
    required String artUniqueId,
    required String artist_unique_id,
    required String message,
    required String fcmToken,
    required String customerUniqueId,
  }) async {
    print("name : $name");
    print("email : $email");
    print("artist_unique_id : $artist_unique_id");
    print("fcmToken : $fcmToken");
    print("address : $message");
    print("artUniqueId : $artUniqueId");
    print("customerUniqueId : $customerUniqueId");
    final url = Uri.parse('$baseUrl/art_enquiry_chat');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          // 'mobile': mobile,
          'artist_fcm_token': fcmToken,
          'message': message,
          'customer_unique_id': customerUniqueId,
          'artist_unique_id': artist_unique_id,
          'art_unique_id': artUniqueId,
        }),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response: $responseData');
        return json.decode(response.body);
      } else {
        print(
            'Failed to load art details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load exhibition details');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  //50. user_side
  Future<Map<String, dynamic>?> registerForExhibitionForFree(
      String registrationCode) async {
    final url = Uri.parse('$baseUrl/exhibtion/freeCustExhReg');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  //51. user_side
  Future<Map<String, dynamic>?> cancelForExhibition(
      String registrationCode) async {
    print(registrationCode);
    final url = Uri.parse('$baseUrl/exhibtion/cancel_exhger_customer');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        return responseData;
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  Future<Map<String, dynamic>?> cancelForExhibitionSeller(
      String registrationCode) async {
    print(registrationCode);
    final url = Uri.parse('$baseUrl/exhibtion/CancelCustExhRegArtist');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      final responseData = json.decode(response.body);
      print(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData);
        return responseData;
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  //52. user_side
  Future<Map<String, dynamic>> fetchExhibitionsTicket(
      String customerUniqueId) async {
    final response = await http.post(
      Uri.parse(
          '$baseUrl/exhibtion/getCustomerExhibitions'), // Replace with your API endpoint
      body: jsonEncode({"customer_unique_id": customerUniqueId}),
      headers: {"Content-Type": "application/json"},
    );

    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load exhibitions');
    }
  }

  Future<Map<String, dynamic>> fetchExhibitionsTicketseller(
      String customerUniqueId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/exhibtion/getCustomerExhibitionsseller'),
      body: jsonEncode({"customer_unique_id": customerUniqueId}),
      headers: {"Content-Type": "application/json"},
    );

    print(response.body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load exhibitions');
    }
  }

  //53. user_side
  Future<List<dynamic>> fetchPrivateArtEnquiries(
      String customer_unique_id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/privateArtEnquiry'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'customer_unique_id': customer_unique_id,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load art enquiries');
    }
  }

  //54. user_side
  Future<List<dynamic>> fetchArtEnquiries(String customer_unique_id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ArtEnquiry'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'customer_unique_id': customer_unique_id,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load art enquiries');
    }
  }

  //55. user_side
  Future<List<ArtReply>> fetchArtReplies(
      String customerUniqueID, String artUniqueID) async {
    print(customerUniqueID);
    print(artUniqueID);
    final response = await http.post(
      Uri.parse('$baseUrl/ArtReply'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'customer_unique_id': customerUniqueID,
        'art_unique_id': artUniqueID,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> replies = data['data'] ?? [];

      return replies.map((reply) => ArtReply.fromJson(reply)).toList();
    } else {
      throw Exception('Failed to load art replies');
    }
  }

  //56. user_side
  Future<List<ArtReply>> fetchPrivateArtReplies(
      String customerUniqueID, String artUniqueID) async {
    final response = await http.post(
      Uri.parse('$baseUrl/privateArtReply'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'customer_unique_id': customerUniqueID,
        'art_unique_id': artUniqueID,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> replies = data['data'] ?? [];

      return replies.map((reply) => ArtReply.fromJson(reply)).toList();
    } else {
      throw Exception('Failed to load art replies');
    }
  }

  //57. user_side
  Future<Map<String, dynamic>?> sendArtReply(
      String senderUniqueId,
      String receiverUniqueId,
      String message,
      String artEnquiryChatId,
      File? imageFile,
      String? fcmToken) async {
    try {
      var uri = Uri.parse('$baseUrl/sendMessage');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['sender_unique_id'] = senderUniqueId;
      request.fields['receiver_unique_id'] = receiverUniqueId;
      request.fields['message'] = message;
      request.fields['reciver_fcm_token'] = fcmToken!;
      request.fields['art_enquiry_chat_id'] = artEnquiryChatId;

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: path.basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("response : ${responseBody}");
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        print('Art reply sent successfully.');
        return jsonResponse;
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';
        print('Failed to send art reply: ${response.statusCode}');
        print('Error message: $errorMessage');

        // Show error message as toast
        showToast(message: errorMessage);

        return jsonResponse;
      }
    } catch (e) {
      print('Exception occurred while sending art reply: $e');
      throw Exception('Failed to send art reply: $e');
    }
  }

  // Future<void> sendArtReply(String sender_unique_id, String receiver_unique_id,
  //     String message, String art_enquiry_chat_id) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/sendMessage'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode({
  //         'sender_unique_id': sender_unique_id,
  //         'receiver_unique_id': receiver_unique_id,
  //         'message': message,
  //         'art_enquiry_chat_id': art_enquiry_chat_id,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // showToast(message: "Art reply sent successfully.");
  //       print('Art reply sent successfully.');
  //     } else {
  //       // Failure
  //       // showToast(message: "Failed to send art reply.");
  //       print(
  //           'Failed to send art reply: ${response.statusCode} ${response.body}');
  //       throw Exception(
  //           'Failed to send art reply: ${response.statusCode} ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Exception occurred while sending art reply: $e');
  //     throw Exception('Failed to send art reply: $e');
  //   }
  // }
  Future<Map<String, dynamic>?> sendArtPrivateReply(
      String senderUniqueId,
      String receiverUniqueId,
      String message,
      String artEnquiryChatId,
      File? imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/sendPrivateMessage');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['sender_unique_id'] = senderUniqueId;
      request.fields['receiver_unique_id'] = receiverUniqueId;
      request.fields['message'] = message.isEmpty ? "" : message;
      request.fields['private_enquiry_chat_id'] = artEnquiryChatId;

      // If there's an image file, add it to the request
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: path.basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("Response: $responseBody");

      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        print('Art reply sent successfully.');
        return jsonResponse;
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';

        print('Failed to send art reply: ${response.statusCode}');
        print('Error message: $errorMessage');
        showToast(message: errorMessage);

        return jsonResponse;
      }
    } catch (e) {
      print('Exception occurred while sending art reply: $e');
      throw Exception('Failed to send art reply: $e');
    }
  }

  Future<Map<String, dynamic>?> sendArtPrivateReplyArtist(
      String senderUniqueId,
      String receiverUniqueId,
      String message,
      String artEnquiryChatId,
      File? imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/SellersendPrivateMessage');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['sender_unique_id'] = senderUniqueId;
      request.fields['receiver_unique_id'] = receiverUniqueId;
      request.fields['message'] = message;
      request.fields['private_enquiry_chat_id'] = artEnquiryChatId;

      // If there's an image file, add it to the request
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images', // 'image' is the field name expected by the API
          stream,
          length,
          filename: path.basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("Response: $responseBody");

      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        print('Art reply sent successfully.');
        return jsonResponse;
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';

        print('Failed to send art reply: ${response.statusCode}');
        print('Error message: $errorMessage');
        showToast(message: errorMessage);

        return jsonResponse;
      }
    } catch (e) {
      print('Exception occurred while sending art reply: $e');
      throw Exception('Failed to send art reply: $e');
    }
  }
  // Future<void> sendArtPrivateReply(String sender_unique_id, String receiver_unique_id,
  //     String message, String art_enquiry_chat_id) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/sendPrivateMessage'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode({
  //         'sender_unique_id': sender_unique_id,
  //         'receiver_unique_id': receiver_unique_id,
  //         'message': message,
  //         'private_enquiry_chat_id': art_enquiry_chat_id,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // showToast(message: "Art reply sent successfully.");
  //       print('Art reply sent successfully.');
  //     } else {
  //       // Failure
  //       // showToast(message: "Failed to send art reply.");
  //       print(
  //           'Failed to send art reply: ${response.statusCode} ${response.body}');
  //       throw Exception(
  //           'Failed to send art reply: ${response.statusCode} ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Exception occurred while sending art reply: $e');
  //     throw Exception('Failed to send art reply: $e');
  //   }
  // }

  //58. user_side
  Future<void> addArtistArtStory(String artUniqueID, String paragraph) async {
    print(artUniqueID);
    final String url = '$baseUrl/add_artist_art_stories';
    final Map<String, dynamic> payload = {
      "art_unique_id": artUniqueID,
      "paragraph": paragraph,
    };
    String? token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(payload),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print(response.body);
        showToast(message: "Art story added successfully");
        print("Art story added successfully");
      } else {
        showToast(message: "Failed to add art story");
        print("Failed to add art story: ${response.statusCode}");
      }
    } catch (e) {
      showToast(message: "Error occurred while adding art story");
      print("Error occurred while adding art story: $e");
    } finally {}
  }

  //59. Seller_side
  Future<Map<String, dynamic>> getTermsConditions(String role) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/get_term_conditions'),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'role': role}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load terms and conditions');
    }
  }

  Future<Map<String, dynamic>> getTermsConditionsForExhibition(
      String exhibition_unique_id) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/get_exhibition_term'),
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'exhibition_unique_id': exhibition_unique_id}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load terms and conditions');
    }
  }

  //60. Seller_side
  Future<Map<String, dynamic>> getAds() async {
    final response = await http.get(
      Uri.parse('$baseUrl/get_ads'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load ads');
    }
  }

  //61.
  Future<List<Map<String, dynamic>>> fetchForUploadArtExhibitions(
      String customerUniqueId) async {
    String? token = await _getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token is missing or invalid");
    }

    final response = await http.post(
      Uri.parse('$baseUrl/exhibtion/userregistered'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'customer_unique_id': customerUniqueId,
      }),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      print('Response Data: $responseData');

      if (responseData['status'] == true &&
          responseData['data'] != null &&
          responseData['data'].isNotEmpty) {
        return List<Map<String, dynamic>>.from(responseData['data']);
      } else {
        print('No exhibitions found or data is empty');
        return [];
      }
    } else {
      throw Exception(
          'Failed to load exhibitions: HTTP Status ${response.statusCode}');
    }
  }

  //62.
  Future<Map<String, dynamic>?> registerForExhibitionForPaid(
      String registrationCode, String payment_id, String amount) async {
    final url = Uri.parse('$baseUrl/exh_success_app');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
      "amount": amount,
      "payment_id": payment_id,
      "payment_type": "Card",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData; // Return the full response data
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  //63.
  Future<Map<String, dynamic>?> registerTicket(String registrationCode) async {
    print("registrationCode : $registrationCode");
    final url = Uri.parse('$baseUrl/exhibtion/getSingleTicket');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData; // Return the full response data
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  Future<Map<String, dynamic>?> registerTicketSeller(
      String registrationCode) async {
    print("registrationCode : $registrationCode");
    final url = Uri.parse('$baseUrl/exhibtion/getSingleTicketseller');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData; // Return the full response data
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  //64.
  Future<Map<String, dynamic>?> addDeliveryAddress({
    required String customerUniqueId,
    required String fullName,
    required String mobile,
    required String country,
    required String state,
    required String city,
    required String address,
    required String pincode,
  }) async {
    const String url = '$serverUrl/add_delivery_address';
    String? token = await _getToken();
    print("customerUniqueId : $customerUniqueId");
    Map<String, dynamic> payload = {
      'customer_unique_id': customerUniqueId,
      'full_name': fullName,
      'mobile': mobile,
      'country': country,
      'state': state,
      'city': city,
      'address': address,
      'pincode': pincode,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        if (responseBody['status'] == true) {
          return responseBody;
        } else {
          print('Error: ${responseBody['message']}');
          return null;
        }
      } else {
        print('Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  //65.
  Future<Map<String, dynamic>> checkQuantity(String customerUniqueId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check_quantity'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'customer_unique_id': customerUniqueId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check quantity');
    }
  }

  //66.
  Future<void> callOrderSuccessApi(String paymentId, String total,
      String customerDeliveryAddressId, List<String> fcmTokenList) async {
    final String apiUrl = '$baseUrl/order_success_app';
    String? token = await _getToken();
    print(fcmTokenList);
    try {
      final Map<String, dynamic> payload = {
        'payment_id': paymentId,
        'payment_method': "Card",
        'amount': total,
        "customer_fcm_tokens": fcmTokenList,
        'customer_delivery_address_id': customerDeliveryAddressId,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status']) {
          print('Order successful');
        } else {
          print('Order failed: ${responseData['message']}');
        }
      } else {
        print('Failed to call API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  //67.
  Future<void> donationSuccessApp({
    required String paymentId,
    required String total,
    required String email,
    required String comment,
    required String name,
    required String company_name,
    File? donationLogo,
  }) async {
    final String apiUrl = '$baseUrl/donation_success_app';
    String? token = await _getToken();

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Add text fields to the multipart request
      request.fields['payment_id'] = paymentId;
      request.fields['payment_method'] = "Card";
      request.fields['amount'] = total;
      request.fields['email'] = email;
      request.fields['comment'] = comment;
      request.fields['name'] = name;
      request.fields['company_name'] = company_name;

      // Add the file if available
      if (donationLogo != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'donation_logo',
            donationLogo.path,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);

        if (responseData['status'] == "true") {
          showToast(message: "Donation Received \nThank You.");
          print('Donation successful');
        } else {
          showToast(message: responseData['message']);
          print('Donation failed: ${responseData['message']}');
        }
      } else {
        print('Failed to call API: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
  // Future<void> donation_success_app(String paymentId, String total,
  //     String email, String comment, String name) async {
  //   final String apiUrl = '$baseUrl/donation_success_app';
  //   String? token = await _getToken();
  //   try {
  //     final Map<String, dynamic> payload = {
  //       'payment_id': paymentId,
  //       'payment_method': "Card",
  //       'amount': total,
  //       'email': email,
  //       'comment': comment,
  //       'name': name,
  //     };
  //
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode(payload),
  //     );
  //
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       final responseData = json.decode(response.body);
  //       if (responseData['status'] == "true") {
  //         showToast(message: "Donation Received \nThank You.");
  //         print('Donate successful');
  //       } else {
  //         showToast(message: responseData['message']);
  //         print('Donate failed: ${responseData['message']}');
  //       }
  //     } else {
  //       print('Failed to call API: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error occurred: $e');
  //   }
  // }

  //68.
  Future<void> boostSuccessApp({
    required String paymentId,
    required String days,
    required String views,
    required String price,
    required String artUniqueId,
    required String customerUniqueId,
  }) async {
    print("paymentId : $paymentId");
    print("days : $days");
    print("views : $views");
    print("price : $price");
    print("artUniqueId : $artUniqueId");
    print("customerUniqueId : $customerUniqueId");
    final url = Uri.parse('$baseUrl/boost_success_app');

    // Prepare the payload
    final Map<String, dynamic> payload = {
      'payment_id': paymentId,
      'payment_method': "Card",
      'days': days,
      'views': views,
      'price': price,
      'art_unique_id': artUniqueId,
      'customer_unique_id': customerUniqueId,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Success: $data');
      } else {
        print('Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Request failed: $e');
    }
  }

  //69.
  Future<OrderResponse> fetchOrders(String customerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_customer_allorder'),
      body: jsonEncode({'customer_unique_id': customerId, "role": "customer"}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return OrderResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load orders');
    }
  }

  //70.
  Future<OrderResponse> fetchSellerOrders(String customerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_seller_allorders'),
      body: jsonEncode({'customer_unique_id': customerId, "role": "seller"}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return OrderResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load orders');
    }
  }

  //71.
  Future<List<dynamic>> fetchBookingRequest(
      String customerUniqueId, String role) async {
    final url = '$baseUrl/seller_order';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'customer_unique_id': customerUniqueId,
          'role': role,
        }),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          return responseData['arts'];
        } else {
          print('Error: ${responseData['message']}');
          return [];
        }
      } else {
        print('Failed to load data');
        return [];
      }
    } catch (error) {
      print('Error: $error');
      return [];
    }
  }

  //72.
  Future<void> addTrackingSystem(
    String customer_unique_id,
    String order_unique_id,
    String art_unique_id,
    String tracking_id,
    String tracking_link,
    String company_name,
    String fcmToken,
  ) async {
    final String url = '$baseUrl/add_tracking_system';
    final Map<String, dynamic> payload = {
      "customer_unique_id": customer_unique_id,
      "order_unique_id": order_unique_id,
      "art_unique_id": art_unique_id,
      "tracking_id": tracking_id,
      "tracking_link": tracking_link,
      "company_name": company_name,
      "fcm_token": fcmToken
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['status'] == true) {
          print(responseBody['message']);
          showToast(message: responseBody['message']);
        } else {
          showToast(message: responseBody['message']);
          print('Failed to add tracking system.');
        }
      } else {
        print('Failed to connect to the server.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  //73.
  Future<void> confirmOrder(String customer_unique_id, String art_unique_id,
      String type, String FCMToken) async {
    final String url = '$baseUrl/seller_confirms_order';
    final Map<String, dynamic> payload = {
      "customer_unique_id": customer_unique_id,
      "art_unique_id": art_unique_id,
      "type": type,
      "customer_fcm_token": FCMToken
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['status'] == true) {
          print(responseBody['message']);
          showToast(message: responseBody['message']);
        } else {
          showToast(message: responseBody['message']);
          print('Failed to confirm the order.');
        }
      } else {
        print('Failed to connect to the server.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  //74.
  Future<Map<String, dynamic>> fetchWalletDetails(
      String customerUniqueId, String role) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_wallet_deatils'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'customer_unique_id': customerUniqueId,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load wallet details');
    }
  }

  //74.
  Future<Map<String, dynamic>> getSingleTransactionDetails(
      String customer_unique_id, String ordered_art_id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/getSingleTransactionDetails'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'customer_unique_id': customer_unique_id,
        'role': "seller",
        'ordered_art_id': ordered_art_id,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load wallet details');
    }
  }

  //75.
  Future<void> addWidthrawlRequest({
    required String customerUniqueId,
    required String role,
    required String widthrawlAmount,
    required String totalAmount,
  }) async {
    final url = Uri.parse('$baseUrl/addWidthrawlRequest');
    final headers = {"Content-Type": "application/json"};
    final body = jsonEncode({
      'customer_unique_id': customerUniqueId,
      'role': role,
      'widthrawl_amount': widthrawlAmount,
      'total_amount': totalAmount,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        showToast(message: responseBody['message']);
        print('Request successful: ${response.body}');
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  //76.
  Future<Map<String, dynamic>> fetchHomeCounts(
      String customer_unique_id) async {
    final url = '$baseUrl/homecounts';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json
          .encode({"customer_unique_id": customer_unique_id, "role": "seller"}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  //77.
  Future<Map<String, dynamic>> fetchOrderTrackDetails(
      String art_unique_id) async {
    final url = '$baseUrl/customer_getting_seller_details';
    String? token = await _getToken();
    print(token);
    print(art_unique_id);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"art_unique_id": art_unique_id, "role": "seller"}),
    );
    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  //78.
  Future<List<Map<String, dynamic>>> getSearchSuggestions(String query) async {
    final response =
        await http.get(Uri.parse('$baseUrl/get_search_suggestion/$query'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to load search suggestions');
    }
  }

  //79.
  // Future<List<SearchSuggestion>> fetchSearchSuggestions(String query) async {
  //   const speedLimitInBytes = 5000000 ~/ 8; // 1 Mbps in bytes per second
  //
  //   final url = Uri.parse('$baseUrl/get_search_suggestion/$query');
  //   String? token = await _getToken();
  //   print('Token: $token');
  //
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token', // Assuming token is needed for authorization
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Simulate downloading data at a limited speed
  //       final totalSize = response.bodyBytes.length;
  //       int downloaded = 0;
  //       List<SearchSuggestion> suggestions = [];
  //
  //       while (downloaded < totalSize) {
  //         // Ensure the chunk size does not exceed the remaining data
  //         final chunkEnd = (downloaded + speedLimitInBytes) > totalSize
  //             ? totalSize
  //             : downloaded + speedLimitInBytes;
  //
  //         // Download the data in chunks based on the speed limit
  //         final chunk = response.bodyBytes.sublist(downloaded, chunkEnd);
  //
  //         // Simulate download speed with a delay (adjust the milliseconds as needed)
  //         await Future.delayed(Duration(milliseconds: 100)); // Simulating download speed
  //
  //         downloaded += chunk.length;
  //
  //         // Process chunk here (e.g., parse JSON and store it)
  //         String chunkStr = String.fromCharCodes(chunk);
  //         final data = json.decode(chunkStr);
  //
  //         // Assuming the response contains 'suggestions' key with the data
  //         final List<dynamic> suggestionList = data['suggestions'];
  //         suggestions.addAll(suggestionList.map((json) => SearchSuggestion.fromJson(json)).toList());
  //       }
  //
  //       return suggestions;
  //     } else {
  //       throw Exception('Failed to load search suggestions');
  //     }
  //   } catch (e) {
  //     print('Error fetching data: $e');
  //     throw Exception('Error fetching search suggestions');
  //   }
  // }
  Future<List<SearchSuggestion>> fetchSearchSuggestions(String query) async {
    final response =
        await http.get(Uri.parse('$baseUrl/get_search_suggestion/$query'));

    print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => SearchSuggestion.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  //80.
  Future<List<searchArt>> fetchSearchArtData(String searchQuery) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_search_art_data"),
      body: json.encode({"search": searchQuery}),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == true) {
        List<dynamic> products = data['MainproductsAllData'];
        return products.map((item) => searchArt.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load art data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> send_otp_email_reg(
    String email,
  ) async {
    final url = Uri.parse('$baseUrl/send-email-open-otp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);
    if (response.statusCode == 200) {
      showToast(message: responseData['message']);
      return {
        'status': responseData['status'].toString(),
        'message': responseData['message'],
      };
      // if (responseData['status'] == 'true') {
      //   // showToast(message: responseData['message']);
      //   // showToast(message: responseData['otp']);
      //   showToast(message: responseData['message']);
      //   return responseData['message'];
      // } else {
      //   showToast(message: responseData['message']);
      //   throw Exception('Failed to send OTP: ${responseData['message']}');
      // }
    } else {
      showToast(message: responseData['message']);
      throw Exception('Failed to send OTP');
    }
  }

  //81.
  Future<Map<String, dynamic>> send_otp_email(
    String email,
  ) async {
    final url = Uri.parse('$baseUrl/sendForgetPasswordOtpemail');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    print(responseData);
    if (response.statusCode == 200) {
      showToast(message: responseData['message']);
      return responseData;
      // if (responseData['status'] == 'true') {
      //   // showToast(message: responseData['message']);
      //   // showToast(message: responseData['otp']);
      //   showToast(message: responseData['message']);
      //   return responseData['message'];
      // } else {
      //   showToast(message: responseData['message']);
      //   throw Exception('Failed to send OTP: ${responseData['message']}');
      // }
    } else {
      showToast(message: responseData['message']);
      throw Exception('Failed to send OTP');
    }
  }

  Future<Map<String, dynamic>> verifyOtpEmailReg(
      String email, String otp) async {
    final url = Uri.parse('$baseUrl/verifyopenEmailOtp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'otp': otp}),
      );

      final Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);

      if (response.statusCode == 200) {
        showToast(message: responseData['message']);
        return {
          'status': responseData['status'].toString(),
          'message': responseData['message'],
        };
      } else {
        showToast(message: responseData['message']);
        throw Exception('Failed to verify OTP');
      }
    } catch (e) {
      showToast(message: e.toString());
      throw Exception('Error verifying OTP: $e');
    }
  }

  // Future<String> verify_otp_email_reg(String email, String otp) async {
  //   final url = Uri.parse('$baseUrl/verifyopenEmailOtp');
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //     },
  //     body: jsonEncode({
  //       'email': email,
  //       'otp': otp,
  //     }),
  //   );
  //
  //   final Map<String, dynamic> responseData = json.decode(response.body);
  //   if (response.statusCode == 200) {
  //     if (responseData['status'] == 'true') {
  //       showToast(message: responseData['message']);
  //       return responseData['message'];
  //     } else {
  //       showToast(message: responseData['message']);
  //       throw Exception('Failed to verify OTP: ${responseData['message']}');
  //     }
  //   } else {
  //     showToast(message: responseData['message']);
  //     throw Exception('Failed to verify OTP');
  //   }
  // }

  //82. user_side
  Future<String> verifyOtp_email(String email, String otp) async {
    final url = Uri.parse('$baseUrl/verifyForgetPasswordemailOtp');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      if (responseData['status'] == 'true') {
        showToast(message: responseData['message']);
        return responseData['message'];
      } else {
        showToast(message: responseData['message']);
        throw Exception('Failed to verify OTP: ${responseData['message']}');
      }
    } else {
      showToast(message: responseData['message']);
      throw Exception('Failed to verify OTP');
    }
  }
  // Future<Map<String, dynamic>> getGoogleLoginCallback(String callbackUrl) async {
  //   print("object");
  //   final url = Uri.parse('$baseUrl/google_login_call_back');
  //   try {
  //     print("object");
  //     final response = await http.get(url);
  //     print("statusCode : ${response.statusCode}");
  //     print("body : ${response.body}");
  //     if (response.statusCode == 200) {
  //       print("object");
  //       return jsonDecode(response.body);
  //     } else {
  //       throw Exception('Failed to load data');
  //     }
  //   } catch (e) {
  //     throw Exception('Error: $e');
  //   }
  // }

  //83.
  Future<Map<String, dynamic>> updateFCM(
      String customerId, String fcmToken) async {
    final url = Uri.parse('$baseUrl/update_fcm');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'customer_unique_id': customerId,
          'fcm_token': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to update FCM token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<Map<String, dynamic>> fetchOrderTrackDetailsForSeller(
      String art_unique_id) async {
    final url = '$baseUrl/seller_getting_customer__details';
    String? token = await _getToken();
    print(token);
    print(art_unique_id);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"art_unique_id": art_unique_id, "role": "seller"}),
    );
    print(response.body);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updateSellerStatus(
      String artUniqueId, String trackingStatus, String fcmToken) async {
    const String apiUrl =
        "$serverUrl/seller_update_status";

    final Map<String, String> payload = {
      'art_unique_id': artUniqueId,
      'tracking_status': trackingStatus,
      "fcm_token": fcmToken
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          // Success
          showToast(message: "Status updated successfully");
        } else {
          // Error from API
          showToast(message: data['message'] ?? "Failed to update status");
        }
      } else {
        // HTTP error
        showToast(
            message:
                "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      // Exception handling
      showToast(message: "An error occurred: $e");
    }
  }

  // Future<void> updateSellerStatusReturn(
  //     String artUniqueId, String trackingStatus) async {
  //   const String apiUrl =
  //       "$serverUrl/seller_update_status"; // Replace with your endpoint URL
  //
  //   final Map<String, String> payload = {
  //     'art_unique_id': artUniqueId,
  //     'tracking_status': trackingStatus,
  //   };
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(apiUrl),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //       body: json.encode(payload),
  //     );
  //
  //     // Handle the response
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       if (data['status'] == true) {
  //         // Success
  //         showToast(message: "Status updated successfully");
  //       } else {
  //         // Error from API
  //         showToast(message: data['message'] ?? "Failed to update status");
  //       }
  //     } else {
  //       // HTTP error
  //       showToast(
  //           message:
  //           "Error: ${response.statusCode} - ${response.reasonPhrase}");
  //     }
  //   } catch (e) {
  //     // Exception handling
  //     showToast(message: "An error occurred: $e");
  //   }
  // }

  Future<Map<String, dynamic>> getCustomerEnquiry(
      String customerUniqueId) async {
    const url = "$serverUrl/get_customer_all_enquiry";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "customer_unique_id": customerUniqueId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<List<ArtReply>> fetchSingleArtReplies(
      String reciver_unique_id, String art_enquiry_chat_id) async {
    print(reciver_unique_id);
    print(art_enquiry_chat_id);
    final response = await http.post(
      Uri.parse('$baseUrl/get_single_enquiry_chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'reciver_unique_id': reciver_unique_id,
        'art_enquiry_chat_id': art_enquiry_chat_id,
      }),
    );

    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> replies = data['chatDetails'] ?? [];

      return replies.map((reply) => ArtReply.fromJson(reply)).toList();
    } else {
      throw Exception('Failed to load art replies');
    }
  }

  Future<List<ArtReply>> fetchSingleArtRepliesArtist(
      String reciver_unique_id, String art_enquiry_chat_id) async {
    print(reciver_unique_id);
    print(art_enquiry_chat_id);
    final response = await http.post(
      Uri.parse('$baseUrl/seller_get_single_art_enquiry_chat_app'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'reciver_unique_id': reciver_unique_id,
        'art_enquiry_chat_id': art_enquiry_chat_id,
      }),
    );

    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);
      final List<dynamic> replies = data['chatDetails'] ?? [];

      return replies.map((reply) => ArtReply.fromJson(reply)).toList();
    } else {
      throw Exception('Failed to load art replies');
    }
  }

  Future<List<ArtReply>> fetchSinglePrivateArtReplies(
      String reciver_unique_id, String art_enquiry_chat_id) async {
    print(reciver_unique_id);
    print(art_enquiry_chat_id);
    final response = await http.post(
      Uri.parse('$baseUrl/get_single_private_enquiry_chat'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'reciver_unique_id': reciver_unique_id,
        'private_enquiry_chat_id': art_enquiry_chat_id,
      }),
    );

    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> replies = data['chatDetails'] ?? [];

      return replies.map((reply) => ArtReply.fromJson(reply)).toList();
    } else {
      throw Exception('Failed to load art replies');
    }
  }

  Future<List<ArtReply>> fetchSinglePrivateArtRepliesArtist(
      String reciver_unique_id, String art_enquiry_chat_id) async {
    print(reciver_unique_id);
    print(art_enquiry_chat_id);
    final response = await http.post(
      Uri.parse('$baseUrl/seller_get_single_private_enquiry_chat_app'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'reciver_unique_id': reciver_unique_id,
        'private_enquiry_chat_id': art_enquiry_chat_id,
      }),
    );

    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print(data);
      final List<dynamic> replies = data['chatDetails'] ?? [];

      print(replies);
      return replies.map((reply) => ArtReply.fromJson(reply)).toList();
    } else {
      throw Exception('Failed to load art replies');
    }
  }

  Future<List<String>> getExhibitionDates(
      String exhibitionUniqueId, String type) async {
    final String endpoint = 'get_exhibition_date';
    final Map<String, String> body = {
      'exhibition_unique_id': exhibitionUniqueId,
      'type': type,
    };

    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['status']) {
          List<String> dates = [];
          for (var item in data['data']) {
            dates.add(item['date']);
          }
          return dates;
        } else {
          throw Exception('Failed to load dates');
        }
      } else {
        throw Exception('Failed to load dates');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<HelpEnquiryResponse> fetchSingleHelpReplies(
      String receiverUniqueId, String helpCenterChatId) async {
    final url = Uri.parse(
        '$serverUrl/get_single_help_enquiry_chat_app');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'reciver_unique_id': receiverUniqueId,
          'help_center_chat_id': helpCenterChatId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return HelpEnquiryResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to fetch help enquiry data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<HelpEnquiryResponse> fetchSingleHelpRepliesArtist(
      String receiverUniqueId, String helpCenterChatId) async {
    final url = Uri.parse(
        '$serverUrl/seller_get_single_help_enquiry_chat_app');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'reciver_unique_id': receiverUniqueId,
          'help_center_chat_id': helpCenterChatId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return HelpEnquiryResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to fetch help enquiry data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<HelpEnquiryResponse> fetchSingleReturnOrderReplies(
      String receiverUniqueId, String helpCenterChatId) async {
    final url = Uri.parse(
        '$serverUrl/get_single_return_enquiry_chat_app');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'reciver_unique_id': receiverUniqueId,
          'return_order_id': helpCenterChatId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        return HelpEnquiryResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to fetch help enquiry data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<Map<String, dynamic>?> sendHelpCenterReply(
      String senderUniqueId,
      String receiverUniqueId,
      String message,
      String artEnquiryChatId,
      File? imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/sendHelpMessage');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['sender_unique_id'] = senderUniqueId;
      request.fields['receiver_unique_id'] = receiverUniqueId;
      request.fields['message'] = message;
      request.fields['help_center_chat_id'] = artEnquiryChatId;

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: path.basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("response : ${responseBody}");
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        print('Art reply sent successfully.');
        return jsonResponse;
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';
        print('Failed to send art reply: ${response.statusCode}');
        print('Error message: $errorMessage');

        // Show error message as toast
        showToast(message: errorMessage);

        return jsonResponse;
      }
    } catch (e) {
      print('Exception occurred while sending art reply: $e');
      throw Exception('Failed to send art reply: $e');
    }
  }

  Future<Map<String, dynamic>?> sendHelpCenterReplyArtist(
      String senderUniqueId,
      String receiverUniqueId,
      String message,
      String artEnquiryChatId,
      File? imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/SellersendhelpMessage');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['sender_unique_id'] = senderUniqueId;
      request.fields['receiver_unique_id'] = receiverUniqueId;
      request.fields['message'] = message;
      request.fields['help_center_chat_id'] = artEnquiryChatId;

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: path.basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("response : ${responseBody}");
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        print('Art reply sent successfully.');
        return jsonResponse;
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';
        print('Failed to send art reply: ${response.statusCode}');
        print('Error message: $errorMessage');

        // Show error message as toast
        showToast(message: errorMessage);

        return jsonResponse;
      }
    } catch (e) {
      print('Exception occurred while sending art reply: $e');
      throw Exception('Failed to send art reply: $e');
    }
  }

  Future<Map<String, dynamic>?> sendReturnOrderReply(
      String senderUniqueId,
      String receiverUniqueId,
      String message,
      String reciver_fcm_token,
      String artEnquiryChatId,
      File? imageFile) async {
    try {
      var uri = Uri.parse('$baseUrl/sendReturnMessage');
      var request = http.MultipartRequest('POST', uri);

      // Add text fields
      request.fields['sender_unique_id'] = senderUniqueId;
      request.fields['receiver_unique_id'] = receiverUniqueId;
      request.fields['message'] = message;
      request.fields['reciver_fcm_token'] = reciver_fcm_token;
      request.fields['return_order_id'] = artEnquiryChatId;

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: path.basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("response : ${responseBody}");
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        print('Art reply sent successfully.');
        return jsonResponse;
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';
        print('Failed to send art reply: ${response.statusCode}');
        print('Error message: $errorMessage');

        // Show error message as toast
        showToast(message: errorMessage);

        return jsonResponse;
      }
    } catch (e) {
      print('Exception occurred while sending art reply: $e');
      throw Exception('Failed to send art reply: $e');
    }
  }

  Future<void> updateArtistName(
      String customerUniqueId, String artistName) async {
    const String url = "$serverUrl/artist_name_update";

    final Map<String, dynamic> payload = {
      "customer_unique_id": customerUniqueId,
      "artist_name": artistName,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print("Artist name updated successfully: $responseData");
        String message = responseData['message'];
        showToast(message: message);
        print("$message");
      } else {
        print("Failed to update artist name: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (error) {
      print("Error occurred: $error");
    }
  }

  Future<HelpEnquiryResponse> fetchSingleReturnOrderRepliesSeller(
      String receiverUniqueId, String helpCenterChatId) async {
    final url = Uri.parse(
        '$serverUrl/seller_get_single_return_enquiry_chat_app');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'reciver_unique_id': receiverUniqueId,
          'return_order_id': helpCenterChatId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        print(jsonResponse);
        return HelpEnquiryResponse.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to fetch help enquiry data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  Future<void> addTrackingSystemReturn(
    String customer_unique_id,
    String order_unique_id,
    String tracking_id,
    String tracking_link,
    String company_name,
    String customer_fcm_token,
  ) async {
    final String url = '$baseUrl/seller_confirm_return_enquiry';
    final Map<String, dynamic> payload = {
      "customer_unique_id": customer_unique_id,
      "return_order_id": order_unique_id,
      "return_tracking_id": tracking_id,
      "return_tracking_link": tracking_link,
      "return_company_name": company_name,
      "customer_fcm_token": customer_fcm_token
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (responseBody['status'] == true) {
          print(responseBody['message']);
          showToast(message: responseBody['message']);
        } else {
          showToast(message: responseBody['message']);
          print('Failed to add tracking system.');
        }
      } else {
        print('Failed to connect to the server.');
      }
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  Future<void> updateSellerStatusReturn(
      String artUniqueId, String trackingStatus, String fcmToken) async {
    const String apiUrl =
        "$serverUrl/seller_update_retrun_status";

    final Map<String, String> payload = {
      'art_unique_id': artUniqueId,
      'fcm_token': fcmToken,
      'tracking_status': trackingStatus,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      // Handle the response
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          // Success
          showToast(message: "Status updated successfully");
        } else {
          // Error from API
          showToast(message: data['message'] ?? "Failed to update status");
        }
      } else {
        // HTTP error
        showToast(
            message:
                "Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (e) {
      // Exception handling
      showToast(message: "An error occurred: $e");
    }
  }

  Future<Map<String, dynamic>> getCustomerEnquiryArtist(
      String customerUniqueId) async {
    const url = "$serverUrl/seller_get_all_enquiry";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "customer_unique_id": customerUniqueId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message']);
      }
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<Map<String, dynamic>?> uploadArtDetailsExhibition(
      Map<String, dynamic> payload) async {
    String? token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse("$serverUrl/addExhibitionArtwork"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error occurred during upload: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>> uploadImageExhibition({
    required String artUniqueId,
    required String artType,
    required File image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/artwork/add-image'),
      );

      // Add fields
      request.fields['art_unique_id'] = artUniqueId;
      request.fields['art_type'] = artType;

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
      ));

      // Add headers
      String? token = await _getToken();
      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var decodedData = json.decode(responseData);
        return decodedData;
      } else {
        return {
          'status': false,
          'message':
              'Failed to upload image. Server responded with ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error: $e');
      return {
        'status': false,
        'message': 'An error occurred while uploading the image.',
      };
    }
  }

  Future<ArtReviewModel> fetchArtDetailsExhibition(String artUniqueId) async {
    String? token = await _getToken();
    print(token);
    final response = await http.post(
      Uri.parse('$baseUrl/exhibition_art_detail'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'art_unique_id': artUniqueId}),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      print(responseData);
      if (responseData['status'] == true) {
        return ArtReviewModel.fromJson(responseData['artallDetails']);
      } else {
        throw Exception('Failed to load art details');
      }
    } else {
      throw Exception('Failed to fetch data from API');
    }
  }

  Future<Map<String, dynamic>> submitExhibition({
    required String customerUniqueId,
    required String exhibitionUniqueId,
  }) async {
    final url = Uri.parse('$baseUrl/exhibition_submit');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'customer_unique_id': customerUniqueId,
          'exhibition_unique_id': exhibitionUniqueId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        return {
          'status': false,
          'message': 'Failed with status code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> registerSellerExhibitions({
    required String name,
    required String email,
    required String mobile,
    String? selectedSheet,
    required String exhibitionUniqueId,
    required String address,
    // required String role,
    required String customerUniqueId,
    required String artist_name,
    required String portfolio_link,
    required String social_link,
  }) async {
    print("name : $name");
    print("email : $email");
    print("mobile : $mobile");
    print("selectedSheet : $selectedSheet");
    print("exhibitionUniqueId : $exhibitionUniqueId");
    print("address : $address");
    print("customerUniqueId : $customerUniqueId");
    print("artist_name : $artist_name");
    print("portfolio_link : $portfolio_link");
    print("social_link : $social_link");
    final url = Uri.parse('$baseUrl/artist_exh_reg');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'mobile': mobile,
          'artist_name': artist_name,
          'portfolio_link': portfolio_link,
          'social_link': social_link,
          'exhibition_unique_id': exhibitionUniqueId,
          'address': address,
          'booth_seat_id': selectedSheet,
          'customer_unique_id': customerUniqueId,
          // 'role': role
          // 'customer',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response: $responseData');
        return json.decode(response.body);
      } else {
        print(
            'Failed to load exhibition details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load exhibition details');
      }
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>?> registerForExhibitionForPaidSeller(
      String registrationCode, String payment_id, String amount) async {
    final url = Uri.parse('$baseUrl/artist_exh_success_app');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
      "amount": amount,
      "payment_id": payment_id,
      "payment_type": "Card",
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  Future<Map<String, dynamic>?> registerForExhibitionForFreeSeller(
      String registrationCode) async {
    final url = Uri.parse('$baseUrl/artistfreeExhReg');

    // Payload
    final Map<String, dynamic> payload = {
      "registration_code": registrationCode,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred while registering: $error');
    }

    return null;
  }

  Future<String?> fetchExhibitionPercentage(String exhibitionUniqueId) async {
    final url = Uri.parse('$baseUrl/get_exhibition_per');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "exhibition_unique_id": exhibitionUniqueId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status']) {
          print('Response Data: $data');
          return data['percantage'];
        } else {
          print('API Error: ${data['message']}');
          return null;
        }
      } else {
        print(
            'Error: Server responded with status code ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> uploadImageForMookUp({
    required String artUniqueId,
    required String customer_id,
    required File image,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        // Uri.parse('https://artistai.genixbit.com/upload-painting/'),
        Uri.parse('https://ai.miramonet.com/upload-painting/'),
      );

      // Add fields
      request.fields['customer_id'] = customer_id;
      request.fields['art_id'] = artUniqueId;

      // Add file
      request.files.add(await http.MultipartFile.fromPath(
        'painting',
        image.path,
      ));

      // Add headers
      // String? token = await _getToken();
      // request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var decodedData = json.decode(responseData);
        return decodedData;
      } else {
        var decodedData = json.decode(responseData);
        return decodedData;
      }
    } catch (e) {
      print('Error: $e');
      return {
        'status': false,
        'message': 'An error occurred while uploading the image.',
      };
    }
  }

  Future<List<ArtistArtModel>> fetchMyArtDataForStory(
    String CustomerUID,
  ) async {
    String? token = await _getToken();
    final url = '$serverUrl/get_artist_artdeatils';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    print("CustomerUID : $CustomerUID");
    final payload = {
      'customer_unique_id': CustomerUID,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: json.encode(payload),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      if (decodedResponse['artdata'] != null) {
        List<dynamic> data = decodedResponse['artdata'];
        return data.map((json) => ArtistArtModel.fromJson(json)).toList();
      } else {
        throw Exception('No art data found in the response');
      }
      // List<dynamic> data = json.decode(response.body)['artdata'];
      // return data.map((json) => ArtistArtModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load art data');
    }
  }

  Future<Map<String, dynamic>?> getSingleArt(
      String artUniqueId, String customerUniqueId) async {
    final url = Uri.parse('$baseUrl/get_single_art');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "art_unique_id": artUniqueId,
          "customer_unique_id": customerUniqueId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status']) {
          return data; // Return the API response
        } else {
          print('Error: ${data['message']}');
          return null;
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }

  static Future<bool> fetchStripeKeys() async {
    try {
      final response = await http.get(Uri.parse("${baseUrl}/get_key"));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == true) {
          String pubKey = data["data"]["stripe_key"];
          String secKey = data["data"]["secret_key"];

          // Save the keys in StripeKeys class
          StripeKeys.setKeys(pubKey, secKey);

          print("Publishable Key: $pubKey");
          print("Secret Key: $secKey");

          return true;
        }
      }
    } catch (e) {
      print("Error fetching keys: $e");
    }
    return false;
  }

  Future<Map<String, dynamic>> addBankDetails({
    required String customerUniqueId,
    required String accountHolderName,
    required String bankName,
    required String accountNumber,
    required String bankCode,
    String? digitalPaymentId,
  }) async {
    final url = Uri.parse("$baseUrl/updateBankDetails");
    String? token = await _getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'customer_unique_id': customerUniqueId,
      'account_holder_name': accountHolderName,
      'bank_name': bankName,
      'account_number': accountNumber,
      'bank_code': bankCode,
      'digital_payment_id': digitalPaymentId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      print(response);
      print(response.statusCode);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'error': 'Failed to add bank details',
          'status': response.statusCode
        };
      }
    } catch (e) {
      return {'error': 'Something went wrong: $e'};
    }
  }

  Future<Map<String, dynamic>> getBankDetails(
      {required String customerUniqueId}) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/getBankDetails'),
      body: jsonEncode({'customer_unique_id': customerUniqueId}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return jsonDecode(response.body);
  }

  Future<http.Response> miramonetChat(
    String customerUniqueId,
  ) async {
    final url = Uri.parse("$baseUrl/miramonet_chat");
    String? token = await _getToken();
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customer_unique_id': customerUniqueId,
        }),
      );

      return response;
    } catch (e) {
      throw Exception("Failed to call API: $e");
    }
  }

  Future<List<ArtReply>> fetchMiraMonetArtReplies(
    String customer_unique_id,
  ) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/get_miramonet_chat_message'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'customer_unique_id': customer_unique_id,
      }),
    );

    print(response);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> replies = data['chatDetails'] ?? [];

      return replies.map((reply) => ArtReply.fromJson(reply)).toList();
    } else {
      throw Exception('Failed to load art replies');
    }
  }

  Future<Map<String, dynamic>?> sendArtReplyMiramonet(
      String senderUniqueId,
      String miramonet_chat_id,
      String message,
      File? imageFile,) async {
    print(senderUniqueId);
    print(miramonet_chat_id);
    print(message);
    print(imageFile);
    try {
      var uri = Uri.parse('$baseUrl/sendMiramonetMessage');
      var request = http.MultipartRequest('POST', uri);
      String? token = await _getToken();
      // Add text fields
      request.fields['sender_unique_id'] = senderUniqueId;
      request.fields['miramonet_chat_id'] = miramonet_chat_id;
      request.fields['message'] = message;
      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Authorization'] = 'Bearer $token';

      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: path.basename(imageFile.path),
        );

        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("response : ${responseBody}");
      final Map<String, dynamic> jsonResponse = json.decode(responseBody);

      if (response.statusCode == 200 && jsonResponse['status'] == true) {
        print('Art reply sent successfully.');
        return jsonResponse;
      } else {
        String errorMessage = jsonResponse['message'] ?? 'Unknown error occurred';
        print('Failed to send art reply: ${response.statusCode}');
        print('Error message: $errorMessage');

        // Show error message as toast
        showToast(message: errorMessage);

        return jsonResponse;
      }
    } catch (e) {
      print('Exception occurred while sending art reply: $e');
      throw Exception('Failed to send art reply: $e');
    }
  }

  Future<Map<String, dynamic>> submitArt({
    required String artUniqueId,
    required String customerUniqueId,
  }) async {
    final String url = "$baseUrl/submit_art";
    String? token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "art_unique_id": artUniqueId,
          "customer_unique_id": customerUniqueId,
        }),
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to submit art: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error submitting art: $e');
    }
  }
}
