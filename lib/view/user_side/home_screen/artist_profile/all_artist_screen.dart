import 'package:artist/view/user_side/home_screen/artist_profile/single_artist_profile_screen/single_artist_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/colors.dart';
import '../../../../core/api_service/api_service.dart';
import '../../../../core/models/artist_model.dart';
import '../../../../core/utils/app_font_weight.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_text_form_field.dart';
import '../../../../core/widgets/custom_text_2.dart';

class AllArtistScreen extends StatefulWidget {
  @override
  _AllArtistScreenState createState() => _AllArtistScreenState();
}

class _AllArtistScreenState extends State<AllArtistScreen> {
  // final List<String> _allArtists = [
  //   'Aessie Cooper',
  //   'Jerome Bell',
  //   'Leslie Alexander',
  //   'Darlene Robertson',
  //   'Jane Cooper',
  //   'Robert Fox',
  //   'Bessie Cooper',
  //   'Jerome Bell',
  //   'Leslie Alexander',
  //   'Darlene Robertson',
  //   'Jane Cooper',
  //   'Robert Fox',
  // ];

  List<ArtistModel> _allArtists = [];
  List<ArtistModel> _filteredArtists = [];
  String _searchQuery = '';
  String _selectedLetter = "A";

  @override
  void initState() {
    super.initState();
    _selectedLetter = 'A';
    _fetchArtists();
  }

  Future<void> _fetchArtists() async {
    try {
      List<ArtistModel> artists = await ApiService().fetchArtists();
      setState(() {
        _allArtists = artists;
        _filterByLetter(_selectedLetter); // Call filter after fetching artists
      });
    } catch (e) {
      // Handle the error gracefully
      print('Error: $e');
      // Optionally, show a UI message for failure
    }
  }

  // void _filterArtists(String query) {
  //   setState(() {
  //     _searchQuery = query;
  //     if (_searchQuery.isEmpty) {
  //       _filteredArtists = _allArtists;
  //     } else {
  //       _filteredArtists = _allArtists
  //           .where((artist) => artist.name.toLowerCase().contains(_searchQuery.toLowerCase()))
  //           .toList();
  //     }
  //   });
  // }
  void _filterArtists(String? query) {
    setState(() {
      _searchQuery = query ?? ''; // If query is null, use an empty string
      if (_searchQuery.isEmpty) {
        _filteredArtists = _allArtists;
      } else {
        _filteredArtists = _allArtists
            .where((artist) => artist.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }


  void _filterByLetter(String letter) {
    setState(() {
      _selectedLetter = letter;
      _filteredArtists = _allArtists
          .where((artist) => artist.name.toLowerCase().startsWith(letter.toLowerCase()))
          .toList();
    });
  }

  // void _filterByLetter(String letter) {
  //   setState(() {
  //     _selectedLetter = letter;
  //     _filteredArtists = _allArtists
  //         .where(
  //             (artist) => artist.toLowerCase().startsWith(letter.toLowerCase()))
  //         .toList();
  //   });
  // }

  Widget _buildAlphabetFilter() {
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: letters.split('').map((letter) {
          final bool isSelected = letter == _selectedLetter;
          return GestureDetector(
            onTap: () => _filterByLetter(letter),
            child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isSelected
                        ? Color.fromRGBO(210, 214, 219, 1)
                        : Colors.transparent,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: WantText2(
                  text: letter,
                  fontSize: Responsive.getFontSize(19),
                  fontWeight: AppFontWeight.medium,
                  textColor: Color.fromRGBO(69, 69, 69, 1),
                )),
          );
        }).toList(),
      ),
    );
  }

  TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
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
                        border:
                            Border.all(color: textFieldBorderColor, width: 1.0),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: Responsive.getWidth(19),
                      ),
                    ),
                  ),
                  SizedBox(width: Responsive.getWidth(80)),
                  WantText2(
                    text: "Our Artists",
                    fontSize: Responsive.getFontSize(18),
                    fontWeight: AppFontWeight.medium,
                    textColor: textBlack,
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.getWidth(11)),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: Responsive.getWidth(20)),
              child: AppTextFormField(
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: Responsive.getWidth(12),
                    vertical: Responsive.getHeight(12)),
                borderRadius: Responsive.getWidth(15),
                controller: _searchController,
                prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey),
                borderColor: Colors.grey,
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.medium,
                ),
                textStyle: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: Responsive.getFontSize(16),
                  fontWeight: AppFontWeight.medium,
                ),
                hintText: "Search",
                onChanged: (String? query) {
                  _filterArtists(query);
                },
              )

            ),
            SizedBox(height: Responsive.getWidth(19)),
            Padding(
              padding: EdgeInsets.only(left: Responsive.getWidth(20)),
              child: _buildAlphabetFilter(),
            ),
            SizedBox(height: Responsive.getWidth(19)),
            Expanded(
              child: _filteredArtists.isEmpty
                  ? Container(
                      width: Responsive.getMainWidth(context),
                      // height: Responsive.getHeight(500),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/profile.png",
                            width: Responsive.getWidth(64),
                            height: Responsive.getWidth(64),
                          ),
                          SizedBox(
                            height: Responsive.getHeight(24),
                          ),
                          WantText2(
                            text: "No Our Artists!",
                            fontSize: Responsive.getFontSize(20),
                            fontWeight: AppFontWeight.semiBold,
                            textColor: textBlack11,
                          ),
                          // SizedBox(
                          //   height: Responsive.getHeight(12),
                          // ),
                          // Padding(
                          //   padding: EdgeInsets.symmetric(
                          //       horizontal: Responsive.getWidth(80)),
                          //   child: Text(
                          //     textAlign: TextAlign.center,
                          //     "You don’t have any artists at this time.",
                          //     style: GoogleFonts.poppins(
                          //       color: Color.fromRGBO(128, 128, 128, 1),
                          //       fontSize: Responsive.getFontSize(16),
                          //       fontWeight: AppFontWeight.regular,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredArtists.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SingleArtistProfileScreen(
                                  artistUniqueId: _filteredArtists[index].customerUniqueId,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: Responsive.getMainWidth(context),
                            padding: EdgeInsets.only(
                              left: Responsive.getWidth(20),
                              top: Responsive.getHeight(6),
                              bottom: Responsive.getHeight(6),
                            ),
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              _filteredArtists[index].name,
                              style: GoogleFonts.poppins(
                                letterSpacing: 4.0,
                                color: Color.fromRGBO(69, 69, 69, 1),
                                fontSize: Responsive.getFontSize(14),
                                fontWeight: AppFontWeight.medium,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}

// Navigator.pushNamed(
// context,
// '/User/SingleArtistProfileScreen',
// );
