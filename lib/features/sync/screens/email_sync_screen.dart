import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

bool _isValidEmail(String s) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$').hasMatch(s.trim());

class EmailSyncScreen extends StatefulWidget {
  const EmailSyncScreen({super.key});

  @override
  State<EmailSyncScreen> createState() => _EmailSyncScreenState();
}

class _EmailSyncScreenState extends State<EmailSyncScreen> {
  final _ctrl = TextEditingController();
  bool _focus = false;
  bool _sent  = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_isValidEmail(_ctrl.text) || _sent) return;
    setState(() => _sent = true);
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _sent = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = _ctrl.text;
    final valid = _isValidEmail(email);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Lk.l, 0, Lk.l, Lk.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Lk.textDim, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
              // Hero block
              const SizedBox(height: Lk.xxl),
              Center(
                child: Column(
                  children: [
                    const _PaperPlaneIcon(),
                    const SizedBox(height: Lk.xl),
                    Text(
                      'Sync Your Locke',
                      style: Lk.ui(24, FontWeight.w700, Lk.text, ls: -0.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Lk.m),
                    SizedBox(
                      width: 300,
                      child: Text(
                        'Enter your email to pair devices and securely sync your '
                        'offline data via a passwordless magic link.',
                        style: Lk.ui(13, FontWeight.w400, Lk.textDim, ls: -0.05),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Lk.xxl),
              // Email label
              Text('EMAIL', style: Lk.ui(11, FontWeight.w600, Lk.textMute, ls: 1.4)),
              const SizedBox(height: 6),
              // Email input card
              AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                height: 56,
                decoration: BoxDecoration(
                  color: Lk.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _focus ? Lk.lineStr : Lk.line),
                  boxShadow: _focus
                      ? [BoxShadow(color: Colors.white.withValues(alpha: 0.04), blurRadius: 0, spreadRadius: 3)]
                      : [],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    // @ glyph
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 140),
                      style: Lk.mono(16, FontWeight.w500,
                          valid ? Lk.accent : Lk.textMute),
                      child: const Text('@'),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        enableSuggestions: false,
                        onChanged: (_) => setState(() {}),
                        onTap: () => setState(() => _focus = true),
                        onTapOutside: (_) => setState(() => _focus = false),
                        style: Lk.mono(15, FontWeight.w500, Lk.text, ls: 0.1),
                        decoration: InputDecoration(
                          hintText: 'your@example.com',
                          hintStyle: Lk.mono(15, FontWeight.w400, Lk.textMute),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    // Inline validity check
                    AnimatedOpacity(
                      opacity: valid ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: AnimatedScale(
                        scale: valid ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 180),
                        child: const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.check, size: 17, color: Lk.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Helper line
              const SizedBox(height: 6),
              SizedBox(
                height: 14,
                child: email.isNotEmpty && !valid
                    ? Text('Enter a valid email address.',
                        style: Lk.ui(11.5, FontWeight.w400, Lk.danger, ls: -0.05))
                    : Text('End-to-end encrypted · we never see your vault contents.',
                        style: Lk.ui(11.5, FontWeight.w400, Lk.textMute, ls: -0.05)),
              ),
              const Spacer(),
              // Primary action button
              GestureDetector(
                onTap: _submit,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: valid ? Lk.text : Lk.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: valid ? Lk.accent : Lk.line,
                    ),
                    boxShadow: valid
                        ? [BoxShadow(color: Lk.accent.withValues(alpha: 0.10), blurRadius: 0, spreadRadius: 3)]
                        : [],
                  ),
                  child: Center(
                    child: _sent
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, size: 18, color: Lk.accent),
                              const SizedBox(width: 10),
                              Text('Magic link sent — check your inbox',
                                  style: Lk.ui(15, FontWeight.w700, Lk.bg, ls: -0.1)),
                            ],
                          )
                        : Text(
                            'Send Magic Link',
                            style: Lk.ui(15, FontWeight.w700,
                                valid ? Lk.bg : Lk.textMute, ls: -0.1),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Secondary skip
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: SizedBox(
                    height: 36,
                    child: Center(
                      child: Text(
                        'Skip — keep this vault local only',
                        style: Lk.ui(13, FontWeight.w500, Lk.textMute, ls: -0.05),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Paper-plane icon ──────────────────────────────────────────────────────────

class _PaperPlaneIcon extends StatelessWidget {
  const _PaperPlaneIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 56, height: 56,
      child: CustomPaint(painter: _PlanePainter()),
    );
  }
}

class _PlanePainter extends CustomPainter {
  const _PlanePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4D7DC)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final s = size.width / 24;
    canvas.scale(s, s);

    // Body of plane
    final body = Path()
      ..moveTo(21, 3)
      ..lineTo(3, 10.2)
      ..lineTo(10, 13)
      ..lineTo(13, 20)
      ..close();
    canvas.drawPath(body, paint);

    // Tail line
    final tail = Path()
      ..moveTo(10, 13)
      ..lineTo(21, 3);
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
