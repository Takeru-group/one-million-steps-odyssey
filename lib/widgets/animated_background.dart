import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AnimatedBackground extends StatefulWidget {
  final String? imageUrl;
  final String fallbackAssetPath;
  final bool isDarkMode;

  const AnimatedBackground({
    super.key,
    this.imageUrl,
    required this.fallbackAssetPath,
    required this.isDarkMode,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 50), // ⭕️ 20秒 ➔ 50秒に統一
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overlayColor = widget.isDarkMode
        ? Colors.black.withOpacity(0.40)
        : Colors.white.withOpacity(0.30);

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final imageWidth = screenHeight * (16 / 9);
        final overflowWidth = imageWidth - constraints.maxWidth;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final double alignmentX =
                    overflowWidth > 0 ? -1.0 + (_controller.value * 2.0) : 0.0;
                return OverflowBox(
                  minWidth: imageWidth,
                  maxWidth: imageWidth,
                  minHeight: screenHeight,
                  maxHeight: screenHeight,
                  alignment: Alignment(alignmentX, 0.0),
                  child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.imageUrl!,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _buildLocalImage(),
                        )
                      : _buildLocalImage(),
                );
              },
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              color: overlayColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocalImage() {
    return Image.asset(
      widget.fallbackAssetPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Container(color: Colors.grey[800]),
    );
  }
}