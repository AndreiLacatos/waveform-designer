import 'package:flutter/widgets.dart';
import 'package:waveform_designer/theme/AppTheme.dart';

class PanPainter extends CustomPainter {
  final double? _start;
  final double? _end;

  PanPainter({
    required double? start,
    required double? end,
  })  : _end = end,
        _start = start;

  @override
  void paint(Canvas canvas, Size size) {
    if (_start == null || _end == null) {
      return;
    }

    final borderPainter = Paint()
      ..color = AppTheme.secondarAccent
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    final fillPainter = Paint()
      ..color = AppTheme.secondarAccent.withAlpha(62)
      ..style = PaintingStyle.fill;

    final startOffset = Offset(_start, 5);
    final endOffset = Offset(_end, size.height - 10);
    var rect = Rect.fromPoints(startOffset, endOffset);
    canvas.drawRect(rect, borderPainter);
    canvas.drawRect(rect, fillPainter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
