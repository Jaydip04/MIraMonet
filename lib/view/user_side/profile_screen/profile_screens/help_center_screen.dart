import 'dart:convert';
import 'dart:io';

import 'package:artist/config/toast.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/base_url.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _artController = TextEditingController();
  TextEditingController _inquiryController = TextEditingController();
  TextEditingController _desController = TextEditingController();
  TextEditingController _uploadController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  Future<void> submitChatRequest() async {
    if (!_formKey.currentState!.validate()) return;
    var uri = Uri.parse(
        "$serverUrl/help_center_chat"); // API endpoint
    var request = http.MultipartRequest('POST', uri);

    // Add fields to the request
    request.fields['customer_unique_id'] =
        customerUniqueID.toString(); // Replace with actual customer ID
    request.fields['name'] = _nameController.text.toString() ?? '';
    request.fields['email'] = _emailController.text.toString() ?? '';
    request.fields['mobile'] = _phoneController.text.toString() ?? '';
    request.fields['art_unique_id'] = _artController.text.toString() ?? '';
    request.fields['enquiry_category_id'] = _selectedCategoryId.toString();
    request.fields['issue'] = _desController.text.toString() ?? '';

    for (var image in _images) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'images[]',
          await image.readAsBytes(),
          filename: image.path.split('/').last,
        ),
      );
    }

    try {
      setState(() {
        isLoading = true;
      });
      var response = await request.send();

      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      showToast(message: data["message"]);
      // Print the entire response body
      print('Response body: $responseBody');

      if (response.statusCode == 200) {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        print("data : $data");
        Navigator.pop(context);
        if (data["status"] == true) {
          setState(() {
            isLoading = false;
          });
          // showToast(message: data["message"]);
          showToast(message: "Request submitted successfully");
          Navigator.pop(context);
          print("Request submitted successfully");
        } else {
          setState(() {
            isLoading = false;
          });
          showToast(message: data["message"]);
          print("Error: ${data["message"]}");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error submitting request: $e");
    }
  }

  Future<List<String>> _prepareImages(List<File> images) async {
    List<String> base64Images = [];

    for (var image in images) {
      List<int> imageBytes = await image.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      base64Images.add(base64Image);
    }

    return base64Images;
  }

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      print("You can only select up to 3 images.");
      return;
    }

    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) {
        print("No image selected.");
        return;
      }

      File imageFile = File(pickedFile.path);

      // Check the file size and compress if necessary
      int fileSizeInBytes = await imageFile.length();
      double fileSizeInMB = fileSizeInBytes / (1024 * 1024);

      if (fileSizeInMB > 2) {
        print("Image size is greater than 2 MB. Compressing...");
        File? compressedImage = await _compressImage(imageFile);

        if (compressedImage != null) {
          print("Image compressed successfully.");
          setState(() {
            _images.add(compressedImage);
          });
        } else {
          print("Failed to compress image.");
        }
      } else {
        print(
            "Image size is within the limit: ${fileSizeInMB.toStringAsFixed(2)} MB.");
        setState(() {
          _images.add(imageFile);
        });
      }
    } catch (e) {
      print("Error capturing or compressing image: $e");
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          path.join(tempDir.path, "compressed_${path.basename(file.path)}");

      final File? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 85,
      );

      if (compressedFile == null) {
        throw Exception("Image compression failed.");
      }

      return compressedFile;
    } catch (e) {
      print("Error compressing image: $e");
      return null;
    }
  }

  String? _selectedPurpose;
  List<String> _frame = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryName;
  int? _selectedCategoryId;

  Future<void> fetchEnquiryCategories() async {
    const String endpoint =
        "$serverUrl/get_enquiry_category";
    final payload = {"role": "customer"};

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["status"] == true) {
          setState(() {
            // Store category ID and Name in _categories
            _categories =
                List<Map<String, dynamic>>.from(data["data"].map((item) => {
                      "enquiry_category_id": item["enquiry_category_id"],
                      "enquiry_category_name": item["enquiry_category_name"]
                    }));
          });
        } else {
          print("Error: ${data["message"]}");
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEnquiryCategories();
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

  String phoneNumber = '';
  String countryCode = '';
  bool isPhoneNumberValid = true;
  PhoneNumber number = PhoneNumber(isoCode: 'US');
  bool _isDropdownOpen = false;
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Row(
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
                SizedBox(width: Responsive.getWidth(80)),
                WantText2(
                    text: "Help Center",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack)
              ],
            ),
          ),
          SizedBox(
            height: Responsive.getHeight(16),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Divider(
              color: Color.fromRGBO(230, 230, 230, 1.0),
            ),
          ),
          SizedBox(
            height: Responsive.getHeight(9),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
            child: Form(
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
                    controller: _nameController,
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
                          text: "Email",
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
                    controller: _emailController,
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
                        return 'Email cannot be empty';
                      }
                      final emailRegex = RegExp(
                        r'^[a-z][a-zA-Z0-9._%+-]*@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Email is not valid';
                      }
                      return null;
                    },
                    hintText: "Enter Email",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Phone Number",
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
                      textFieldController: _phoneController,
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
                        hintText: 'Enter Contact number',
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
                        //     _phoneController.clear();
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
                  //   controller: _phoneController,
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
                  //   keyboardType: TextInputType.numberWithOptions(
                  //       signed: true, decimal: true),
                  //   // onChanged: (p0) {
                  //   //   _formKey.currentState!.validate();
                  //   // },
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Phone Number cannot be empty';
                  //     }
                  //     return null;
                  //   },
                  //   hintText: "phone number",
                  // ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Art ID",
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
                    controller: _artController,
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
                        return 'Art ID cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Art Id",
                  ),

                  FormField<String>(
                    validator: (value) {
                      if (_selectedCategoryName == null ||
                          _selectedCategoryName!.isEmpty ||
                          _selectedCategoryName == 'Select') {
                        return 'Please select a Category';
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> state) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: Responsive.getHeight(15)),
                          Row(
                            children: [
                              WantText2(
                                  text: "Inquiry Category",
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
                          SizedBox(height: Responsive.getHeight(5)),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isDropdownOpen = !_isDropdownOpen;
                              });
                            },
                            child: InputDecorator(
                              decoration:
                              _inputDecoration(state, 'Select'),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  WantText2(
                                    text: _selectedCategoryName ?? "Select Inquiry Category",
                                    fontSize:
                                    Responsive.getFontSize(14),
                                    fontWeight: _selectedCategoryName == null
                                        ? AppFontWeight.regular
                                        : AppFontWeight.medium,
                                    textColor: _selectedCategoryName == null
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
                          if (_isDropdownOpen)
                            Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                height: Responsive.getHeight(150),
                                color: Colors.white,
                                child: ListView(
                                  shrinkWrap: true,
                                  children:_categories.map((category) {
                                    return  ListTile(
                                      title: WantText2(text: category["enquiry_category_name"], fontSize:   Responsive.getFontSize(14), fontWeight: AppFontWeight.medium, textColor: textBlack11),
                                      // Text(title),
                                      onTap: () {
                                        state.didChange(category["enquiry_category_name"]);
                                        setState(() {
                                          _selectedCategoryName = category["enquiry_category_name"];
                                          _selectedCategoryId =
                                          _categories.firstWhere((category) =>
                                          category["enquiry_category_name"] ==
                                              category["enquiry_category_name"])["enquiry_category_id"];
                                        });
                                        print(
                                            "_selectedCategoryName : $_selectedCategoryName");
                                        print(
                                            "_selectedCategoryId : $_selectedCategoryId");
                                        state.didChange(
                                            category["enquiry_category_name"]); // Update form field value
                                        setState(() {
                                          _isDropdownOpen =
                                          false; // Close dropdown after selection
                                        });
                                      },
                                    );
                                  }).toList(),
                                  // _categories.map((String title) {
                                  //   return ListTile(
                                  //     title: WantText2(text: title, fontSize:   Responsive.getFontSize(14), fontWeight: AppFontWeight.medium, textColor: textBlack11),
                                  //     // Text(title),
                                  //     onTap: () {
                                  //       state.didChange(title);
                                  //       setState(() {
                                  //         _selectedCategoryName = title;
                                  //         _selectedCategoryId =
                                  //         _categories.firstWhere((category) =>
                                  //         category["enquiry_category_name"] ==
                                  //             title)["enquiry_category_id"];
                                  //       });
                                  //       print(
                                  //           "_selectedCategoryName : $_selectedCategoryName");
                                  //       print(
                                  //           "_selectedCategoryId : $_selectedCategoryId");
                                  //       state.didChange(
                                  //           title); // Update form field value
                                  //       setState(() {
                                  //         _isDropdownOpen =
                                  //         false; // Close dropdown after selection
                                  //       });
                                  //     },
                                  //   );
                                  // }).toList(),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  // FormField<String>(
                  //   validator: (value) {
                  //     if (_selectedCategoryName == null ||
                  //         _selectedCategoryName!.isEmpty ||
                  //         _selectedCategoryName == 'Select') {
                  //       return 'Please select a Category';
                  //     }
                  //     return null;
                  //   },
                  //   builder: (FormFieldState<String> state) {
                  //     return Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         SizedBox(height: Responsive.getHeight(15)),
                  //         WantText2(
                  //             text: "Inquiry Category",
                  //             fontSize: Responsive.getFontSize(16),
                  //             fontWeight: AppFontWeight.medium,
                  //             textColor: textBlack9),
                  //         SizedBox(height: Responsive.getHeight(5)),
                  //         InputDecorator(
                  //           decoration: _inputDecoration(state, 'Select'),
                  //           child: DropdownButtonHideUnderline(
                  //
                  //             child: DropdownButton<String>(
                  //
                  //               dropdownColor: white,
                  //               hint: WantText2(
                  //                 text: "Select",
                  //                 fontSize: Responsive.getFontSize(14),
                  //                 fontWeight: AppFontWeight.regular,
                  //                 textColor: Color.fromRGBO(131, 145, 161, 1.0),
                  //               ),
                  //               icon: Icon(
                  //                 Icons.keyboard_arrow_down_outlined,
                  //                 color: Color.fromRGBO(131, 131, 131, 1),
                  //                 size: Responsive.getWidth(28),
                  //               ),
                  //               value: _selectedCategoryName,
                  //               isDense: true,
                  //               onChanged: (value) {
                  //                 // _formKey.currentState!.validate();
                  //                 state.didChange(value);
                  //                 setState(() {
                  //                   _selectedCategoryName = value;
                  //                   _selectedCategoryId =
                  //                       _categories.firstWhere((category) =>
                  //                           category["enquiry_category_name"] ==
                  //                           value)["enquiry_category_id"];
                  //                 });
                  //                 print(
                  //                     "_selectedCategoryName : $_selectedCategoryName");
                  //                 print(
                  //                     "_selectedCategoryId : $_selectedCategoryId");
                  //                 // String purpose = _getPurpose(_selectedPurpose);
                  //                 // fetchExhibitionSlots(widget.exhibitionUniqueId, purpose ,_selectedDate!);
                  //               },
                  //               items: _categories.map((category) {
                  //                 return DropdownMenuItem<String>(
                  //                   value: category["enquiry_category_name"],
                  //                   child: WantText2(
                  //                     text: category["enquiry_category_name"],
                  //                     fontSize: Responsive.getFontSize(14),
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
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Description of the Issue",
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
                    controller: _desController,
                    borderColor: textFieldBorderColor,
                    maxLines: 6,
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
                    hintText: "Enter Description of the Issue",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Upload Files",
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
                    controller: _uploadController,
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
                    suffixIcon: Icon(
                      Icons.camera_alt_outlined,
                      color: Color.fromRGBO(161, 161, 161, 1.0),
                      size: Responsive.getWidth(24),
                    ),
                    readOnly: true,
                    onTap: _images.length < 3 ? _pickImage : null,
                    hintText: "${_images.length} / 3",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    mainAxisAlignment: _images.length > 2
                        ? MainAxisAlignment.spaceAround
                        : MainAxisAlignment.start,
                    children: _images
                        .map(
                          (image) => Stack(
                            children: [
                              Container(
                                height: Responsive.getHeight(114),
                                width: Responsive.getWidth(107),
                                margin: EdgeInsets.only(
                                    right: _images.length > 2
                                        ? Responsive.getWidth(0)
                                        : Responsive.getWidth(6)),
                                padding: EdgeInsets.all(Responsive.getWidth(5)),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(250, 249, 245, 1),
                                  border: Border.all(
                                      color: Color.fromRGBO(158, 158, 158, 0.4),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.file(image, fit: BoxFit.contain),
                              ),
                              // if (imageUrl != null)
                              Positioned(
                                top: 5,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    _images.remove(image);
                                    setState(() {
                                      // _uploadController.text = "${_images.length} / 3";
                                    });
                                    // showCongratulationsDialog(context, index);
                                  },
                                  child: Image.asset(
                                    "assets/artist/upload_page/delete.png",
                                    height: Responsive.getWidth(16),
                                    width: Responsive.getWidth(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if(_formKey.currentState!.validate()){
                          if (_images.length > 1) {
                            submitChatRequest();
                          } else {
                            showToast(message: "Add Image First");
                          }
                        }else{
                          showToast(message: "Invalid Data");
                        }
                        // submitChatRequest();
                      },
                      child: Container(
                        height: Responsive.getHeight(50),
                        width: Responsive.getWidth(354),
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
                                        "SUBMIT REQUEST",
                                        style: GoogleFonts.poppins(
                                          letterSpacing: 1.5,
                                          textStyle: TextStyle(
                                            fontSize:
                                                Responsive.getFontSize(18),
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
                  // GeneralButton(
                  //   Width: Responsive.getWidth(354),
                  //   onTap: () {
                  //     submitChatRequest();
                  //   },
                  //   label: "",
                  //   isBoarderRadiusLess: true,
                  // ),
                  SizedBox(
                    height: Responsive.getHeight(10),
                  ),
                ],
              ),
            ),
          )
        ],
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
}
