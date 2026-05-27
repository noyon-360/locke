import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

// ── Key variants ─────────────────────────────────────────────────────────────

enum KeyType { digit, fingerprint, backspace, proceed, cancel }

class KeypadKey extends StatefulWidget {
  final String digit;        // '0'..'9'
  final String? subLabel;    // 'ABC', 'DEF' …
  final KeyType type;
  final VoidCallback? onTap;
  final bool enabled;

  const KeypadKey.digit(
    this.digit, {
    super.key,
    this.subLabel,
    required this.onTap,
    this.enabled = true,
  }) : type = KeyType.digit;

  const KeypadKey.fingerprint({super.key, required this.onTap})
      : digit = '',
        subLabel = null,
        type = KeyType.fingerprint,
        enabled = true;

  const KeypadKey.backspace({super.key, required this.onTap})
      : digit = '',
        subLabel = null,
        type = KeyType.backspace,
        enabled = true;

  const KeypadKey.proceed({super.key, required this.onTap, required this.enabled})
      : digit = '',
        subLabel = null,
        type = KeyType.proceed;

  const KeypadKey.cancel({super.key, required this.onTap, required this.enabled})
      : digit = '',
        subLabel = null,
        type = KeyType.cancel;

  @override
  State<KeypadKey> createState() => _KeypadKeyState();
}

class _KeypadKeyState extends State<KeypadKey> {
  bool _pressed = false;

  void _onDown(_) {
    if (!widget.enabled) return;
    setState(() => _pressed = true);
  }

  void _onUp(_) {
    setState(() => _pressed = false);
    if (widget.enabled) widget.onTap?.call();
  }

  void _onCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onDown,
      onTapUp: _onUp,
      onTapCancel: _onCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        height: 64,
        decoration: BoxDecoration(
          color: _pressed && widget.enabled ? Lk.surfaceHi : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Transform.scale(
          scale: _pressed && widget.enabled ? 0.97 : 1.0,
          child: Center(child: _buildContent()),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (widget.type) {
      case KeyType.digit:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.digit, style: Lk.mono(26, FontWeight.w400, Lk.text)),
            if (widget.subLabel != null && widget.subLabel!.isNotEmpty)
              Text(
                widget.subLabel!,
                style: Lk.ui(9, FontWeight.w600, Lk.textMute, ls: 1.4),
              ),
          ],
        );

      case KeyType.fingerprint:
        return Icon(Icons.fingerprint, size: 28, color: Lk.accent);

      case KeyType.backspace:
        return Icon(Icons.backspace_outlined, size: 22, color: Lk.textDim);

      case KeyType.proceed:
        final col = widget.enabled ? Lk.accent : Lk.accent.withValues(alpha: 0.35);
        return Icon(Icons.arrow_forward_rounded, size: 26, color: col);

      case KeyType.cancel:
        final col = widget.enabled ? Lk.accent : Lk.accent.withValues(alpha: 0.35);
        return Text('Cancel', style: Lk.ui(16, FontWeight.w600, col, ls: -0.1));
    }
  }
}

// ── Shared keypad grid ────────────────────────────────────────────────────────

class PinKeypad extends StatelessWidget {
  final List<List<KeypadKey>> rows;

  const PinKeypad({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: row.map((key) {
              return Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: key,
              ));
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
