
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widget/transport_field.dart';
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      color: Colors.white,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transport Directory',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Manage and view transport details',
                  style: TextStyle(fontSize: 11, color: muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${controller.totalData} records',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 8),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search transport, owner, mobile, location...',
          hintStyle: const TextStyle(fontSize: 12, color: muted),
          prefixIcon: const Icon(Icons.search, color: primary, size: 21),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
            onPressed: controller.clearSearch,
            icon: const Icon(Icons.close, size: 19),
          )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primary),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading && controller.transports.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
          strokeWidth: 2.5,
        ),
      );
    }

    if (controller.errorMessage.isNotEmpty &&
        controller.transports.isEmpty) {
      return _buildMessage(
        icon: Icons.cloud_off_outlined,
        title: 'Unable to load transports',
        subtitle: controller.errorMessage,
        action: true,
      );
    }

    if (controller.transports.isEmpty) {
      return _buildMessage(
        icon: Icons.local_shipping_outlined,
        title: 'No transports found',
        subtitle: 'Try searching with another keyword.',
      );
    }

    return RefreshIndicator(
      color: primary,
      onRefresh: controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
        itemCount: controller.transports.length,
        itemBuilder: (context, index) {
          return _transportCard(controller.transports[index]);
        },
      ),
    );
  }

  Widget _transportCard(TransportModel transport) {
    final location = transport.location.trim();
    final address = transport.address.trim();
    final owner = transport.owner.trim();
    final mobile = transport.mobile.trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE9EDF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transport.transport.trim().isEmpty
                          ? 'Unnamed Transport'
                          : transport.transport,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (owner.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        owner,
                        style: const TextStyle(
                          fontSize: 11,
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${transport.id}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          if (mobile.isNotEmpty ||
              location.isNotEmpty ||
              address.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Color(0xFFEDF0F5)),
            ),
            Wrap(
              spacing: 16,
              runSpacing: 9,
              children: [
                if (mobile.isNotEmpty)
                  _infoItem(
                    Icons.phone_outlined,
                    mobile,
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: mobile),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Mobile number copied'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                if (location.isNotEmpty)
                  _infoItem(Icons.location_on_outlined, location),
              ],
            ),
            if (address.isNotEmpty) ...[
              const SizedBox(height: 9),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.home_outlined,
                    size: 15,
                    color: muted,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(
                        fontSize: 11,
                        color: muted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _infoItem(
      IconData icon,
      String value, {
        VoidCallback? onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.copy, size: 12, color: muted),
          ],
        ],
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String subtitle,
    bool action = false,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: muted),
            ),
            if (action) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh, size: 17),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
