import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

InputDecoration dec(String label, {String? hint, String? prefix, String? suffix}) => InputDecoration(
      labelText: label,
      hintText: hint,
      prefixText: prefix,
      suffixText: suffix,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
    );

/// Compact field used inside the item grid (no floating label).
InputDecoration cellDec(String hint) => InputDecoration(
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    );

class Panel extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  const Panel({
    super.key,
    this.title,
    this.trailing,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink)),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: const TextStyle(color: AppColors.muted)),
                ),
            ],
          ),
        ),
        Wrap(spacing: 8, runSpacing: 8, children: actions),
      ],
    );
  }
}

class KpiCard extends StatelessWidget {
  final String label, value;
  final String? sub;
  final IconData icon;
  final Color color;
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    required this.icon,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color.withAlpha(28), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                ),
                if (sub != null) Text(sub!, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays cards out in a responsive grid (4, 2 or 1 per row).
Widget kpiGrid(List<Widget> cards) {
  return LayoutBuilder(
    builder: (context, c) {
      final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 560 ? 2 : 1);
      final w = (c.maxWidth - 16 * (cols - 1)) / cols;
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [for (final k in cards) SizedBox(width: w, child: k)],
      );
    },
  );
}

class HScroll extends StatelessWidget {
  final double minWidth;
  final Widget child;
  const HScroll({super.key, required this.minWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: math.max(c.maxWidth, minWidth), child: child),
      ),
    );
  }
}

class Col {
  final String label;
  final double? width; // null = takes the remaining space
  final bool right;
  const Col(this.label, {this.width, this.right = false});
}

class DataGrid extends StatelessWidget {
  final List<Col> cols;
  final List<List<Widget>> rows;
  final List<VoidCallback?>? onTap;
  final double minWidth;

  const DataGrid({
    super.key,
    required this.cols,
    required this.rows,
    this.onTap,
    this.minWidth = 820,
  });

  Widget _cell(Col c, Widget w) {
    final aligned = Align(alignment: c.right ? Alignment.centerRight : Alignment.centerLeft, child: w);
    final padded = Padding(padding: const EdgeInsets.only(right: 10), child: aligned);
    return c.width != null ? SizedBox(width: c.width, child: padded) : Expanded(child: padded);
  }

  @override
  Widget build(BuildContext context) {
    final header = Container(
      color: AppColors.headerFill,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          for (final c in cols)
            _cell(
              c,
              Text(
                c.label.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted, letterSpacing: 0.4),
              ),
            ),
        ],
      ),
    );

    return HScroll(
      minWidth: minWidth,
      child: Column(
        children: [
          header,
          const Divider(height: 1),
          for (var r = 0; r < rows.length; r++) ...[
            InkWell(
              onTap: onTap != null ? onTap![r] : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                child: Row(
                  children: [for (var i = 0; i < cols.length; i++) _cell(cols[i], rows[r][i])],
                ),
              ),
            ),
            const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class BarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> values;
  final String Function(double) fmt;
  const BarChart({super.key, required this.labels, required this.values, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final maxV = values.fold<double>(0, (a, b) => math.max(a, b));
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(fmt(values[i]), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    const SizedBox(height: 4),
                    Container(
                      height: maxV <= 0 ? 2 : math.max(2.0, 150 * values[i] / maxV),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(labels[i], style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Scrolling page body with a readable maximum width, centred in the window.
class PageScroll extends StatelessWidget {
  final List<Widget> children;
  const PageScroll({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: children,
        ),
      ),
    );
  }
}

Widget emptyState(IconData icon, String message) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.muted),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
          ],
        ),
      ),
    );
