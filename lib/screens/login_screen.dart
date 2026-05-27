import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/keypad.dart';
import 'vault_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _pin = '';
  static const _max = 6;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8),  weight: 20),
      TweenSequenceItem(tween: Tween(begin: 8, end: -5),  weight: 20),
      TweenSequenceItem(tween: Tween(begin: -5, end: 5),  weight: 20),
      TweenSequenceItem(tween: Tween(begin: 5, end: 0),   weight: 20),
    ]).animate(_shakeCtrl);
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _press(String k) {
    if (k == 'del') {
      setState(() => _pin = _pin.isEmpty ? '' : _pin.substring(0, _pin.length - 1));
      return;
    }
    if (k == 'bio') {
      // Simulate biometric — go straight to vault
      _navigateToVault();
      return;
    }
    if (_pin.length >= _max) return;
    final next = _pin + k;
    setState(() => _pin = next);

    if (next.length == _max) {
      // Demo: any PIN accepted — shake briefly then navigate
      Future.delayed(const Duration(milliseconds: 220), () async {
        await _shakeCtrl.forward(from: 0);
        _shakeCtrl.reset();
        if (mounted) {
          setState(() => _pin = '');
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) _navigateToVault();
        }
      });
    }
  }

  void _navigateToVault() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const VaultDashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        KeypadKey.fingerprint(onTap: () => _press('bio')),
        KeypadKey.digit('0', onTap: () => _press('0')),
        KeypadKey.backspace(onTap: () => _press('del')),
      ],
    ];

    return Scaffold(
      backgroundColor: Lk.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Lk.l, 0, Lk.l, Lk.xl),
          child: Column(
            children: [
              // Status pill
              const SizedBox(height: Lk.s),
              _StatusPill(),
              // Brand mark
              const SizedBox(height: 56),
              _BrandMark(),
              const SizedBox(height: 40),
              // PIN dots with shake
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                ),
                child: _PinDots(filled: _pin.length, total: _max),
              ),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: Lk.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Lk.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Lk.accent,
              boxShadow: [BoxShadow(color: Lk.accent.withValues(alpha: 0.6), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'VAULT LOCKED',
            style: Lk.ui(11, FontWeight.w600, Lk.textDim, ls: 1.4),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Lk.lineStr),
          ),
          child: const Center(
            child: Icon(Icons.lock_outline, size: 20, color: Lk.text),
          ),
        ),
        const SizedBox(height: 14),
        Text('Locke', style: Lk.ui(18, FontWeight.w600, Lk.text, ls: -0.2)),
        const SizedBox(height: 4),
        Text('Enter your master PIN', style: Lk.ui(12, FontWeight.w400, Lk.textMute, ls: 0.2)),
      ],
    );
  }
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
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 10, height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFilled ? Lk.text : Colors.transparent,
              border: Border.all(
                color: isFilled ? Lk.text : Lk.lineStr,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
