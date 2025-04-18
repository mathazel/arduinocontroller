import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Function(TapDownDetails)? onTapDown;
  final Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;
  final double height;
  final double width;
  final Color? backgroundColor;
  final double fontSize;
  final bool useTapGesture;
  final IconData? icon;
  final double? borderRadius;
  final Color? shadowColor;

  const ControlButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.height = 80,
    this.width = 80,
    this.backgroundColor,
    this.fontSize = 24,
    this.useTapGesture = false,
    this.icon,
    this.borderRadius,
    this.shadowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonContent = Container(
      decoration: BoxDecoration(
        shape: borderRadius != null ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        color: backgroundColor ?? Theme.of(context).primaryColor,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (backgroundColor ?? Theme.of(context).primaryColor).withOpacity(0.9),
            backgroundColor ?? Theme.of(context).primaryColor,
            (backgroundColor ?? Theme.of(context).primaryColor).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? (backgroundColor ?? Theme.of(context).primaryColor).withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: icon != null
            ? Icon(
                icon,
                color: Colors.white,
                size: fontSize * 1.2,
              )
            : Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: borderRadius != null 
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius!)) 
            : const CircleBorder(),
        child: buttonContent,
      ),
    );

    return SizedBox(
      height: height,
      width: width,
      child: useTapGesture && onTapDown != null && onTapUp != null && onTapCancel != null
          ? GestureDetector(
              onTapDown: onTapDown,
              onTapUp: onTapUp,
              onTapCancel: onTapCancel,
              child: button,
            )
          : button,
    );
  }
} 