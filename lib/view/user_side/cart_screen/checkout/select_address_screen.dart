import 'package:artist/config/toast.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:artist/view/user_side/cart_screen/checkout/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/country_state_city_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import '../../profile_screen/profile_screens/address_book_screen.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  // List<Address> addresses = [
  //   Address(id: '1', address: 'B205 Mauli Apt, Manpada Rd, Opp Gavdevi Mandir'),
  //   Address(id: '2', address: 'B206 Mauli Apt, Manpada Rd, Opp Gavdevi Mandir'),
  //   Address(id: '3', address: 'B207 Mauli Apt, Manpada Rd, Opp Gavdevi Mandir'),
  //   Address(id: '4', address: 'B208 Mauli Apt, Manpada Rd, Opp Gavdevi Mandir'),
  // ];
  String? selectedAddressId;
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();

  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController _countryController = TextEditingController();
  TextEditingController _cityController = TextEditingController();
  TextEditingController _stateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  @override
  void dispose() {
    _loadUserData();
    mobileNumberController.dispose();
    nameController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    addressController.dispose();
    zipCodeController.dispose();
    _stateController.dispose();
    super.dispose();
  }

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
    fetchCountries();
    _loadUserData();
  }

  String? customerUniqueID;
  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    setState(() {
      customerUniqueID = customerUniqueId;
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

  bool isLoading = false;

  void addAddress() {
    if (nameController.text.isEmpty) {
      showToast(message: "Please Enter Name");
    } else if (mobileNumberController.text.isEmpty) {
      showToast(message: "Please Enter Mobile");
    } else if (addressController.text.isEmpty) {
      showToast(message: "Please Enter Address");
    } else if (zipCodeController.text.isEmpty) {
      showToast(message: "Please Enter Pincode");
    } else if (_countryController.text.isEmpty) {
      showToast(message: "Please Enter Country");
    } else if (_stateController.text.isEmpty) {
      showToast(message: "Please Enter State");
    } else if (_cityController.text.isEmpty) {
      showToast(message: "Please Enter Name");
    } else {
      handleAddDeliveryAddress(context);
    }
  }

  void handleAddDeliveryAddress(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    final response = await ApiService().addDeliveryAddress(
      customerUniqueId: customerUniqueID.toString(),
      fullName: nameController.text.toString(),
      mobile: mobileNumberController.text.toString(),
      country: selectedCountry!.id.toString(),
      state: selectedState!.id.toString(),
      city: selectedCity!.id.toString(),
      address: addressController.text.toString(),
      pincode: zipCodeController.text.toString(),
    );

    if (response != null) {
      setState(() {
        isLoading = false;
      });
      String deliveryAddressId =
          response['customers_delivery_address_id'].toString();
      print('Delivery Address ID: $deliveryAddressId');
      showToast(message: "Add Delivery Address Successfully.");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PaymentScreen(deliveryAddressId: deliveryAddressId)),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showToast(message: "Failed to add delivery address");
    }
  }
  String phoneNumber = '';
  String countryCode = '';
  bool isPhoneNumberValid = true;
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: whiteBack,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
        child: ListView(
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
                  width: Responsive.getWidth(70),
                ),
                WantText2(
                    text: "Add Address",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack)
              ],
            ),
            SizedBox(
              height: Responsive.getHeight(10),
            ),
            // Container(
            //     height: Responsive.getHeight(56),
            //     width: Responsive.getWidth(336),
            //     padding: EdgeInsets.symmetric(
            //         horizontal: Responsive.getWidth(49),
            //         vertical: Responsive.getHeight(20)),
            //     decoration: BoxDecoration(
            //       boxShadow: [
            //         BoxShadow(
            //             color: Color.fromRGBO(0, 0, 0, 0.1),
            //             blurRadius: 17,
            //             spreadRadius: 0,
            //             offset: Offset(0, 4))
            //       ],
            //       color: white,
            //       borderRadius: BorderRadius.circular(Responsive.getWidth(20)),
            //     ),
            //     child: Image.asset(
            //       "assets/step_1.png",
            //       width: Responsive.getWidth(238),
            //       height: Responsive.getHeight(16),
            //     )),
            SizedBox(height: Responsive.getHeight(20)),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      WantText2(
                          text: "Full Name",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
                      WantText2(
                          text: "*",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                    ],
                  ),
                  SizedBox(
                    height: Responsive.getHeight(5),
                  ),
                  AppTextFormField(
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(14)),
                    borderRadius: Responsive.getWidth(8),
                    controller: nameController,
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
                        return 'Full Name cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Name",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Mobile Number",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
                      WantText2(
                          text: "*",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                    ],
                  ),
                  SizedBox(
                    height: Responsive.getHeight(5),
                  ),
                  Container(
                    // width: Responsive.getWidth(252),
                    padding: EdgeInsets.only(
                      left: Responsive.getWidth(16),
                    ),
                    decoration: BoxDecoration(
                      // color: Color.fromRGBO(247, 248, 249, 1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          width: 1,
                          color:
                          // isPhoneNumberValid
                          //     ?
                          textFieldBorderColor
                        // : Colors.red,
                      ),
                    ),
                    child: InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        setState(() {
                          phoneNumber = number.phoneNumber ?? '';
                          countryCode = number.dialCode ?? '';
                        });
                        print("Full number: $phoneNumber");
                        print("Country code: $countryCode");
                      },
                      onInputValidated: (bool value) {
                        setState(() {
                          isPhoneNumberValid = value;
                        });
                        print(value ? 'Valid' : 'Invalid');
                      },
                      selectorConfig: SelectorConfig(
                        setSelectorButtonAsPrefixIcon: false,
                        useBottomSheetSafeArea: true,
                        leadingPadding: 0,
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        useEmoji: false,
                        trailingSpace: false,
                      ),
                      ignoreBlank: false,
                      autoValidateMode: AutovalidateMode.disabled,
                      initialValue: number,
                      textFieldController: mobileNumberController,
                      formatInput: false,
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onSaved: (PhoneNumber number) {
                        String formattedNumber =
                            number.phoneNumber?.replaceFirst('+', '') ?? '';
                        print('On Saved: $formattedNumber');
                      },
                      cursorColor: Colors.black,
                      textStyle: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        color: black,
                        fontSize: 14.00,
                        fontWeight: FontWeight.w500,
                      ),
                      inputDecoration: InputDecoration(
                        isDense: true,
                        hintText: 'Enter Mobile Number',
                        hintStyle: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          color: textGray,
                          fontSize: 14.00,
                          fontWeight: FontWeight.normal,
                        ),
                        // fillColor: Color.fromRGBO(247, 248, 249, 1),
                        // filled: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 0, vertical: 10),
                        // suffixIcon: IconButton(
                        //   icon: Icon(
                        //     Icons.clear,
                        //     color: Colors.grey,
                        //   ),
                        //   onPressed: () {
                        //     mobileNumberController.clear();
                        //   },
                        // ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 0,
                          minHeight: 0,
                        ),
                        suffixIconConstraints: BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        errorMaxLines: 3,
                        counterText: "",
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide.none,
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)),
                          borderSide:
                          BorderSide(color: Colors.red, width: 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                              color: Colors.transparent, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                              color: Colors.transparent, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(
                              color: Colors.transparent, width: 1),
                        ),
                      ),
                    ),
                  ),
                  // AppTextFormField(
                  //   fillColor: Color.fromRGBO(247, 248, 249, 1),
                  //   contentPadding: EdgeInsets.symmetric(
                  //       horizontal: Responsive.getWidth(18),
                  //       vertical: Responsive.getHeight(14)),
                  //   borderRadius: Responsive.getWidth(8),
                  //   controller: mobileNumberController,
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
                  //   keyboardType: TextInputType.phone,
                  //   inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  //   // onChanged: (p0) {
                  //   //   _formKey.currentState!.validate();
                  //   // },
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Mobile number cannot be empty';
                  //     }
                  //     return null;
                  //   },
                  //   hintText: "number",
                  // ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),

                  Row(
                    children: [
                      WantText2(
                          text: "Address",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
                      WantText2(
                          text: "*",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                    ],
                  ),
                  SizedBox(
                    height: Responsive.getHeight(5),
                  ),
                  AppTextFormField(
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(14)),
                    borderRadius: Responsive.getWidth(8),
                    controller: addressController,
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
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Country",
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
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'Country cannot be empty';
                    //   }
                    //   return null;
                    // },
                    setVisible: (visible) {
                      setState(() {
                        isCountryDropdownVisible = visible;
                      });
                    },
                    // isEditableText: "country"
                  ),
                  SizedBox(
                    height: Responsive.getHeight(16),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "States",
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
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'State cannot be empty';
                    //   }
                    //   return null;
                    // },
                    setVisible: (visible) {
                      setState(() {
                        isStateDropdownVisible = visible;
                      });
                    },
                    // isEditableText: "state"
                  ),
                  SizedBox(
                    height: Responsive.getHeight(16),
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
                    // validator: (value) {
                    //   if (value == null || value.isEmpty) {
                    //     return 'City cannot be empty';
                    //   }
                    //   return null;
                    // },
                    setVisible: (visible) {
                      setState(() {
                        isCityDropdownVisible = visible;
                      });
                    },
                    // isEditableText: "city"
                  ),

                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Zip Code",
                          fontSize: Responsive.getFontSize(16),
                          fontWeight: AppFontWeight.medium,
                          textColor: textBlack9),
                      WantText2(
                          text: "*",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Color.fromRGBO(246, 0, 0, 1.0)),
                    ],
                  ),
                  SizedBox(
                    height: Responsive.getHeight(5),
                  ),
                  AppTextFormField(
                    fillColor: Color.fromRGBO(247, 248, 249, 1),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(18),
                        vertical: Responsive.getHeight(14)),
                    borderRadius: Responsive.getWidth(8),
                    controller: zipCodeController,
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
                        return 'Zip cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Zip",
                  ),

                ],
              ),
            ),
            SizedBox(height: Responsive.getHeight(23)),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    addAddress();
                  } else {
                    showToast(message: "Invalid Data");
                  }
                },
                child: Container(
                  height: Responsive.getHeight(50),
                  width: Responsive.getWidth(341),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: black,
                      borderRadius:
                          BorderRadius.circular(Responsive.getWidth(8)),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          isLoading
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
                                  "CONFIRM",
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
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(20),
            ),
          ],
        ),
      ),
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
}
