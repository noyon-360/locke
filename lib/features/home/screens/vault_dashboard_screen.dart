import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';
import '../../auth/models/locke_entry.dart';
import 'quick_add_sheet.dart';
import '../../sync/screens/email_sync_screen.dart';

// ── Username obfuscation ──────────────────────────────────────────────────────

String _obscure(String s) {
  if (s.isEmpty) return '';
  if (s.contains('@')) {
    final at    = s.indexOf('@');
    final u     = s.substring(0, at);
    final d     = s.substring(at);
    final dots  = '•' * min(u.length - 2, 6);
    final masked = u.length <= 3 ? '•' * u.length : '${u.substring(0, 2)}$dots';
    return '$masked$d';
  }
  if (s.length <= 3) return '•' * s.length;
  return '${s.substring(0, 2)}${'•' * min(s.length - 2, 8)}';
}

// ── Screen ────────────────────────────────────────────────────────────────────

class VaultDashboardScreen extends StatefulWidget {
  const VaultDashboardScreen({super.key});

  @override
  State<VaultDashboardScreen> createState() => _VaultDashboardScreenState();
}

class _VaultDashboardScreenState extends State<VaultDashboardScreen> {
  final _searchCtrl = TextEditingController();
  String _query     = '';
  final _revealed   = <String, bool>{};
  String? _toast;
  bool _sheetOpen   = false;
  bool _fabPressed  = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<LockeEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kVaultSeed;
    return kVaultSeed.where((e) =>
        e.title.toLowerCase().contains(q) ||
        e.username.toLowerCase().contains(q)).toList();
  }

  void _copy(LockeEntry e) {
    Clipboard.setData(ClipboardData(text: e.password));
    setState(() => _toast = 'Password copied · ${e.title}');
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: Lk.bg,
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────
          Column(
            children: [
              // Header
              _DashboardHeader(
                count: kVaultSeed.length,
                query: _query,
                searchCtrl: _searchCtrl,
                onQueryChanged: (q) => setState(() => _query = q),
                onClearQuery: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
                onEmailSync: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmailSyncScreen()),
                ),
              ),
              // List
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          'No entries match "$_query"',
                          style: Lk.ui(13, FontWeight.w400, Lk.textMute),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1, thickness: 1, color: Lk.line,
                        ),
                        itemBuilder: (_, i) {
                          final item = items[i];
                          return _VaultRow(
                            item: item,
                            revealed: _revealed[item.id] ?? false,
                            onToggleReveal: () => setState(() =>
                                _revealed[item.id] = !(_revealed[item.id] ?? false)),
                            onCopy: () => _copy(item),
                          );
                        },
                      ),
              ),
            ],
          ),

          // ── FAB ───────────────────────────────────────────────────
          Positioned(
            right: 22, bottom: 32,
            child: GestureDetector(
              onTapDown: (_) => setState(() => _fabPressed = true),
              onTapUp: (_) {
                setState(() { _fabPressed = false; _sheetOpen = true; });
              },
              onTapCancel: () => setState(() => _fabPressed = false),
              child: AnimatedScale(
                scale: _fabPressed ? 0.94 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Lk.accent,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(color: Color(0x47A8D5B7), blurRadius: 32, offset: Offset(0, 12)),
                      BoxShadow(color: Color(0x66000000), blurRadius: 6,  offset: Offset(0, 2)),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Lk.accentInk, size: 24),
                ),
              ),
            ),
          ),

          // ── Toast ─────────────────────────────────────────────────
          if (_toast != null)
            Positioned(
              bottom: 110, left: 0, right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Lk.text,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 15, color: Lk.bg),
                      const SizedBox(width: 8),
                      Text(_toast!, style: Lk.ui(13, FontWeight.w600, Lk.bg, ls: -0.1)),
                    ],
                  ),
                ),
              ),
            ),

          // ── Quick-Add sheet ────────────────────────────────────────
          if (_sheetOpen)
            QuickAddSheet(
              open: _sheetOpen,
              onClose: () => setState(() => _sheetOpen = false),
            ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _DashboardHeader extends StatelessWidget {
  final int count;
  final String query;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final VoidCallback onEmailSync;

  const _DashboardHeader({
    required this.count,
    required this.query,
    required this.searchCtrl,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onEmailSync,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Lk.bg,
        border: Border(bottom: BorderSide(color: Lk.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        Lk.l,
        MediaQuery.of(context).padding.top + 16,
        Lk.l,
        12,
      ),
      child: Column(
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Locke', style: Lk.ui(26, FontWeight.w700, Lk.text, ls: -0.5)),
              const SizedBox(width: 10),
              Text('$count', style: Lk.ui(13, FontWeight.w500, Lk.textMute)),
              const Spacer(),
              // Email sync icon
              GestureDetector(
                onTap: onEmailSync,
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.sync_outlined, size: 18, color: Lk.textDim),
                ),
              ),
              const SizedBox(width: 12),
              // Unlocked pill
              Container(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: BoxDecoration(
                  color: Lk.accentSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 11, color: Lk.accent),
                    const SizedBox(width: 6),
                    Text('Unlocked',
                        style: Lk.ui(10, FontWeight.w700, Lk.accent, ls: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Lk.m),
          // Search bar
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Lk.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Lk.line),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search, size: 15, color: Lk.textMute),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: searchCtrl,
                    onChanged: onQueryChanged,
                    style: Lk.ui(14, FontWeight.w400, Lk.text, ls: -0.1),
                    decoration: InputDecoration(
                      hintText: 'Search vault',
                      hintStyle: Lk.ui(14, FontWeight.w400, Lk.textMute),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                if (query.isNotEmpty) ...[
                  IconButton(
                    onPressed: onClearQuery,
                    icon: const Icon(Icons.close, size: 15, color: Lk.textMute),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32),
                  ),
                ],
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list_rounded, size: 16, color: Lk.textDim),
                  padding: const EdgeInsets.only(right: 4),
                  constraints: const BoxConstraints(minWidth: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Row ───────────────────────────────────────────────────────────────────────

class _VaultRow extends StatefulWidget {
  final LockeEntry item;
  final bool revealed;
  final VoidCallback onToggleReveal;
  final VoidCallback onCopy;

  const _VaultRow({
    required this.item,
    required this.revealed,
    required this.onToggleReveal,
    required this.onCopy,
  });

  @override
  State<_VaultRow> createState() => _VaultRowState();
}

class _VaultRowState extends State<_VaultRow> {
  bool _copied = false;

  void _handleCopy() {
    setState(() => _copied = true);
    widget.onCopy();
    Future.delayed(const Duration(milliseconds: 1200),
        () { if (mounted) setState(() => _copied = false); });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final avatarColor = HSLColor.fromAHSL(1, item.hue.toDouble(), 0.5, 0.78).toColor();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Row(
        children: [
          // Monogram avatar
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Lk.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Lk.lineStr),
            ),
            child: Center(
              child: Text(
                item.title[0],
                style: Lk.ui(14, FontWeight.w600, avatarColor, ls: -0.2),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Title + username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  overflow: TextOverflow.ellipsis,
                  style: Lk.ui(15, FontWeight.w600, Lk.text, ls: -0.2),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.revealed ? item.username : _obscure(item.username),
                  overflow: TextOverflow.ellipsis,
                  style: widget.revealed
                      ? Lk.mono(12, FontWeight.w400, Lk.textDim)
                      : Lk.ui(12, FontWeight.w400, Lk.textDim, ls: -0.1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Eye toggle
          _RowBtn(
            onTap: widget.onToggleReveal,
            active: widget.revealed,
            child: Icon(
              widget.revealed
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 17,
              color: widget.revealed ? Lk.text : Lk.textDim,
            ),
          ),
          const SizedBox(width: 4),
          // Copy button
          _RowBtn(
            onTap: _handleCopy,
            active: _copied,
            accent: _copied,
            child: Icon(
              _copied ? Icons.check : Icons.content_copy_outlined,
              size: 17,
              color: _copied ? Lk.accent : Lk.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _RowBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool active;
  final bool accent;

  const _RowBtn({
    required this.child,
    required this.onTap,
    this.active = false,
    this.accent = false,
  });

  @override
  State<_RowBtn> createState() => _RowBtnState();
}

class _RowBtnState extends State<_RowBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.transparent;
    if (widget.active) {
      bg = widget.accent ? Lk.accentSoft : Lk.surfaceHi;
    } else if (_hover) {
      bg = Lk.surface;
    }

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hover = true),
      onTapUp: (_) => setState(() => _hover = false),
      onTapCancel: () => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(child: widget.child),
      ),
    );
  }
}
