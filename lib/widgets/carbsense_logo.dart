import 'package:flutter/material.dart';

class CarbSenseLogo extends StatelessWidget {
  final double size;
  const CarbSenseLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LogoPainter()),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // ── 1. Outer gradient ring ───────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = SweepGradient(
          colors: const [
            Color(0xFF1A56DB),
            Color(0xFF4F9CF9),
            Color(0xFF0D9E75),
            Color(0xFF1A56DB),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.07,
    );

    // ── 2. Dark navy ring ────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.90,
      Paint()
        ..shader = LinearGradient(
          colors: const [Color(0xFF0F3460), Color(0xFF062A1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.90),
        ),
    );

    // ── 3. Purple inner ring ─────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.80,
      Paint()..color = const Color(0xFF1e1060),
    );

    // ── 4. White circle ──────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.70,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -0.2),
          colors: const [Colors.white, Color(0xFFEEF2FF)],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.70),
        ),
    );

    // ── 5. Blood drop ────────────────────────────────────────────────
    // ── 5. Blood drop ────────────────────────────────────────────────
    final dropCy = cy - r * 0.05;
    final dropW = r * 0.38;
    final dropTop = dropCy - r * 0.55;
    //final dropTop = dropCy - r * 0.40;
    final dropBot = dropCy + r * 0.42; // ← add this line
    final dropPath =
        Path()
          ..moveTo(cx, dropTop) // pointy top
          ..cubicTo(
            cx + r * 0.08,
            dropTop + r * 0.14, // control 1 — stay narrow near tip
            cx + dropW,
            dropCy - r * 0.05, // control 2 — flare out gradually
            cx + dropW,
            dropCy + r * 0.12, // right side middle
          )
          ..cubicTo(
            cx + dropW,
            dropCy + r * 0.32, // control 1 — round bottom right
            cx + r * 0.18,
            dropCy + r * 0.42, // control 2
            cx,
            dropCy + r * 0.42, // bottom centre
          )
          ..cubicTo(
            cx - r * 0.18,
            dropCy + r * 0.42, // control 1 — round bottom left
            cx - dropW,
            dropCy + r * 0.32, // control 2
            cx - dropW,
            dropCy + r * 0.12, // left side middle
          )
          ..cubicTo(
            cx - dropW,
            dropCy - r * 0.05, // control 1 — taper back to tip
            cx - r * 0.08,
            dropTop + r * 0.14, // control 2 — stay narrow near tip
            cx,
            dropTop, // back to pointy top
          );

    // Drop fill
    canvas.drawPath(
      dropPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          colors: const [Color(0xFFE84545), Color(0xFF9E1515)],
        ).createShader(
          Rect.fromCenter(
            center: Offset(cx, dropCy),
            width: dropW * 2,
            height: (dropBot - dropTop),
          ),
        ),
    );

    // Drop shine
    canvas.drawPath(
      dropPath,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.5,
          colors: [
            Colors.white.withValues(alpha: 0.50),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(cx, dropCy),
            width: dropW * 2,
            height: (dropBot - dropTop),
          ),
        ),
    );

    // ── 6. ECG line across drop ──────────────────────────────────────
    final ey = dropCy + r * 0.07; // vertical centre of ECG
    final ex = r * 0.26; // half-width of ECG line

    canvas.drawPath(
      Path()
        ..moveTo(cx - ex, ey)
        ..lineTo(cx - ex * 0.65, ey)
        ..lineTo(cx - ex * 0.42, ey - r * 0.13)
        ..lineTo(cx - ex * 0.16, ey + r * 0.20)
        ..lineTo(cx, ey - r * 0.06)
        ..lineTo(cx + ex * 0.22, ey + r * 0.11)
        ..lineTo(cx + ex * 0.45, ey + r * 0.02)
        ..lineTo(cx + ex * 0.65, ey + r * 0.02)
        ..lineTo(cx + ex, ey),
      Paint()
        ..color = Colors.white
        ..strokeWidth = r * 0.035
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // ── 7. Leaf stem ─────────────────────────────────────────────────
    final stemTop = dropBot + r * 0.01; // just below drop
    final stemBot = dropBot + r * 0.16;

    canvas.drawLine(
      Offset(cx, stemTop),
      Offset(cx, stemBot),
      Paint()
        ..color = const Color(0xFF0D9E75)
        ..strokeWidth = r * 0.03
        ..strokeCap = StrokeCap.round,
    );

    // ── 8. Leaf body ─────────────────────────────────────────────────
    final lTop = stemTop - r * 0.02;
    final lBot = stemTop + r * 0.19;
    final lW = r * 0.15;

    canvas.drawPath(
      Path()
        ..moveTo(cx, lBot)
        ..cubicTo(
          cx - lW,
          lBot - r * 0.06,
          cx - lW * 1.2,
          lTop + r * 0.08,
          cx - lW * 0.5,
          lTop,
        )
        ..cubicTo(
          cx + lW * 0.3,
          lTop - r * 0.04,
          cx + lW * 1.1,
          lTop + r * 0.10,
          cx + lW,
          lBot - r * 0.06,
        )
        ..lineTo(cx, lBot),
      Paint()..color = const Color(0xFF0D9E75),
    );

    // Leaf centre vein
    canvas.drawLine(
      Offset(cx, lBot),
      Offset(cx + r * 0.01, lTop + r * 0.02),
      Paint()
        ..color = const Color(0xFF34C99A)
        ..strokeWidth = r * 0.018
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Leaf side veins
    final veinPaint =
        Paint()
          ..color = const Color(0xFF34C99A).withValues(alpha: 0.65)
          ..strokeWidth = r * 0.012
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, lBot - r * 0.06),
      Offset(cx - lW * 0.65, lBot - r * 0.11),
      veinPaint,
    );
    canvas.drawLine(
      Offset(cx + r * 0.01, lBot - r * 0.12),
      Offset(cx + lW * 0.60, lBot - r * 0.17),
      veinPaint,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter old) => false;
}
