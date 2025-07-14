import 'package:artist/config/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _ArtistBankDetilsScreenState();
}

class _ArtistBankDetilsScreenState extends State<BankDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _holderNameController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();
  TextEditingController _bankCodeController = TextEditingController();
  TextEditingController _digitalIdController = TextEditingController();
  bool isLoading = false;
  bool isLoading2 = false;

  @override
  void initState() {
    super.initState();
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
    if (customerUniqueID != null && customerUniqueID!.isNotEmpty) {
      _fetchBankDetails();
    }
  }

  bool? isAvailable;
  void _fetchBankDetails() async {
    setState(() {
      isLoading2 = true;
    });

    ApiService apiService = ApiService();
    final response = await apiService.getBankDetails(
      customerUniqueId: customerUniqueID.toString(),
    );

    if (response['status'] == true && response['data'] != null) {
      final data = response['data'];

      setState(() {
        isAvailable = true;
        _holderNameController.text = data['account_holder_name'] ?? '';
        _bankNameController.text = data['bank_name'] ?? '';
        _accountNumberController.text = data['account_number'] ?? '';
        _bankCodeController.text = data['bank_code'] ?? '';
        _digitalIdController.text = data['digital_payment_id'] ?? '';
        isLoading2 = false;
      });
    } else {
      setState(() {
        isAvailable = false;
        isLoading2 = false;
      });
      // showToast(message: "Failed to load bank details");
    }
  }


  void submitBankDetails() async {
    ApiService apiService = ApiService();
    setState(() {
      isLoading = true;
    });

    final response = await apiService.addBankDetails(
      customerUniqueId: customerUniqueID.toString(),
      accountHolderName: _holderNameController.text.toString(),
      bankName: _bankNameController.text.toString(),
      accountNumber: _accountNumberController.text.toString(),
      bankCode: _bankCodeController.text.toString(),
      digitalPaymentId: _digitalIdController.text.toString(),
    );

    print(response);
    if(response['status'] == true){
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
      showToast(message: response['message']);
    }else {
      setState(() {
        isLoading = false;
      });
      showToast(message: response['message']);
    }
    // if (response.containsKey('error')) {
    //
    //   print("Error: ${response['error']}");
    // } else {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   print("Success: ${response}");
    // }
  }


  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: isLoading2 ? Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.black,
          ),
        ),
      ) : ListView(
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
                SizedBox(width: Responsive.getWidth(70)),
                WantText2(
                    text: "Bank Details",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack),

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
                          text: "Account Holder Name",
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
                    controller: _holderNameController,
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
                        return 'Account Holder Name cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Account Holder Name",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Bank Name",
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
                    controller: _bankNameController,
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
                        return 'Bank Name cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Bank Name",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Account Number",
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
                    controller: _accountNumberController,
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
                        return 'Account Number cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Account Number",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Bank Code",
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
                    controller: _bankCodeController,
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
                        return 'Bank Code cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Bank Code",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(15),
                  ),
                  Row(
                    children: [
                      WantText2(
                          text: "Digital Payment ID",
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
                    controller: _digitalIdController,
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
                        return 'Digital Payment ID cannot be empty';
                      }
                      return null;
                    },
                    hintText: "Enter Digital Payment ID",
                  ),
                  SizedBox(
                    height: Responsive.getHeight(25),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if(_formKey.currentState!.validate()){
                          submitBankDetails();
                        }else{
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
                                  isAvailable! ? "UPDATE" :"SUBMIT",
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
