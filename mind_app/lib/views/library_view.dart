import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'story_player.dart';
import '../models/user_model.dart';
import 'bottom_nav_bar.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color accentOrange = Color(0xFFFF8811);

class LibraryView extends StatelessWidget {
  final User user;

  // Story List with Image Paths
  final List<Map<String, dynamic>> staticStories = const [
    {
      "title": "The Giving Tree",
      "author": "Shel Silverstein",
      "cover": "assets/story1/page1.png",
      "pages": [
        {
          "text": "Once there was a tree... and she loved a little boy.",
          "image": "assets/story1/page1.png"
        },
        {
          "text":
              "And every day the boy would come to eat her apples and play.",
          "image": "assets/story1/page2.png"
        },
        {
          "text": "The tree was very happy to give everything to the boy.",
          "image": "assets/story1/page3.png"
        }
      ]
    },
    {
      "title": "Peter Rabbit",
      "author": "Beatrix Potter",
      "cover": "assets/story2/page1.png",
      "pages": [
        {
          "text": "Once upon a time there were four little Rabbits...",
          "image": "assets/story2/page1.png"
        },
        {
          "text": "Flopsy, Mopsy, Cottontail, and Peter.",
          "image": "assets/story2/page2.png"
        },
        {
          "text": "Peter was very naughty and ran to Mr. McGregor's garden!",
          "image": "assets/story2/page3.png"
        }
      ]
    },
    {
      "title": "Hungry Caterpillar",
      "author": "Eric Carle",
      "cover": "assets/story3/page1.png",
      "pages": [
        {
          "text": "In the light of the moon, a little egg lay on a leaf.",
          "image": "assets/story3/page1.png"
        },
        {
          "text": "On Monday, he ate through one apple.",
          "image": "assets/story3/page2.png"
        },
        {
          "text": "Suddenly, he became a butterfly!",
          "image": "assets/story3/page3.png"
        }
      ]
    }
  ];

  const LibraryView({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildLibraryBanner(context),
                    const SizedBox(height: 25),
                    _buildCategoryCircles(),
                    const SizedBox(height: 30),
                    Text(
                      "New Adventures",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildBookGrid(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        user: user,
        primaryColor: mainBlue,
        isDark: false,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.black87),
          ),
          const Text(
            "Magic Library",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLibraryBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFFF9E2D), Color(0xFFFF712D)]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF712D).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -20,
              child: Icon(
                Icons.auto_stories_rounded,
                size: 160,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Discover Magic\nStories",
                    style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.1),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => _navigateToStory(context, 0),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: accentOrange,
                        elevation: 0,
                        shape: const StadiumBorder()),
                    child: const Text("Read Now",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCircles() {
    final List<Map<String, dynamic>> cats = [
      {'n': 'Biology', 'i': '🧬', 'c': const Color(0xFFE1F5FE)},
      {'n': 'Animals', 'i': '🐰', 'c': const Color(0xFFFFF3E0)},
      {'n': 'Geography', 'i': '🌍', 'c': const Color(0xFFE8F5E9)},
      {'n': 'Science', 'i': '🧪', 'c': const Color(0xFFF3E5F5)},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cats
          .map((cat) => Column(children: [
                Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                        color: cat['c'] as Color, shape: BoxShape.circle),
                    child: Center(
                        child: Text(cat['i'] as String,
                            style: const TextStyle(fontSize: 32)))),
                const SizedBox(height: 10),
                Text(cat['n'] as String,
                    style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45)),
              ]))
          .toList(),
    );
  }

  Widget _buildBookGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 20,
        childAspectRatio: 0.55,
      ),
      itemCount: staticStories.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _navigateToStory(context, index),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                    color: Colors.grey[100],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(4, 4),
                      )
                    ],
                    image: DecorationImage(
                      image: AssetImage(staticStories[index]['cover']),
                      fit: BoxFit.cover,
                      onError: (e, s) {},
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    ),
                    child: Stack(
                      children: [
                        // Book Spine Effect
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 10,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Positioned(
                          bottom: 8,
                          right: 8,
                          child: Icon(Icons.menu_book_rounded,
                              color: Colors.white70, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(staticStories[index]['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              Text(staticStories[index]['author'],
                  maxLines: 1,
                  style: GoogleFonts.nunito(
                      fontSize: 11,
                      color: Colors.black38,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }

  void _navigateToStory(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MagicStoryPlayer(
          title: staticStories[index]['title'],
          storyPages: (staticStories[index]['pages'] as List)
              .map((p) => {
                    "text": p['text'].toString(),
                    "image": p['image'].toString(),
                  })
              .toList(),
        ),
      ),
    );
  }
}
