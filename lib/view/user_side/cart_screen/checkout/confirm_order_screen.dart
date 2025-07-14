import 'package:artist/config/colors.dart';
import 'package:artist/core/utils/app_font_weight.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/core/widgets/custom_text_2.dart';
import 'package:artist/core/widgets/general_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderConfirmationPage extends StatelessWidget {
  String email = "john@mail.com";
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: Responsive.getHeight(24),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      textAlign: TextAlign.start,
                      "Thank You\nFor Your Order",
                      style: GoogleFonts.poppins(
                        letterSpacing: 1.5,
                        color: textBlack,
                        fontSize: Responsive.getFontSize(28),
                        fontWeight: AppFontWeight.medium,
                      ),
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/User',
                              (Route<dynamic> route) => false,
                        );
                      },
                      child: Container(
                        width: Responsive.getWidth(46),
                        height: Responsive.getWidth(46),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Responsive.getWidth(50)),
                            color: black),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: Responsive.getHeight(22)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                child: Text(
                  textAlign: TextAlign.start,
                  "We’ve emailed you a confirmation to $email and we’ll notify you when your order has been dispatched.",
                  style: GoogleFonts.poppins(
                    letterSpacing: 1.5,
                    color: textGray17,
                    fontSize: Responsive.getFontSize(14),
                    fontWeight: AppFontWeight.regular,
                  ),
                ),
              ),
              SizedBox(height: Responsive.getHeight(54)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(8)),
                child: Divider(
                  color: Color.fromRGBO(228, 228, 228, 1),
                  thickness: 8,
                ),
              ),
              SizedBox(height: Responsive.getHeight(30)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WantText2(
                            text: "Delivery",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack),
                        Container(
                          width: Responsive.getWidth(145),
                          child: Text(
                            "John Smith 2950 S 108th St 53227, West Allis, US $email",
                            textAlign: TextAlign.end,
                            style: GoogleFonts.poppins(
                              letterSpacing: 1.5,
                              color: textGray17,
                              fontSize: Responsive.getFontSize(14),
                              fontWeight: AppFontWeight.regular,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Divider(
                      color: Color.fromRGBO(228, 228, 228, 1),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WantText2(
                            text: "Purchase Number",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack),
                        WantText2(
                            text: "C19283791823",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Divider(
                      color: Color.fromRGBO(228, 228, 228, 1),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WantText2(
                            text: "Payment",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack),
                        WantText2(
                            text: "136******383",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Divider(
                      color: Color.fromRGBO(228, 228, 228, 1),
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WantText2(
                            text: "Subtotal",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                        WantText2(
                            text: "US\$10.00",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WantText2(
                            text: "Delivery",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                        WantText2(
                            text: "US\$0.00",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WantText2(
                            text: "Tax",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                        WantText2(
                            text: "US\$0.00",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.regular,
                            textColor: textGray17),
                      ],
                    ),
                    SizedBox(height: Responsive.getHeight(4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WantText2(
                            text: "Total",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack),
                        WantText2(
                            text: "US\$10.00",
                            fontSize: Responsive.getFontSize(16),
                            fontWeight: AppFontWeight.medium,
                            textColor: textBlack),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.getHeight(54)),
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: Responsive.getWidth(8)),
                child: Divider(
                  color: Color.fromRGBO(228, 228, 228, 1),
                  thickness: 8,
                ),
              ),
              SizedBox(height: Responsive.getHeight(30)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WantText2(
                      text: "Item",
                      fontSize: Responsive.getFontSize(16),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack,
                    ),
                    SizedBox(height: Responsive.getHeight(24)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/back.png',
                          width: Responsive.getWidth(140),
                          height: Responsive.getWidth(140),
                        ),
                        SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Arrives by Tue, 10 May",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  color: textGreen,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.medium,
                                ),
                              ),
                              SizedBox(height: Responsive.getHeight(3)),
                              Text(
                                "Nike Everyday Plus Cushioned",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  color: textBlack,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.medium,
                                ),
                              ),
                              Text(
                                "US\$10.00",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  color: textBlack,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.medium,
                                ),
                              ),
                              SizedBox(height: Responsive.getHeight(8)),
                              Text(
                                "Size: L (10-13 / 8-12)",
                                textAlign: TextAlign.start,
                                style: GoogleFonts.poppins(
                                  color: textGray17,
                                  fontSize: Responsive.getFontSize(14),
                                  fontWeight: AppFontWeight.medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: Responsive.getHeight(46),),
              GeneralButton(Width: Responsive.getWidth(335), onTap: (){}, label: "Track Order"),
              SizedBox(height: Responsive.getHeight(24),),
              GeneralButton(Width: Responsive.getWidth(335), onTap: (){}, label: "Save Receipt",isSelected: false,buttonClick: true,)
            ],
          ),
        ),
      ),
    );
  }
}
