import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../services/story_service.dart';

const Color mainBlue = Color(0xFF3AAFFF);
const Color secondaryPurple = Color(0xFFA55FEF);
const Color sunnyYellow = Color(0xFFFDDF50);
const Color accentOrange = Color(0xFFFF8811);

class StoryReaderPage extends StatefulWidget {
  final String storyId;
  final User user;

  const StoryReaderPage({
    required this.storyId,
    required this.user,
    super.key,
  });

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage>
    with TickerProviderStateMixin {
  StoryDetail? _detail;
  bool _loading = true;
  String? _error;

  late PageController _pageCtrl;
  int _currentPage = 0;
  bool _finished = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _loadDetail();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final detail = await StoryService.getStoryDetail(widget.storyId);
    if (!mounted) return;
    if (detail == null) {
      setState(() {
        _error = 'Oops! We couldn\'t find your story book.';
        _loading = false;
      });
    } else {
      setState(() {
        _detail = detail;
        _loading = false;
      });
      _fadeCtrl.forward();
    }
  }

  void _goToPage(int index) {
    _pageCtrl.animateToPage(index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart);
  }

  void _nextPage() {
    final total = _detail!.pages.length;
    if (_currentPage < total - 1) {
      HapticFeedback.mediumImpact();
      _goToPage(_currentPage + 1);
    } else {
      setState(() => _finished = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _loading
          ? _buildLoader()
          : _error != null
              ? _buildError()
              : _finished
                  ? _buildFinished()
                  : _buildReader(),
    );
  }

  Widget _buildLoader() =>
      const Center(child: CircularProgressIndicator(color: mainBlue));

  Widget _buildError() => SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📚', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 20),
              Text(_error!,
                  style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loadDetail,
                style: ElevatedButton.styleFrom(
                    backgroundColor: mainBlue, shape: const StadiumBorder()),
                child: const Text('Try Again',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );

  Widget _buildFinished() {
    final story = _detail!.story;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withValues(alpha: 0.1), Colors.white]),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(story.coverEmoji, style: const TextStyle(fontSize: 80)),
            const SizedBox(height: 20),
            const Text('The End! 🎉',
                style: TextStyle(
                    fontFamily: 'Recoleta',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 10),
            Text('You read "${story.title}"!',
                style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _finished = false;
                  _currentPage = 0;
                });
                _pageCtrl.jumpToPage(0);
              },
              icon: const Icon(Icons.replay_rounded, color: Colors.white),
              label: const Text('Read Again',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Library',
                    style: TextStyle(
                        color: mainBlue, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildReader() {
    final story = _detail!.story;
    final pages = _detail!.pages;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainBlue.withValues(alpha: 0.05), Colors.white]),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildModernHeader(story, pages.length),
              _buildProgressBar(pages.length),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) => _buildPageContent(pages[i]),
                ),
              ),
              _buildBottomControls(pages.length),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader(Story story, int total) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded, color: Colors.black87)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(story.title,
                  style: const TextStyle(
                      fontFamily: 'Recoleta',
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: mainBlue, borderRadius: BorderRadius.circular(15)),
            child: Text('${_currentPage + 1} / $total',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: LinearProgressIndicator(
        value: total > 0 ? (_currentPage + 1) / total : 0,
        backgroundColor: mainBlue.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(mainBlue),
        minHeight: 6,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildPageContent(StoryPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (page.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(page.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      color: mainBlue.withValues(alpha: 0.05),
                      child: const Icon(Icons.menu_book_rounded,
                          size: 50, color: mainBlue))),
            ),
          const SizedBox(height: 25),
          if (page.title.isNotEmpty)
            Text(page.title,
                style: const TextStyle(
                    fontFamily: 'Recoleta',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: secondaryPurple)),
          const SizedBox(height: 15),
          Text(page.body,
              style: GoogleFonts.nunito(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.6,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomControls(int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CircleNavButton(
              icon: Icons.arrow_back_ios_new_rounded,
              enabled: _currentPage > 0,
              onTap: () => _goToPage(_currentPage - 1)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 5,
                  shadowColor: accentOrange.withValues(alpha: 0.4),
                ),
                child: Text(
                    _currentPage < total - 1 ? "Next Page" : "Finish Story",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _CircleNavButton(
      {required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: enabled ? mainBlue.withValues(alpha: 0.1) : Colors.grey.shade100,
            shape: BoxShape.circle),
        child: Icon(icon,
            color: enabled ? mainBlue : Colors.grey.shade400, size: 20),
      ),
    );
  }
}
