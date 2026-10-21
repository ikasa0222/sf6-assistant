import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 莫奈动态流动背景画布 (Monet Ambient Canvas)
///
/// 模拟莫奈印象派油画通透流动质感，页面底层渲染 3 个柔和低饱和度色球（赤陶红、鼠尾草绿、暖砂金），
/// 结合平滑平移与呼吸漫游，营造如暖阳映照羊皮纸般的温润典雅背景。
class MonetAmbientCanvas extends StatefulWidget {
  final Widget child;
  final bool isAnimated;

  const MonetAmbientCanvas({
    super.key,
    required this.child,
    this.isAnimated = true,
  });

  @override
  State<MonetAmbientCanvas> createState() => _MonetAmbientCanvasState();
}

class _MonetAmbientCanvasState extends State<MonetAmbientCanvas>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    if (widget.isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant MonetAmbientCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimated && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 温暖羊皮纸核心底色 (Parchment: #141413)
        const Positioned.fill(
          child: ColoredBox(
            color: Color(0xFF141413),
          ),
        ),

        // 莫奈油画色球流动层
        Positioned.fill(
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _MonetCanvasPainter(
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
        ),

        // 前景内容层
        widget.child,
      ],
    );
  }
}

class _MonetCanvasPainter extends CustomPainter {
  final double progress;

  _MonetCanvasPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final t = progress * 2 * math.pi;

    // 1. 赤陶红柔和色球 (Terracotta #D97757) - 左上方漫游
    final x1 = size.width * 0.28 + math.sin(t) * (size.width * 0.12);
    final y1 = size.height * 0.22 + math.cos(t * 0.8) * (size.height * 0.08);
    final r1 = math.max(size.width, size.height) * 0.42;

    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD97757).withOpacity(0.18),
          const Color(0xFFD97757).withOpacity(0.06),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x1, y1), radius: r1));

    canvas.drawCircle(Offset(x1, y1), r1, paint1);

    // 2. 森林鼠尾草绿柔和色球 (Sage #7A9A78) - 右中部至右下漫游
    final x2 = size.width * 0.74 + math.cos(t * 0.9) * (size.width * 0.14);
    final y2 = size.height * 0.55 + math.sin(t * 1.1) * (size.height * 0.10);
    final r2 = math.max(size.width, size.height) * 0.38;

    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF7A9A78).withOpacity(0.14),
          const Color(0xFF7A9A78).withOpacity(0.04),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x2, y2), radius: r2));

    canvas.drawCircle(Offset(x2, y2), r2, paint2);

    // 3. 暖砂琥珀金色球 (Sand Amber #D97706) - 底部偏左漫游
    final x3 = size.width * 0.45 + math.sin(t * 0.7 + 1.5) * (size.width * 0.15);
    final y3 = size.height * 0.82 + math.cos(t * 0.85) * (size.height * 0.07);
    final r3 = math.max(size.width, size.height) * 0.40;

    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD97706).withOpacity(0.13),
          const Color(0xFFD97706).withOpacity(0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(x3, y3), radius: r3));

    canvas.drawCircle(Offset(x3, y3), r3, paint3);
  }

  @override
  bool shouldRepaint(covariant _MonetCanvasPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
