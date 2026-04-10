import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appearance',
          style: TextStyle(
            fontFamily: 'Recoleta',
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppTheme.themeNotifier,
        builder: (context, currentMode, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose your theme",
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),
                _buildThemeCard(
                  context,
                  title: "Light Mode",
                  mode: ThemeMode.light,
                  currentMode: currentMode,
                  icon: Icons.light_mode_rounded,
                ),
                const SizedBox(height: 16),
                _buildThemeCard(
                  context,
                  title: "Dark Mode",
                  mode: ThemeMode.dark,
                  currentMode: currentMode,
                  icon: Icons.dark_mode_rounded,
                ),
                const SizedBox(height: 16),
                _buildThemeCard(
                  context,
                  title: "System Default",
                  mode: ThemeMode.system,
                  currentMode: currentMode,
                  icon: Icons.settings_brightness_rounded,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(
    BuildContext context, {
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required IconData icon,
  }) {
    final bool isSelected = currentMode == mode;
    const Color mainBlue = AppTheme.mainBlue;

    return GestureDetector(
      onTap: () {
        AppTheme.themeNotifier.value = mode;
        AppTheme.saveTheme(mode);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? mainBlue : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? mainBlue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? mainBlue : Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: mainBlue),
          ],
        ),
      ),
    );
  }
}
