import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/colors.dart';
import '../../../../config/toast.dart';
import '../../../../core/api_service/base_url.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';

class OrderDetailsScreen extends StatefulWidget {
  final art_unique_id;
  const OrderDetailsScreen({super.key, this.art_unique_id});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  TextEditingController _soldDateController = TextEditingController();
  TextEditingController _soldAmountController = TextEditingController();
  TextEditingController _servicesFeeController = TextEditingController();
  TextEditingController _portalTaxController = TextEditingController();
  TextEditingController _buyerPremiumController = TextEditingController();
  TextEditingController _pickDateController = TextEditingController();
  TextEditingController _vatDutiesController = TextEditingController();
  TextEditingController _trackIdCntroller = TextEditingController();
  TextEditingController _trackLinkController = TextEditingController();
  TextEditingController _companyNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  bool isLoading = true;
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
    _fetchOrderDetails();
  }

  bool isTrackingNull = true;
  Future<void> _fetchOrderDetails() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/get_private_order_data'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "customer_unique_id": customerUniqueID,
          "art_unique_id": widget.art_unique_id,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        if (data['status'] == true) {
          final orderData = data['orderData'];

          setState(() {
            isTrackingNull = orderData['isTrackingNull'] ?? true;
            _soldDateController.text = orderData['sold_date'] ?? "";
            _soldAmountController.text = orderData['sold_amount'] ?? "";
            _servicesFeeController.text = orderData['service_fee'] ?? "";
            _portalTaxController.text = orderData['portal_tax'] ?? "";
            _buyerPremiumController.text = orderData['buyer_premium'] ?? "";
            _vatDutiesController.text = orderData['vat_import_fee'] ?? "";
            _pickDateController.text = orderData['pick_date'] ?? "";
            _trackIdCntroller.text = orderData['tracking_id'] ?? "";
            _trackLinkController.text = orderData['tracking_link'] ?? "";
            _companyNameController.text = orderData['company_name'] ?? "";
          });
        } else {
          setState(() {
            isLoading = false;
          });
          showToast(message: data['message']);
        }
      } else {
        setState(() {
          isLoading = false;
        });
        showToast(message: data['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showToast(message: "Failed to load data");
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
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
                  SizedBox(
                    width: Responsive.getWidth(70),
                  ),
                  WantText2(
                      text: "Order Details",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
            ),
            SizedBox(
              height: Responsive.getHeight(16),
            ),
            isLoading
                ? Container(
                    width: Responsive.getMainWidth(context),
                    height: Responsive.getHeight(700),
                    child: Center(
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: Responsive.getWidth(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WantText2(
                            text: "Sold Date",
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
                          controller: _soldDateController,
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
                          hintText: "Sold Date",
                          readOnly: true,
                        ),
                        SizedBox(
                          height: Responsive.getHeight(16),
                        ),
                        WantText2(
                            text: "Sold Amount",
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
                          controller: _soldAmountController,
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
                          hintText: "Sold Amount",
                          readOnly: true,
                        ),
                        SizedBox(
                          height: Responsive.getHeight(16),
                        ),
                        WantText2(
                            text: "Services Fee",
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
                          controller: _servicesFeeController,
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
                          hintText: "Services Fee",
                          readOnly: true,
                        ),
                        SizedBox(
                          height: Responsive.getHeight(16),
                        ),
                        WantText2(
                            text: "Portal Tax",
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
                          controller: _portalTaxController,
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
                          hintText: "Portal Tax",
                          readOnly: true,
                        ),
                        SizedBox(
                          height: Responsive.getHeight(16),
                        ),
                        WantText2(
                            text: "Buyer Premium",
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
                          controller: _buyerPremiumController,
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
                          hintText: "Buyer Premium",
                          readOnly: true,
                        ),
                        SizedBox(
                          height: Responsive.getHeight(16),
                        ),

                        isTrackingNull
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  WantText2(
                                      text: "Pick Date",
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
                                    controller: _pickDateController,
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
                                    hintText: "Pick Date",
                                    readOnly: true,
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(16),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WantText2(
                                      text: "Vat/Import Duties",
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
                                    controller: _vatDutiesController,
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
                                    hintText: "Vat/Import Duties",
                                    readOnly: true,
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(16),
                                  ),
                                  WantText2(
                                      text: "Track ID",
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
                                    controller: _trackIdCntroller,
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
                                    hintText: "Track ID",
                                    readOnly: true,
                                    suffixIcon: IconButton(
                                      icon: Image.asset(
                                        'assets/copy.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: _trackIdCntroller.text));
                                        showToast(
                                            message:
                                                "Track ID copied to clipboard!");
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(16),
                                  ),
                                  WantText2(
                                      text: "Track Link",
                                      fontSize: Responsive.getFontSize(16),
                                      fontWeight: AppFontWeight.medium,
                                      textColor: textBlack11),
                                  SizedBox(
                                    height: Responsive.getHeight(4),
                                  ),
                                  // AppTextFormField(
                                  //   fillColor: white,
                                  //   contentPadding: EdgeInsets.symmetric(
                                  //       horizontal: Responsive.getWidth(18),
                                  //       vertical: Responsive.getHeight(15)),
                                  //   borderRadius: Responsive.getWidth(8),
                                  //   controller: _trackLinkController,
                                  //   borderColor: textFieldBorderColor,
                                  //   hintStyle: GoogleFonts.poppins(
                                  //     color: textGray,
                                  //     fontSize: Responsive.getFontSize(15),
                                  //     fontWeight: AppFontWeight.medium,
                                  //   ),
                                  //   textStyle: GoogleFonts.poppins(
                                  //     color: textBlack,
                                  //     fontSize: Responsive.getFontSize(15),
                                  //     fontWeight: AppFontWeight.medium,
                                  //   ),
                                  //   hintText: "Track Link",
                                  //   readOnly: true,
                                  //   suffixIcon: IconButton(
                                  //     icon: Image.asset(
                                  //       'assets/copy.png',
                                  //       width: 24,
                                  //       height: 24,
                                  //     ),
                                  //     onPressed: () {
                                  //       Clipboard.setData(ClipboardData(
                                  //           text: _trackLinkController.text));
                                  //       showToast(
                                  //           message:
                                  //               "Track Link copied to clipboard!");
                                  //     },
                                  //   ),
                                  // ),
                                  AppTextFormField(
                                    fillColor: white,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: Responsive.getWidth(18),
                                      vertical: Responsive.getHeight(15),
                                    ),
                                    borderRadius: Responsive.getWidth(8),
                                    controller: _trackLinkController,
                                    borderColor: textFieldBorderColor,
                                    hintStyle: GoogleFonts.poppins(
                                      color: textGray,
                                      fontSize: Responsive.getFontSize(15),
                                      fontWeight: AppFontWeight.medium,
                                    ),
                                    textStyle: GoogleFonts.poppins(
                                      color: textGray,
                                      fontSize: Responsive.getFontSize(15),
                                      fontWeight: AppFontWeight.medium,
                                    ),
                                    hintText: "Track Link",
                                    readOnly: true,
                                    onTap: () async {
                                      final url = _trackLinkController.text.trim();
                                      if (url.isNotEmpty && Uri.parse(url).isAbsolute) {
                                        if (await canLaunchUrl(Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                        } else {
                                          showToast(message: "Could not launch the link!");
                                        }
                                      } else {
                                        showToast(message: "Invalid or empty track link!");
                                      }
                                    },
                                    suffixIcon: IconButton(
                                      icon: Image.asset(
                                        'assets/copy.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: _trackLinkController.text));
                                        showToast(
                                            message:
                                                "Track Link copied to clipboard!");
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(16),
                                  ),
                                  WantText2(
                                      text: "Company Name",
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
                                    controller: _companyNameController,
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
                                    hintText: "Company Name",
                                    readOnly: true,
                                    suffixIcon: IconButton(
                                      icon: Image.asset(
                                        'assets/copy.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: _companyNameController.text));
                                        showToast(
                                            message:
                                                "Company Name copied to clipboard!");
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: Responsive.getHeight(16),
                                  ),
                                ],
                              )
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
