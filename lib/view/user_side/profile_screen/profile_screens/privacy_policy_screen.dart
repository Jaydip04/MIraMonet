import 'package:artist/core/api_service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/colors.dart';
import '../../../../core/models/privacy_policy_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/custom_text_2.dart';
import '../../../artist_side/artist_profile_screen/artist_profile_screens/artist_privacy_policy_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  State<PrivacyPolicyScreen> createState() =>
      _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final List<String> policyAndConditions = [];
  final List<String> termsAndConditions = [];
  bool isLoading = true;
  String insertedDate = "";

  Future<void> _loadPrivacyPolicy(String role) async {
    try {
      PrivacyPolicy privacyPolicy = await ApiService().fetchPrivacyPolicy(role);

      termsAndConditions.clear();

      for (var term in privacyPolicy.terms) {
        if (term.heading.toLowerCase().contains('terms')) {
          for (var para in term.conditionsParas) {
            termsAndConditions.add(para.paragraph);
          }
        }
      }

      for (var policy in privacyPolicy.policy) {
        setState(() {
          insertedDate  = policy.insertedDate;
        });
        print("Privacy Policy ID: ${policy.privacyPolicyId}");
        print("Role: ${policy.role}");
        print("Inserted Date: ${policy.insertedDate}");
        if (policy.heading.toLowerCase().contains('privacy')) {
          for (var para in policy.policyParas) {
            policyAndConditions.add(para.paragraph);
          }
        }
      }

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      print('Error fetching privacy policy: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  String role = '';

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = (prefs.get('role') is String)
          ? prefs.getString('role') ?? ''
          : prefs.getInt('role')?.toString() ?? '';
    });
    _loadPrivacyPolicy(role);
  }

  String convertDate(String inputDate) {
    DateTime date = DateTime.parse(inputDate);
    DateTime newDate = DateTime(date.year - 1, date.month - 1, date.day);
    return DateFormat("MMM dd, yyyy").format(newDate);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  @override
  void dispose() {
    _loadUserData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
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
          : SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    SizedBox(width: 70),
                    Text(
                      "Privacy Policy",
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18),
                insertedDate.isEmpty
                    ? Container(
                  height: Responsive.getHeight(600),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/profile_image/iconoir_privacy_policy.png",
                        width: Responsive.getWidth(64),
                        height: Responsive.getWidth(64),
                      ),
                      SizedBox(height: Responsive.getHeight(10)),
                      WantText2(
                        text: "No Policy!",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.semiBold,
                        textColor: textBlack11,
                      ),
                    ],
                  ),
                )
                    : Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Last update: ",
                            style: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            convertDate(insertedDate),
                            style: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      policyAndConditions.length == 0
                          ? Text(
                        "No Policy",
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textGray,
                        ),
                      )
                          : ListView.builder(
                        shrinkWrap: true,
                        physics:
                        NeverScrollableScrollPhysics(),
                        itemCount: policyAndConditions.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: Responsive.getMainWidth(
                                context),
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 4.0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      policyAndConditions[
                                      index],
                                      style:
                                      GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                      policyAndConditions.length == 0
                          ? Container()
                          : Text(
                        "Terms & Conditions",
                        style: GoogleFonts.poppins(
                          letterSpacing: 1.5,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      termsAndConditions.length == 0
                          ? Container()
                          : ListView.builder(
                        shrinkWrap: true,
                        physics:
                        NeverScrollableScrollPhysics(),
                        itemCount: termsAndConditions.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: Responsive.getMainWidth(
                                context),
                            child: Padding(
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 4.0),
                              child: Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${index + 1}. ',
                                    style:
                                    GoogleFonts.poppins(
                                      letterSpacing: 1.5,
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.w400,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      termsAndConditions[
                                      index],
                                      style:
                                      GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
