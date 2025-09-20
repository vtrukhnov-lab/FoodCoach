import 'package:flutter/material.dart';
import 'dart:math' as math;

class IonCharacter extends StatefulWidget {
  final double size;
  final IonMood mood;
  final bool showGlow;
  final bool showElectrolytes;
  final HydrationLevel hydrationLevel;

  const IonCharacter({
    super.key,
    this.size = 140,
    this.mood = IonMood.happy,
    this.showGlow = true,
    this.showElectrolytes = true,
    this.hydrationLevel = HydrationLevel.normal,
  });

  @override
  State<IonCharacter> createState() => _IonCharacterState();
}

enum IonMood {
  happy,
  excited,
  winking,
  proud,
  thinking,
  worried,
  celebrating,
  waving,
  thumbsUp
}

enum HydrationLevel { low, normal, high, perfect }

class _IonCharacterState extends State<IonCharacter>
    with TickerProviderStateMixin {
  late final AnimationController _breathingController =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat(reverse: true);
  late final AnimationController _blinkController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 140));
  late final AnimationController _bounceController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  late final AnimationController _waveController =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
  late final AnimationController _floatController =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat(reverse: true);

  late final Animation<double> _breath =
      Tween(begin: 0.985, end: 1.015).animate(CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));
  late final Animation<double> _blink =
      Tween(begin: 1.0, end: 0.08).animate(CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut));
  late final Animation<double> _bounce =
      Tween(begin: 0.0, end: -10.0).animate(CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));
  late final Animation<double> _wave =
      Tween(begin: 0.0, end: 0.30).animate(CurvedAnimation(parent: _waveController, curve: Curves.easeInOut));
  late final Animation<double> _float =
      Tween(begin: -6.0, end: 6.0).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _startBlinking();
    _bounceController.forward();
    if (widget.mood == IonMood.waving || widget.mood == IonMood.excited) _startWaving();
  }

  Future<void> _startBlinking() async {
    final rnd = math.Random();
    while (mounted) {
      await Future.delayed(Duration(milliseconds: 2200 + rnd.nextInt(1500)));
      if (!mounted) break;
      await _blinkController.forward();
      await _blinkController.reverse();
    }
  }

  Future<void> _startWaving() async {
    while (mounted && (widget.mood == IonMood.waving || widget.mood == IonMood.excited)) {
      await _waveController.forward();
      await _waveController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void didUpdateWidget(covariant IonCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood) {
      if (widget.mood == IonMood.waving || widget.mood == IonMood.excited) _startWaving();
      if (widget.mood == IonMood.celebrating) _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _blinkController.dispose();
    _bounceController.dispose();
    _waveController.dispose();
    _floatController.dispose();
    super.dispose();
    // ignore: unused_field
  }

  List<Color> _bodyColors() {
    switch (widget.hydrationLevel) {
      case HydrationLevel.low:
        return const [Color(0xFF7AB8F5), Color(0xFF9ECFFF)];
      case HydrationLevel.high:
        return const [Color(0xFF1A9FFF), Color(0xFF2EB0FF)];
      case HydrationLevel.perfect:
        return const [Color(0xFF2EC5FF), Color(0xFF8AF5A3)];
      case HydrationLevel.normal:
      default:
        return const [Color(0xFF2EC5FF), Color(0xFF3DD5FF)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breath, _blink, _bounce, _wave, _float]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: Transform.scale(
            scale: _breath.value,
            child: SizedBox(
              width: widget.size * 1.5,
              height: widget.size * 1.35,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // мягкая тень
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: widget.size * 0.62,
                      height: widget.size * 0.10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, spreadRadius: 2),
                        ],
                      ),
                    ),
                  ),

                  // внешний неоновый ореол (для perfect/по желанию)
                  if (widget.showGlow)
                    Positioned(
                      top: widget.size * 0.12,
                      child: Container(
                        width: widget.size * 1.36,
                        height: widget.size * 1.36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              (widget.hydrationLevel == HydrationLevel.perfect ? const Color(0xFF8AF5A3) : const Color(0xFF2EC5FF)).withValues(alpha: 0.35),
                              const Color(0xFF2EC5FF).withValues(alpha: 0.10),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),

                  // электролиты
                  if (widget.showElectrolytes) ...[
                    Positioned(
                      left: widget.size * 0.10,
                      top: widget.size * 0.20 + _float.value,
                      child: _electro('Na⁺', const Color(0xFF8AF5A3)),
                    ),
                    Positioned(
                      right: widget.size * 0.14,
                      top: widget.size * 0.14 - _float.value,
                      child: _electro('K', const Color(0xFFFFC857)),
                    ),
                    Positioned(
                      right: widget.size * 0.10,
                      bottom: widget.size * 0.30 + _float.value * .5,
                      child: _electro('Mg', const Color(0xFFFF6B9D)),
                    ),
                    Positioned(
                      left: widget.size * 0.06,
                      bottom: widget.size * 0.40 - _float.value * .45,
                      child: _electro('Mg²⁺', const Color(0xFFFF6B9D), s: 0.85),
                    ),
                  ],

                  // тело капли
                  Positioned(
                    top: widget.size * 0.12,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _IonPainter(
                        mood: widget.mood,
                        blinkValue: _blink.value,
                        waveValue: _wave.value,
                        bodyColors: _bodyColors(),
                        hydrationLevel: widget.hydrationLevel,
                      ),
                    ),
                  ),

                  // значок риска при низкой гидратации
                  if (widget.hydrationLevel == HydrationLevel.low)
                    Positioned(
                      top: widget.size * 0.04,
                      right: widget.size * 0.28,
                      child: Icon(Icons.warning_rounded, color: const Color(0xFFFFC857), size: widget.size * 0.16),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _electro(String t, Color c, {double s = 1}) {
    final fs = widget.size * 0.10 * s;
    return Container(
      padding: EdgeInsets.all(widget.size * 0.02),
      child: Text(
        t,
        style: TextStyle(
          fontSize: fs,
          fontWeight: FontWeight.w700,
          color: c,
          shadows: [Shadow(color: c.withValues(alpha: .55), blurRadius: 6)],
        ),
      ),
    );
  }
}

// ================= PAINTER =================

class _IonPainter extends CustomPainter {
  final IonMood mood;
  final double blinkValue; // 1.0 — открыто; ~0.1 — почти закрыто
  final double waveValue;  // 0..0.3 для поворота кисти
  final List<Color> bodyColors;
  final HydrationLevel hydrationLevel;

  _IonPainter({
    required this.mood,
    required this.blinkValue,
    required this.waveValue,
    required this.bodyColors,
    required this.hydrationLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // форма капли
    final dropPath = _dropPath(size);

    // заливка капли: радиальный градиент (циан → мята)
    final fill = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.2, -.15),
        radius: 1.0,
        colors: [bodyColors.first, bodyColors.last],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * .55));

    // неоновый контур
    final neon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..color = const Color(0xFF2EC5FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // тонкий верхний контур
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.016
      ..color = Colors.white.withValues(alpha: .7);

    // рисуем
    canvas.drawPath(dropPath, fill);
    canvas.drawPath(dropPath, neon);
    canvas.drawPath(dropPath, stroke);

    // глянцевый блик
    final highlight = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width * .36, size.height * .34),
        width: size.width * .20,
        height: size.height * .28,
      ));
    canvas.drawPath(highlight, Paint()..color = Colors.white.withValues(alpha: .28));

    // маленький блик
    canvas.drawCircle(
      Offset(size.width * .66, size.height * .30),
      size.width * .06,
      Paint()..color = Colors.white.withValues(alpha: .55),
    );

    // лицо
    _drawFace(canvas, size);

    // руки/жесты — только для нужных настроений
    switch (mood) {
      case IonMood.waving:
      case IonMood.excited:
        _drawWavingArm(canvas, size, left: true);
        break;
      case IonMood.celebrating:
        _drawRaisedArm(canvas, size, left: true);
        _drawRaisedArm(canvas, size, left: false);
        break;
      case IonMood.proud:
        _drawArmOnHip(canvas, size, left: true);
        _drawArmOnHip(canvas, size, left: false);
        break;
      case IonMood.thumbsUp:
        _drawThumbsUp(canvas, size);
        break;
      default:
        // happy / winking / thinking / worried — без рук и ног
        break;
    }
  }

  Path _dropPath(Size size) {
    final p = Path();
    p.moveTo(size.width / 2, size.height * 0.10);
    p.quadraticBezierTo(size.width * 0.18, size.height * 0.28, size.width * 0.18, size.height * 0.50);
    p.quadraticBezierTo(size.width * 0.18, size.height * 0.74, size.width * 0.50, size.height * 0.78);
    p.quadraticBezierTo(size.width * 0.82, size.height * 0.74, size.width * 0.82, size.height * 0.50);
    p.quadraticBezierTo(size.width * 0.82, size.height * 0.28, size.width / 2, size.height * 0.10);
    p.close();
    return p;
  }

  void _drawFace(Canvas canvas, Size size) {
    final eyeColor = const Color(0xFF0A5F8C);
    final mouthPaint = Paint()
      ..color = eyeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * 0.03;

    // глаза — простые тёмные овалы с «схлопыванием» по вертикали при мигании
    final left = Offset(size.width * .36, size.height * .46);
    final right = Offset(size.width * .64, size.height * .46);
    final eyeW = size.width * .10;
    final eyeH = size.width * .14 * blinkValue.clamp(0.08, 1.0);

    canvas.drawOval(Rect.fromCenter(center: left, width: eyeW, height: eyeH), Paint()..color = eyeColor);
    if (mood == IonMood.winking) {
      // подмигивание правым
      final wink = Path()
        ..moveTo(right.dx - eyeW / 2, right.dy)
        ..quadraticBezierTo(right.dx, right.dy + 3, right.dx + eyeW / 2, right.dy);
      canvas.drawPath(wink, mouthPaint);
    } else {
      canvas.drawOval(Rect.fromCenter(center: right, width: eyeW, height: eyeH), Paint()..color = eyeColor);
    }

    // рот
    final c = Offset(size.width / 2, size.height * .60);
    Path path;
    switch (mood) {
      case IonMood.worried:
        path = Path()
          ..moveTo(c.dx - size.width * .12, c.dy + 4)
          ..quadraticBezierTo(c.dx, c.dy - size.width * .05, c.dx + size.width * .12, c.dy + 4);
        break;
      case IonMood.thinking:
        path = Path()
          ..moveTo(c.dx - size.width * .08, c.dy)
          ..quadraticBezierTo(c.dx, c.dy - 3, c.dx + size.width * .06, c.dy + 3);
        break;
      case IonMood.excited:
      case IonMood.celebrating:
        path = Path()
          ..moveTo(c.dx - size.width * .16, c.dy - 2)
          ..quadraticBezierTo(c.dx, c.dy + size.width * .12, c.dx + size.width * .16, c.dy - 2);
        break;
      case IonMood.proud:
        path = Path()
          ..moveTo(c.dx - size.width * .10, c.dy + 2)
          ..quadraticBezierTo(c.dx, c.dy + size.width * .05, c.dx + size.width * .10, c.dy + 2);
        break;
      default:
        path = Path()
          ..moveTo(c.dx - size.width * .12, c.dy)
          ..quadraticBezierTo(c.dx, c.dy + size.width * .08, c.dx + size.width * .12, c.dy);
    }
    canvas.drawPath(path, mouthPaint);

    // лёгкий «румянец» для excited/celebrating
    if (mood == IonMood.excited || mood == IonMood.celebrating) {
      final blush = Paint()..color = Colors.pink.withValues(alpha: .28);
      canvas.drawCircle(Offset(size.width * .22, size.height * .52), size.width * .06, blush);
      canvas.drawCircle(Offset(size.width * .78, size.height * .52), size.width * .06, blush);
    }

    // «сухие штрихи» при low-гидратации
    if (hydrationLevel == HydrationLevel.low) {
      final dry = Paint()
        ..color = eyeColor.withValues(alpha: .22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      for (int i = 0; i < 3; i++) {
        canvas.drawLine(Offset(size.width * .16, size.height * (.50 + i * .015)),
            Offset(size.width * .24, size.height * (.50 + i * .015)), dry);
        canvas.drawLine(Offset(size.width * .76, size.height * (.50 + i * .015)),
            Offset(size.width * .84, size.height * (.50 + i * .015)), dry);
      }
    }
  }

  // ====== руки (минималистичные цилиндры), рисуем только когда надо ======

  Paint get _armPaint => Paint()
    ..color = bodyColors.first.withValues(alpha: .95)
    ..style = PaintingStyle.fill;

  void _drawWavingArm(Canvas canvas, Size size, {required bool left}) {
    final angle = waveValue * math.pi / 6 * (left ? -1 : 1);
    final start = Offset(size.width * (left ? .24 : .76), size.height * .52);

    canvas.save();
    canvas.translate(start.dx, start.dy);
    canvas.rotate(angle);
    final p = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -size.width * .04, size.width * .26, size.width * .08),
        Radius.circular(size.width * .04),
      ));
    canvas.drawPath(p, _armPaint);
    // ладонь
    canvas.drawCircle(Offset(size.width * .26, 0), size.width * .07, _armPaint);
    canvas.restore();
  }

  void _drawRaisedArm(Canvas canvas, Size size, {required bool left}) {
    final start = Offset(size.width * (left ? .30 : .70), size.height * .45);
    final end = Offset(size.width * (left ? .18 : .82), size.height * .22);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(size.width * (left ? .25 : .75), size.height * .30, end.dx, end.dy);
    final paint = _armPaint..strokeCap = StrokeCap.round..style = PaintingStyle.stroke..strokeWidth = size.width * .11;
    canvas.drawPath(path, paint);
    canvas.drawCircle(end, size.width * .07, _armPaint);
  }

  void _drawArmOnHip(Canvas canvas, Size size, {required bool left}) {
    final start = Offset(size.width * (left ? .30 : .70), size.height * .52);
    final mid = Offset(size.width * (left ? .26 : .74), size.height * .60);
    final end = Offset(size.width * (left ? .34 : .66), size.height * .65);

    final path = Path()..moveTo(start.dx, start.dy)..quadraticBezierTo(mid.dx, mid.dy, end.dx, end.dy);
    final paint = _armPaint..strokeCap = StrokeCap.round..style = PaintingStyle.stroke..strokeWidth = size.width * .11;
    canvas.drawPath(path, paint);
    canvas.drawCircle(end, size.width * .065, _armPaint);
  }

  void _drawThumbsUp(Canvas canvas, Size size) {
    final start = Offset(size.width * .28, size.height * .50);
    final elbow = Offset(size.width * .16, size.height * .42);
    final hand = Offset(size.width * .10, size.height * .38);
    final paint = _armPaint..strokeCap = StrokeCap.round..style = PaintingStyle.stroke..strokeWidth = size.width * .11;

    final path = Path()..moveTo(start.dx, start.dy)..quadraticBezierTo(elbow.dx, elbow.dy, hand.dx, hand.dy);
    canvas.drawPath(path, paint);
    canvas.drawCircle(hand, size.width * .075, _armPaint); // кулак

    // большой палец
    final thumb = Path()
      ..moveTo(hand.dx + size.width * .02, hand.dy - size.width * .01)
      ..lineTo(hand.dx + size.width * .02, hand.dy - size.width * .08)
      ..lineTo(hand.dx + size.width * .07, hand.dy - size.width * .08)
      ..lineTo(hand.dx + size.width * .06, hand.dy - size.width * .01)
      ..close();
    canvas.drawPath(thumb, _armPaint);
  }

  @override
  bool shouldRepaint(covariant _IonPainter old) {
    return old.mood != mood ||
        old.blinkValue != blinkValue ||
        old.waveValue != waveValue ||
        old.hydrationLevel != hydrationLevel ||
        old.bodyColors != bodyColors;
  }
}
