import 'package:flutter/material.dart';
import '../views/chat_screen.dart';

class MindieDraggableBall extends StatefulWidget {
  const MindieDraggableBall({super.key});

  @override
  State<MindieDraggableBall> createState() => _MindieDraggableBallState();
}

class _MindieDraggableBallState extends State<MindieDraggableBall>
    with TickerProviderStateMixin {
  // ValueNotifier so only the ball repositions — no full tree rebuild
  late ValueNotifier<Offset> _position;
  bool _isInitialized = false;

  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  late AnimationController _snapController;
  late Animation<Offset> _snapAnimation;

  @override
  void initState() {
    super.initState();

    _position = ValueNotifier(Offset.zero);

    // Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Snap animation
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _snapAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic,
    ));

    _snapController.addListener(() {
      _position.value = _snapAnimation.value;
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _snapController.dispose();
    _position.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Cancel any ongoing snap so drag feels instant
    if (_snapController.isAnimating) _snapController.stop();
    _position.value = _position.value + details.delta;
  }

  void _onPanEnd(Size screenSize) {
    final current = _position.value;

    double targetX;
    if (current.dx + 40 < screenSize.width / 2) {
      targetX = 16.0;
    } else {
      targetX = screenSize.width - 80 - 16.0;
    }

    double targetY = current.dy.clamp(
      80.0,
      screenSize.height - 180.0,
    );

    final Offset targetOffset = Offset(targetX, targetY);

    _snapAnimation = Tween<Offset>(
      begin: current,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _snapController,
      curve: Curves.easeOutCubic,
    ));

    _snapController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (!_isInitialized) {
      _position.value = Offset(
        screenSize.width - 80 - 16.0,
        screenSize.height - 200 - 16.0,
      );
      _isInitialized = true;
    }

    return ValueListenableBuilder<Offset>(
      valueListenable: _position,
      builder: (context, pos, child) {
        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: child!,
        );
      },
      child: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: (_) => _onPanEnd(screenSize),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Hero(
            tag: 'mindie-bot',
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/mindie.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF3AAFFF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🦄', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
