import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MagicStoryPlayer extends StatefulWidget {
  final String title;
  final List<Map<String, String>> storyPages;

  const MagicStoryPlayer(
      {super.key, required this.title, required this.storyPages});

  @override
  State<MagicStoryPlayer> createState() => _MagicStoryPlayerState();
}

class _MagicStoryPlayerState extends State<MagicStoryPlayer> {
  final PageController _pageController = PageController();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients) {
        setState(() {
          // calculate progress based on current page index and total pages
          _progress =
              (_pageController.page ?? 0) / (widget.storyPages.length - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ──  Story Content ──
          PageView.builder(
            controller: _pageController,
            itemCount: widget.storyPages.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildStorySlide(
                widget.storyPages[index]['text'] ?? "Loading story...",
                widget.storyPages[index]['image'] ?? "",
                index,
              );
            },
          ),

          // ──  Top Control Bar ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCircleButton(
                          Icons.close_rounded, () => Navigator.pop(context)),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      _buildCircleButton(Icons.volume_up_rounded, () {}),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress.isFinite ? _progress : 0.0,
                      backgroundColor: Colors.blue[50],
                      color: const Color(0xFF3AAFFF),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ──  Navigation Buttons (Next/Back) ──
          _buildNavButtons(),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40, left: 30, right: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_progress > 0)
              _buildActionCircle(Icons.arrow_back_ios_new_rounded, () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }, isPrimary: false)
            else
              const SizedBox(width: 56),
            _buildActionCircle(
              _progress >= 0.99
                  ? Icons.check_rounded
                  : Icons.arrow_forward_ios_rounded,
              () {
                if (_progress < 0.99) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pop(context);
                }
              },
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySlide(String text, String imagePath, int index) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(50)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(50)),
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image_rounded,
                              size: 80, color: Colors.blueGrey),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.auto_stories_rounded,
                          size: 120, color: Color(0xFF3AAFFF)),
                    ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCircle(IconData icon, VoidCallback onTap,
      {required bool isPrimary}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? const Color(0xFF3AAFFF) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Icon(icon,
            color: isPrimary ? Colors.white : Colors.black54, size: 24),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Icon(icon, color: Colors.black54, size: 26),
      ),
    );
  }
}
