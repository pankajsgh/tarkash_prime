import 'package:calculation_panel/core/theme/colors.dart';
import 'package:calculation_panel/core/ulitls/utility.dart';
import 'package:calculation_panel/core/vars/global_vars.dart';
import 'package:calculation_panel/features/components/custome_dropdown_widget.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/controller/supplier_controller.dart';
import 'package:calculation_panel/features/purchase_challan/representaion/supplier_header/supplier_dropdown.dart';
import 'package:flutter/material.dart';

import '../../model/store_model.dart';
import '../../model/transport_model.dart';
import '../../controller/purchase_controller.dart';
import 'model/supplier_model.dart';

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

  static const double fieldWidth = 240;
  static const double dateFieldWidth = 160;

  static const double fieldHeight = 36;

  @override
  void initState() {
    super.initState();

    controller = SupplierController();
    controller.dateController.text = formatDate(DateTime.now());
    widget.purchaseController.setData(controller.dateController.text);
    GlobalVars.currentData = controller.dateController.text;

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

  void _selectSupplier(Party? supplier) {

    widget.purchaseController.setAgent(
      supplier?.agency,
    );
    controller.gstinController.text= supplier!=null? supplier.gstNo: '';

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
      TextEditingController textController, {required String hint, IconData? prefix,}) {
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
        onChanged: (String? value){
          widget.purchaseController.setChallanNo(controller.challanController.text, controller.gstinController.text);

        },
      ),
    );
  }

  DateTime? _parseDate(String value) {
    final parts = value.split('/');

    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);

    final month = int.tryParse(parts[1]);

    final year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    try {
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final currentDate = _parseDate(controller.dateController.text);

    final result = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result == null) return;
    String selectedDate = formatDate(result);
    controller.setDate(selectedDate);
    widget.purchaseController.setData(selectedDate);
    GlobalVars.currentData = selectedDate;
    widget.purchaseController.setData(selectedDate);
  }


  // ===========================================================================
  // DATE
  // ===========================================================================

  Widget _dateField() {
    return SizedBox(
      width: dateFieldWidth,
      height: fieldHeight,
      child: TextField(
        controller: controller.dateController,
        readOnly: true,
        onTap: () {
          selectDate(context);
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
            value: widget.purchaseController.selectedStore,
            height: fieldHeight,
            borderColor: Colors.grey.shade300,
            borderRadius: 8,
            items: controller.stores,
            onSearch: (value) {},
            displayString: (item) {
              return item.store ?? '';
            },
            onSelect: (value) {
              // controller.setStore(value);
              widget.purchaseController.setStore(value);
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
            value: widget.purchaseController.selectedTransport,
            height: fieldHeight,
            borderColor: Colors.grey.shade300,
            borderRadius: 8,
            items: controller.transports,
            onSearch: (value) {},
            displayString: (item) {
              return item.transport ?? '';
            },
            onSelect: (value) {
              widget.purchaseController.setTransport(value);
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
            selectedSupplier: widget.purchaseController.selectSupplier,
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

  Widget _fieldBlock(String label, Widget field) {
    return Column(
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
        field
      ],
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
  void didUpdateWidget(covariant SupplierHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    controller.challanController.text = widget.purchaseController.challanNo;
  }

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
        runSpacing: 12,
        children: List.generate(
          6,
          _buildFormField,
        ),
      ),
    );
  }
}