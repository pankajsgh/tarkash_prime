
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../controller/log_controller.dart';
import '../model/logs_model.dart';

class LogListScreen extends StatefulWidget {
  final String invId;
  final String challanNo;
  final String? title;

  const LogListScreen({
    super.key,
    required this.invId,
    required this.challanNo,
    this.title,
  });

  @override
  State<LogListScreen> createState() => _LogListScreenState();
}

class _LogListScreenState extends State<LogListScreen> {
  late final LogController controller;

  static const Color primaryColor = themeColor;
  static const Color pageColor = Color(0xFFF4F6FA);

  @override
  void initState() {
    super.initState();
    controller = LogController(invId: widget.invId);
    controller.fetchLogs();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      appBar: AppBar(
        title: Text(widget.title ?? 'Log History'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Challan No: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.challanNo,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                if (controller.isLoading && controller.logs.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryColor,
                    ),
                  );
                }

                if (controller.errorMessage.isNotEmpty &&
                    controller.logs.isEmpty) {
                  return _EmptyState(
                    icon: Icons.error_outline,
                    message: controller.errorMessage,
                    buttonText: 'Retry',
                    onPressed: controller.fetchLogs,
                  );
                }

                if (controller.logs.isEmpty) {
                  return _EmptyState(
                    icon: Icons.history,
                    message: 'No log history found for this document.',
                    buttonText: 'Refresh',
                    onPressed: controller.fetchLogs,
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.fetchLogs,
                  color: primaryColor,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: controller.logs.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final log = controller.logs[index];

                      // Newest first; next entry is older.
                      final previousLog =
                      index + 1 < controller.logs.length
                          ? controller.logs[index + 1]
                          : null;

                      return _LogCard(
                        log: log,
                        previousLog: previousLog,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NORMALIZE JSON FOR COMPARISON
// ============================================================

dynamic _normalizeForComparison(dynamic value) {
  if (value is Map) {
    final result = <String, dynamic>{};
    final keys = value.keys
        .map((key) => key.toString())
        .where((key) => key.toLowerCase() != 'id')
        .toList()
      ..sort();

    for (final key in keys) {
      final originalKey = value.keys.firstWhere(
            (item) => item.toString() == key,
      );

      result[key] = _normalizeForComparison(value[originalKey]);
    }

    return result;
  }

  if (value is List) {
    final result = value
        .map(_normalizeForComparison)
        .toList();

    // List order should not create false changes.
    result.sort(
          (a, b) => jsonEncode(a).compareTo(jsonEncode(b)),
    );

    return result;
  }

  if (value is String) {
    final trimmed = value.trim();

    // Decode JSON embedded inside a string.
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        return _normalizeForComparison(jsonDecode(trimmed));
      } catch (_) {
        // Not valid embedded JSON; compare as text.
      }
    }

    final number = num.tryParse(trimmed);

    if (trimmed.isNotEmpty && number != null) {
      return number;
    }

    return trimmed;
  }

  return value;
}

// ============================================================
// REMOVE IDS FROM DISPLAYED JSON
// ============================================================

dynamic _removeIdFields(dynamic value) {
  if (value is Map) {
    final result = <String, dynamic>{};

    value.forEach((key, item) {
      if (key.toString().toLowerCase() == 'id') return;
      result[key.toString()] = _removeIdFields(item);
    });

    return result;
  }

  if (value is List) {
    return value.map(_removeIdFields).toList();
  }

  return value;
}

// ============================================================
// COMPARE SNAPSHOTS
// ============================================================

Map<String, Map<String, dynamic>> compareJsonData(
    String previousJson,
    String currentJson,
    ) {
  dynamic previous;
  dynamic current;

  try {
    previous = _normalizeForComparison(jsonDecode(previousJson));
    current = _normalizeForComparison(jsonDecode(currentJson));
  } catch (_) {
    return {};
  }

  if (previous is! Map || current is! Map) return {};

  final changes = <String, Map<String, dynamic>>{};

  void compare(
      Map oldMap,
      Map newMap, [
        String prefix = '',
      ]) {
    final keys = <String>{
      ...oldMap.keys.map((key) => key.toString()),
      ...newMap.keys.map((key) => key.toString()),
    }..removeWhere((key) => key.toLowerCase() == 'id');

    for (final key in keys) {
      final path = prefix.isEmpty ? key : '$prefix.$key';

      final oldValue = oldMap.containsKey(key)
          ? oldMap[key]
          : _MissingValue.instance;

      final newValue = newMap.containsKey(key)
          ? newMap[key]
          : _MissingValue.instance;

      if (oldValue is Map && newValue is Map) {
        compare(oldValue, newValue, path);
      } else if (!_valuesEqual(oldValue, newValue)) {
        changes[path] = {
          'old': oldValue,
          'new': newValue,
        };
      }
    }
  }

  compare(previous, current);
  return changes;
}

bool _valuesEqual(dynamic first, dynamic second) {
  if (identical(first, _MissingValue.instance) ||
      identical(second, _MissingValue.instance)) {
    return identical(first, second);
  }

  return jsonEncode(_normalizeForComparison(first)) ==
      jsonEncode(_normalizeForComparison(second));
}

String _displayValue(dynamic value) {
  if (identical(value, _MissingValue.instance)) {
    return '(not present)';
  }

  if (value == null) return 'null';

  if (value is Map || value is List) {
    return const JsonEncoder.withIndent('  ')
        .convert(_removeIdFields(value));
  }

  if (value.toString().isEmpty) return '(empty)';

  return value.toString();
}

class _MissingValue {
  const _MissingValue._();

  static const instance = _MissingValue._();
}

// ============================================================
// LOG CARD
// ============================================================

class _LogCard extends StatelessWidget {
  final LogModel log;
  final LogModel? previousLog;

  const _LogCard({
    required this.log,
    this.previousLog,
  });

  static const Color primaryColor = Color(0xFF3267D5);

  @override
  Widget build(BuildContext context) {
    final action = log.action.trim().isEmpty
        ? 'update'
        : log.action.trim();

    final normalizedAction = action.toLowerCase();
    final isCreate = normalizedAction == 'create';
    final isDelete = normalizedAction == 'delete';

    final actionColor = isCreate
        ? Colors.green.shade700
        : isDelete
        ? Colors.red.shade700
        : primaryColor;

    final hasPreviousSnapshot =
        previousLog != null &&
            previousLog!.newData.trim().isNotEmpty &&
            log.newData.trim().isNotEmpty;

    final changes = hasPreviousSnapshot
        ? compareJsonData(
      previousLog!.newData,
      log.newData,
    )
        : <String, Map<String, dynamic>>{};

    final hasRealChanges = changes.isNotEmpty;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        leading: CircleAvatar(
          radius: 19,
          backgroundColor: actionColor.withValues(alpha: 0.10),
          child: Icon(
            isCreate
                ? Icons.add
                : isDelete
                ? Icons.delete_outline
                : Icons.edit_outlined,
            color: actionColor,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                log.description.isNotEmpty
                    ? log.description
                    : '${log.type.isEmpty ? 'Document' : log.type} $action',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                action.toUpperCase(),
                style: TextStyle(
                  color: actionColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            [
              if (log.type.isNotEmpty) log.type,
              if (log.uid.isNotEmpty) 'User: ${log.uid}',
              if (log.createdAt.isNotEmpty) log.createdAt,
            ].join('  •  '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ),
        children: [
          if (hasPreviousSnapshot && !hasRealChanges) ...[
            const _InfoMessage(
              message: 'No meaningful changes found.',
            ),
            const SizedBox(height: 8),
            _JsonSection(
              title: 'Data',
              value: log.newData,
            ),
          ] else if (hasPreviousSnapshot && hasRealChanges) ...[
            _SectionHeading(
              icon: Icons.compare_arrows,
              title: 'Changes from previous log',
              trailing: '${changes.length} changed',
            ),
            const SizedBox(height: 8),
            ...changes.entries.map(
                  (entry) => _ChangeRow(
                field: entry.key,
                oldValue: entry.value['old'],
                newValue: entry.value['new'],
              ),
            ),
          ] else ...[
            const _SectionHeading(
              icon: Icons.info_outline,
              title: 'Snapshot details',
            ),
            const SizedBox(height: 8),
            if (log.newData.trim().isNotEmpty)
              _JsonSection(
                title: 'Data',
                value: log.newData,
              )
            else if (log.oldData.trim().isNotEmpty)
              _JsonSection(
                title: 'Data',
                value: log.oldData,
              ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// CHANGE ROW
// ============================================================

class _ChangeRow extends StatelessWidget {
  final String field;
  final dynamic oldValue;
  final dynamic newValue;

  const _ChangeRow({
    required this.field,
    required this.oldValue,
    required this.newValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E7F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF303846),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ValueBox(
                  label: 'Previous',
                  value: _displayValue(oldValue),
                  color: Colors.red.shade700,
                  background: const Color(0xFFFFF0F0),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 14,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.black45,
                ),
              ),
              Expanded(
                child: _ValueBox(
                  label: 'Current',
                  value: _displayValue(newValue),
                  color: Colors.green.shade700,
                  background: const Color(0xFFEFFAF2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color background;

  const _ValueBox({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              color: Color(0xFF252B36),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION HEADING
// ============================================================

class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;

  const _SectionHeading({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF3267D5),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
      ],
    );
  }
}

// ============================================================
// JSON DETAILS
// ============================================================

class _JsonSection extends StatelessWidget {
  final String title;
  final String value;

  const _JsonSection({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    String formatted = value;

    try {
      formatted = const JsonEncoder.withIndent('  ')
          .convert(_removeIdFields(jsonDecode(value)));
    } catch (_) {
      // Keep original text when it is not valid JSON.
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E7F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3267D5),
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            formatted,
            style: const TextStyle(
              fontSize: 11,
              height: 1.45,
              fontFamily: 'monospace',
              color: Color(0xFF252B36),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO MESSAGE
// ============================================================

class _InfoMessage extends StatelessWidget {
  final String message;

  const _InfoMessage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.black54,
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
