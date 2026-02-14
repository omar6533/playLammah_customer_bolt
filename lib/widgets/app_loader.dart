import 'package:flutter/material.dart';
import 'package:trivia_game/widgets/lammah_logo.dart';
import '../theme/app_colors.dart';

class AppLoader extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final bool showBackground;
  final String? loadingText;

  const AppLoader({
    Key? key,
    this.size = 120,
    this.backgroundColor,
    this.showBackground = true,
    this.loadingText,
  }) : super(key: key);

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.showBackground
          ? (widget.backgroundColor ?? AppColors.white)
          : null,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  ),
                );
              },
              child: LammhLogo(
                size: widget.size,
                color: AppColors.primaryRed,
              ),
            ),
            if (widget.loadingText != null) ...[
              const SizedBox(height: 24),
              Text(
                widget.loadingText!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final String? message;

  const AppLoadingOverlay({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AppLoader(
            size: 80,
            showBackground: false,
            loadingText: message,
          ),
        ),
      ),
    );
  }
}
