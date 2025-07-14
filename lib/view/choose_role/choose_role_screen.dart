import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import '../../core/utils/app_font_weight.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/custom_text.dart';
import '../../core/widgets/general_button.dart';

class ChooseRoleScreen extends StatefulWidget {
  @override
  _ChooseRoleScreenState createState() => _ChooseRoleScreenState();
}

class _ChooseRoleScreenState extends State<ChooseRoleScreen> {
  String? _selectedOption = 'customer';

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Container(
                width: Responsive.getWidth(335),
                height: Responsive.getMainHeight(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: Responsive.getHeight(96),
                    ),
                    Text(
                      "Sign Up As",
                      style: GoogleFonts.urbanist(
                        color: textBlack7,
                        fontSize: Responsive.getFontSize(26),
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    Text(
                      "Choose an Option",
                      style: GoogleFonts.urbanist(
                        color: textBlack7,
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: AppFontWeight.regular,
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(26),
                    ),
                    _buildOption('customer', "User"),
                    SizedBox(
                      height: Responsive.getHeight(15),
                    ),
                    _buildOption('seller', "Artist"),
                    Spacer(),
                    Center(
                      child: GeneralButton(
                        Width: Responsive.getWidth(331),
                        onTap: () async {
                          if (_selectedOption != null) {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            print("'selectedRole', $_selectedOption!");
                            await prefs.setString(
                                'selectedRole', _selectedOption!);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/SignUP',
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                        label: "Next",
                        isBoarderRadiusLess: true,
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(13),
                    ),
                    Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WantText(
                              text: "Already have an account? ",
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                              textColor: buttonBlack),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/SignIn',
                                (Route<dynamic> route) => false,
                              );
                            },
                            child: WantText(
                                text: "Login Now",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.bold,
                                textColor: textBlack),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Responsive.getHeight(10),
                    ),
                  ],
                )),
          ),
        ));
  }

  Widget _buildOption(String title, String view) {
    Responsive.init(context);
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOption = title;
        });
      },
      child: Container(
        width: Responsive.getWidth(335),
        padding: EdgeInsets.symmetric(
            horizontal: Responsive.getWidth(12),
            vertical: Responsive.getHeight(14)),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                _selectedOption == title ? Colors.black : textFieldBorderColor4,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            WantText2(
                text: view,
                fontSize: Responsive.getFontSize(14),
                fontWeight: AppFontWeight.medium,
                textColor: _selectedOption == title ? black : textFieldBorderColor4),
            _selectedOption == title
                ? Icon(Icons.check_circle, color: Colors.black)
                : Icon(Icons.radio_button_unchecked,
                    color: textFieldBorderColor4),
          ],
        ),
      ),
    );
  }
}
