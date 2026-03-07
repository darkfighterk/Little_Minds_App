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
      extendBodyBehindAppBar: true, // body goes behind transparent appBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
          color: Colors.transparent,
          child: Row(
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
        ),
      ),
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
                const SizedBox(height: 20), // optional spacing below AppBar

                /// APP LOGO
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white24,
                  backgroundImage: AssetImage("assets/logo.png"),
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

                /// BACKGROUND IMAGE SECTION
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/learn_pic.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// ---------------- OUR VISION ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "OUR VISION",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To create a fun and engaging digital learning environment where young explorers "
                        "can develop knowledge, creativity, and problem-solving skills while enjoying "
                        "their learning journey.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ---------------- OUR MISSION ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "OUR MISSION",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "To support children aged 6 to 18 by providing interactive tools such as quizzes, "
                        "puzzles, drawing activities, and digital notebooks that make learning simple, "
                        "enjoyable, and accessible anytime.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ---------------- APP FEATURES ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "APP FEATURES",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Quiz Arena",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Play MCQ quizzes from different subjects like History and more. "
                        "Students can progress level by level like a game while improving knowledge.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Text to Image",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Upload an image and easily extract or copy the text that appears in it. "
                        "This helps students quickly capture written information from pictures.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Notebook",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "A simple digital notebook where students can write and save notes "
                        "about what they learn.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Story Time",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Provides interesting stories suitable for different age groups "
                        "to improve reading and imagination.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Drawing Pad",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Allows children to draw pictures freely and express their creativity.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Puzzles",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Picture puzzles where users arrange pieces correctly "
                        "to complete the full image and improve problem-solving skills.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ---------------- OUR VALUES ----------------
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "OUR VALUES",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "• Encouraging Curiosity and Creativity",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "We believe every child has a natural curiosity. Our platform encourages students "
                        "to explore ideas, solve puzzles, draw creatively, and express their imagination "
                        "while learning.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "• Making Learning Fun and Interactive",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Education should never be boring. Through engaging features like Quiz Arena, "
                        "Image Puzzles, and Story Time, we transform traditional learning into an "
                        "enjoyable adventure.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "• Supporting Growth and Confidence",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Our goal is to help students build confidence in their abilities by giving them "
                        "tools to practice knowledge, improve skills, and discover their unique talents.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, height: 1.6),
                      ),
                    ],
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Group Seven",
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
                            "Flutter App Developers",
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
                    icon: Image.asset(
                      "assets/icons/github.png",
                      height: 22,
                      width: 22,
                    ),
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
