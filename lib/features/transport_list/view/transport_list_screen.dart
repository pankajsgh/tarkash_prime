import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../purchase_challan/model/transport_model.dart';
import '../controller/transport_list_controller.dart';

class TransportListScreen extends StatefulWidget {
  const TransportListScreen({super.key});

  @override
  State<TransportListScreen> createState() =>
      _TransportListScreenState();
}

class _TransportListScreenState extends State<TransportListScreen> {
  late final TransportListController controller;

  static const Color primary = Color(0xFF3267D5);
  static const Color background = Color(0xFFF4F6FA);
  static const Color border = Color(0xFFE5E9F0);
  static const Color textColor = Color(0xFF202939);
  static const Color muted = Color(0xFF7B8495);

  @override
  void initState() {
    super.initState();
    controller = TransportListController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _editTransport(TransportModel item) {
    // TODO: Open your existing edit screen.
    debugPrint('Edit transport ID: ${item.id}');
  }

  void _deleteTransport(TransportModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Transport'),
          content: Text(
            'Are you sure you want to delete ${item.transport}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                // TODO: Call your delete API here.
                debugPrint('Delete transport ID: ${item.id}');
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  return Column(
                    children: [
                      _buildSearch(),
                      Expanded(child: _buildBody()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// ==========================================================
// HEADER
// ==========================================================

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 13,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_shipping_outlined,
            color: primary,
            size: 23,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Transport List',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '${controller.totalData} Records',
              style: const TextStyle(
                fontSize: 11,
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ==========================================================
// SEARCH
// ==========================================================

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: const TextStyle(
          fontSize: 12,
          color: textColor,
        ),
        decoration: InputDecoration(
          hintText: 'Search transport...',
          hintStyle: const TextStyle(
            fontSize: 12,
            color: muted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 19,
            color: muted,
          ),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
            onPressed: controller.clearSearch,
            icon: const Icon(Icons.close, size: 17),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: const BorderSide(color: primary),
          ),
        ),
      ),
    );
  }

// ==========================================================
// BODY
// ==========================================================

  Widget _buildBody() {
    if (controller.isLoading && controller.transports.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
          strokeWidth: 2,
        ),
      );
    }

    if (controller.errorMessage.isNotEmpty &&
        controller.transports.isEmpty) {
      return _buildEmpty(
        'Unable to load transports',
        controller.errorMessage,
        true,
      );
    }

    if (controller.transports.isEmpty) {
      return _buildEmpty(
        'No records found',
        'No transport data available.',
        false,
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(10, 2, 10, 15),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            children: [
              _buildTableHeader(),

              ...List.generate(
                controller.transports.length,
                    (index) {
                  return _buildTableRow(
                    controller.transports[index],
                    index,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

// ==========================================================
// TABLE HEADER
// ==========================================================

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 11,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F4F8),
        border: Border(
          bottom: BorderSide(color: border),
        ),
      ),
      child: const Row(
        children: [
          SizedBox(width: 30, child: Text('#', style: _headerStyle)),
          Expanded(flex: 3, child: Text('Transport', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Owner', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Mobile', style: _headerStyle)),
          SizedBox(width: 65, child: Text('Action', style: _headerStyle)),
        ],
      ),
    );
  }
// ==========================================================
// TABLE ROW
// ==========================================================

  Widget _buildTableRow(TransportModel item, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDF0F4)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${index + 1}',
              style: _cellStyle.copyWith(color: muted),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              item.transport.trim().isEmpty ? '-' : item.transport.trim(),
              style: _cellStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.owner.trim().isEmpty ? '-' : item.owner.trim(),
              style: _cellStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              item.mobile.trim().isEmpty ? '-' : item.mobile.trim(),
              style: _cellStyle,
            ),
          ),
          SizedBox(
            width: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => _editTransport(item),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 17,
                      color: primary,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _deleteTransport(item),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Icon(
                      Icons.delete_outline,
                      size: 17,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
// ==========================================================
// EMPTY / ERROR
// ==========================================================

  Widget _buildEmpty(
      String title,
      String subtitle,
      bool showRetry,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.table_rows_outlined,
              size: 40,
              color: muted,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: muted,
              ),
            ),
            if (showRetry) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    fontSize: 10,
    color: Color(0xFF586477),
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _cellStyle = TextStyle(
    fontSize: 10,
    color: textColor,
    height: 1.4,
  );
}
