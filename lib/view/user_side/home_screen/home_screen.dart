import 'dart:async';

import 'package:artist/config/colors.dart';
import 'package:artist/core/models/artist_model.dart';
import 'package:artist/core/utils/responsive.dart';
import 'package:artist/view/user_side/home_screen/product_detail/single_product/single_private_product_detail_screen.dart';
import 'package:artist/view/user_side/home_screen/product_detail/single_product/single_product_detail_screen.dart';
import 'package:artist/view/user_side/home_screen/search_screen.dart';
import 'package:artist/view/user_side/home_screen/upcoming_exhibition/single_upcoming_exhibitions/single_upcoming_exhibition_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/models/category_model.dart';
import '../../../core/models/customer_modell.dart';
import '../../../core/models/user_side/all_artist_story_model.dart';
import '../../../core/models/user_side/customer_all_art_model.dart';
import '../../../core/models/user_side/customer_exhibitions_model.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/widgets/app_text_form_field.dart';
import '../../../core/widgets/custom_text_2.dart';
import '../artists_stories_screen/single_atist_store/single_artist_story_screen.dart';
import 'all_category/all_category_screen.dart';
import 'all_category/single_category/single_category_screen.dart';
import 'artist_profile/single_artist_profile_screen/single_artist_profile_screen.dart';

class SearchSuggestion {
  final String? productName;
  final int? productId;
  final String? uniqueId;
  final String? art_unique_id;
  final int? categoryId;
  final String? artistName;

  SearchSuggestion({
    this.productName,
    this.productId,
    this.uniqueId,
    this.art_unique_id,
    this.categoryId,
    this.artistName,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      productName:
          json['title'] ?? json['category_name'] ?? json['artist_name'],
      productId: json['art_id'],
      uniqueId: json['artist_unique_id'],
      art_unique_id: json['art_unique_id'],
      categoryId: json['category_id'],
      artistName: json['artist_name'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  late Timer _timer;
  double _scrollPosition = 0.0;
  late Future<List<ArtistModel>> futureArtists;
  late Future<List<CustomerAllArtModel>> artData;
  late Future<List<CustomerAllArtModel>> artDataPrivate;
  late Future<List<Story>> artistStory;

  late Future<List<CustomerExhibitionsModel>> futureExhibitions;
  List<SearchSuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _showResults = true;
  String? customerUniqueID;
  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  final ApiService apiService = ApiService();
  late Future<List<Category>> _categoriesFuture;
  bool _isScrolling = true;
  bool isLoggedIn = false;
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getString('UserToken') != null;
    });
  }

  late StreamSubscription<List<ConnectivityResult>> subscription;
  @override
  void initState() {
    super.initState();
    _checkLoginStatus().then((onValue) {
      if (isLoggedIn) {
        print("object");
        _loadUserData();
      } else {
        print("object0");
      }
    });

    _categoriesFuture = ApiService().fetchCategories();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
    artData = ApiService().getAllArt();
    artDataPrivate = ApiService().getAllPrivateArt();
    futureArtists = ApiService().fetchArtists();
    artistStory = ApiService().fetchArtistStories();
    futureExhibitions = ApiService().fetchExhibitionsForCustomer();

    _scrollController = ScrollController();
    // _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
    //   if (_scrollController.hasClients) {
    //     double maxScroll = _scrollController.position.maxScrollExtent;
    //     double currentScroll = _scrollController.position.pixels;
    //
    //     // Move forward smoothly
    //     double nextScroll = currentScroll + 2; // Adjust speed here
    //
    //     if (nextScroll >= maxScroll) {
    //       // Reset to the start for infinite scrolling
    //       _scrollController.jumpTo(0.0);
    //     } else {
    //       _scrollController.animateTo(
    //         nextScroll,
    //         duration: Duration(milliseconds: 100),
    //         curve: Curves.linear,
    //       );
    //     }
    //   }
    // });
    // _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    //   if (_scrollController.hasClients) {
    //     _scrollPosition += 50;
    //     if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
    //       _scrollPosition = 0.0;
    //     }
    //     _scrollController.animateTo(
    //       _scrollPosition,
    //       duration: Duration(seconds: 1),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });
    // _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    //   if (_scrollController.hasClients) {
    //     double maxScroll = _scrollController.position.maxScrollExtent;
    //
    //     _scrollPosition += 120;
    //     if (_scrollPosition >= maxScroll) {
    //       _scrollPosition = 0.0;
    //     }
    //
    //     _scrollController.animateTo(
    //       _scrollPosition,
    //       duration: Duration(seconds: 3),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });
    // _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
    //   if (_scrollController.hasClients) {
    //     double maxScroll = _scrollController.position.maxScrollExtent;
    //
    //     // Check if we reached the end, then reset to the beginning
    //     if (_scrollController.offset >= maxScroll) {
    //       _scrollController.jumpTo(0.0);
    //     } else {
    //       _scrollController.animateTo(
    //         _scrollController.offset + 2, // Moves smoothly without a limit
    //         duration: Duration(milliseconds: 50),
    //         curve: Curves.easeInOut, // Ensures smooth, steady scrolling
    //       );
    //     }
    //   }
    // });
    // _timer = Timer.periodic(Duration(seconds: 4), (timer) {
    //   if (_scrollController.hasClients) {
    //     _scrollPosition += 50;
    //     if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
    //       _scrollPosition = 0.0;
    //     }
    //     _scrollController.animateTo(
    //       _scrollPosition,
    //       duration: Duration(seconds: 4),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });
  }

  // void _onSearchChanged(String query) {
  //   if (query.length >= 3) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //
  //     ApiService().fetchSearchSuggestions(query).then((suggestions) {
  //       setState(() {
  //         _suggestions = suggestions;
  //         _showResults = true;
  //         _isLoading = false;
  //       });
  //     }).catchError((e) {
  //       // Handle errors if fetching fails
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       print('Error fetching search suggestions: $e');
  //     });
  //   } else {
  //     // Reset suggestions and hide results if the query length is less than 3
  //     setState(() {
  //       _suggestions = [];
  //       _showResults = false;
  //     });
  //   }
  // }

  void _onSearchChanged(String query) {
    // if (query.length >= 3) {
    setState(() {
      _isLoading = true;
    });

    ApiService().fetchSearchSuggestions(query).then((suggestions) {
      setState(() {
        _suggestions = suggestions;
        _showResults = true;
        _isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching search suggestions: $e');
    });
    // } else {
    //   setState(() {
    //     _suggestions = [];
    //     _showResults = false;
    //   });
    // }
  }

  // Widget _buildSuggestions() {
  //   if (_isLoading) {
  //     // FocusScope.of(context).unfocus();
  //     return Center(
  //       child: SizedBox(
  //         height: 20,
  //         width: 20,
  //         child: CircularProgressIndicator(
  //           strokeWidth: 3,
  //           color: Colors.black,
  //         ),
  //       ),
  //     );
  //   }
  //   if (_suggestions.isEmpty) {
  //     return _searchController.text.isEmpty
  //         ? SizedBox()
  //         : Container(
  //             margin: EdgeInsets.symmetric(horizontal: 10.00, vertical: 5.00),
  //             padding: EdgeInsets.symmetric(horizontal: 10.00, vertical: 12.00),
  //             decoration: BoxDecoration(
  //                 color: Colors.grey.withOpacity(0.2),
  //                 borderRadius: BorderRadius.circular(10.00)),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "No Search Found",
  //                       textAlign: TextAlign.start,
  //                       style: GoogleFonts.poppins(
  //                           color: Colors.black,
  //                           // fontSize: fontSize,
  //                           fontWeight: FontWeight.bold,
  //                           letterSpacing: 1.5),
  //                       // TextStyle(
  //                       //     color: Colors.black, fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //                 // Divider()
  //               ],
  //             ),
  //           );
  //   }
  //   return ListView.builder(
  //     shrinkWrap: true,
  //     itemCount: _suggestions.length,
  //     itemBuilder: (context, index) {
  //       return GestureDetector(
  //         onTap: () {
  //           Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (_) => SearchScreen(
  //                         search_query: _suggestions[index].productName,
  //                       )));
  //           _showResults = false;
  //         },
  //         child: Container(
  //           margin: EdgeInsets.symmetric(horizontal: 10.00, vertical: 5.00),
  //           padding: EdgeInsets.symmetric(horizontal: 10.00, vertical: 12.00),
  //           decoration: BoxDecoration(
  //               color: Colors.grey.withOpacity(0.2),
  //               borderRadius: BorderRadius.circular(10.00)),
  //           child: Column(
  //             children: [
  //               Row(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     _suggestions[index].productName,
  //                     textAlign: TextAlign.start,
  //                     style: GoogleFonts.poppins(
  //                         color: Colors.black,
  //                         // fontSize: fontSize,
  //                         fontWeight: FontWeight.bold,
  //                         letterSpacing: 1.5),
  //                     // TextStyle(
  //                     //     color: Colors.black, fontWeight: FontWeight.bold),
  //                   ),
  //                 ],
  //               ),
  //               // Divider()
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildSuggestions() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
        ),
      );
    }
    if (_suggestions.isEmpty) {
      return _searchController.text.isEmpty
          ? SizedBox()
          : Container(
              margin: EdgeInsets.symmetric(horizontal: 10.00, vertical: 5.00),
              padding: EdgeInsets.symmetric(horizontal: 10.00, vertical: 12.00),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.00)),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "No Search Found",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.poppins(
                            color: Colors.black,
                            // fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                        // TextStyle(
                        //     color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  // Divider()
                ],
              ),
            );
    }
    return SizedBox(
      height: Responsive.getHeight(300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () async {
              print(_suggestions[index]);
              if (_suggestions[index].uniqueId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleArtistProfileScreen(
                        artistUniqueId: _suggestions[index].uniqueId!),
                  ),
                );
              } else if (_suggestions[index].categoryId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SingleCategoryScreen(
                      Category_id: _suggestions[index].categoryId!,
                      Category_name: _suggestions[index].productName,
                    ),
                  ),
                );
              } else if (_suggestions[index].art_unique_id != null) {
                ApiService apiService = ApiService();
                Map<String, dynamic>? result = await apiService.getSingleArt(
                    _suggestions[index].art_unique_id!.toString(),
                    customerUniqueID.toString());

                if (result != null) {
                  String mainArtType = result['art']['art_type'];
                  String status = result['art']['status'];
                  print('Main Art Type: $mainArtType');

                  if (mainArtType == "Online") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SingleProductDetailScreen(
                          artUniqueId: _suggestions[index].art_unique_id!,
                          art_status: status,
                        ),
                      ),
                    );
                  } else if (mainArtType == "Private") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SinglePrivateProductDetailScreen(
                            artUniqueId: _suggestions[index].art_unique_id!),
                      ),
                    );
                  }
                  // List<dynamic> categoryArtData = result['categoryArtData'];
                  // for (var art in categoryArtData) {
                  //   print('Category Art Type: ${art['art_type']}');
                  // }
                }
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0)),
              child: Text(
                _suggestions[index].productName ?? "",
                textAlign: TextAlign.start,
                style: GoogleFonts.poppins(
                    color: Colors.black,
                    // fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
                // TextStyle(
                //     color: Colors.black, fontWeight: FontWeight.bold),
              ),
              // Text(_suggestions[index].productName ?? "",
              //     style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(
      () {
        _onSearchChanged(_searchController.text);
      },
    );
    _searchController.dispose();
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerUniqueId = (prefs.get('customerUniqueId') is String)
        ? prefs.getString('customerUniqueId') ?? ''
        : prefs.getInt('customerUniqueId')?.toString() ?? '';

    print(customerUniqueId.toString());
    fetchCustomerData(customerUniqueId);
    setState(() {
      customerUniqueID = customerUniqueId;
    });
  }

  void fetchCustomerData(String customerUniqueId) async {
    ApiService apiService = ApiService();

    try {
      CustomerData customerData =
          await apiService.getCustomerData(customerUniqueId);
      print("customerData : $customerData");
      _updateControllers(customerData);
    } catch (e) {
      print('Error fetching customer data: $e');
    }
  }

  String? imageUrl;
  String? name;

  void _updateControllers(CustomerData customerData) {
    setState(() {
      imageUrl = customerData.customerProfile;
      name = customerData.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _showResults = false;
          });
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Responsive.getHeight(16),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isLoggedIn
                              ? name == null
                                  ? Text(
                                      textAlign: TextAlign.start,
                                      "Hi",
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: textBlack8,
                                        fontSize: Responsive.getFontSize(20),
                                        fontWeight: AppFontWeight.bold,
                                      ),
                                    )
                                  : Text(
                                      textAlign: TextAlign.start,
                                      "Hi $name!",
                                      style: GoogleFonts.poppins(
                                        letterSpacing: 1.5,
                                        color: textBlack8,
                                        fontSize: Responsive.getFontSize(20),
                                        fontWeight: AppFontWeight.bold,
                                      ),
                                    )
                              : Text(
                                  textAlign: TextAlign.start,
                                  "Hi User!",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: textBlack8,
                                    fontSize: Responsive.getFontSize(20),
                                    fontWeight: AppFontWeight.bold,
                                  ),
                                ),
                          isLoggedIn
                              ? Text(
                                  textAlign: TextAlign.start,
                                  "May you always in a good condition",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: Color.fromRGBO(63, 63, 70, 1),
                                    fontSize: Responsive.getFontSize(12),
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                )
                              : Text(
                                  textAlign: TextAlign.start,
                                  "Login for the best experience.",
                                  style: GoogleFonts.poppins(
                                    letterSpacing: 1.5,
                                    color: Color.fromRGBO(63, 63, 70, 1),
                                    fontSize: Responsive.getFontSize(12),
                                    fontWeight: AppFontWeight.medium,
                                  ),
                                ),
                        ],
                      ),
                      isLoggedIn
                          ? AnimationConfiguration.synchronized(
                              duration: const Duration(milliseconds: 2000),
                              child: SlideAnimation(
                                curve: Curves.easeInOut,
                                child: FadeInAnimation(
                                  duration: const Duration(milliseconds: 1000),
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/User/Notification',
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                              padding: EdgeInsets.all(6),
                                              width: Responsive.getWidth(32),
                                              height: Responsive.getWidth(32),
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    249, 250, 251, 1),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.05),
                                                    spreadRadius: 0,
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Responsive.getWidth(8)),
                                                border: Border.all(
                                                  width: 1,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.05),
                                                ),
                                              ),
                                              child: Image.asset(
                                                "assets/bell_blank.png",
                                                width: Responsive.getWidth(24),
                                                height:
                                                    Responsive.getHeight(24),
                                              )),
                                          // Positioned(
                                          //   top: 0,
                                          //   right: 0,
                                          //   child: Container(
                                          //     width: 15,
                                          //     height: 15,
                                          //     decoration: BoxDecoration(
                                          //         color: Colors.red,
                                          //         borderRadius:
                                          //             BorderRadius.circular(30)),
                                          //     child: Center(
                                          //         child: WantText2(
                                          //             text: "1",
                                          //             fontSize:
                                          //                 Responsive.getWidth(10),
                                          //             fontWeight: AppFontWeight.bold,
                                          //             textColor: white)),
                                          //   ),
                                          // )
                                        ],
                                      )),
                                ),
                              ),
                            )
                          : AnimationConfiguration.synchronized(
                              duration: const Duration(milliseconds: 2000),
                              child: SlideAnimation(
                                curve: Curves.easeInOut,
                                child: FadeInAnimation(
                                  duration: const Duration(milliseconds: 1000),
                                  child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/SignIn',
                                          (Route<dynamic> route) => false,
                                        );
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                              padding: EdgeInsets.all(6),
                                              width: Responsive.getWidth(32),
                                              height: Responsive.getWidth(32),
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    249, 250, 251, 1),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.05),
                                                    spreadRadius: 0,
                                                    offset: Offset(0, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        Responsive.getWidth(8)),
                                                border: Border.all(
                                                  width: 1,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.05),
                                                ),
                                              ),
                                              child: Image.asset(
                                                "assets/login.png",
                                                width: Responsive.getWidth(24),
                                                height:
                                                    Responsive.getHeight(24),
                                              )),
                                          // Positioned(
                                          //   top: 0,
                                          //   right: 0,
                                          //   child: Container(
                                          //     width: 15,
                                          //     height: 15,
                                          //     decoration: BoxDecoration(
                                          //         color: Colors.red,
                                          //         borderRadius:
                                          //             BorderRadius.circular(30)),
                                          //     child: Center(
                                          //         child: WantText2(
                                          //             text: "1",
                                          //             fontSize:
                                          //                 Responsive.getWidth(10),
                                          //             fontWeight: AppFontWeight.bold,
                                          //             textColor: white)),
                                          //   ),
                                          // )
                                        ],
                                      )),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.getHeight(21)),
                Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: AppTextFormField(
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        borderRadius: 15,
                        controller: _searchController,
                        prefixIcon:
                            Icon(CupertinoIcons.search, color: Colors.grey),
                        borderColor: Colors.grey,
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: AppFontWeight.medium,
                        ),
                        textStyle: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: AppFontWeight.medium,
                        ),
                        hintText: "Search",
                      ),
                    ),
                    if (_showResults)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10.00),
                        decoration: BoxDecoration(
                            // border: Border.all(width: 1.0,color: Colors.grey.shade400),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0XFF11111A).withOpacity(0.10),
                                offset: const Offset(0.0, 0.0),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10.00)),
                        child: _buildSuggestions(),
                      ),
                  ],
                ),
                SizedBox(height: Responsive.getHeight(21)),
                // Padding(
                //   padding:
                //       EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       WantText2(
                //         text: "Categories",
                //         fontSize: Responsive.getFontSize(20),
                //         fontWeight: AppFontWeight.medium,
                //         textColor: Colors.black,
                //       ),
                //       WantText2(
                //         text: "",
                //         fontSize: Responsive.getFontSize(12),
                //         fontWeight: AppFontWeight.medium,
                //         textColor: Colors.grey,
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: Responsive.getHeight(17)),
                // CategoryList(),
                FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.black,
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                          child: WantText2(
                              text: "No categories available.",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.regular,
                              textColor: black));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                          child: WantText2(
                              text: "No categories available.",
                              fontSize: Responsive.getFontSize(16),
                              fontWeight: AppFontWeight.regular,
                              textColor: black));
                    } else {
                      final categories = snapshot.data!;
                      return Container(
                        margin: EdgeInsets.only(left: Responsive.getWidth(18)),
                        height: Responsive.getHeight(100),
                        child: Row(
                          children: [
                            Container(
                              width: Responsive.getWidth(290),
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: categories.length > 4
                                    ? 4
                                    : categories.length,
                                itemBuilder: (context, index) {
                                  final category = categories[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                SingleCategoryScreen(
                                                  Category_id: categories[index]
                                                      .categoryId,
                                                  Category_name:
                                                      categories[index]
                                                          .categoryName,
                                                )),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: Responsive.getWidth(50),
                                          height: Responsive.getWidth(70),
                                          margin: EdgeInsets.only(right: 25),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: Responsive.getWidth(48),
                                                height: Responsive.getWidth(48),
                                                // padding: EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      233, 255, 248, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  child: Image.network(
                                                    category.categoryIcon,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      Responsive.getHeight(4)),
                                              WantText2(
                                                text: category.categoryName,
                                                fontSize:
                                                    Responsive.getFontSize(12),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                                textColor: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            categories.length > 4
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AllCategoryScreen(
                                                  categories: categories),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: Responsive.getWidth(60),
                                          height: Responsive.getWidth(70),
                                          // margin: EdgeInsets.only(right: 12),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: Responsive.getWidth(48),
                                                height: Responsive.getWidth(48),
                                                decoration: BoxDecoration(
                                                  color: Color.fromRGBO(
                                                      233, 255, 248, 1),
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                    "assets/all.png",
                                                    height:
                                                        Responsive.getWidth(24),
                                                    width:
                                                        Responsive.getWidth(24),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                      Responsive.getHeight(4)),
                                              WantText2(
                                                text: "All",
                                                fontSize:
                                                    Responsive.getFontSize(12),
                                                fontWeight:
                                                    AppFontWeight.regular,
                                                textColor: Colors.black,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: Responsive.getHeight(17)),
                futureExhibitions.toString().isEmpty ? SizedBox() :  Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WantText2(
                        text: "Upcoming Exhibitions",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.medium,
                        textColor: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/User/UpcomingExhibitionsScreen',
                          );
                        },
                        child: WantText2(
                          text: "See all",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                futureExhibitions.toString().isEmpty ? SizedBox() :  SizedBox(height: Responsive.getHeight(8)),
                futureExhibitions.toString().isEmpty ? SizedBox() :  Container(
                  padding: EdgeInsets.only(left: 20),
                  height: Responsive.getHeight(205),
                  child: FutureBuilder<List<CustomerExhibitionsModel>>(
                    future: futureExhibitions,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
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
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: WantText2(
                                text: "No exhibitions found",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.regular,
                                textColor: black));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Center(
                                child: WantText2(
                                    text: "No exhibitions found",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: black)));
                      }
                      final exhibition = snapshot.data!;
                      return ScrollLoopAutoScroll(
                        // controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        enableScrollInput: false,
                        delay: Duration(seconds: 0),
                        duration: Duration(seconds: 360),
                        gap: 0,
                        reverseScroll: false,
                        child: Row(
                          children: List.generate(exhibition.length, (index) {
                            final item = exhibition[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isScrolling = !_isScrolling;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SingleUpcomingExhibitionScreen(
                                      exhibition_unique_id:
                                          item.exhibitionUniqueId,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: Responsive.getWidth(120),
                                margin: EdgeInsets.only(right: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(120),
                                      height: Responsive.getHeight(150),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        image: DecorationImage(
                                          image: NetworkImage(item.logo),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name.toUpperCase(),
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize:
                                                Responsive.getFontSize(12),
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on_outlined,
                                                size: 10),
                                            SizedBox(width: 2),
                                            Flexible(
                                              child: Text(
                                                maxLines: 1,
                                                "${item.address1} ${item.city.nameOfCity} ${item.state.stateSubdivisionName} ${item.country.countryName}",
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black
                                                      .withOpacity(0.8),
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          10),
                                                  fontWeight: FontWeight.normal,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                      //   ListView.builder(
                      //   shrinkWrap: true,
                      //   // physics: NeverScrollableScrollPhysics(),
                      //   controller: _scrollController,
                      //   scrollDirection: Axis.horizontal,
                      //   itemCount: exhibition.length,
                      //   itemBuilder: (context, index) {
                      //     final item = exhibition[index];
                      //     return GestureDetector(
                      //       onTap: () {
                      //         Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (_) =>
                      //                     SingleUpcomingExhibitionScreen(
                      //                       exhibition_unique_id:
                      //                           item.exhibitionUniqueId,
                      //                     )));
                      //       },
                      //       child: Container(
                      //         width: Responsive.getWidth(120),
                      //         // height: Responsive.getHeight(196),
                      //         margin: EdgeInsets.only(right: 20),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             Container(
                      //               width: Responsive.getWidth(120),
                      //               height: Responsive.getHeight(150),
                      //               decoration: BoxDecoration(
                      //                 borderRadius: BorderRadius.circular(5),
                      //                 image: DecorationImage(
                      //                   image: NetworkImage(item.logo),
                      //                   fit: BoxFit.cover,
                      //                 ),
                      //               ),
                      //             ),
                      //             SizedBox(height: 6),
                      //             Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment.start,
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 Text(
                      //                   item.name.toUpperCase(),
                      //                   overflow: TextOverflow.ellipsis,
                      //                   style: GoogleFonts.poppins(
                      //                       color: Colors.black,
                      //                       fontSize:
                      //                           Responsive.getFontSize(12),
                      //                       fontWeight: AppFontWeight.semiBold,
                      //                       letterSpacing: 1.5),
                      //                 ),
                      //                 SizedBox(height: 3),
                      //                 Row(
                      //                   children: [
                      //                     Icon(Icons.location_on_outlined,
                      //                         size: 10),
                      //                     SizedBox(width: 2),
                      //                     Flexible(
                      //                       child: Text(
                      //                         maxLines: 1,
                      //                         "${item.address1} ${item.city.nameOfCity} ${item.state.stateSubdivisionName} ${item.country.countryName}",
                      //                         style: GoogleFonts.poppins(
                      //                             color: Colors.black
                      //                                 .withOpacity(0.8),
                      //                             fontSize:
                      //                                 Responsive.getFontSize(
                      //                                     10),
                      //                             fontWeight: FontWeight.normal,
                      //                             letterSpacing: 1.5),
                      //                         // TextStyle(
                      //                         //     fontSize: 10,
                      //                         //     fontWeight: FontWeight.normal,
                      //                         //     color: Colors.black.withOpacity(0.8)),
                      //                       ),
                      //                     ),
                      //                   ],
                      //                 ),
                      //               ],
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // );
                    },
                  ),
                ),
                // SizedBox(height: Responsive.getHeight(10)),
                futureArtists.toString().isEmpty ? SizedBox() : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WantText2(
                        text: "Our Artist",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.medium,
                        textColor: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/User/AllArtistScreen',
                          );
                        },
                        child: WantText2(
                          text: "See all",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                futureArtists.toString().isEmpty ? SizedBox() : SizedBox(height: Responsive.getHeight(11)),
                futureArtists.toString().isEmpty ? SizedBox() : Container(
                  padding: EdgeInsets.only(left: Responsive.getWidth(16)),
                  height: Responsive.getHeight(100),
                  child: FutureBuilder<List<ArtistModel>>(
                    future: futureArtists,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                            child: Center(
                                child: WantText2(
                                    text: "No artists found",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: black)));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: WantText2(
                                text: "No artists found",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.regular,
                                textColor: black));
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          // physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final artist = snapshot.data![index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SingleArtistProfileScreen(
                                      artistUniqueId: artist.customerUniqueId,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: Responsive.getWidth(54),
                                height: Responsive.getWidth(54),
                                margin: EdgeInsets.only(
                                    right: Responsive.getWidth(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: Responsive.getWidth(54),
                                      height: Responsive.getWidth(54),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(30)),
                                        // image: DecorationImage(
                                        //   image: artist.customerProfile == null
                                        //       ? AssetImage(
                                        //           "assets/artists_stories_back.png")
                                        //       : NetworkImage(
                                        //           artist.customerProfile!),
                                        //   fit: BoxFit.fill,
                                        // ),
                                      ),
                                      child: artist.customerProfile == null
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  Colors.grey.shade300,
                                              child: Text(
                                                '${artist.name[0].toUpperCase()}',
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    color: black,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              child: Image.network(
                                                artist.customerProfile!,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                    ),
                                    SizedBox(height: Responsive.getHeight(6)),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        WantText2(
                                            text: artist.name,
                                            fontSize:
                                                Responsive.getFontSize(14),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: textBlack)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                artData.toString().isEmpty ? SizedBox() : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WantText2(
                        text: "Trending Art",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.medium,
                        textColor: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/User/AllProductDetails",
                          );
                        },
                        child: WantText2(
                          text: "See all",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                artData.toString().isEmpty ? SizedBox() : SizedBox(height: Responsive.getHeight(12)),
                artData.toString().isEmpty ? SizedBox() : SizedBox(
                  height: Responsive.getHeight(250),
                  child: Padding(
                    padding: EdgeInsets.only(left: Responsive.getWidth(21)),
                    child: FutureBuilder<List<CustomerAllArtModel>>(
                      future: artData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: WantText2(
                                  text: "No Art found",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black));
                        }

                        final artItems = snapshot.data ?? [];

                        return artItems.length == 0
                            ? Center(
                                child: WantText2(
                                    text: "No Art found",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: black),
                              )
                            : ListView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                itemCount: artItems.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final artItem = artItems[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  SingleProductDetailScreen(
                                                      artUniqueId: artItem
                                                          .artUniqueId)));
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   '/User/SingleProductDetailScreen',
                                      //   arguments: ArtItemArguments(artItem.artUniqueId),
                                      // );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: Responsive.getWidth(16)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          artItem.artImages.length == 0
                                              ? Container(
                                                  height:
                                                      Responsive.getHeight(175),
                                                  width:
                                                      Responsive.getWidth(159),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Responsive.getWidth(
                                                                16)),
                                                    color: Colors.grey.shade300,
                                                    // image: DecorationImage(
                                                    //   image: NetworkImage(artItem
                                                    //       .artImages[0]
                                                    //       .image), // Use dynamic image URL
                                                    //   fit: BoxFit.fill,
                                                    // ),
                                                  ),
                                                  child: Center(
                                                      child: WantText2(
                                                          text:
                                                              artItem.title[0],
                                                          fontSize: Responsive
                                                              .getFontSize(20),
                                                          fontWeight:
                                                              AppFontWeight
                                                                  .bold,
                                                          textColor: black)),
                                                )
                                              : Container(
                                                  height:
                                                      Responsive.getHeight(175),
                                                  width:
                                                      Responsive.getWidth(159),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Responsive.getWidth(
                                                                16)),
                                                    image: DecorationImage(
                                                      image: NetworkImage(artItem
                                                          .artImages[0]
                                                          .image), // Use dynamic image URL
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                              height: Responsive.getHeight(6)),
                                          Container(
                                            width: Responsive.getWidth(159),
                                            // height: Responsive.getHeight(96),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                WantText2(
                                                  text: artItem.title,
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          14),
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: textBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                WantText2(
                                                  text: artItem.artistName,
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          11),
                                                  fontWeight:
                                                      AppFontWeight.regular,
                                                  textColor: textBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                WantText2(
                                                  text: "\$${artItem.price}",
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          14),
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: textBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                      },
                    ),
                  ),
                ),
                artDataPrivate.toString().isEmpty ? SizedBox() : SizedBox(height: Responsive.getHeight(10)),
                artDataPrivate.toString().isEmpty ? SizedBox() : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WantText2(
                        text: "Private Art",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.medium,
                        textColor: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/User/AllPrivateProductDetails",
                          );
                        },
                        child: WantText2(
                          text: "See all",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                artDataPrivate.toString().isEmpty ? SizedBox() : SizedBox(height: Responsive.getHeight(12)),
                artDataPrivate.toString().isEmpty ? SizedBox() : SizedBox(
                  height: Responsive.getHeight(250),
                  child: Padding(
                    padding: EdgeInsets.only(left: Responsive.getWidth(21)),
                    child: FutureBuilder<List<CustomerAllArtModel>>(
                      future: artDataPrivate,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: WantText2(
                                  text: "No Art found",
                                  fontSize: Responsive.getFontSize(16),
                                  fontWeight: AppFontWeight.regular,
                                  textColor: black));
                        }

                        final artItems = snapshot.data ?? [];

                        return artItems.length == 0
                            ? Center(
                                child: WantText2(
                                    text: "No Art found",
                                    fontSize: Responsive.getFontSize(16),
                                    fontWeight: AppFontWeight.regular,
                                    textColor: black),
                              )
                            : ListView.builder(
                                // physics: NeverScrollableScrollPhysics(),
                                itemCount: artItems.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final artItem = artItems[index];

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  SinglePrivateProductDetailScreen(
                                                      artUniqueId: artItem
                                                          .artUniqueId)));
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   '/User/SingleProductDetailScreen',
                                      //   arguments: ArtItemArguments(artItem.artUniqueId),
                                      // );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          right: Responsive.getWidth(16)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          artItem.artImages.length == 0
                                              ? Container(
                                                  height:
                                                      Responsive.getHeight(175),
                                                  width:
                                                      Responsive.getWidth(159),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Responsive.getWidth(
                                                                16)),
                                                    color: Colors.grey.shade300,
                                                    // image: DecorationImage(
                                                    //   image: NetworkImage(artItem
                                                    //       .artImages[0]
                                                    //       .image), // Use dynamic image URL
                                                    //   fit: BoxFit.fill,
                                                    // ),
                                                  ),
                                                  child: Center(
                                                      child: WantText2(
                                                          text:
                                                              artItem.title[0],
                                                          fontSize: Responsive
                                                              .getFontSize(20),
                                                          fontWeight:
                                                              AppFontWeight
                                                                  .bold,
                                                          textColor: black)),
                                                )
                                              : Container(
                                                  height:
                                                      Responsive.getHeight(175),
                                                  width:
                                                      Responsive.getWidth(159),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Responsive.getWidth(
                                                                16)),
                                                    image: DecorationImage(
                                                      image: NetworkImage(artItem
                                                          .artImages[0]
                                                          .image), // Use dynamic image URL
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                          SizedBox(
                                              height: Responsive.getHeight(6)),
                                          Container(
                                            width: Responsive.getWidth(159),
                                            // height: 59,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                WantText2(
                                                  text: artItem.title,
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          14),
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: textBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                WantText2(
                                                  text: artItem.artistName,
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          11),
                                                  fontWeight:
                                                      AppFontWeight.regular,
                                                  textColor: textBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                WantText2(
                                                  text: "Request For Price",
                                                  fontSize:
                                                      Responsive.getFontSize(
                                                          12),
                                                  fontWeight:
                                                      AppFontWeight.medium,
                                                  textColor: textBlack,
                                                  textOverflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                      },
                    ),
                  ),
                ),
                artistStory.toString().isEmpty ? SizedBox() : SizedBox(height: Responsive.getHeight(10)),
                artistStory.toString().isEmpty ? SizedBox() : Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      WantText2(
                        text: "Artist Stories",
                        fontSize: Responsive.getFontSize(20),
                        fontWeight: AppFontWeight.medium,
                        textColor: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/User/AllArtistStoriesScreen",
                          );
                        },
                        child: WantText2(
                          text: "See all",
                          fontSize: Responsive.getFontSize(12),
                          fontWeight: AppFontWeight.medium,
                          textColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                artistStory.toString().isEmpty ? SizedBox() : SizedBox(height: Responsive.getHeight(12)),
                artistStory.toString().isEmpty ? SizedBox() : Container(
                  padding: EdgeInsets.only(left: Responsive.getWidth(21)),
                  height: Responsive.getHeight(295),
                  child: FutureBuilder<List<Story>>(
                    future: artistStory,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.black,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        print("Error ${snapshot.error}");
                        return Center(
                            child: WantText2(
                                text: "No stories available",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.regular,
                                textColor: black));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        print("Data ${snapshot.hasData}");
                        return Center(
                            child: WantText2(
                                text: "No stories available",
                                fontSize: Responsive.getFontSize(16),
                                fontWeight: AppFontWeight.regular,
                                textColor: black));
                      } else {
                        final artStory = snapshot.data ?? [];
                        return ListView.builder(
                          // physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: artStory.length,
                          itemBuilder: (context, index) {
                            final story = artStory[index];
                            return GestureDetector(
                              onTap: () {
                                print(story.art.artId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SingleArtistStoryScreen(
                                      artistUniqueId: story.art.artId,
                                    ),
                                  ),
                                );
                                // Navigator.pushNamed(
                                //   context,
                                //   '/User/SingleArtistStoryScreen',
                                // );
                              },
                              child: Container(
                                width: Responsive.getWidth(170),
                                margin: EdgeInsets.only(
                                    right: Responsive.getWidth(20)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image container
                                    Container(
                                      height: Responsive.getHeight(170),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Responsive.getWidth(5)),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            story.images.first.imageUrl,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: Responsive.getHeight(6)),

                                    // Info container
                                    Container(
                                      height: 90,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          // Customer profile name
                                          WantText2(
                                            text: story.art.title,
                                            fontSize:
                                                Responsive.getFontSize(12),
                                            fontWeight: AppFontWeight.semiBold,
                                            textColor: textBlack13,
                                            textOverflow: TextOverflow.ellipsis,
                                          ),

                                          // Art title
                                          WantText2(
                                            text: story.art.artistName,
                                            fontSize: Responsive.getFontSize(8),
                                            fontWeight: AppFontWeight.regular,
                                            textColor: textGray14,
                                            textOverflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            textAlign: TextAlign.start,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            story.paragraphs.first.paragraph,
                                            style: GoogleFonts.poppins(
                                              color: textGray13,
                                              fontSize:
                                                  Responsive.getFontSize(8),
                                              fontWeight: AppFontWeight.regular,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: Responsive.getHeight(20),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class CategoryList extends StatefulWidget {
//   @override
//   State<CategoryList> createState() => _CategoryListState();
// }
//
// class _CategoryListState extends State<CategoryList> {
//
//
//   @override
//   void initState() {
//     super.initState();
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return
//   }
// }
