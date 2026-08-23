import 'package:calculation_panel/core/theme/colors.dart';
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/components/custome_dropdown_widget.dart';
import 'package:calculation_panel/features/dashboard/model/store_model.dart';
import 'package:calculation_panel/features/dashboard/model/transport_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/purchase_controller.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/model/supplier_model.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/supplier_controller.dart';
import 'package:calculation_panel/features/dashboard/representaion/supplier_header/supplier_dropdown.dart';
import 'package:flutter/material.dart';

class SupplierHeader extends StatefulWidget {
  final PurchaseController purchaseController;

  const SupplierHeader({
    super.key,
    required this.purchaseController,
  });

  @override
  State<SupplierHeader> createState() =>
      _SupplierHeaderState();
}

class _SupplierHeaderState extends State<SupplierHeader> {
  late final SupplierController controller;

  static const double fieldWidth = 260;
  static const double fieldHeight = 36;

  @override
  void initState() {
    super.initState();

    controller = SupplierController();

    controller.dateController.text =
        formatDate(DateTime.now());

    GlobalVars.currentData =
        controller.dateController.text;

    Future.delayed(
      const Duration(milliseconds: 500),
          () {
        if (!mounted) return;

        controller.getPartyTypeList('');
      },
    );
  }

  // ===========================================================================
  // SUPPLIER
  // ===========================================================================

  void _selectSupplier(Party supplier) {
    controller.setSupplier(supplier);

    widget.purchaseController.setAgent(
      supplier.agency,
    );

    widget.purchaseController.setSupplier(
      supplier,
    );
  }

  // ===========================================================================
  // INPUT DECORATION
  // ===========================================================================

  InputDecoration _inputDecoration(
      String hint, {
        IconData? prefix,
      }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: borderColor,
      ),
    );

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: textLight,
      ),
      prefixIcon: prefix == null
          ? null
          : Icon(
        prefix,
        size: 17,
        color: textLight,
      ),
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      isDense: true,
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xff3B82F6),
          width: 1.3,
        ),
      ),
    );
  }

  // ===========================================================================
  // TEXT FIELD
  // ===========================================================================

  Widget _textField(
      TextEditingController textController, {
        required String hint,
        IconData? prefix,
      }) {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: TextField(
        controller: textController,
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        decoration: _inputDecoration(
          hint,
          prefix: prefix,
        ),
      ),
    );
  }

  // ===========================================================================
  // DATE
  // ===========================================================================

  Widget _dateField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: TextField(
        controller: controller.dateController,
        readOnly: true,
        onTap: () {
          controller.selectDate(context);
        },
        style: const TextStyle(
          fontSize: 12,
          color: textDark,
        ),
        decoration: _inputDecoration(
          'Select date',
          prefix: Icons.calendar_today_outlined,
        ),
      ),
    );
  }

  // ===========================================================================
  // STORE
  // ===========================================================================

  Widget _storeField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SearchableCustomerDropdown<StoreModel>(
            value: controller.selectedStore,
            height: fieldHeight,
            borderColor: Colors.grey.shade300,
            borderRadius: 8,
            items: controller.stores,
            onSearch: (value) {},
            displayString: (item) {
              return item.store ?? '';
            },
            onSelect: (value) {
              controller.setStore(value);
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // TRANSPORT
  // ===========================================================================

  Widget _transportField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SearchableCustomerDropdown<TransportModel>(
            value: controller.selectedTransport,
            height: fieldHeight,
            borderColor: Colors.grey.shade300,
            borderRadius: 8,
            items: controller.transports,
            onSearch: (value) {},
            displayString: (item) {
              return item.transport ?? '';
            },
            onSelect: (value) {
              controller.setTransport(value);
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // SUPPLIER
  // ===========================================================================

  Widget _supplierField() {
    return SizedBox(
      width: fieldWidth,
      height: fieldHeight,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return SupplierDropdown(
            suppliers: controller.suppliers,
            selectedSupplier:
            controller.selectedSupplier,
            onSearch: (value) {
              controller.getPartyTypeList(value);
            },
            onSelect: _selectSupplier,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // FIELD BLOCK
  // ===========================================================================

  Widget _fieldBlock(
      String label,
      Widget field,
      ) {
    return SizedBox(
      width: fieldWidth,
      height: 65,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 17,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xff475569),
              ),
            ),
          ),

          const SizedBox(height: 6),

          SizedBox(
            width: fieldWidth,
            height: fieldHeight,
            child: field,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FORM
  // ===========================================================================

  Widget _buildFormField(int index) {
    switch (index) {
      case 0:
        return _fieldBlock(
          'Supplier',
          _supplierField(),
        );

      case 1:
        return _fieldBlock(
          'GSTIN Number',
          _textField(
            controller.gstinController,
            hint: 'Enter GSTIN number',
            prefix: Icons.badge_outlined,
          ),
        );

      case 2:
        return _fieldBlock(
          'Store',
          _storeField(),
        );

      case 3:
        return _fieldBlock(
          'Challan Number',
          _textField(
            controller.challanController,
            hint: 'Enter challan number',
            prefix: Icons.numbers_rounded,
          ),
        );

      case 4:
        return _fieldBlock(
          'Date',
          _dateField(),
        );

      case 5:
        return _fieldBlock(
          'Transport',
          _transportField(),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xffE6EBF2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 15,
        runSpacing: 15,
        children: List.generate(
          6,
          _buildFormField,
        ),
      ),
    );
  }
}