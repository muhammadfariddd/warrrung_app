import 'dart:math';
import 'package:flutter/material.dart';

/// A high-fidelity, custom-painted WhatsApp logo icon widget.
class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color color;

  const WhatsAppIcon({super.key, this.size = 24.0, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WhatsAppPainter(color),
    );
  }
}

class _WhatsAppPainter extends CustomPainter {
  final Color iconColor;

  _WhatsAppPainter(this.iconColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Draw the bubble body outline / path
    // We draw a circle, but with a tail at the bottom left (approx 225 degrees)
    final center = Offset(w * 0.5, h * 0.46);
    final radius = w * 0.44;

    // Speech bubble path (circle + tail)
    final bubblePath = Path();

    // Add main circle (slightly offset to leave room for tail)
    bubblePath.addOval(Rect.fromCircle(center: center, radius: radius));

    // Tail path (pointing to bottom-left)
    final tailPath = Path()
      ..moveTo(w * 0.22, h * 0.74)
      ..lineTo(w * 0.12, h * 0.88)
      ..lineTo(w * 0.32, h * 0.82)
      ..close();

    canvas.drawPath(bubblePath, paint);
    canvas.drawPath(tailPath, paint);

    // Draw phone receiver inside
    final receiverPaint = Paint()
      ..color = iconColor == Colors.white
          ? const Color(0xFF25D366)
          : Colors.white
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // We can draw a phone receiver using simple curves/rects
    // To make it look extremely clean and precise, we draw it as a Path.
    final phonePath = Path();

    // Coordinates normalized for a 24x24 space inside the bubble
    // We scale by w / 24
    final s = w / 24.0;

    // Drawing a curved telephone receiver
    phonePath.moveTo(7.5 * s, 10.0 * s);
    phonePath.quadraticBezierTo(9.0 * s, 13.0 * s, 13.0 * s, 15.0 * s);
    phonePath.lineTo(14.5 * s, 13.8 * s);
    phonePath.quadraticBezierTo(15.2 * s, 13.2 * s, 16.0 * s, 13.6 * s);
    phonePath.lineTo(18.2 * s, 14.8 * s);
    phonePath.quadraticBezierTo(19.0 * s, 15.3 * s, 18.7 * s, 16.2 * s);
    phonePath.lineTo(17.8 * s, 18.2 * s);
    phonePath.quadraticBezierTo(17.0 * s, 19.0 * s, 14.5 * s, 18.5 * s);
    phonePath.quadraticBezierTo(9.5 * s, 17.5 * s, 5.5 * s, 11.5 * s);
    phonePath.quadraticBezierTo(4.0 * s, 8.0 * s, 5.5 * s, 6.0 * s);
    phonePath.lineTo(7.2 * s, 5.2 * s);
    phonePath.quadraticBezierTo(8.0 * s, 4.8 * s, 8.5 * s, 5.6 * s);
    phonePath.lineTo(9.8 * s, 7.8 * s);
    phonePath.quadraticBezierTo(10.2 * s, 8.6 * s, 9.6 * s, 9.2 * s);
    phonePath.close();

    canvas.drawPath(phonePath, receiverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A high-fidelity, custom-painted Google "G" logo icon widget.
class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = min(w, h) / 2;
    final center = Offset(w / 2, h / 2);

    // Google G is composed of 4 color arcs
    // Red: Top arc
    // Yellow: Left arc
    // Green: Bottom arc
    // Blue: Right arc + horizontal line

    final double strokeWidth = r * 0.35;

    // We will draw it using Paths
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;

    final rect = Rect.fromCircle(center: center, radius: r - strokeWidth / 2);

    // 1. Red Top arc (from 195 to 330 degrees)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -195 * pi / 180, 135 * pi / 180, false, paint);

    // 2. Yellow Left arc (from 135 to 195 degrees)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, -225 * pi / 180, 45 * pi / 180, false, paint);

    // 3. Green Bottom arc (from 45 to 135 degrees)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, -360 * pi / 180, 135 * pi / 180, false, paint);

    // 4. Blue Right section (from -45 to 45 degrees + horizontal crossbar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -45 * pi / 180, 90 * pi / 180, false, paint);

    // Draw the horizontal bar of Google G
    final crossbarPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Crossbar starting from center to the right edge
    final crossbarRect = Rect.fromLTRB(
      center.dx,
      center.dy - strokeWidth / 2,
      center.dx + r,
      center.dy + strokeWidth / 2,
    );
    canvas.drawRect(crossbarRect, crossbarPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
