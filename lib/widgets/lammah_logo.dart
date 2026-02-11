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
    final h = size.height;

    final path1 = Path();
    path1.moveTo(w * 0.25, h * 0.15);
    path1.cubicTo(w * 0.15, h * 0.15, w * 0.15, h * 0.25, w * 0.15, h * 0.35);
    path1.cubicTo(w * 0.15, h * 0.45, w * 0.25, h * 0.45, w * 0.35, h * 0.45);

    final path2 = Path();
    path2.moveTo(w * 0.75, h * 0.15);
    path2.cubicTo(w * 0.85, h * 0.15, w * 0.85, h * 0.25, w * 0.85, h * 0.35);
    path2.cubicTo(w * 0.85, h * 0.45, w * 0.75, h * 0.45, w * 0.65, h * 0.45);

    final path3 = Path();
    path3.moveTo(w * 0.25, h * 0.55);
    path3.cubicTo(w * 0.15, h * 0.55, w * 0.15, h * 0.65, w * 0.15, h * 0.75);
    path3.cubicTo(w * 0.15, h * 0.85, w * 0.25, h * 0.85, w * 0.35, h * 0.85);

    final path4 = Path();
    path4.moveTo(w * 0.75, h * 0.55);
    path4.cubicTo(w * 0.85, h * 0.55, w * 0.85, h * 0.65, w * 0.85, h * 0.75);
    path4.cubicTo(w * 0.85, h * 0.85, w * 0.75, h * 0.85, w * 0.65, h * 0.85);

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
    canvas.drawPath(path4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
