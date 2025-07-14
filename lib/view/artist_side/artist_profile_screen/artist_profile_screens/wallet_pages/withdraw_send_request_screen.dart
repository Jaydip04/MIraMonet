import 'package:artist/config/toast.dart';
import 'package:artist/core/api_service/api_service.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../config/colors.dart';
import '../../../../../core/utils/app_font_weight.dart';
import '../../../../../core/widgets/app_text_form_field.dart';
import '../../../../../core/widgets/custom_text_2.dart';

class WithdrawSendRequestScreen extends StatefulWidget {
  final total_amount;
  final customer_unique_id;
  const WithdrawSendRequestScreen(
      {super.key,
      required this.customer_unique_id,
      required this.total_amount});

  @override
  State<WithdrawSendRequestScreen> createState() =>
      _WithdrawSendRequestScreenState();
}

class _WithdrawSendRequestScreenState extends State<WithdrawSendRequestScreen> {
  TextEditingController amount = TextEditingController();
  bool isClick = false;

  @override
  void initState() {
    super.initState();
    amount.text = '\$';
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
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
                        border:
                            Border.all(color: textFieldBorderColor, width: 1.0),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: Responsive.getWidth(19),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.getWidth(100)),
                  WantText2(
                    text: "Wallet",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack,
                  ),
                ],
              ),
              SizedBox(
                height: Responsive.getHeight(20),
              ),
              Divider(
                color: Color.fromRGBO(230, 230, 230, 1.0),
              ),
              Image.asset(
                "assets/request.png",
                height: Responsive.getHeight(104),
                width: Responsive.getWidth(96),
              ),
              SizedBox(
                height: Responsive.getHeight(50),
              ),
              TextFormField(
                controller: amount,
                cursorColor: Colors.black,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  // prefixText: '\$', // Prefix the $ symbol
                  prefixStyle: GoogleFonts.poppins(
                    letterSpacing: 1.5,
                    color: textBlack, // Set the color of the $ symbol
                    fontSize: Responsive.getFontSize(
                        32), // Match the font size to your text
                    fontWeight: AppFontWeight.medium,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: Responsive.getHeight(18),
                  ),
                  border: InputBorder.none,
                  hintText: "Enter amount",
                  hintStyle: GoogleFonts.poppins(
                    letterSpacing: 1.5,
                    color: textGray,
                    fontSize: Responsive.getFontSize(16),
                    fontWeight: AppFontWeight.medium,
                  ),
                  alignLabelWithHint: true,
                ),
                style: GoogleFonts.poppins(
                  letterSpacing: 1.5,
                  color: textBlack,
                  fontSize: Responsive.getFontSize(32),
                  fontWeight: AppFontWeight.medium,
                ),
                textAlign:
                    TextAlign.center, // Center the text inside the field
                onChanged: (value) {
                  if (!value.startsWith('\$')) {
                    amount.text = '\$' + value;
                    amount.selection = TextSelection.fromPosition(
                        TextPosition(offset: amount.text.length));
                  }
                  String amountWithoutDollar =
                      amount.text.replaceAll(RegExp(r'[^\d]'), '');
                  print("Entered Amount (without \$): $amountWithoutDollar");
                  // print(amount.text.toString());
                },
              ),
              // SizedBox(
              //   width: Responsive.getWidth(100),
              //   child: TextFormField(
              //     cursorColor: Colors.black,
              //     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              //     keyboardType: TextInputType.number,
              //     decoration: InputDecoration(
              //       prefixText: "\$", // Prefix the $ symbol
              //       prefixStyle: GoogleFonts.poppins(
              //         letterSpacing: 1.5,
              //         color: textBlack, // Set the color of the $ symbol
              //         fontSize: Responsive.getFontSize(32), // Match the font size to your text
              //         fontWeight: AppFontWeight.medium,
              //       ),
              //       contentPadding: EdgeInsets.symmetric(
              //         vertical: Responsive.getHeight(18),
              //       ),
              //       border: InputBorder.none,
              //       hintText: "amount",
              //       hintStyle: GoogleFonts.poppins(
              //         letterSpacing: 1.5,
              //         color: textGray,
              //         fontSize: Responsive.getFontSize(16),
              //         fontWeight: AppFontWeight.medium,
              //       ),
              //       alignLabelWithHint: true,
              //     ),
              //     style: GoogleFonts.poppins(
              //       letterSpacing: 1.5,
              //       color: textBlack,
              //       fontSize: Responsive.getFontSize(32),
              //       fontWeight: AppFontWeight.medium,
              //     ),
              //     controller: amount,
              //     textAlign: TextAlign.center,
              //   ),
              // ),
              Spacer(),
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    String amountWithoutDollar =
                        amount.text.replaceAll(RegExp(r'[^\d]'), '');
                    print("Entered Amount (without \$): $amountWithoutDollar");
                    setState(() {
                      isClick = true;
                    });
                    print(widget.customer_unique_id);
                    print(widget.total_amount);
                    if (amount.text.isEmpty) {
                      showToast(message: "Enter amount");
                      setState(() {
                        isClick = false;
                      });
                    } else if(amountWithoutDollar == "0"){
                      setState(() {
                        isClick = false;
                      });
                      showToast(message: "Enter amount");
                    }
                    else if (int.parse(widget.total_amount) <
                        int.parse(amountWithoutDollar.toString())) {
                      setState(() {
                        isClick = false;
                      });
                      showToast(
                          message:
                              "The account balance is not sufficient for the withdrawal amount");
                    } else {

                      print("object");
                      if(amountWithoutDollar == "0"){
                        showToast(message: "Enter amount");
                      }else{
                        ApiService()
                            .addWidthrawlRequest(
                          customerUniqueId: widget.customer_unique_id.toString(),
                          role: "seller",
                          widthrawlAmount: amountWithoutDollar.toString(),
                          totalAmount: widget.total_amount.toString(),
                        )
                            .then((onValue) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/Artist/Profile',
                                (route) => false,
                          );
                          setState(() {
                            isClick = false;
                          });
                        });
                      }
                    }
                  },
                  child: Container(
                    height: Responsive.getHeight(45),
                    width: Responsive.getMainWidth(context),
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
                                    "SEND REQUEST",
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
