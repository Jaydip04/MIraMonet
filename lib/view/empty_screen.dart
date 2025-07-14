// import 'package:artist/config/colors.dart';
// import 'package:artist/core/utils/responsive.dart';
// import 'package:artist/core/widgets/custom_text_2.dart';
// import 'package:artist/core/widgets/general_button.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// class EmptyScreen extends StatefulWidget {
//   const EmptyScreen({super.key});
//
//   @override
//   State<EmptyScreen> createState() => _EmptyScreenState();
// }
//
// class _EmptyScreenState extends State<EmptyScreen> {
//
//
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email'],
//   );
//
//   Future<void> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         print("User canceled login");
//         return;
//       }
//
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//
//       final String idToken = googleAuth.idToken!;
//
//       await sendTokenToBackend(idToken);
//     } catch (e) {
//       print("Error during Google Sign-In: $e");
//     }
//   }
//
//   Future<void> sendTokenToBackend(String idToken) async {
//     final response = await http.post(
//       Uri.parse("https://headstart.genixbit.com/api/customer_data"),
//       body: {'google_id_token': idToken},
//     );
//
//     if (response.statusCode == 200) {
//       print("Login successful: ${response.body}");
//     } else {
//       print("Login failed: ${response.body}");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               GeneralButton(Width: Responsive.getWidth(355), onTap: (){
//                 signInWithGoogle();
//               }, label: "Google")
//           // Container(
//           // height: MediaQuery.of(context).size.height * 0.06,
//           // width: MediaQuery.of(context).size.width,
//           // decoration: BoxDecoration(
//           //   borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02),
//           //   border: Border.all(color: Colors.grey),
//           //   image: DecorationImage(
//           //     opacity: 0.6,
//           //     image: AssetImage("assets/images/textFormFieldBG.png"),
//           //     fit: BoxFit.cover,
//           //   ),
//           // ),
//           // child: Stack(
//           //   children: [
//           //     // Hint text
//           //     Positioned.fill(
//           //       child: Align(
//           //         alignment: Alignment.centerLeft,
//           //         child: Padding(
//           //           padding: EdgeInsets.symmetric(
//           //               horizontal: MediaQuery.of(context).size.width * 0.04),
//           //           child: Text(
//           //            "select",
//           //             style: GoogleFonts.dmSans(
//           //               color: textGray,
//           //               fontSize: MediaQuery.of(context).size.width * 0.04,
//           //               fontWeight: FontWeight.w500,
//           //             ),
//           //           ),
//           //         ),
//           //       ),
//           //     ),
//           //     // Dropdown button
//           //     // DropdownButton2<String>(
//           //     //   iconStyleData: IconStyleData(
//           //     //       icon: Padding(
//           //     //         padding: EdgeInsets.all(8.0),
//           //     //         child: Icon(
//           //     //           Icons.keyboard_arrow_down,
//           //     //           color: colorBlack,
//           //     //           size: MediaQuery.of(context).size.width * 0.065,
//           //     //         ),
//           //     //       )),
//           //     //   value: value,
//           //     //   isExpanded: true,
//           //     //   underline: SizedBox(),
//           //     //   items: items,
//           //     //   onChanged: (selectedValue) {
//           //     //     onChanged(selectedValue);
//           //     //   },
//           //     //   dropdownStyleData: DropdownStyleData(
//           //     //     maxHeight: MediaQuery.of(context).size.width * 0.5,
//           //     //     width: MediaQuery.of(context).size.width * 0.82,
//           //     //     decoration: BoxDecoration(
//           //     //       borderRadius: BorderRadius.circular(14),
//           //     //       color: white,
//           //     //     ),
//           //     //     offset: const Offset(0, 0),
//           //     //     scrollbarTheme: ScrollbarThemeData(
//           //     //       radius: const Radius.circular(40),
//           //     //       thickness: MaterialStateProperty.all<double>(6),
//           //     //       thumbVisibility: MaterialStateProperty.all<bool>(true),
//           //     //     ),
//           //     //   ),
//           //     // ),
//           //   ],
//           // ),
//           //       ),
//               // Container(
//               //   height: 50,
//               //   margin: EdgeInsets.all(10),
//               //   padding: EdgeInsets.symmetric(horizontal: 10),
//               //   width: double.infinity,
//               //   decoration: BoxDecoration(
//               //       border: Border.all(color: Colors.grey),
//               //       borderRadius: BorderRadius.circular(8)),
//               //   child: Row(
//               //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //     children: [
//               //       Column(
//               //         children: [
//               //           Row(
//               //             children: [
//               //               ClipRRect(
//               //                 child: Image.asset(
//               //                   "assets/donate.png",
//               //                   width: 28,
//               //                   height: 28,
//               //                 ),
//               //                 borderRadius: BorderRadius.circular(5),
//               //               ),
//               //               SizedBox(
//               //                 width: 10,
//               //               ),
//               //               WantText2(
//               //                   text: "demo.pdf",
//               //                   fontSize: 14,
//               //                   fontWeight: FontWeight.bold,
//               //                   textColor: Colors.black),
//               //             ],
//               //             mainAxisAlignment: MainAxisAlignment.center,
//               //             crossAxisAlignment: CrossAxisAlignment.center,
//               //           ),
//               //         ],
//               //         mainAxisAlignment: MainAxisAlignment.center,
//               //         crossAxisAlignment: CrossAxisAlignment.center,
//               //       ),
//               //       Image.asset(
//               //         "assets/delete.png",
//               //         width: 16,
//               //         height: 16,
//               //       ),
//               //     ],
//               //   ),
//               // )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
