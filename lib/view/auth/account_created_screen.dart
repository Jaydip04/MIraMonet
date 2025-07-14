
import 'package:artist/view/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';

import '../../config/colors.dart';
import '../../core/utils/app_font_weight.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/general_button.dart';

class AccountCreatedScreen extends StatefulWidget {

  AccountCreatedScreen({super.key});

  @override
  State<AccountCreatedScreen> createState() => _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends State<AccountCreatedScreen> {
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Container(
                width: Responsive.getWidth(331),
                height: Responsive.getMainHeight(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/successmark.png",width: Responsive.getWidth(100),height: Responsive.getWidth(100),),
                    SizedBox(height: Responsive.getHeight(35),),
                    Text(
                      "Password Changed!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        color: textBlack,
                        fontSize: Responsive.getFontSize(30),
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(8),),
                    Text(
                      "Your password has been changed successfully.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.urbanist(
                        color: textGray,
                        fontSize: Responsive.getFontSize(16),
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                    SizedBox(height: Responsive.getHeight(40),),
                    Align(
                        alignment: Alignment.center,
                        child: GeneralButton(
                          Width: Responsive.getWidth(331),
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/SignIn',
                                  (Route<dynamic> route) => false,
                            );
                          },
                          label: "Back to Login",
                          isBoarderRadiusLess: true,
                        )),
                  ],
                )),
          ),
        ));
  }
}
