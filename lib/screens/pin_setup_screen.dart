import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/keypad.dart';
import 'login_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  String _pin = '';
  static const _max = 6;

  void _press(String k) {
    if (k == 'cancel') {
      setState(() => _pin = '');
      return;
    }
    if (k == 'proceed') {
      if (_pin.length == _max) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }
    if (k == 'del') {
      setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1));
      return;
    }
    if (_pin.length >= _max) return;
    setState(() => _pin += k);
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _pin.length == _max;
    final hasPin     = _pin.isNotEmpty;

    final rows = [
      [
        KeypadKey.digit('1', onTap: () => _press('1')),
        KeypadKey.digit('2', subLabel: 'ABC', onTap: () => _press('2')),
        KeypadKey.digit('3', subLabel: 'DEF', onTap: () => _press('3')),
      ],
      [
        KeypadKey.digit('4', subLabel: 'GHI', onTap: () => _press('4')),
        KeypadKey.digit('5', subLabel: 'JKL', onTap: () => _press('5')),
        KeypadKey.digit('6', subLabel: 'MNO', onTap: () => _press('6')),
      ],
      [
        KeypadKey.digit('7', subLabel: 'PQRS', onTap: () => _press('7')),
        KeypadKey.digit('8', subLabel: 'TUV',  onTap: () => _press('8')),
        KeypadKey.digit('9', subLabel: 'WXYZ', onTap: () => _press('9')),
      ],
      [
        KeypadKey.proceed(onTap: () => _press('proceed'), enabled: canProceed),
        KeypadKey.digit('0', onTap: () => _press('0')),
        KeypadKey.cancel(onTap: () => _press('cancel'), enabled: hasPin),
      ],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Lk.l, 0, Lk.l, Lk.xl),
          child: Column(
            children: [
              // Lock icon
              const SizedBox(height: Lk.xl),
              const _LockIcon(),
              const SizedBox(height: Lk.l),
              // Headings
              Text(
                'Set Your Master PIN',
                style: Lk.ui(22, FontWeight.w700, Lk.text, ls: -0.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Lk.s),
              Text(
                'Create a 6-digit PIN to secure your vault.',
                style: Lk.ui(13, FontWeight.w400, Lk.textDim, ls: -0.1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Lk.xxl),
              // PIN dots
              _PinDots(filled: _pin.length, total: _max),
              // Keypad pushed to bottom
              const Spacer(),
              PinKeypad(rows: rows),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _LockIcon extends StatelessWidget {
  const _LockIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(painter: _LockPainter()),
    );
  }
}

class _LockPainter extends CustomPainter {
  const _LockPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4D7DC)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final scale = size.width / 24;
    canvas.scale(scale, scale);

    // Body rect
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(3.5, 10.5, 17, 11),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(body, paint);

    // Shackle arc
    final path = Path()
      ..moveTo(7.5, 10.5)
      ..lineTo(7.5, 7)
      ..arcToPoint(const Offset(16.5, 7), radius: const Radius.circular(4.5))
      ..lineTo(16.5, 10.5);
    canvas.drawPath(path, paint);

    // Keyhole dot
    canvas.drawCircle(const Offset(12, 16), 1.4,
        paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _PinDots extends StatelessWidget {
  final int filled;
  final int total;

  const _PinDots({required this.filled, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? Lk.text : Colors.transparent,
              border: Border.all(
                color: isFilled ? Lk.text : const Color(0x38FFFFFF),
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
