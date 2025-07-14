import 'dart:convert';
import 'dart:io';

import 'package:artist/config/toast.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/country_state_city_model.dart';
import '../../../../core/models/customer_modell.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'package:http/http.dart' as http;

class MyDetailsScreen extends StatefulWidget {
  const MyDetailsScreen({super.key});

  @override
  State<MyDetailsScreen> createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    fetchCountries();
  }

  bool isNameEditable = true;
  bool isEmailEditable = true;
  bool isPhoneEditable = true;
  bool isAddressEditable = true;
  bool isCountryEditable = true;
  bool isStateEditable = true;
  bool isCityEditable = true;
  bool isZipEditable = true;

  void toggleEdit(String field) {
    setState(() {
      if (field == 'name') {
        isNameEditable = !isNameEditable;
      } else if (field == 'email') {
        isEmailEditable = !isEmailEditable;
      } else if (field == 'phone') {
        isPhoneEditable = !isPhoneEditable;
      } else if (field == 'address') {
        isAddressEditable = !isAddressEditable;
      } else if (field == 'country') {
        isCountryEditable = !isCountryEditable;
      } else if (field == 'state') {
        isStateEditable = !isStateEditable;
      } else if (field == 'city') {
        isCityEditable = !isCityEditable;
      } else if (field == 'zip') {
        isZipEditable = !isZipEditable;
      }
    });
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

  @override
  void dispose() {
    emailController.dispose();
    mobileNumberController.dispose();
    nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    addressController.dispose();
    zipCodeController.dispose();
    _loadUserData();
    super.dispose();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    fetchCustomerData(customerUniqueId);
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  void fetchCustomerData(String customerUniqueId) async {
    ApiService apiService = ApiService();

    try {
      CustomerData customerData =
          await apiService.getCustomerData(customerUniqueId);
      print("customerData : $customerData");
      _updateControllers(customerData);
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  String? imageUrl;
  String? selectedCountryId;
  String? selectedStateId;
  String? selectedCityId;
  String? name;
  void _updateControllers(CustomerData customerData) {
    setState(() {
      isLoading2 = false;
      imageUrl = customerData.customerProfile;
      name = customerData.name;
      emailController.text = customerData.email;
      mobileNumberController.text = customerData.mobile;
      nameController.text = customerData.name;
      _countryController.text =
          customerData.country!.countryName.toString() ?? '';
      _stateController.text = customerData.state!.stateSubdivisionName ?? '';
      _cityController.text = customerData.city!.nameOfCity ?? '';
      addressController.text = customerData.address ?? '';
      zipCodeController.text = customerData.zipCode ?? '';

      selectedCountryId = customerData.country!.countryId.toString();
      selectedStateId = customerData.state!.stateSubdivisionId.toString();
      selectedCityId = customerData.city!.citiesId.toString();
    });
  }

  // Future<Position> _getCurrentLocation() async {
  //   try {
  //     // Check if location services are enabled
  //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       // Prompt user to enable location settings
  //       await Geolocator.openLocationSettings();
  //       throw 'Location services are disabled. Please enable them.';
  //     }
  //
  //     // Check and request permission
  //     LocationPermission permission = await Geolocator.checkPermission();
  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         throw 'Location permissions are denied';
  //       }
  //     }
  //
  //     if (permission == LocationPermission.deniedForever) {
  //       throw 'Location permissions are permanently denied, please enable them manually.';
  //     }
  //
  //     // Fetch the current position
  //     return await Geolocator.getCurrentPosition();
  //   } catch (e) {
  //     throw 'Error getting location: $e';
  //   }
  // }
  void _updateProfile(String? latitude, String? longitude) async {
    setState(() {
      isLoading = true;
    });
    await ApiService()
        .editCustomerProfile(
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      role: "customer",
      intro: "",
      customerUniqueID: customerUniqueID.toString(),
      name: nameController.text.toString(),
      address: addressController.text.toString(),
      country: selectedCountryId == null
          ? selectedCountry!.id.toString()
          : selectedCountryId!,
      state: selectedStateId == null
          ? selectedState!.id.toString()
          : selectedStateId!,
      city: selectedCityId == null
          ? selectedCity!.id.toString()
          : selectedCityId!,
      zipCode: zipCodeController.text.toString(),
      imagePath: _image == null ? null : _image!.path,
    )
        .then((onValue) {
      showToast(message: "Profile Update Successfully");
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<Position> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      throw 'Error getting location: $e';
    }
  }

  void showDeleteAccountDialog(
      BuildContext context,
      ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: whiteBack,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          insetPadding:
          EdgeInsets.symmetric(horizontal: Responsive.getWidth(14)),
          child: Container(
            margin: EdgeInsets.all(0),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidth(11),
                    vertical: Responsive.getHeight(24)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WantText2(
                        text: "Location Permission",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack),
                    SizedBox(height: Responsive.getHeight(8)),
                    Text(
                      textAlign: TextAlign.center,
                      "We use your location to help you discover nearby art exhibitions. This enhances your experience by providing personalized recommendations. Would you like to enable location access?",
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        color: Color.fromRGBO(128, 128, 128, 1),
                        fontSize: Responsive.getFontSize(14),
                        fontWeight: AppFontWeight.regular,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Center(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              Position currentPosition = await _getCurrentLocation();
                              _updateProfile(
                                currentPosition.latitude.toString(),
                                currentPosition.longitude.toString(),
                              );
                            } catch (e) {
                              showToast(message: e.toString());
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                          child: Container(
                            height: Responsive.getHeight(44),
                            width: Responsive.getWidth(311),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: black,
                                ),
                                color: black,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Allow",
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        textStyle: TextStyle(
                                          fontSize: Responsive.getFontSize(18),
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
                        )),
                    SizedBox(height: Responsive.getHeight(12)),
                    Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _updateProfile(null, null);
                          },
                          child: Container(
                            height: Responsive.getHeight(44),
                            width: Responsive.getWidth(311),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromRGBO(208, 213, 221, 1.0),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Not Now",
                                      style: GoogleFonts.urbanist(
                                        textStyle: TextStyle(
                                          fontSize: Responsive.getFontSize(18),
                                          color: Color.fromRGBO(52, 64, 84, 1.0),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  XFile? _image;

  final ImagePicker _picker = ImagePicker();

  Future<bool> _checkPermission() async {
    PermissionStatus status = await Permission.photos.status;
    if (!status.isGranted) {
      PermissionStatus newStatus = await Permission.photos.request();
      return newStatus.isGranted;
    }
    return true;
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = image;
    });
  }

  bool isLoading = false;
  bool isLoading2 = true;
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: isLoading2
          ? Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.black,
                ),
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                                  borderRadius: BorderRadius.circular(
                                      Responsive.getWidth(12)),
                                  border: Border.all(
                                      color: textFieldBorderColor, width: 1.0)),
                              child: Icon(
                                Icons.arrow_back_ios_new_outlined,
                                size: Responsive.getWidth(19),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Responsive.getWidth(90),
                          ),
                          WantText2(
                              text: "My Details",
                              fontSize: Responsive.getFontSize(18),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack)
                        ],
                      ),
                      SizedBox(
                        height: Responsive.getHeight(25),
                      ),
                      Divider(
                        color: Color.fromRGBO(230, 230, 230, 1),
                      ),
                      SizedBox(
                        height: Responsive.getHeight(14),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                      width: Responsive.getWidth(84),
                                      height: Responsive.getWidth(84),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.1)),
                                      child: _image != null
                                          ? Image.file(
                                              File(_image!.path),
                                              fit: BoxFit.cover,
                                            )
                                          : imageUrl != null
                                              ? Image.network(
                                                  imageUrl!,
                                                  fit: BoxFit.cover,
                                                )
                                              : CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor:
                                                      Colors.grey.shade300,
                                                  child: Text(
                                                    '${name![0].toUpperCase()}',
                                                    style: TextStyle(
                                                        fontSize: 24,
                                                        color: black,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickImage,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.black,
                                      child: Icon(
                                        Icons.edit, // Edit icon
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(20),
                          ),
                          WantText2(
                              text: "Full Name",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
                          SizedBox(
                            height: Responsive.getHeight(4),
                          ),
                          AppTextFormField(
                            fillColor: white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(15)),
                            borderRadius: Responsive.getWidth(8),
                            controller: nameController,
                            borderColor: textFieldBorderColor,
                            hintStyle: GoogleFonts.poppins(
                              color: textGray,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            textStyle: GoogleFonts.poppins(
                              color: textBlack,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            hintText: "Enter Full Name",
                            readOnly: isNameEditable,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isNameEditable ? Icons.edit_off : Icons.edit,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                toggleEdit("name");
                              },
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(16),
                          ),
                          WantText2(
                              text: "Email Address",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
                          SizedBox(
                            height: Responsive.getHeight(4),
                          ),
                          AppTextFormField(
                            fillColor: white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(15)),
                            borderRadius: Responsive.getWidth(8),
                            controller: emailController,
                            borderColor: textFieldBorderColor,
                            hintStyle: GoogleFonts.poppins(
                              color: textGray,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            textStyle: GoogleFonts.poppins(
                              color: textBlack,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            hintText: "Enter Email",
                            readOnly: isEmailEditable,
                          ),
                          SizedBox(
                            height: Responsive.getHeight(16),
                          ),
                          WantText2(
                              text: "Phone Number",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
                          SizedBox(
                            height: Responsive.getHeight(4),
                          ),
                          AppTextFormField(
                            fillColor: white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(15)),
                            borderRadius: Responsive.getWidth(8),
                            controller: mobileNumberController,
                            borderColor: textFieldBorderColor,
                            hintStyle: GoogleFonts.poppins(
                              color: textGray,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            textStyle: GoogleFonts.poppins(
                              color: textBlack,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            hintText: "Enter Mobile",
                            readOnly: isPhoneEditable,
                          ),
                          SizedBox(
                            height: Responsive.getHeight(16),
                          ),
                          WantText2(
                              text: "Address",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
                          SizedBox(
                            height: Responsive.getHeight(4),
                          ),
                          AppTextFormField(
                            fillColor: white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(15)),
                            borderRadius: Responsive.getWidth(8),
                            controller: addressController,
                            borderColor: textFieldBorderColor,
                            hintStyle: GoogleFonts.poppins(
                              color: textGray,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            textStyle: GoogleFonts.poppins(
                              color: textBlack,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            hintText: "Enter Address",
                            readOnly: isAddressEditable,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isAddressEditable ? Icons.edit_off : Icons.edit,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                toggleEdit("address");
                              },
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(16),
                          ),
                          WantText2(
                              text: "Country",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
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
                              isEditable: isCountryEditable,
                              isEditableText: "country"),
                          SizedBox(
                            height: Responsive.getHeight(16),
                          ),
                          WantText2(
                              text: "State",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
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
                              isEditable: isStateEditable,
                              isEditableText: "state"),
                          SizedBox(
                            height: Responsive.getHeight(16),
                          ),
                          WantText2(
                              text: "City",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
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
                              isEditable: isCityEditable,
                              isEditableText: "city"),
                          SizedBox(
                            height: Responsive.getHeight(16),
                          ),
                          WantText2(
                              text: "Zip",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.medium,
                              textColor: textBlack11),
                          SizedBox(
                            height: Responsive.getHeight(4),
                          ),
                          AppTextFormField(
                            fillColor: white,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: Responsive.getWidth(18),
                                vertical: Responsive.getHeight(15)),
                            borderRadius: Responsive.getWidth(8),
                            controller: zipCodeController,
                            borderColor: textFieldBorderColor,
                            hintStyle: GoogleFonts.poppins(
                              color: textGray,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            textStyle: GoogleFonts.poppins(
                              color: textBlack,
                              fontSize: Responsive.getFontSize(15),
                              fontWeight: AppFontWeight.medium,
                            ),
                            hintText: "Enter Zip",
                            readOnly: isZipEditable,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isZipEditable ? Icons.edit_off : Icons.edit,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                toggleEdit("zip");
                              },
                            ),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(26),
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                showDeleteAccountDialog(context);
                              },
                              child: Container(
                                height: Responsive.getHeight(50),
                                width: Responsive.getWidth(341),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    color: black,
                                    borderRadius: BorderRadius.circular(
                                        Responsive.getWidth(8)),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        isLoading
                                            ? Center(
                                                child: SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                "SUBMIT",
                                                style: GoogleFonts.poppins(
                                                  letterSpacing: 1.5,
                                                  textStyle: TextStyle(
                                                    fontSize:
                                                        Responsive.getFontSize(
                                                            18),
                                                    letterSpacing: 1.5,
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
                          )
                          // GeneralButton(
                          //   Width: Responsive.getWidth(341),
                          //   onTap: () async {
                          //     // await _getCurrentLocation();
                          //     _updateProfile();
                          //   },
                          //   label: "Submit",
                          //   isBoarderRadiusLess: true,
                          // )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildTextField<T>({
    required TextEditingController controller,
    required bool isVisible,
    required bool isEditable,
    required String hintText,
    required String isEditableText,
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
          hintText: hintText,
          onChanged: (newValue) {
            onChanged(newValue ?? ''); // Ensure newValue is non-nullable
            setVisible(true);
          },
          readOnly: isEditable,
          suffixIcon: IconButton(
            icon: Icon(
              isEditable ? Icons.edit_off : Icons.edit,
              color: Colors.grey,
            ),
            onPressed: () {
              setVisible(true);
              toggleEdit(isEditableText);
            },
          ),
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
}
