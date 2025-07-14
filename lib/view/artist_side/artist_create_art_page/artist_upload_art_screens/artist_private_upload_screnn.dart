import 'dart:convert';

import 'package:artist/config/toast.dart';
import 'package:artist/core/models/upload_art_model/category_select_model.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:artist/view/artist_side/artist_create_art_page/artist_upload_art_screens/artist_additional_detail_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/api_service/base_url.dart';
import '../../../../core/models/country_state_city_model.dart';
import '../../../../core/models/upload_art_model/portal_percentage_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../../user_side/home_screen/home_screen.dart';

class ArtistPrivateUploadScrenn extends StatefulWidget {
  const ArtistPrivateUploadScrenn({super.key});

  @override
  State<ArtistPrivateUploadScrenn> createState() =>
      _ArtistPrivateUploadScrennState();
}

class _ArtistPrivateUploadScrennState extends State<ArtistPrivateUploadScrenn> {
  TextEditingController titleController = TextEditingController();
  TextEditingController artistController = TextEditingController();
  TextEditingController editionController = TextEditingController();
  TextEditingController fromPriceController = TextEditingController();
  TextEditingController toPriceController = TextEditingController();
  TextEditingController sinceController = TextEditingController();
  TextEditingController pickUpAddressController = TextEditingController();
  TextEditingController _zipCodeController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController desController = TextEditingController();
  TextEditingController portalController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    artistController.dispose();
    editionController.dispose();
    fromPriceController.dispose();
    toPriceController.dispose();
    sinceController.dispose();
    pickUpAddressController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    desController.dispose();
    super.dispose();
  }

  String? _selectedframe;
  final List<String> _frame = ["Yes", "No"];

  List<Country> allCountries = [];
  List<Country> filteredCountries = [];
  List<StateModel> allStates = [];
  List<StateModel> filteredStates = [];
  List<City> allCities = [];
  List<City> filteredCities = [];

  bool isCountryDropdownVisible = false;
  bool isStateDropdownVisible = false;
  bool isCityDropdownVisible = false;

  Country? selectedCountry;
  StateModel? selectedState;
  City? selectedCity;

  List<UploadCategory> categories = [];
  List<SubCategory> subCategories = [];

  int? selectedCategoryId;
  String? _selectedCategory;
  int? selectedSubCategoryId;
  String? _selectedSubCategory;

  List<PortalPercentage> portalPercentages = [];

  String? _selectedPercentage;

  int? selectedPercentageId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchCategories();
    fetchCountries();
    fetchPortalPercentages();
    desController.addListener(() {
      setState(() {
        _charCount = desController.text.length;
      });
    });
  }

  Future<void> fetchPortalPercentages() async {
    try {
      final fetchedPercentages = await ApiService.getPortalPercentages("Private");

      if (fetchedPercentages != null &&
          fetchedPercentages["status"] == true &&
          fetchedPercentages["data"] is List &&
          fetchedPercentages["data"].isNotEmpty) {

        String percentage = fetchedPercentages["data"][0]["percentage"] ?? "";

        setState(() {
          portalController.text = percentage;
        });
      }
    } catch (e) {
      print('Error fetching percentages: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await ApiService.getCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      setState(() {});
    }
  }

  Future<void> fetchSubCategories(String categoryId) async {
    final url = Uri.parse("$serverUrl/subCategories");

    try {
      final response = await http.post(
        url,
        body: jsonEncode({"category_id": categoryId}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status']) {
          setState(() {
            subCategories = (data['sub_categories_array'] as List)
                .map((json) => SubCategory.fromJson(json))
                .toList();
          });
        }
      } else {
        print("Failed to load subcategories");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> fetchCountries() async {
    try {
      final countries = await ApiService.getCountries();
      setState(() {
        allCountries = countries;
        filteredCountries = countries;
        print("Countries fetched: ${allCountries.length}");
      });
    } catch (e) {
      print("Failed to fetch countries: $e");
      // Optionally, show an error message to the user
    }
  }

  Future<void> fetchStates(int countryId) async {
    try {
      final states = await ApiService.getStates(countryId);
      setState(() {
        allStates = states;
        filteredStates = states;
        print("States fetched: ${allStates.length}");
      });
    } catch (e) {
      print("Failed to fetch states: $e");
      // Optionally, show an error message to the user
    }
  }

  Future<void> fetchCities(int stateId) async {
    try {
      final cities = await ApiService.getCities(stateId);
      setState(() {
        allCities = cities;
        filteredCities = cities;
        print("Cities fetched: ${allCities.length}");
      });
    } catch (e) {
      print("Failed to fetch cities: $e");
      // Optionally, show an error message to the user
    }
  }

  void filterCountries(String query) {
    setState(() {
      filteredCountries = allCountries
          .where((country) =>
              country.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print("Filtered countries: ${filteredCountries.length}");
    });
  }

  void filterStates(String query) {
    setState(() {
      filteredStates = allStates
          .where(
              (state) => state.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print("Filtered states: ${filteredStates.length}");
    });
  }

  void filterCities(String query) {
    setState(() {
      filteredCities = allCities
          .where(
              (city) => city.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      print("Filtered cities: ${filteredCities.length}");
    });
  }

  void selectCountry(Country country) {
    setState(() {
      selectedCountry = country;
      _countryController.text = country.name;
      isCountryDropdownVisible = false;
      _stateController.clear();
      _cityController.clear();
      allStates.clear();
      allCities.clear();
      fetchStates(country.id);
    });
  }

  void selectState(StateModel state) {
    setState(() {
      selectedState = state;
      _stateController.text = state.name;
      isStateDropdownVisible = false;
      _cityController.clear();
      allCities.clear();
      fetchCities(state.id);
    });
  }

  void selectCity(City city) {
    setState(() {
      selectedCity = city;
      _cityController.text = city.name;
      isCityDropdownVisible = false;
    });
  }



  String? customerUniqueID;

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String mobile = (prefs.get('mobile') is String)
        ? prefs.getString('mobile') ?? ''
        : prefs.getInt('mobile')?.toString() ?? '';
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    setState(() {
      customerUniqueID = customerUniqueId;
    });

    print(mobile.toString());
    print(customerUniqueId.toString());
  }

  bool isClick = false;

  void _upload() async {
    setState(() {
      isClick = true;
    });
    if (titleController.text.isEmpty ||
        artistController.text.isEmpty ||
        editionController.text.isEmpty ||
        fromPriceController.text.isEmpty ||
        sinceController.text.isEmpty ||
        pickUpAddressController.text.isEmpty ||
        _zipCodeController.text.isEmpty ||
        selectedCategoryId == null ||
        selectedSubCategoryId == null ||
        selectedCountry == null ||
        selectedState == null ||
        selectedCity == null ||
        _selectedframe == null ||
        portalController.text.isEmpty ||
        desController.text.isEmpty) {
      setState(() {
        isClick = false;
      });
      showToast(message: 'Please fill all the fields.');
      return; // Exit the function if any field is empty
    }
    print("customerUniqueId : ${customerUniqueID.toString()}");
    print("title : ${titleController.text.toString()}");
    print("artist : ${artistController.text.toString()}");
    print("edition : ${editionController.text.toString()}");
    print("estimate_price_from : ${fromPriceController.text.toString()}");
    print("estimate_price_to : ${toPriceController.text.toString()}");
    print("since : ${sinceController.text.toString()}");
    print("category : ${selectedCategoryId.toString()}");
    print("pickup Address : ${pickUpAddressController.text.toString()}");
    print("pincode : ${_zipCodeController.text.toString()}");
    print("country : ${selectedCountry!.id.toString()}");
    print("state : ${selectedState!.id.toString()}");
    print("city : ${selectedCity!.id.toString()}");
    print("frame : ${_selectedframe.toString()}");
    print("portal : ${_selectedPercentage.toString()}");
    print("des : ${desController.text.toString()}");

    final payload = {
      'customer_unique_id': customerUniqueID.toString(),
      'title': titleController.text.toString(),
      'art_type': "Private",
      'artist_name': artistController.text.toString(),
      'edition': editionController.text.toString(),
      'since': sinceController.text.toString(),
      'estimate_price_from': fromPriceController.text.toString(),
      'estimate_price_to': toPriceController.text.toString(),
      'pickup_address': pickUpAddressController.text.toString(),
      'pincode': _zipCodeController.text.toString(),
      'state': selectedState!.id.toString(),
      'city': selectedCity!.id.toString(),
      'frame': _selectedframe.toString(),
      'paragraph': desController.text.toString(),
      'country': selectedCountry!.id.toString(),
      'category_id': selectedCategoryId,
      'sub_category_1_id': selectedSubCategoryId,
      'portal_percentages': _selectedPercentage.toString(),
    };

    print("Payload: $payload");

    // var response = await ApiService.uploadArtDetails(payload);
    ApiService apiService = ApiService();
    var response = await apiService.uploadArtDetails(payload);

    if (response != null) {
      if (response['status'] == true) {
        String artUniqueId = response['art_unique_id'];
        String category_name =  response['category_name'] == null ? "" : response['category_name'].toString();
        String category_id = response['category_id'] == null ? "" : response['category_id'].toString();
        showToast(message: response['message']);
        print("Artwork added successfully. Art Unique ID: $artUniqueId");
        setState(() {
          isClick = false;
        });
        saveArtUniqueId(artUniqueId).then((onValue) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ArtistAdditionalDetailScreen(category_id: category_id)));
        });
      } else {
        setState(() {
          isClick = false;
        });
        showToast(message: response['message']);
        print("Failed to add artwork: ${response['message']}");
      }
    } else {
      setState(() {
        isClick = false;
      });
      print("Failed to upload artwork.");
    }
  }
  // Art Unique ID : CO24000203001
  // Art Unique ID : CO24000203002

  Future<void> saveArtUniqueId(String artUniqueId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('artUniqueId', artUniqueId);
  }

  bool _isChecked = false;
  final _formKey = GlobalKey<FormState>();
  bool _isDropdownOpen = false;
  bool _isDropdownOpen2 = false;
  bool _isDropdownOpen3 = false;
  int _charCount = 0;
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: Responsive.getWidth(41),
                        height: Responsive.getHeight(41),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(12)),
                            border: Border.all(
                                color: textFieldBorderColor, width: 1.0)),
                        child: Icon(
                          Icons.arrow_back_ios_new_outlined,
                          size: Responsive.getWidth(19),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: Responsive.getWidth(85),
                    ),
                    WantText2(
                        text: "Upload Art",
                        fontSize: Responsive.getFontSize(18),
                        fontWeight: AppFontWeight.medium,
                        textColor: textBlack)
                  ],
                ),
                Container(
                  width: Responsive.getWidth(341),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: Responsive.getHeight(29),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Title of artwork",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        AppTextFormField(
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18)),
                          borderRadius: Responsive.getWidth(8),
                          controller: titleController,
                          borderColor: textFieldBorderColor,
                          hintStyle: GoogleFonts.urbanist(
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          // onChanged: (p0) {
                          //   _formKey.currentState!.validate();
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title of artwork cannot be empty';
                            }
                            return null;
                          },
                          hintText: "Enter Title of artwork",
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Artist Name",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        AppTextFormField(
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18)),
                          borderRadius: Responsive.getWidth(8),
                          controller: artistController,
                          borderColor: textFieldBorderColor,
                          hintStyle: GoogleFonts.urbanist(
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          // onChanged: (p0) {
                          //   _formKey.currentState!.validate();
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Artist Name cannot be empty';
                            }
                            return null;
                          },
                          hintText: "Enter Artist Name",
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Edition",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        AppTextFormField(
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18)),
                          borderRadius: Responsive.getWidth(8),
                          controller: editionController,
                          borderColor: textFieldBorderColor,
                          hintStyle: GoogleFonts.urbanist(
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          // onChanged: (p0) {
                          //   _formKey.currentState!.validate();
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Edition cannot be empty';
                            }
                            return null;
                          },
                          hintText: "Enter Edition",
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Estimate Price Range(In \$)",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: AppTextFormField(
                                // fillColor: Color.fromRGBO(247, 248, 249, 1),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: Responsive.getWidth(18),
                                    vertical: Responsive.getHeight(18)),
                                borderRadius: Responsive.getWidth(8),
                                controller: fromPriceController,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                keyboardType: TextInputType.number,
                                borderColor: textFieldBorderColor,
                                hintStyle: GoogleFonts.urbanist(
                                  color: textGray,
                                  fontSize: Responsive.getFontSize(15),
                                  fontWeight: AppFontWeight.medium,
                                ),
                                textStyle: GoogleFonts.urbanist(
                                  color: textBlack,
                                  fontSize: Responsive.getFontSize(15),
                                  fontWeight: AppFontWeight.medium,
                                ),
                                // onChanged: (p0) {
                                //   _formKey.currentState!.validate();
                                // },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Price cannot be empty';
                                  }
                                  final regex = RegExp(r'^[0-9]+(\.[0-9]{1,2})?$'); // Allows only digits with optional decimals
                                  if (!regex.hasMatch(value)) {
                                    return 'Price must be a valid number without special characters';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Price must be a valid number';
                                  }
                                  if (double.parse(value) <= 0) {
                                    return 'Price must be greater than zero';
                                  }
                                  return null;
                                },
                                hintText: "Enter From Price",
                              ),
                            ),
                            SizedBox(
                              width: Responsive.getWidth(20),
                            ),
                            Flexible(
                              child: AppTextFormField(
                                // fillColor: Color.fromRGBO(247, 248, 249, 1),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: Responsive.getWidth(18),
                                    vertical: Responsive.getHeight(18)),
                                borderRadius: Responsive.getWidth(8),
                                controller: toPriceController,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                keyboardType: TextInputType.number,
                                borderColor: textFieldBorderColor,
                                hintStyle: GoogleFonts.urbanist(
                                  color: textGray,
                                  fontSize: Responsive.getFontSize(15),
                                  fontWeight: AppFontWeight.medium,
                                ),
                                textStyle: GoogleFonts.urbanist(
                                  color: textBlack,
                                  fontSize: Responsive.getFontSize(15),
                                  fontWeight: AppFontWeight.medium,
                                ),
                                // onChanged: (p0) {
                                //   _formKey.currentState!.validate();
                                // },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Price cannot be empty';
                                  }
                                  final regex = RegExp(r'^[0-9]+(\.[0-9]{1,2})?$'); // Allows only digits with optional decimals
                                  if (!regex.hasMatch(value)) {
                                    return 'Price must be a valid number without special characters';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Price must be a valid number';
                                  }
                                  if (double.parse(value) <= 0) {
                                    return 'Price must be greater than zero';
                                  }
                                  return null;
                                },

                                hintText: "Enter To Price",
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Since",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        AppTextFormField(
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18)),
                          borderRadius: Responsive.getWidth(8),
                          controller: sinceController,
                          borderColor: textFieldBorderColor,
                          hintStyle: GoogleFonts.urbanist(
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          // onChanged: (p0) {
                          //   _formKey.currentState!.validate();
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Since cannot be empty';
                            }
                            return null;
                          },
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          hintText: "Enter Since",
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Category",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        FormField<String>(
                          validator: (value) {
                            if (_selectedCategory == null || _selectedCategory!.isEmpty || _selectedCategory == 'Select') {
                              return 'Please select a category';
                            }
                            return null;
                          },
                          builder: (FormFieldState<String> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Selection Field
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDropdownOpen = !_isDropdownOpen; // Toggle dropdown visibility
                                    });
                                  },
                                  child: InputDecorator(
                                    decoration: _inputDecoration(state, 'Select Category'),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        WantText2(
                                          text: _selectedCategory ?? "Select Category",
                                          fontSize: Responsive.getFontSize(14),
                                          fontWeight: _selectedCategory == null ? AppFontWeight.regular : AppFontWeight.medium,
                                          textColor: _selectedCategory == null
                                              ? Color.fromRGBO(131, 145, 161, 1.0)
                                              : textBlack11,
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color: Color.fromRGBO(131, 131, 131, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Dropdown List (Only visible if `_isDropdownOpen` is true)
                                if (_isDropdownOpen)
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.white,
                                      height: Responsive.getHeight(150),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: categories.length,
                                        itemBuilder: (context, index) {
                                          UploadCategory category = categories[index];
                                          return ListTile(
                                            title: WantText2(
                                              text: category.categoryName,
                                              fontSize: Responsive.getFontSize(14),
                                              fontWeight: AppFontWeight.medium,
                                              textColor: textBlack11,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _selectedCategory = category.categoryName;
                                                selectedCategoryId = category.categoryId; // Assign correct category ID
                                                _isDropdownOpen = false;
                                                _selectedSubCategory = null;
                                                selectedSubCategoryId = null;
                                                subCategories
                                                    .clear();
                                              });
                                              fetchSubCategories(category
                                                  .categoryId
                                                  .toString());
                                              print("_selectedCategory : $_selectedCategory");
                                              print("selectedCategoryId : $selectedCategoryId");

                                              state.didChange(category.categoryName); // Update form field state
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Sub Category",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        FormField<String>(
                          validator: (value) {
                            if (_selectedSubCategory  == null ||
                                _selectedSubCategory !.isEmpty ||
                                _selectedSubCategory  == 'Select') {
                              return 'Please select a sub category';
                            }
                            return null;
                          },
                          builder: (FormFieldState<String> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Selection Field
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDropdownOpen3  =
                                      !_isDropdownOpen3 ; // Toggle dropdown visibility
                                    });
                                  },
                                  child: InputDecorator(
                                    decoration: _inputDecoration(
                                        state, 'Select Sub Category'),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        WantText2(
                                          text: _selectedSubCategory ??
                                              "Select Sub Category",
                                          fontSize: Responsive.getFontSize(14),
                                          fontWeight: _selectedSubCategory == null
                                              ? AppFontWeight.regular
                                              : AppFontWeight.medium,
                                          textColor: _selectedSubCategory == null
                                              ? Color.fromRGBO(
                                              131, 145, 161, 1.0)
                                              : textBlack11,
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color:
                                          Color.fromRGBO(131, 131, 131, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Dropdown List (Only visible if `_isDropdownOpen` is true)
                                if (_isDropdownOpen3)
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: double.infinity,
                                      height: Responsive.getHeight(150),
                                      color: Colors.white,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: subCategories.length,
                                        itemBuilder: (context, index) {
                                          SubCategory subCategory = subCategories[index];
                                          return ListTile(
                                            title: WantText2(
                                              text: subCategory.subCategoryName,
                                              fontSize:
                                              Responsive.getFontSize(14),
                                              fontWeight: AppFontWeight.medium,
                                              textColor: textBlack11,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                _selectedSubCategory =
                                                    subCategory.subCategoryName;
                                                selectedSubCategoryId = subCategory
                                                    .subCategoryId; // Assign correct category ID
                                                _isDropdownOpen3 = false;
                                                // _selectedSubCategory = null;
                                                // selectedSubCategoryId = null;
                                                // subCategories
                                                //     .clear(); // Close dropdown
                                              });

                                              print(
                                                  "_selectedSubCategory : $_selectedSubCategory");
                                              print(
                                                  "selectedSubCategoryId : $selectedSubCategoryId");
                                              state.didChange(subCategory
                                                  .subCategoryName); // Update form field state
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),

                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Address",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        AppTextFormField(
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18)),
                          borderRadius: Responsive.getWidth(8),
                          controller: pickUpAddressController,
                          borderColor: textFieldBorderColor,
                          hintStyle: GoogleFonts.urbanist(
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          // onChanged: (p0) {
                          //   _formKey.currentState!.validate();
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Address cannot be empty';
                            }
                            return null;
                          },
                          hintText: "Enter Address",
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),

                        Row(
                          children: [
                            WantText2(
                                text: "Country of Origin",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        buildTextField(
                          hintText: "Select Country",
                          controller: _countryController,
                          isVisible: isCountryDropdownVisible,
                          filteredItems: filteredCountries,
                          onChanged: filterCountries,
                          onTap: (country) => selectCountry(country),
                          setVisible: (visible) {
                            setState(() {
                              isCountryDropdownVisible = visible;
                            });
                          },
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "State",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        buildTextField(
                          hintText: "Select State",
                          controller: _stateController,
                          isVisible: isStateDropdownVisible,
                          filteredItems: filteredStates,
                          onChanged: filterStates,
                          onTap: (state) => selectState(state),
                          setVisible: (visible) {
                            setState(() {
                              isStateDropdownVisible = visible;
                            });
                          },
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "City",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        buildTextField(
                          hintText: "Select City",
                          controller: _cityController,
                          isVisible: isCityDropdownVisible,
                          filteredItems: filteredCities,
                          onChanged: filterCities,
                          onTap: (city) => selectCity(city),
                          setVisible: (visible) {
                            setState(() {
                              isCityDropdownVisible = visible;
                            });
                          },
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Zip code",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        AppTextFormField(
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18)),
                          borderRadius: Responsive.getWidth(8),
                          controller: _zipCodeController,
                          borderColor: textFieldBorderColor,
                          hintStyle: GoogleFonts.urbanist(
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          // onChanged: (p0) {
                          //   _formKey.currentState!.validate();
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Zip Code cannot be empty';
                            }
                            return null;
                          },
                          hintText: "Enter Zip code",
                        ),

                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Sold with frame",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        FormField<String>(
                          validator: (value) {
                            if (_selectedframe == null ||
                                _selectedframe!.isEmpty ||
                                _selectedframe == 'Select') {
                              return 'Please select a frame';
                            }
                            return null;
                          },
                          builder: (FormFieldState<String> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // SizedBox(height: Responsive.getHeight(15)),
                                // WantText2(
                                //   text: "Purpose of Booking",
                                //   fontSize: Responsive.getFontSize(10),
                                //   fontWeight: AppFontWeight.medium,
                                //   textColor: textBlack9,
                                // ),
                                // SizedBox(height: Responsive.getHeight(5)),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDropdownOpen2 = !_isDropdownOpen2;
                                    });
                                  },
                                  child: InputDecorator(
                                    decoration:
                                    _inputDecoration(state, 'Select Sold with frame'),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        WantText2(
                                          text: _selectedframe ?? "Select Sold with frame",
                                          fontSize:
                                          Responsive.getFontSize(14),
                                          fontWeight: _selectedframe == null
                                              ? AppFontWeight.regular
                                              : AppFontWeight.medium,
                                          textColor: _selectedframe == null
                                              ? Color.fromRGBO(
                                              131, 145, 161, 1.0)
                                              : textBlack11,
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down_outlined,
                                          color: Color.fromRGBO(
                                              131, 131, 131, 1),
                                          // size: Responsive.getWidth(28),
                                        ),
                                        // Icon(Icons.keyboard_arrow_down_outlined),
                                      ],
                                    ),
                                  ),
                                ),
                                // Show dropdown only if it's open
                                if (_isDropdownOpen2)
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: double.infinity,
                                      color: Colors.white,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: _frame.map((String title) {
                                          return ListTile(
                                            title: WantText2(text: title, fontSize:   Responsive.getFontSize(14), fontWeight: AppFontWeight.medium, textColor: textBlack11),
                                            // Text(title),
                                            onTap: () {
                                              state.didChange(
                                                  title); // Update the state
                                              setState(() {
                                                _selectedframe = title;
                                              });// Update form field value
                                              setState(() {
                                                _isDropdownOpen2 =
                                                false; // Close dropdown after selection
                                              });
                                            },
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Portal percentage",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        AppTextFormField(
                          // fillColor: Color.fromRGBO(247, 248, 249, 1),
                          // maxLines: 4,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: Responsive.getWidth(18),
                              vertical: Responsive.getHeight(18)),
                          borderRadius: Responsive.getWidth(8),
                          controller: portalController,
                          readOnly: true,
                          borderColor: textFieldBorderColor,
                          hintStyle: GoogleFonts.urbanist(
                            color: textGray,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          textStyle: GoogleFonts.urbanist(
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          // onChanged: (p0) {
                          //   _formKey.currentState!.validate();
                          // },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description cannot be empty';
                            }
                            return null;
                          },
                          hintText: "Enter Portal percentage",
                        ),
                        // FormField<String>(
                        //   validator: (value) {
                        //     if (_selectedPercentage == null || _selectedPercentage!.isEmpty) {
                        //       return 'Please select a percentage';
                        //     }
                        //     return null;
                        //   },
                        //   builder: (FormFieldState<String> state) {
                        //     return Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         InputDecorator(
                        //           decoration: InputDecoration(
                        //             isDense: true,
                        //             hintText: 'Select',
                        //             hintStyle: GoogleFonts.poppins(
                        //               color: textGray,
                        //               fontSize: 14.0,
                        //               fontWeight: FontWeight.normal,
                        //             ),
                        //             contentPadding: EdgeInsets.fromLTRB(16, 15, 16, 15),
                        //             focusedErrorBorder: OutlineInputBorder(
                        //               borderRadius: BorderRadius.all(Radius.circular(10)),
                        //               borderSide: BorderSide.none,
                        //             ),
                        //             errorBorder: OutlineInputBorder(
                        //               borderRadius: BorderRadius.all(Radius.circular(10)),
                        //               borderSide: const BorderSide(color: Colors.red, width: 1),
                        //             ),
                        //             border: OutlineInputBorder(
                        //               borderRadius: BorderRadius.all(Radius.circular(10)),
                        //               borderSide: BorderSide(color: textFieldBorderColor, width: 1),
                        //             ),
                        //             enabledBorder: OutlineInputBorder(
                        //               borderRadius: BorderRadius.all(Radius.circular(10)),
                        //               borderSide: BorderSide(color: textFieldBorderColor, width: 1),
                        //             ),
                        //             focusedBorder: OutlineInputBorder(
                        //               borderRadius: BorderRadius.all(Radius.circular(10)),
                        //               borderSide: BorderSide(color: textFieldBorderColor, width: 1),
                        //             ),
                        //             errorText: state.errorText, // Show validation error
                        //           ),
                        //           child: DropdownButtonHideUnderline(
                        //             child: DropdownButton<String>(
                        //               dropdownColor: white,
                        //               hint: WantText2(
                        //                 text: "Select",
                        //                 fontSize: Responsive.getFontSize(16),
                        //                 fontWeight: AppFontWeight.regular,
                        //                 textColor: textBlack11,
                        //               ),
                        //               icon: Icon(
                        //                 Icons.keyboard_arrow_down_outlined,
                        //                 color: Color.fromRGBO(131, 131, 131, 1),
                        //                 size: Responsive.getWidth(28),
                        //               ),
                        //               value: _selectedPercentage,
                        //               isDense: true,
                        //               onChanged: (value) {
                        //                 state.didChange(value); // Notify FormField of value change
                        //                 setState(() {
                        //                   _selectedPercentage = value;
                        //                   // Find the selected category ID
                        //                   selectedPercentageId = portalPercentages
                        //                       .firstWhere((percentage) =>
                        //                   percentage.percentage == value)
                        //                       .portalPercentagesId;
                        //                 });
                        //                 print("_selectedPercentage : $_selectedPercentage");
                        //                 print("selectedPercentageId : $selectedPercentageId");
                        //               },
                        //               items: portalPercentages.map((PortalPercentage percentage) {
                        //                 return DropdownMenuItem<String>(
                        //                   value: percentage.percentage,
                        //                   child: WantText2(
                        //                     text: percentage.percentage,
                        //                     fontSize: Responsive.getFontSize(16),
                        //                     fontWeight: AppFontWeight.medium,
                        //                     textColor: textBlack11,
                        //                   ),
                        //                 );
                        //               }).toList(),
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Row(
                          children: [
                            WantText2(
                                text: "Description",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.medium,
                                textColor: textBlack11),
                            WantText2(
                                text: "*",
                                fontSize: Responsive.getFontSize(12),
                                fontWeight: AppFontWeight.medium,
                                textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                          ],
                        ),
                        SizedBox(
                          height: Responsive.getHeight(4),
                        ),
                        TextFormField(
                          controller: desController,
                          maxLines:  4, // Dynamic maxLines
                          maxLength: 200,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Description cannot be empty';
                            }
                            return null;
                          },
                          style: GoogleFonts.poppins(
                            letterSpacing: 1.5,
                            color: textBlack,
                            fontSize: Responsive.getFontSize(15),
                            fontWeight: AppFontWeight.medium,
                          ),
                          cursorColor: black,
                          decoration: InputDecoration(
                            hintText: "Enter Description",
                            // hintText: "Enter Art Story",
                            hintStyle: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              color: textGray,
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),

                            counterText: "$_charCount/200",
                            counterStyle: TextStyle(color: Colors.grey),
                            isDense: true,
                            errorMaxLines: 3,
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(color: Colors.red, width: 1),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(
                                  color: textFieldBorderColor ?? Colors.transparent,
                                  width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(
                                  color: textFieldBorderColor ?? Colors.transparent,
                                  width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(Responsive.getWidth(8)),
                              ),
                              borderSide: BorderSide(
                                  color: textFieldBorderColor ?? Colors.transparent,
                                  width: 1),
                            ),
                          ),
                        ),
                        // AppTextFormField(
                        //   // fillColor: Color.fromRGBO(247, 248, 249, 1),
                        //   maxLines: 4,
                        //   contentPadding: EdgeInsets.symmetric(
                        //       horizontal: Responsive.getWidth(18),
                        //       vertical: Responsive.getHeight(18)),
                        //   borderRadius: Responsive.getWidth(8),
                        //   controller: desController,
                        //   borderColor: textFieldBorderColor,
                        //   hintStyle: GoogleFonts.urbanist(
                        //     color: textGray,
                        //     fontSize: Responsive.getFontSize(15),
                        //     fontWeight: AppFontWeight.medium,
                        //   ),
                        //   textStyle: GoogleFonts.urbanist(
                        //     color: textBlack,
                        //     fontSize: Responsive.getFontSize(15),
                        //     fontWeight: AppFontWeight.medium,
                        //   ),
                        //   // onChanged: (p0) {
                        //   //   _formKey.currentState!.validate();
                        //   // },
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Description cannot be empty';
                        //     }
                        //     return null;
                        //   },
                        //   hintText: "Enter Description",
                        // ),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        TermsCheckbox(),
                        SizedBox(
                          height: Responsive.getHeight(13),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                if(_isChecked){
                                  _upload();
                                }else{
                                  showToast(message: "Check Terms of Service");
                                }
                              } else {
                                showToast(message: 'Form is invalid');
                                print("Form is invalid");
                              }

                            },
                            child: Container(
                              height: Responsive.getHeight(45),
                              width: Responsive.getWidth(331),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  color: black,
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(8)),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      isClick
                                          ? Center(
                                              child: SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 3,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              "Next",
                                              style: GoogleFonts.poppins(
                                                letterSpacing: 1.5,
                                                textStyle: TextStyle(
                                                  fontSize:
                                                      Responsive.getFontSize(18),
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Responsive.getHeight(20),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      FormFieldState<String> state, String hintText) {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(
        letterSpacing: 1.5,
        color: Color.fromRGBO(131, 145, 161, 1.0),
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      ),
      contentPadding: EdgeInsets.fromLTRB(16, 15, 10, 15),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: textFieldBorderColor, width: 1),
      ),
      errorText: state.errorText, // Show error message
    );
  }

  Widget buildTextField<T>({
    required TextEditingController controller,
    required bool isVisible,
    required String hintText,
    required List<T> filteredItems,
    required Function(String) onChanged,
    required Function(T) onTap,
    required Function(bool) setVisible,
  }) {
    return Column(
      children: [
        AppTextFormField(
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidth(18),
            vertical: Responsive.getHeight(18),
          ),
          borderRadius: Responsive.getWidth(8),
          controller: controller,
          borderColor: textFieldBorderColor,
          hintStyle: GoogleFonts.urbanist(
            color: textGray,
            fontSize: Responsive.getFontSize(15),
            fontWeight: AppFontWeight.medium,
          ),
          textStyle: GoogleFonts.urbanist(
            color: textBlack,
            fontSize: Responsive.getFontSize(15),
            fontWeight: AppFontWeight.medium,
          ),
          onChanged: (newValue) {
            // _formKey.currentState!.validate();
            onChanged(newValue ?? ''); // Ensure newValue is non-nullable
            setVisible(true);
          },
          suffixIcon:GestureDetector(
            onTap: (){
              setVisible(true);
            },
            child: Icon(
              size: 24,
              Icons.keyboard_arrow_down_outlined,
              color: Color.fromRGBO(
                  131, 131, 131, 1),
              // size: Responsive.getWidth(28),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$hintText cannot be empty';
            }
            return null;
          },
          hintText: hintText,
        ),
        if (isVisible)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: white,
              height: Responsive.getHeight(150),
              // decoration: BoxDecoration(
              //   border: Border.all(color: Colors.black.withOpacity(0.5)),
              //   borderRadius: BorderRadius.circular(8),
              //   color: Colors.white,
              // ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return ListTile(
                    title: Text(
                      item is Country
                          ? item.name
                          : item is StateModel
                          ? item.name
                          : (item as City).name,
                      style: GoogleFonts.poppins(letterSpacing: 1.5),
                    ),
                    onTap: () => onTap(item),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget TermsCheckbox() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isChecked = !_isChecked;
            });
          },
          child: Container(
            width: Responsive.getWidth(20),
            height: Responsive.getWidth(20),
            decoration: BoxDecoration(
                color: _isChecked ? black : Colors.transparent,
                borderRadius: BorderRadius.circular(Responsive.getWidth(4)),
                border: Border.all(color: Color.fromRGBO(0, 0, 0, 1))),
            child: _isChecked
                ? Center(
                    child: Icon(
                    Icons.check,
                    color: white,
                    size: 16,
                  ))
                : Container(),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Flexible(
          child: GestureDetector(
            onTap: () {
              _fetchAndShowTerms(context);
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'I have read and agree to the ',
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: Color.fromRGBO(27, 43, 65, 0.72),
                      fontSize: Responsive.getFontSize(10),
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: GoogleFonts.poppins(
                      letterSpacing: 1.5,
                      color: Color.fromRGBO(0, 0, 0, 1),
                      fontSize: Responsive.getFontSize(10),
                      decoration: TextDecoration.underline,
                      fontWeight: AppFontWeight.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  void _fetchAndShowTerms(BuildContext context) async {
    try {
      final termsData = await ApiService().getTermsConditions("Private");
      _showTermsDialog(context, termsData);
    } catch (error) {
      print('Error fetching terms and conditions: $error');
    }
  }

  void _showTermsDialog(BuildContext context, Map<String, dynamic> termsData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            margin: EdgeInsets.all(0),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 1,
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          CupertinoIcons.multiply_circle,
                          color: Colors.grey,
                        ),
                      )
                    ],
                  ),
                  for (var term in termsData['terms'])
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          term['heading'],
                          style:  GoogleFonts.poppins(
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5),
                        ),
                        for (var para in term['conditions_paras'])
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(para['paragraph'],style: GoogleFonts.poppins(
                                      fontSize: Responsive.getFontSize(14),
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 1.5),),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  // Widget buildTextField<T>({
  //   required TextEditingController controller,
  //   required bool isVisible,
  //   required String hintText,
  //   required List<T> filteredItems,
  //   required Function(String) onChanged,
  //   required Function(T) onTap,
  //   required Function(bool) setVisible,
  // }) {
  //   return Column(
  //     children: [
  //       AppTextFormField(
  //         contentPadding: EdgeInsets.symmetric(
  //           horizontal: Responsive.getWidth(18),
  //           vertical: Responsive.getHeight(18),
  //         ),
  //         borderRadius: Responsive.getWidth(8),
  //         controller: controller,
  //         borderColor: textFieldBorderColor,
  //         hintStyle: GoogleFonts.urbanist(
  //           color: textGray,
  //           fontSize: Responsive.getFontSize(15),
  //           fontWeight: AppFontWeight.medium,
  //         ),
  //         textStyle: GoogleFonts.urbanist(
  //           color: textBlack,
  //           fontSize: Responsive.getFontSize(15),
  //           fontWeight: AppFontWeight.medium,
  //         ),
  //         hintText: hintText,
  //         onChanged: (newValue) {
  //           // _formKey.currentState!.validate();
  //           onChanged(newValue ?? ''); // Ensure newValue is non-nullable
  //           setVisible(true);
  //         },
  //         validator: (value) {
  //           if (value == null || value.isEmpty) {
  //             return '$hintText cannot be empty';
  //           }
  //           return null;
  //         },
  //       ),
  //       if (isVisible)
  //         Container(
  //           height: Responsive.getHeight(110),
  //           decoration: BoxDecoration(
  //             border: Border.all(color: Colors.black.withOpacity(0.5)),
  //             borderRadius: BorderRadius.circular(8),
  //             color: Colors.white,
  //           ),
  //           child: ListView.builder(
  //             shrinkWrap: true,
  //             itemCount: filteredItems.length,
  //             itemBuilder: (context, index) {
  //               final item = filteredItems[index];
  //               return ListTile(
  //                 title: Text(item is Country
  //                     ? item.name
  //                     : item is StateModel
  //                         ? item.name
  //                         : (item as City).name,style: GoogleFonts.poppins(letterSpacing: 1.5),),
  //                 onTap: () => onTap(item),
  //               );
  //             },
  //           ),
  //         ),
  //     ],
  //   );
  // }
}
