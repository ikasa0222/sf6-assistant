import 'dart:ui';
import 'package:flutter/material.dart';

/// 苹果 iOS 液态玻璃拟态容器 (Liquid Glass Container)
///
/// 严格遵循 Apple HIG 与视觉工程规范：
/// 外层立体环境柔和阴影 -> 内部圆角裁切 -> 真实底层高斯模糊 -> 半透明象牙润泽衬底与微发光高光边框。
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
    this.borderRadius = 22.0,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0.8,
    this.blurSigma = 24.0,
    this.shadows,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? const Color(0x73252523);
    final effectiveBorder = borderColor ?? const Color(0x38F0EEE6);

    final defaultShadows = [
      BoxShadow(
        color: Colors.black.withOpacity(0.40),
        blurRadius: 28,
        spreadRadius: 0,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: const Color(0xFFD97757).withOpacity(0.06),
        blurRadius: 16,
        spreadRadius: 1,
        offset: const Offset(0, -1),
      ),
    ];

    Widget body = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorder, width: borderWidth),
      ),
      child: child,
    );

    if (onTap != null) {
      body = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: body,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows ?? defaultShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: body,
        ),
      ),
    );
  }
}
