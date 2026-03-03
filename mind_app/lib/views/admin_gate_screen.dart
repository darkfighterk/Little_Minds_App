import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_puzzle_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────────────────────────────────────

const _bg = Color(0xFF0F1117);
const _surface = Color(0xFF1A1D27);
const _accent = Color(0xFF6C63FF);
const _accentSoft = Color(0xFF9B94FF);
const _danger = Color(0xFFFF5C5C);
const _textPrimary = Color(0xFFF0F0F5);
const _textSecondary = Color(0xFF9395A5);
const _border = Color(0xFF2E3248);

/// Shows an admin-key gate before opening the crossword editor.
/// Pass [editId] to edit an existing puzzle, or leave null to create new.
class AdminGateScreen extends StatefulWidget {
  final int? editId;

  const AdminGateScreen({super.key, this.editId});

  @override
  State<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends State<AdminGateScreen>
    with SingleTickerProviderStateMixin {
  final _keyCtrl = TextEditingController();
  bool _obscure = true;
  bool _checking = false;
  String? _error;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final key = _keyCtrl.text.trim();
    if (key.isEmpty) {
      setState(() => _error = 'Admin key is required');
      _shakeCtrl.forward(from: 0);
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      // Validate key by hitting a protected endpoint
      await ApiService().adminGetCrosswords(key);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CreatePuzzleScreen(
            adminKey: key,
            editId: widget.editId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error =
            e.toString().contains('403') || e.toString().contains('Invalid')
                ? 'Incorrect admin key. Access denied.'
                : 'Could not reach server. Check connection.';
        _checking = false;
      });
      _shakeCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _border),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_accent, Color(0xFFBB5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: Icon(
                    widget.editId != null
                        ? Icons.edit_rounded
                        : Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  widget.editId != null
                      ? 'Edit Puzzle #${widget.editId}'
                      : 'Admin Access',
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.editId != null
                      ? 'Enter your admin key to edit this crossword'
                      : 'Enter your admin key to create\nor manage crossword puzzles',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: _textSecondary, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 40),

                // Key field with shake on error
                AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (context, child) {
                    final offset = _error != null
                        ? (4.0 *
                            (1 - _shakeAnim.value) *
                            ((_shakeCtrl.value * 6).toInt().isEven ? 1 : -1))
                        : 0.0;
                    return Transform.translate(
                        offset: Offset(offset, 0), child: child);
                  },
                  child: TextFormField(
                    controller: _keyCtrl,
                    obscureText: _obscure,
                    onFieldSubmitted: (_) => _verify(),
                    style: const TextStyle(color: _textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Admin Key',
                      hintText: 'Enter your secret admin key',
                      errorText: _error,
                      labelStyle:
                          const TextStyle(color: _textSecondary, fontSize: 13),
                      hintStyle: const TextStyle(
                          color: Color(0xFF4A4D60), fontSize: 13),
                      prefixIcon: const Icon(Icons.key_rounded,
                          color: _textSecondary, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: _textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      filled: true,
                      fillColor: _surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: _accent, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _danger),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: _danger, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _checking ? null : _verify,
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _checking
                              ? const LinearGradient(colors: [
                                  Color(0xFF4A4D60),
                                  Color(0xFF3A3D50)
                                ])
                              : const LinearGradient(
                                  colors: [_accent, Color(0xFF9B59FF)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _checking
                              ? null
                              : [
                                  BoxShadow(
                                    color: _accent.withOpacity(0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  )
                                ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _checking
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      widget.editId != null
                                          ? Icons.edit_rounded
                                          : Icons.lock_open_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      widget.editId != null
                                          ? 'Open Editor'
                                          : 'Unlock Admin Panel',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
