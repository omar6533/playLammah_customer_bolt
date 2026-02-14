import 'package:flutter/material.dart';

class LammhLogo extends StatelessWidget {
  final double size;
  final Color color;

  const LammhLogo({
    Key? key,
    this.size = 120,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LammhLogoPainter(color: color),
    );
  }
}

class _LammhLogoPainter extends CustomPainter {
  final Color color;

  _LammhLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final s = w / 400; // scaling factor

    // Top Left Bracket
    final path1 = Path()
      ..moveTo(88 * s, 72 * s)
      ..cubicTo(60 * s, 48 * s, 48 * s, 60 * s, 48 * s, 100 * s)
      ..cubicTo(48 * s, 140 * s, 72 * s, 168 * s, 112 * s, 168 * s)
      ..cubicTo(140 * s, 168 * s, 160 * s, 152 * s, 168 * s, 128 * s);

    // Top Right Bracket
    final path2 = Path()
      ..moveTo(312 * s, 72 * s)
      ..cubicTo(340 * s, 48 * s, 352 * s, 60 * s, 352 * s, 100 * s)
      ..cubicTo(352 * s, 140 * s, 328 * s, 168 * s, 288 * s, 168 * s)
      ..cubicTo(260 * s, 168 * s, 240 * s, 152 * s, 232 * s, 128 * s);

    // Bottom Left Bracket
    final path3 = Path()
      ..moveTo(88 * s, 232 * s)
      ..cubicTo(60 * s, 208 * s, 48 * s, 220 * s, 48 * s, 260 * s)
      ..cubicTo(48 * s, 300 * s, 72 * s, 328 * s, 112 * s, 328 * s)
      ..cubicTo(140 * s, 328 * s, 160 * s, 312 * s, 168 * s, 288 * s);

    // Bottom Right Bracket
    final path4 = Path()
      ..moveTo(312 * s, 232 * s)
      ..cubicTo(340 * s, 208 * s, 352 * s, 220 * s, 352 * s, 260 * s)
      ..cubicTo(352 * s, 300 * s, 328 * s, 328 * s, 288 * s, 328 * s)
      ..cubicTo(260 * s, 328 * s, 240 * s, 312 * s, 232 * s, 288 * s);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);

    // Decorative Dots
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final dotRadius = 16 * s;
    canvas.drawCircle(Offset(128 * s, 112 * s), dotRadius, fillPaint);
    canvas.drawCircle(Offset(272 * s, 112 * s), dotRadius, fillPaint);
    canvas.drawCircle(Offset(128 * s, 272 * s), dotRadius, fillPaint);
    canvas.drawCircle(Offset(272 * s, 272 * s), dotRadius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
