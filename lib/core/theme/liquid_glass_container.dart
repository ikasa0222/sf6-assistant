import 'dart:ui';
import 'package:flutter/material.dart';

/// 苹果 iOS 液态玻璃拟态容器 (Liquid Glass Container)
///
/// 具备 16px 高斯毛玻璃滤镜、半透明象牙暖黑衬底、极细暖奶油高光微边框与内发光立体倒角。
class LiquidGlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double blurSigma;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  const LiquidGlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 18.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.blurSigma = 16.0,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? const Color(0xB8252523);
    final effectiveBorder = borderColor ?? const Color(0x33F0EEE6);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorder, width: borderWidth),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: const Color(0xFFD97757).withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, -1),
              ),
            ],
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: content,
        ),
      ),
    );
  }
}
