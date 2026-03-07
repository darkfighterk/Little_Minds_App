import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  static const String githubUrl =
      "https://github.com/darkfighterk/Little_Minds_App.git";

  Future<void> openGithub() async {
    final Uri url = Uri.parse(githubUrl);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff3b0b66),
              Color(0xff6a11cb),
              Color(0xff8e2de2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// Back Button
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Spacer(),
                    const Text(
                      "About Explorer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 20),

                /// APP LOGO
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.explore,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Explorer Learning App",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                /// APP DESCRIPTION
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.6,
                      ),
                      children: [
                        TextSpan(
                          text: "OUR VISION\n",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.purpleAccent,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        TextSpan(
                          text:
                              "To create a fun and engaging digital learning environment where young explorers "
                              "can develop knowledge, creativity, and problem-solving skills while enjoying "
                              "their learning journey.\n\n",
                        ),
                        TextSpan(
                          text: "OUR MISSION\n",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.purpleAccent,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        TextSpan(
                          text:
                              "To support children aged 6 to 18 by providing interactive tools such as quizzes, "
                              "puzzles, drawing activities, and digital notebooks that make learning simple, "
                              "enjoyable, and accessible anytime.\n\n",
                        ),

                        /// ---------------- APP FEATURES ----------------
                        TextSpan(
                          text: "APP FEATURES\n",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.purpleAccent,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),

                        TextSpan(
                          text: "Quiz Arena\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Play MCQ quizzes from different subjects like History and more. "
                              "Students can progress level by level like a game while improving knowledge.\n\n",
                        ),

                        TextSpan(
                          text: "Text to Image\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Upload an image and easily extract or copy the text that appears in it. "
                              "This helps students quickly capture written information from pictures.\n\n",
                        ),

                        TextSpan(
                          text: "Notebook\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "A simple digital notebook where students can write and save notes "
                              "about what they learn.\n\n",
                        ),

                        TextSpan(
                          text: "Story Time\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Provides interesting stories suitable for different age groups "
                              "to improve reading and imagination.\n\n",
                        ),

                        TextSpan(
                          text: "Drawing Pad\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Allows children to draw pictures freely and express their creativity.\n\n",
                        ),

                        TextSpan(
                          text: "Puzzles\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Picture puzzles where users arrange pieces correctly "
                              "to complete the full image and improve problem-solving skills.\n\n",
                        ),

                        /// ---------------- OUR VALUES ----------------
                        TextSpan(
                          text: "OUR VALUES\n",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.purpleAccent,
                                blurRadius: 10,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: "• Encouraging Curiosity and Creativity\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "We believe every child has a natural curiosity. Our platform encourages students "
                              "to explore ideas, solve puzzles, draw creatively, and express their imagination "
                              "while learning.\n\n",
                        ),
                        TextSpan(
                          text: "• Making Learning Fun and Interactive\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Education should never be boring. Through engaging features like Quiz Arena, "
                              "Image Puzzles, and Story Time, we transform traditional learning into an "
                              "enjoyable adventure.\n\n",
                        ),
                        TextSpan(
                          text: "• Supporting Growth and Confidence\n",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              "Our goal is to help students build confidence in their abilities by giving them "
                              "tools to practice knowledge, improve skills, and discover their unique talents.",
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// DEVELOPER CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Developer",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Explorer Team",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Flutter App Developer",
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.help_outline),
                        label: const Text("FAQ"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("FAQ section coming soon"),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.email),
                        label: const Text("Contact"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Contact feature coming soon"),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                /// GITHUB BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.code),
                    label: const Text("View on GitHub"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      final Uri url = Uri.parse(githubUrl);

                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {
                        throw "Could not launch $url";
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "© 2026 Explorer App",
                  style: TextStyle(
                    color: Colors.white60,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
