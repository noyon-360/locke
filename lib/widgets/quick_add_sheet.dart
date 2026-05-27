import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme.dart';

// ── Password utilities ────────────────────────────────────────────────────────

String generatePassword() {
  const lower = 'abcdefghijkmnpqrstuvwxyz';
  const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  const nums  = '23456789';
  const syms  = r'!@#$%^&*-_=+';
  const all   = lower + upper + nums + syms;
  final rand  = Random.secure();

  final chars = [
    lower[rand.nextInt(lower.length)],
    upper[rand.nextInt(upper.length)],
    nums[rand.nextInt(nums.length)],
    syms[rand.nextInt(syms.length)],
    ...List.generate(12, (_) => all[rand.nextInt(all.length)]),
  ]..shuffle(rand);
  return chars.join();
}

({String label, double pct, Color color}) passwordStrength(String pw) {
  if (pw.isEmpty) return (label: '', pct: 0, color: Lk.textFaint);
  int score = 0;
  if (pw.length >= 8) score++;
  if (pw.length >= 14) score++;
  if (RegExp(r'[A-Z]').hasMatch(pw) && RegExp(r'[a-z]').hasMatch(pw)) score++;
  if (RegExp(r'\d').hasMatch(pw)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(pw)) score++;
  const levels = [
    (label: 'Weak',      pct: 0.25, color: Lk.danger),
    (label: 'Weak',      pct: 0.40, color: Lk.danger),
    (label: 'Fair',      pct: 0.55, color: Color(0xFFE8C58A)),
    (label: 'Good',      pct: 0.75, color: Color(0xFFE8C58A)),
    (label: 'Strong',    pct: 0.90, color: Lk.accent),
    (label: 'Excellent', pct: 1.00, color: Lk.accent),
  ];
  return levels[score];
}

// ── Sheet widget ──────────────────────────────────────────────────────────────

class QuickAddSheet extends StatefulWidget {
  final bool open;
  final VoidCallback onClose;

  const QuickAddSheet({super.key, required this.open, required this.onClose});

  @override
  State<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends State<QuickAddSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  final _titleCtrl = TextEditingController();
  final _userCtrl  = TextEditingController();
  final _pwCtrl    = TextEditingController();
  bool _showPw     = false;
  bool _genSpin    = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
    _slide = Tween(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    if (widget.open) _ctrl.forward();
  }

  @override
  void didUpdateWidget(QuickAddSheet old) {
    super.didUpdateWidget(old);
    if (widget.open && !old.open) {
      _ctrl.forward();
    } else if (!widget.open && old.open) {
      _ctrl.reverse().then((_) {
        _titleCtrl.clear();
        _userCtrl.clear();
        _pwCtrl.clear();
        if (mounted) setState(() { _showPw = false; _genSpin = false; });
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _titleCtrl.dispose();
    _userCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  void _generate() {
    _pwCtrl.text = generatePassword();
    setState(() { _showPw = true; _genSpin = true; });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _genSpin = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pw = _pwCtrl.text;
    final canSave = _titleCtrl.text.trim().isNotEmpty &&
        _userCtrl.text.trim().isNotEmpty &&
        pw.trim().isNotEmpty;
    final st = passwordStrength(pw);

    return Stack(
      children: [
        // Scrim with blur
        FadeTransition(
          opacity: _fade,
          child: GestureDetector(
            onTap: widget.onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Lk.scrim),
            ),
          ),
        ),

        // Sheet
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _slide,
            child: Container(
              decoration: const BoxDecoration(
                color: Lk.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top:   BorderSide(color: Lk.line),
                  left:  BorderSide(color: Lk.line),
                  right: BorderSide(color: Lk.line),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Grab handle
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 38, height: 4,
                      decoration: BoxDecoration(
                        color: Lk.lineStr,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Entry', style: Lk.ui(17, FontWeight.w700, Lk.text, ls: -0.3)),
                        _CloseBtn(onTap: widget.onClose),
                      ],
                    ),
                  ),
                  // Form
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormField(
                          label: 'APP / SERVICE',
                          placeholder: 'e.g. GitHub',
                          controller: _titleCtrl,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          label: 'USERNAME / EMAIL',
                          placeholder: 'you@example.com',
                          controller: _userCtrl,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 16),
                        _PasswordField(
                          controller: _pwCtrl,
                          showPw: _showPw,
                          genSpin: _genSpin,
                          onToggleVisibility: () => setState(() => _showPw = !_showPw),
                          onGenerate: _generate,
                          onChanged: (_) => setState(() {}),
                        ),
                        // Strength meter
                        AnimatedOpacity(
                          opacity: pw.isNotEmpty ? 1 : 0,
                          duration: const Duration(milliseconds: 180),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: Stack(children: [
                                      Container(height: 3, color: Lk.line),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        height: 3,
                                        width: double.infinity,
                                        alignment: Alignment.centerLeft,
                                        child: FractionallySizedBox(
                                          widthFactor: st.pct,
                                          child: Container(color: st.color),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                SizedBox(
                                  width: 56,
                                  child: Text(
                                    st.label,
                                    textAlign: TextAlign.right,
                                    style: Lk.ui(11, FontWeight.w600, st.color, ls: 0.2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: canSave ? Lk.accent : Lk.surfaceHi,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: canSave ? widget.onClose : null,
                          child: Center(
                            child: Text(
                              'Save to Locke',
                              style: Lk.ui(15, FontWeight.w700,
                                  canSave ? Lk.accentInk : Lk.textMute, ls: -0.1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CloseBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: Lk.surfaceHi,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.close, size: 16, color: Lk.textDim),
      ),
    );
  }
}

class _FormField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _FormField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> {
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Lk.ui(11, FontWeight.w600, Lk.textMute, ls: 1.4)),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 48,
          decoration: BoxDecoration(
            color: Lk.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _focus ? Lk.lineStr : Lk.line),
          ),
          child: TextField(
            controller: widget.controller,
            onChanged: widget.onChanged,
            onTap: () => setState(() => _focus = true),
            onTapOutside: (_) => setState(() => _focus = false),
            style: Lk.ui(14, FontWeight.w400, Lk.text, ls: -0.1),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: Lk.ui(14, FontWeight.w400, Lk.textMute),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool showPw;
  final bool genSpin;
  final VoidCallback onToggleVisibility;
  final VoidCallback onGenerate;
  final ValueChanged<String> onChanged;

  const _PasswordField({
    required this.controller,
    required this.showPw,
    required this.genSpin,
    required this.onToggleVisibility,
    required this.onGenerate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PASSWORD', style: Lk.ui(11, FontWeight.w600, Lk.textMute, ls: 1.4)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Lk.bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Lk.line),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  obscureText: !showPw,
                  style: showPw
                      ? Lk.mono(14, FontWeight.w400, Lk.text, ls: 0.4)
                      : Lk.ui(14, FontWeight.w400, Lk.text),
                  decoration: InputDecoration(
                    hintText: '••••••••••••',
                    hintStyle: Lk.ui(14, FontWeight.w400, Lk.textMute),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              // Eye toggle
              IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  showPw ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 17,
                  color: Lk.textDim,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              // Generate button
              GestureDetector(
                onTap: onGenerate,
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedRotation(
                        turns: genSpin ? 0.5 : 0,
                        duration: const Duration(milliseconds: 400),
                        child: const Icon(Icons.refresh, size: 13, color: Lk.accent),
                      ),
                      const SizedBox(width: 6),
                      Text('Generate',
                          style: Lk.ui(12.5, FontWeight.w700, Lk.accent, ls: 0.4)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
