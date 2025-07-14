import 'package:artist/view/user_side/artists_stories_screen/single_atist_store/single_artist_story_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/colors.dart';
import '../../../core/api_service/api_service.dart';
import '../../../core/models/user_side/all_artist_story_model.dart';
import '../../../core/utils/app_font_weight.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/custom_text_2.dart';

class AllArtistStoriesScreen extends StatefulWidget {
  const AllArtistStoriesScreen({super.key});

  @override
  State<AllArtistStoriesScreen> createState() => _AllArtistStoriesScreenState();
}

class _AllArtistStoriesScreenState extends State<AllArtistStoriesScreen> {
  late Future<List<Story>> artistStory;

  @override
  void initState() {
    artistStory = ApiService().fetchArtistStories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Responsive.getWidth(16)),
          child: ListView(
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
                          border: Border.all(
                              color: textFieldBorderColor, width: 1.0)),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        size: Responsive.getWidth(19),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Responsive.getWidth(80),
                  ),
                  WantText2(
                      text: "Artist Stories",
                      fontSize: Responsive.getFontSize(18),
                      fontWeight: AppFontWeight.medium,
                      textColor: textBlack)
                ],
              ),
              SizedBox(height: Responsive.getHeight(25)),
              Divider(
                color: Color.fromRGBO(230, 230, 230, 1),
                thickness: 1,
              ),
              SizedBox(height: Responsive.getHeight(25)),
              SizedBox(
                width: Responsive.getMainWidth(context),
                child: FutureBuilder<List<Story>>(
                  future: artistStory,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return  Center(
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
                      return Center(child: WantText2(text: 'No stories available',fontWeight: AppFontWeight.regular,fontSize: Responsive.getFontSize(16),textColor: black,));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: WantText2(text: 'No stories available',fontWeight: AppFontWeight.regular,fontSize: Responsive.getFontSize(16),textColor: black,));
                    } else {
                      final artStory = snapshot.data ?? [];
                      return  Center(
                        child: StaggeredGridView.countBuilder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: artStory.length,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            crossAxisCount: 4,
                            staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                            itemBuilder: (context, index) {
                              final story = artStory[index];
                              return Center(
                                child: GestureDetector(
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
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: Responsive.getHeight(170),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              Responsive.getWidth(5)),
                                          image: DecorationImage(
                                            image: NetworkImage(story.images.first.imageUrl,),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: Responsive.getHeight(6)),
                                      Container(
                                        height: 90,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            WantText2(
                                              text: story.art.title,
                                              fontSize: Responsive.getFontSize(12),
                                              fontWeight: AppFontWeight.semiBold,
                                              textColor: textBlack13,
                                              textOverflow: TextOverflow.ellipsis,
                                            ),
                                            WantText2(
                                              text: story.art.artistName,
                                              fontSize: Responsive.getFontSize(8),
                                              fontWeight: AppFontWeight.regular,
                                              textColor: textGray14,
                                              textOverflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              textAlign: TextAlign.start,
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                              story.paragraphs.first.paragraph,
                                              style: GoogleFonts.poppins(
                                                letterSpacing: 1.5,
                                                color: textGray13,
                                                fontSize: Responsive.getFontSize(8),
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
                            }),
                      );
                    }
                  },
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
